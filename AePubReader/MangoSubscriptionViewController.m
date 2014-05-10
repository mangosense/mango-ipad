//
//  MangoSubscriptionViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 10/04/14.
//
//

#import "MangoSubscriptionViewController.h"
#import "SubscriptionInfo.h"
#import "AePubReaderAppDelegate.h"
#import "CargoBay.h"
#import "Constants.h"


#define MONTHLY_TAG 9
#define QUARTERLY_TAG 29
#define YEARLY_TAG 99

@interface MangoSubscriptionViewController ()

@end

@implementation MangoSubscriptionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        userEmail = delegate.loggedInUserInfo.email;
        userId = delegate.loggedInUserInfo.id;
        userDeviceID = delegate.deviceId;
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
   // datePicker.timeZone = [NSTimeZone timeZoneWithName: @"PST"];
    
    if(!userEmail){
        ID = userDeviceID;
    }
    else{
        ID = userEmail;
    }
    
    [self setupInitialUI];
}

//- (void) viewWillAppear:(BOOL)animated{
//    
//    //call for api to get products
//    
//    MangoApiController *apiController = [MangoApiController sharedApiController];
//    apiController.delegate = self;
//   // [apiController loginWithEmail:_emailTextField.text AndPassword:_passwordTextField.text IsNew:NO Name:nil];
//    [apiController getSubscriptionProductsInformation:<#(NSString *)#> withDelegate:self;
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initial Setup

- (void)setupSubscriptionView:(UIView *)subscriptionView {
    [subscriptionView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [subscriptionView.layer setShadowOpacity:0.7f];
    [subscriptionView.layer setShadowRadius:5.0f];
    [subscriptionView.layer setShadowOffset:CGSizeMake(0.0f, 0.0f)];
}

- (void)setupSubscriptionViewsUI {
    [self setupSubscriptionView:_monthlySubscriptionView];
    [self setupSubscriptionView:_yearlySubscriptionView];
    [self setupSubscriptionView:_quarterlySubcriptionView];
}

     
- (void)setupInitialUI {
         
    MangoApiController *apiController = [MangoApiController sharedApiController];
    NSString *url;
    apiController.delegate = self;
    url = SubscriptionPlans;
         
    [apiController getSubscriptionProductsInformation:url withDelegate:self];
         
    [self setupSubscriptionViewsUI];
}
     
- (void) subscriptionSetup :(NSArray *)planArray{
         
    NSLog(@"response values are %@", planArray);
    _arraySubscriptionPlan = planArray;
    
    for(id object in planArray){
        
        for (UIView *subview in [self.view subviews]){
            if([subview isKindOfClass:[UIView class]]){
                if(subview.tag == [[object valueForKey:@"duration"] intValue]){
                    for(UIView *secsubview in [subview subviews]){
                        if([secsubview isKindOfClass:[UILabel class]]){
                            UILabel *lbl = (UILabel *)secsubview;
                            if(lbl.tag == 1){
                                lbl.text = [object valueForKey:@"name"];
                            }
                            else if(lbl.tag == 303){
                                lbl.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"price"] valueForKey:@"usd"]];
                            }
                            
                        }
                    }
                }
            }
            
        }
        
    }
}

     
     
     
#pragma mark - Action Methods

- (IBAction)backButtonTapped:(id)sender {
    [self.presentingViewController.presentingViewController
     dismissViewControllerAnimated:YES
     completion:nil];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)subscribeButtonTapped:(id)sender {
   // UIButton *button = (UIButton *)sender;
    NSString *productId;
    
    for(id object in _arraySubscriptionPlan){
        
        if([[object valueForKey:@"duration"] intValue] == [sender tag]){
            productId = [object valueForKey:@"id"];
        }
    }
    
    
//    if (button.tag == MONTHLY_TAG) {
//        productId = @"535a2218566173e8e9070000";
//    } else if (button.tag == QUARTERLY_TAG) {
//        productId = @"535a228f566173e8e9090000";
//    } else if (button.tag == YEARLY_TAG) {
//        productId = @"535a2316566173e8e90b0000";
//    }
    
    [[PurchaseManager sharedManager] itemProceedToPurchase:productId storeIdentifier:productId withDelegate:self];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //put progress hud here ...
    
    
   /* NSString* str = @"teststring";
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    [self itemReadyToUse:productId ForTransaction:@"535a2316566173e8e90b0000" withReciptData:data andAmount:@"12"];*/
}

#pragma mark - PurchaseManager Delegate Methods

- (void)itemReadyToUse:(NSString *)productID ForTransaction:(NSString *)transactionId withReciptData:(NSData*)recipt Amount:(NSString *)amount  andExpireDate:(NSString *)exp_Date{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    SubscriptionInfo *subscriptionInfoData = [[SubscriptionInfo alloc] init];
    if(!userId){
        subscriptionInfoData.id = productID;
    }
    else{
        subscriptionInfoData.id = userId;
    }
    subscriptionInfoData.subscriptionProductId = productID;
    subscriptionInfoData.subscriptionTransctionId = transactionId;
    subscriptionInfoData.subscriptionReceiptData = recipt;
    subscriptionInfoData.subscriptionAmount = amount;
    subscriptionInfoData.subscriptionExpireDate = exp_Date;
    
    if (appDelegate.subscriptionInfo) {
        [appDelegate.ejdbController deleteSubscriptionObject:appDelegate.subscriptionInfo];
    }
    
    NSLog(@"Product value found as %d", [appDelegate.ejdbController insertOrUpdateObject:subscriptionInfoData]);
    [appDelegate.ejdbController insertOrUpdateObject:subscriptionInfoData];
    if ([appDelegate.ejdbController insertOrUpdateObject:subscriptionInfoData]) {
        appDelegate.subscriptionInfo = subscriptionInfoData;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)updateBookProgress:(int)progress{
    
}

/*- (IBAction)restoreSubscription:(id)sender{
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[CargoBay sharedManager]];
    [[CargoBay sharedManager] setPaymentQueueUpdatedTransactionsBlock:^(SKPaymentQueue *queue, NSArray *transactions) {
        NSLog(@"Updated Transactions: %@", transactions);
        
        for (SKPaymentTransaction *transaction in transactions)
        {
            NSLog(@"Payment State: %d", transaction.transactionState);
            switch (transaction.transactionState) {
                case SKPaymentTransactionStateFailed:
                {
                    NSLog(@"Transaction Failed! Details:\n %@", transaction.error);
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                }
                    break;
                    
                case SKPaymentTransactionStateRestored:
                {
                    NSLog(@"Product Restored!");
                    
                    NSString *transactionId;
                    if (transaction.originalTransaction) {
                        transactionId = transaction.originalTransaction.transactionIdentifier;
                    } else {
                        transactionId = transaction.transactionIdentifier;
                    }
               //     [self validateReceipt:productId ForTransactionId:transactionId amount:currentProductPrice storeIdentifier:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] withDelegate:delegate];
                    
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                    
                    
                   
                }
                    break;
                    
                default:
                    break;
            }
        }
    }];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}*/


@end
