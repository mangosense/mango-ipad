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
#import "CustomNavViewController.h"
#import "LandPageChoiceViewController.h"


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

- (void) checkIfViewFromBookDetail : (int) value{
    
    fromBookDetail = value;
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _settingsProbSupportView.alpha = 0.4f;
    // Do any additional setup after loading the view from its nib.
    
   // datePicker.timeZone = [NSTimeZone timeZoneWithName: @"PST"];
    
    if(!userEmail){
        ID = userDeviceID;
    }
    else{
        ID = userEmail;
    }
    
    [self setupInitialUI];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[CargoBay sharedManager]];
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

     
#pragma show subscription plans or not

- (IBAction)displySubacriptionOrNot:(id)sender{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *yearString = [formatter stringFromDate:[NSDate date]];
    int parentalControlAge = ([yearString integerValue] - [_textQuesSolution.text integerValue]);
    [_textQuesSolution resignFirstResponder];
    if((parentalControlAge >= 13) && (parentalControlAge <=100)){
        //show subscription plans
        _settingsProbSupportView.hidden = YES;
        _settingsProbView.hidden = YES;
    }
    else{
        //close subscription plan
        [self backButtonTapped:0];
    }
}

#pragma mark - Action Methods

- (IBAction)backButtonTapped:(id)sender {

    if(fromBookDetail){
        /*[self.presentingViewController.presentedViewController
         dismissViewControllerAnimated:YES
            completion:nil];
        [self dismissViewControllerAnimated:YES completion:^{
        
        }];*/
        [self dismissViewControllerAnimated:NO completion:nil];
        
        //[self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        

    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}

//hide keyboard on background tap

- (IBAction)backgroundTap:(id)sender {
    [_textQuesSolution resignFirstResponder];
    
}

#pragma buy product

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

- (IBAction)subscribeButtonTapped:(id)sender {
   // UIButton *button = (UIButton *)sender;
    NSString *productId;
    
    if(![self connected])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please internet connection appears offline, please try later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
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
    NSString *planProductId = [productId stringByAppendingString:@"_ios"];
    [[PurchaseManager sharedManager] itemProceedToPurchase:planProductId storeIdentifier:planProductId withDelegate:self];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //put progress hud here ...
    
    //Test Story as App//
    //[self updateBookProgress:0];
    //
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
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:@"Create, read and customize stories and turn reading into your child's favourite activity" delegate:self cancelButtonTitle:@"Start now" otherButtonTitles:nil, nil];
    [alert show];
    [self backButtonTapped:0];
    
    //Test for story as app HARISH
 /*   NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int validUserSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
    if (path && !validUserSubscription){
        
        [prefs setBool:YES forKey:@"ISSUBSCRIPTIONVALID"];
        
        //LoginNewViewController *loginView = [[LoginNewViewController alloc] initWithNibName:@"LoginNewViewController" bundle:nil];
       // [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
        LandPageChoiceViewController *myViewController = [[LandPageChoiceViewController alloc] initWithNibName:@"LandPageChoiceViewController" bundle:nil];
    
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:myViewController];
        //now present this navigation controller as modally
        //[self presentModalViewController:navigationController animated:YES];
        [self presentViewController:navigationController animated:YES completion:nil];
        //[self backButtonTapped:0];
    }*/
    
    //
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

#pragma restore purchase 

- (IBAction)restorePurchase:(id)sender{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int validSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
    
    if(!validSubscription){
        
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
                        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                        [self validateReceipt:transaction.originalTransaction.payment.productIdentifier ForTransactionId:transaction.originalTransaction.transactionIdentifier amount:@"0" storeIdentifier:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] withDelegate:self];
                        
                        
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            
            if(transactions.count){
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Product Restores" message:@"Your product has been restored successfully!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
            }
            
        }];
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
        
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Restore Error" message:@"You are already subscribed, there no need to restore!!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}


- (void)validateReceipt:(NSString *)productId ForTransactionId:(NSString *)transactionId amount:(NSString *)amount storeIdentifier:(NSData *)receiptData withDelegate:(id <SubscriptionProtocol>)delegate {
    //Use this when receipt_validate is error free
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [[MangoApiController sharedApiController] validateReceiptWithData:receiptData ForTransaction:transactionId amount:amount storyId:productId block:^(id response, NSInteger type, NSString *error) {
        if ([[response objectForKey:@"status"] integerValue] == 1) {
            NSLog(@"SuccessResponse:%@", response);
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setBool:YES forKey:@"ISSUBSCRIPTIONVALID"];
            AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
            SubscriptionInfo *subscriptionInfoData = [[SubscriptionInfo alloc] init];
            if(!userId){
                subscriptionInfoData.id = productId;
            }
            else{
                subscriptionInfoData.id = userId;
            }
            subscriptionInfoData.subscriptionProductId = productId;
            subscriptionInfoData.subscriptionTransctionId = transactionId;
            subscriptionInfoData.subscriptionReceiptData = receiptData;
            subscriptionInfoData.subscriptionAmount = amount;
            subscriptionInfoData.subscriptionExpireDate = [response objectForKey:@"expires_at"];
            
            NSLog(@"Product value found as %d", [appDelegate.ejdbController insertOrUpdateObject:subscriptionInfoData]);
            
            if (appDelegate.subscriptionInfo) {
                [appDelegate.ejdbController deleteSubscriptionObject:appDelegate.subscriptionInfo];
            }
            
            [appDelegate.ejdbController insertOrUpdateObject:subscriptionInfoData];
            //if ([appDelegate.ejdbController insertOrUpdateObject:subscriptionInfo]) {
            appDelegate.subscriptionInfo = subscriptionInfoData;
            
            
            
        }
        else {
            NSLog(@"ReceiptError:%@", error);
            [prefs setBool:NO forKey:@"ISSUBSCRIPTIONVALID"];
        }
        [prefs synchronize];
        
    }];
}


- (void) viewDidDisappear:(BOOL)animated {
    if(fromBookDetail){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CloseDetailView" object:self];
    }
    
}

@end
