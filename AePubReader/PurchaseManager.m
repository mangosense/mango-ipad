//
//  PurchaseManager.m
//  MangoReader
//
//  Created by Avinash Nehra on 1/31/14.
//
//

#import "PurchaseManager.h"
#import "MangoApiController.h"
#import "CargoBay.h"
#import "MBProgressHUD.h"

@implementation PurchaseManager

+ (id)sharedManager {
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

- (BOOL)isProductPurchased:(NSString *)productId purchasedProductList:(NSArray *)purchasedBooks {
    BOOL isBookPurchased = NO;
    for (NSDictionary *dataDict in purchasedBooks) {
        NSString *bookId = [dataDict objectForKey:@"id"];
        if ([bookId isEqualToString:productId]) {
            isBookPurchased = YES;
            break;
        }
    }
    return isBookPurchased;
}

- (void)itemProceedToPurchase :(NSString *)productId storeIdentifier:(NSString *)productIdentifier withDelegate:(id <PurchaseManagerProtocol>)delegate {
    NSAssert((productIdentifier.length > 0), @"Product identifier should have some characters lenght");
    
    __block NSString *currentProductPrice;
    UIView *loadingView;
    
    if ([delegate isKindOfClass:[UIViewController class]]) {
        loadingView = ((UIViewController *)delegate).view;
    }
    
    //Observer Method for updated Transactions
    [[CargoBay sharedManager] setPaymentQueueUpdatedTransactionsBlock:^(SKPaymentQueue *queue, NSArray *transactions) {
        NSLog(@"Updated Transactions: %@", transactions);
        
        for (SKPaymentTransaction *transaction in transactions)
        {
            NSLog(@"Payment State: %d", transaction.transactionState);
            switch (transaction.transactionState) {
                
                case SKPaymentTransactionStatePurchased:
                {
                    NSLog(@"Product Purchased!");
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                    NSString *transactionId;
                    if (transaction.originalTransaction) {
                        transactionId = transaction.originalTransaction.transactionIdentifier;
                    } else {
                        transactionId = transaction.transactionIdentifier;
                    }
                    [self validateReceipt:productId ForTransactionId:transactionId amount:currentProductPrice storeIdentifier:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] withDelegate:delegate];
                }
                    break;
                    
                case SKPaymentTransactionStateFailed:
                {
                    NSLog(@"Transaction Failed! Details:\n %@", transaction.error);
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                }
                    break;
                    
                case SKPaymentTransactionStateRestored:
                {
                    NSLog(@"Product Restored!");
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                    [self validateReceipt:productId ForTransactionId:transaction.originalTransaction.transactionIdentifier amount:currentProductPrice storeIdentifier:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] withDelegate:delegate];
                }
                    break;
                    
                default:
                    break;
            }
            if (transaction.transactionState != SKPaymentTransactionStatePurchasing) {
                [MBProgressHUD hideAllHUDsForView:loadingView animated:YES];
            }
        }
    }];
    
    //Get products from identifires....
    NSSet * productSet = [NSSet setWithArray:@[productIdentifier]];
    [MBProgressHUD showHUDAddedTo:loadingView animated:YES];
    [[CargoBay sharedManager] productsWithIdentifiers:productSet success:^(NSArray *products, NSArray *invalidIdentifiers) {
        if (products.count) {
            NSLog(@"Products: %@", products);
            //Initialise payment queue
            SKProduct * product = products[0];
            currentProductPrice = [product.price stringValue];
            SKPayment * payement = [SKPayment paymentWithProduct:product];
            [[SKPaymentQueue defaultQueue] addPayment:payement];
        }
        else {
            //Hide progress HUD if no products found
            [MBProgressHUD hideAllHUDsForView:loadingView animated:YES];
            NSLog(@"LOL:No Product found");
        }
        NSLog(@"Invalid Identifiers: %@", invalidIdentifiers);
    } failure:^(NSError *error) {
        //Hide progress HUD if Error!!
        [MBProgressHUD hideAllHUDsForView:loadingView animated:YES];
        NSLog(@"GetProductError: %@", error);
    }];
}

//Encode receipt data
- (NSString *)encode:(const uint8_t *)input length:(NSInteger)length {
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
	
    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
	
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
			value <<= 8;
			
			if (j < length) {
				value |= (0xFF & input[j]);
			}
        }
		
        NSInteger index = (i / 3) * 4;
        output[index + 0] = table[(value >> 18) & 0x3F];
        output[index + 1] = table[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? table[(value >> 6) & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? table[(value >> 0) & 0x3F] : '=';
    }
	
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

- (void)validateReceipt:(NSString *)productId ForTransactionId:(NSString *)transactionId amount:(NSString *)amount storeIdentifier:(NSData *)receiptData withDelegate:(id <PurchaseManagerProtocol>)delegate {
    //Use this when receipt_validate is error free
    [[MangoApiController sharedApiController] validateReceiptWithData:receiptData ForTransaction:transactionId amount:amount storyId:productId block:^(id response, NSInteger type, NSString *error) {
        if (type == 1) {
            NSLog(@"SuccessResponse:%@", response);
            //If Succeed.
            [delegate itemReadyToUse:productId ForTransaction:transactionId];
            if ([delegate respondsToSelector:@selector(updateBookProgress:)]) {
                [delegate updateBookProgress:0];
            }
        }
        else {
            NSLog(@"ReceiptError:%@", error);
        }
    }];
}

@end
