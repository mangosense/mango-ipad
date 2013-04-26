//
//  PopPurchaseViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 14/11/12.
//
//

#import "PopPurchaseViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "AePubReaderAppDelegate.h"
#import "DataModelControl.h"
#import "StoreBooks.h"

#import "PruchaseFree.h"
#import "LiveViewController.h"
#import "RecieptValidation.h"
#import "Base64.h"
@interface PopPurchaseViewController ()

@end

@implementation PopPurchaseViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil Identity:(NSInteger)indentity live:(LiveViewController *)liveController {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _identity=indentity;
        _liveViewController=liveController;
       
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
}
-(void)viewWillDisappear:(BOOL)animated{
 
        
    if (_alertView) {
         [_alertView dismissWithClickedButtonIndex:0 animated:YES];
    }
    NSString * string=[NSString stringWithFormat: @"In the store details for particular book existed" ];
    [Flurry logEvent:string];
    //[[SKPaymentQueue defaultQueue]removeTransactionObserver:_liveViewController];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
  
    UIBarButtonItem *leftDone=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];

    self.navigationItem.leftBarButtonItem=leftDone;

    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *identity=[[NSString alloc]initWithFormat:@"%d",_identity ];
   StoreBooks *booksStore= [delegate.dataModel getStoreBookById:identity];
   NSString * string=[NSString stringWithFormat: @"In the store book titled %@ looked at and id %@",booksStore.title,booksStore.productIdentity ];
    [Flurry logEvent:string];
    _titleLabel.text=booksStore.title;
    [_detailsWebView loadHTMLString:booksStore.desc baseURL:nil];
    NSLog(@"local Image Location %@",booksStore.localImage);
    UIImage *image=[[UIImage alloc]initWithContentsOfFile:booksStore.localImage];
    [_imageView setImage:image];

    float size=[booksStore.size floatValue];
  //  [image release];
    NSLog(@"%@",[NSNumber numberWithLongLong:size] );
    size=size/1024.0f;
    NSLog(@"%@",[NSNumber numberWithLongLong:size] );
    size=size/1024.0f;
    NSLog(@"%@",[NSNumber numberWithLongLong:size] );
    _fileSizeLabel.text=[NSString stringWithFormat:@"File Size :%@ MB",[NSNumber numberWithLongLong:size] ];
  //  [identity release];
    NSLog(@"The value of the bool is %@\n", ([booksStore.free boolValue] ? @"YES" : @"NO"));
   _isFree= [booksStore.free boolValue];
 _purchaseLabel.text=@"Please wait...";
    if([booksStore.free boolValue]){
       _purchaseLabel.text=[NSString stringWithFormat:@"Price : Free "];
    }else{
        if ([SKPaymentQueue canMakePayments]) {
            NSString *iden=[NSString stringWithFormat:@"%d",_identity ];
            NSSet *prodIds=[NSSet setWithObject:iden];
            SKProductsRequest *productRequest=[[SKProductsRequest alloc]initWithProductIdentifiers:prodIds];
            productRequest.delegate=self;
            [productRequest start];
  

            [_purchaseButton setEnabled:NO];
        }else{
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"You are not authorsized to make payments" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
          //  [alertView release];
            [self done:nil];
        }
    }
    _freeSpace.text=[NSString stringWithFormat:@"Free Space : %lld",[self getFreeDiskspace]];
   
}
-(uint64_t)getFreeDiskspace {
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    totalFreeSpace=(totalFreeSpace/1024ll)/1024ll;
    return totalFreeSpace;
}
-(void)done:(id)sender{
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*- (void)dealloc {
    [_imageView release];
    [_titleLabel release];
  
    [_fileSizeLabel release];
    [_purchaseLabel release];
    _products=nil;
    _payment=nil;
    _value=nil;
    [_purchaseButton release];
    [_detailsWebView release];
    [super dealloc];
}*/
- (void)viewDidUnload {
     
    [self setImageView:nil];
    [self setTitleLabel:nil];
  
    [self setFileSizeLabel:nil];
    [self setPurchaseLabel:nil];
    [self setPurchaseButton:nil];
    [self setDetailsWebView:nil];
    [self setFreeSpace:nil];
    [super viewDidUnload];
}
- (IBAction)purchaseAndDownload:(id)sender {
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (IBAction)toPurchase:(id)sender {
    // must be done application did finish launching
  //  AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
  //  [[SKPaymentQueue defaultQueue] removeTransactionObserver:_liveViewController];
    // if not logged in
    [Flurry logEvent:[NSString stringWithFormat:@"Book of id %d bought",_identity]];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"email"]){
        if (_isFree) {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Purchase Successful" message:@"Do you want to download it now?" delegate:_liveViewController cancelButtonTitle:@"NO" otherButtonTitles: @"YES", nil];
            // [alertViewDelegate autorelease];
            [alertView show];
      //     [alertView release];
            
        }else{
            AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;

            delegate.dismissAlertViewFlag=YES;
            delegate.dismissAlertView=_alertView;
            NSLog(@"Product %@",_products.localizedTitle);
          //    [[SKPaymentQueue defaultQueue]addTransactionObserver:_liveViewController];
            _payment=[SKPayment paymentWithProduct:_products];
            [[SKPaymentQueue defaultQueue] addPayment:_payment];
            _alertView=nil;

        }
        return;
    }//

    [_purchaseButton setEnabled:NO];
    if (!_isFree) {// if not free request payment
     
        NSLog(@"Product %@",_products.localizedTitle);
          // [[SKPaymentQueue defaultQueue]addTransactionObserver:_liveViewController];
        _payment=[SKPayment paymentWithProduct:_products];
        [[SKPaymentQueue defaultQueue] addPayment:_payment];
        _alertView=nil;
       // [_alertView show];
    }else{// if free then request
        [_purchaseButton setEnabled:NO];
        NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
        [dictionary setValue:[NSNumber numberWithInteger:0 ] forKey:@"amount"];
        NSNumber *userid=[[NSUserDefaults standardUserDefaults]objectForKey:@"id"];
       // email=@"1";
     //   userid=[NSNumber numberWithInteger:130];
        [dictionary setValue:userid forKey:@"user_id"];
        [dictionary setValue:[NSNumber numberWithInteger:_identity ] forKey:@"book_id"];
   //      [dictionary setValue:[NSNumber numberWithInteger:557 ] forKey:@"book_id"];
        [dictionary setValue:@"INR" forKey:@"currency"];
        [dictionary setValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"auth_token"] forKey:@"auth_token"];
       // [dictionary setValue:@"sxd4igWVyWAY6uzxgzRv" forKey:@"auth_token"];
         NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        
        NSString *valueJson=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"value json request %@",valueJson);
        NSString *stringURL=[[NSUserDefaults standardUserDefaults] objectForKey:@"baseurl"];
       // NSString *stringURL=[NSString stringWithFormat:@"http://www.mangoreader.com/api/v1/register_a_purchase.json?amount=0&&user_id=%@&book_id=%d&&currency=INR",email,_identity ];
       // NSURL *url=[NSURL URLWithString:stringURL];
        //stringURL=@"http://192.168.2.29:3000/api/v1/";
       // stringURL=@"http://staging.mangoreader.com/api/v1/";
        stringURL=[stringURL stringByAppendingString:@"register_a_purchase.json"];
        NSLog(@"register pur url %@",stringURL);
        NSURL *url=[NSURL URLWithString:stringURL];
        
        NSMutableURLRequest *mutableRequest=[[NSMutableURLRequest alloc]initWithURL:url];
        [mutableRequest setHTTPMethod:@"POST"];
          [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [mutableRequest setHTTPBody:jsonData];
        PruchaseFree *purchase=[[PruchaseFree alloc]initWithPop:self LiveController:_liveViewController fileLink:_identity];
        NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:mutableRequest delegate:purchase];
        [connection start];
        
      //  [connection autorelease];
      //  [dictionary release];
      //  [mutableRequest release];
      //  [purchase release];
     //   [valueJson release];
    }
}


