//
//  MangoDashbProfileViewController.m
//  MangoReader
//
//  Created by Harish on 4/27/14.
//
//

#import "MangoDashbProfileViewController.h"
#import "SubscriptionInfo.h"
#import "AePubReaderAppDelegate.h"
#import "CargoBay.h"
#import "Constants.h"

@interface MangoDashbProfileViewController ()

@end

@implementation MangoDashbProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"My Profile";
        AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        userId = appDelegate.loggedInUserInfo.id;
        userEmail = appDelegate.loggedInUserInfo.email;
       
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.loggedInUserInfo){
        _loginButton.titleLabel.text  = @"Login";
        _userEmail.text = @"User";
    }
    else{
        _userEmail.text = userEmail;
    }
    
    //check for already subscribed user
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int validSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
    
    if(!validSubscription){
        
        if(appDelegate.subscriptionInfo){
            
            [[MangoApiController sharedApiController]validateSubscription:appDelegate.subscriptionInfo.subscriptionTransctionId andDeviceId:appDelegate.deviceId block:^(id response, NSInteger type, NSString *error){
                NSLog(@"type --- %d", type);
                if ([[response objectForKey:@"status"] integerValue] == 1){
                    
                    _viewInfoDisplay.hidden = NO;
                }
            }];
        }
        
        else{
            
            [[MangoApiController sharedApiController]validateSubscription:appDelegate.subscriptionInfo.subscriptionTransctionId andDeviceId:appDelegate.deviceId block:^(id response, NSInteger type, NSString *error){
                NSLog(@"type --- %d", type);
                if ([[response objectForKey:@"status"] integerValue] == 1){
                    
                    _viewInfoDisplay.hidden = NO;
                }
            }];
        }
    }

    else{
        _viewInfoDisplay.hidden = NO;

    }
    
    
    [self setupInitialUI];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewDidAppear:(BOOL)animated{
    
    if(![self connected])
    {
        _viewInfoDisplay.hidden = NO;
    }
}

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


- (IBAction)logoutUser:(id)sender{
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.loggedInUserInfo) {
        UserInfo *loggedInUserInfo = [appDelegate.ejdbController getUserInfoForId:appDelegate.loggedInUserInfo.id];
        [appDelegate.ejdbController deleteObject:loggedInUserInfo];
        
        appDelegate.loggedInUserInfo = nil;
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}


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
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Restore product failed !!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Product Restores" message:@"Your product has been restored successfully!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            
        }
        else {
            NSLog(@"ReceiptError:%@", error);
            [prefs setBool:NO forKey:@"ISSUBSCRIPTIONVALID"];
        }
        [prefs synchronize];
    }];
}


- (IBAction)moveToBack:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)subscribeButtonTapped:(id)sender {
    // UIButton *button = (UIButton *)sender;
    NSString *productId;
    
    for(id object in _arraySubscriptionPlan){
        
        if([[object valueForKey:@"duration"] intValue] == [sender tag]){
            productId = [object valueForKey:@"id"];
        }
    }

    [[PurchaseManager sharedManager] itemProceedToPurchase:productId storeIdentifier:productId withDelegate:self];
    
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