-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
 _products=  [response.products lastObject];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *identity=[[NSString alloc]initWithFormat:@"%d",_identity ];
    StoreBooks *booksStore= [delegate.dataModel getStoreBookById:identity];
   // [identity release];
    if (_products) {
     
        booksStore.amount=_products.price;
        [delegate.dataModel saveStoreBookData:booksStore];
   // [_products retain];
  
    
    NSLocale *priceLocale=_products.priceLocale;
    NSNumberFormatter *formatter=[[NSNumberFormatter alloc]init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [formatter setLocale:priceLocale];
    _value=nil;
        _purchaseLabel.text=[NSString stringWithFormat:@"Price : %@",[formatter stringFromNumber:_products.price]];
    _liveViewController.price=_products.price;
       // delegate.price=_products.price;
//[_liveViewController.price retain];
  //  [formatter release];
        
         }
    else{
        NSNumber *number=[NSNumber numberWithInt:0];
        booksStore.amount=number;
        [delegate.dataModel saveStoreBookData:booksStore];
        
        _purchaseLabel.text=[NSString stringWithFormat:@"Price : Free "];
        _isFree=true;
    }
    [_alertView dismissWithClickedButtonIndex:0 animated:YES];
    _alertView=nil;
    [_purchaseButton setEnabled:YES];
        
}
-(void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    if(error.code==SKErrorStoreProductNotAvailable){
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Message" message:@"Product is waiting for Apple approval or not available on store" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        [self done:nil];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex==1&&alertView.tag==50) {//yes
        [self done:nil];
        [self.liveViewController.parentViewController.navigationController popToRootViewControllerAnimated:YES];
        
    }
}
@end
