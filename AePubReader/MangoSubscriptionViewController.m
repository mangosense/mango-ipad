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
#import "EmailSubscriptionLinkViewController.h"

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
    currentPage = @"subscription_screen";
   // datePicker.timeZone = [NSTimeZone timeZoneWithName: @"PST"];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading Products";
    if(!userEmail){
        ID = userDeviceID;
    }
    else{
        ID = userEmail;
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    validSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
    
    path = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
    
    NSString *extendedValue;
    if(path){
        //assign bundle id value
        extendedValue = [NSString stringWithFormat:@"_%@", [[NSBundle mainBundle] bundleIdentifier]];
    }
    else{
        //just assign _ios value
        extendedValue = @"_ios";
    }
    
    subscriptionProductId = [[NSArray alloc] initWithObjects:[SUBSCRIPTION_MONTHLY stringByAppendingString:extendedValue], [SUBSCRIPTION_QUATERLY stringByAppendingString:extendedValue], [SUBSCRIPTION_YEARLY stringByAppendingString:extendedValue], nil];
    subscriptionPlanName = [[NSArray alloc] initWithObjects:@"Monthly", @"Quarterly", @"Yearly", nil];
    
    [self setupInitialUI];
    
}

- (void) viewDidAppear:(BOOL)animated{
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
    [dimensions setObject:@"subscription_screen" forKey:PARAMETER_ACTION];
    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
    [dimensions setObject:@"Subscription screen open" forKey:PARAMETER_EVENT_DESCRIPTION];
    if(userEmail){
        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
    }
    [delegate trackEventAnalytic:@"subscription_screen" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
//    [delegate trackMixpanelEvents:dimensions eventName:@"subscription_screen"];

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

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
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
         
    /*MangoApiController *apiController = [MangoApiController sharedApiController];
    NSString *url;
    apiController.delegate = self;
    url = SubscriptionPlans;
         
    [apiController getSubscriptionProductsInformation:url withDelegate:self];
         
    [self setupSubscriptionViewsUI];*/
    [self subscriptionSetup];
}
     
//- (void) subscriptionSetup :(NSArray *)planArray{
- (void) subscriptionSetup{
    
    subscriptionPlanPrice = [[NSMutableArray alloc] init];
    NSSet * productSet = [NSSet setWithArray:subscriptionProductId];
    [[CargoBay sharedManager] productsWithIdentifiers:productSet success:^(NSArray *products, NSArray *invalidIdentifiers) {
        
        if (products.count) {
            for(int i =0; i < products.count; ++i){
                
                NSLog(@"Products: %@", products);
                //Initialise payment queue
                SKProduct * product = products[i];
                [subscriptionPlanPrice addObject:[product.price stringValue]];
                //NSString* currentProductPrice = [product.price stringValue];
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
                [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                [numberFormatter setLocale:product.priceLocale];
                NSString *formattedString = [numberFormatter stringFromNumber:product.price];
                if(i==0){
                    _label1PlanPrice.text = [NSString stringWithFormat:@"%@ /month", formattedString];
                }
                else if(i==1){
                    _label2PlanTotalPrice.text = formattedString;
                    float perMonthPrice = [product.price floatValue]/4;
                    NSString *formattedStringPerMonth = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:perMonthPrice]];
                    _label2PlanPrice.text = [NSString stringWithFormat:@"%@ /month", formattedStringPerMonth];
                }
                else if(i==2){
                    _label3PlanTotalPrice.text = formattedString;
                    float perMonthPrice = [product.price floatValue]/12;
                    NSString *formattedStringPerMonth = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:perMonthPrice]];
                    _label3PlanPrice.text = [NSString stringWithFormat:@"%@ /month", formattedStringPerMonth];
                }
                
            }
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
        else {
            //Hide progress HUD if no products found
            NSLog(@"LOL:No Product found");
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Prouct Error" message:@"Sorry! no product found, please check your internet connection" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            
            //[self performSelector:@selector(hideAlertView:) withObject:alert afterDelay:1.5];
            
            //[self backButtonTapped:0];
        }
        NSLog(@"Invalid Identifiers: %@", invalidIdentifiers);
    } failure:^(NSError *error) {
        //Hide progress HUD if Error!!
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSLog(@"GetProductError: %@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Prouct Error" message:@"Sorry! no product found, please check your internet connection" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
        //[self performSelector:@selector(hideAlertView:) withObject:alert afterDelay:1.5];
        //[self backButtonTapped:0];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:@"Prouct Error"]){
        
        if(buttonIndex ==0){
            [self backButtonTapped:0];
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
    [self.view endEditing:YES];
    if((parentalControlAge >= 13) && (parentalControlAge <=100)){
        //show subscription plans
        _settingsProbSupportView.hidden = YES;
        _settingsProbView.hidden = YES;
    }
    else{
        //close subscription plan
        alertAgeError = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Please enter correct birth year!!" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alertAgeError show];
        [self performSelector:@selector(hideAlertViewHere) withObject:alertAgeError afterDelay:1.5];
        
        //[self backButtonTapped:0];
    }
}

- (void) hideAlertViewHere {
    
    [alertAgeError dismissWithClickedButtonIndex:0 animated:YES];
    [self backButtonTapped:0];
    
}

#pragma mark - Action Methods

- (IBAction)backButtonTapped:(id)sender {
    [self resignFirstResponder];
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

//- (BOOL)disablesAutomaticKeyboardDismissal {
//    return [self disablesAutomaticKeyboardDismissal];
//}

//hide keyboard on background tap

- (IBAction)backgroundTap:(id)sender {
    [_textQuesSolution resignFirstResponder];
   
}

#pragma buy product

- (IBAction)subscribeButtonTapped:(id)sender {
   // UIButton *button = (UIButton *)sender;
    NSString *productId;
    NSString *planName;
    NSString *planPrice;
    
    if(![self connected])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please internet connection appears offline, please try later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if(!subscriptionProductId.count){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Product Error" message:@"No product found for the selected plan, please try later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
//    if (button.tag == MONTHLY_TAG) {
//        productId = @"535a2218566173e8e9070000";
//    } else if (button.tag == QUARTERLY_TAG) {
//        productId = @"535a228f566173e8e9090000";
//    } else if (button.tag == YEARLY_TAG) {
//        productId = @"535a2316566173e8e90b0000";
//    }
    NSString *planProductId = [subscriptionProductId objectAtIndex:[sender tag]-1];
    planPrice = [subscriptionPlanPrice objectAtIndex:[sender tag] -1];
    planName = [subscriptionPlanName objectAtIndex:[sender tag] -1];
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
    [dimensions setObject:@"subscription_click" forKey:PARAMETER_ACTION];
    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
    [dimensions setObject:planProductId forKey:PARAMETER_SUBSCRIPTION_PLAN_ID];
    [dimensions setObject:planName forKey:PARAMETER_SUBSCRIPTION_PLAN_NAME];
    [dimensions setObject:planPrice forKey:PARAMETER_SUBSCRIPTION_PLAN_PRICE];
    [dimensions setObject:@"Subscription plan click" forKey:PARAMETER_EVENT_DESCRIPTION];
    if(userEmail){
        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
    }
    [delegate trackEventAnalytic:@"subscription_click" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
//    [delegate trackMixpanelEvents:dimensions eventName:@"subscription_click"];
    
    // take current payment queue
    SKPaymentQueue* currentQueue = [SKPaymentQueue defaultQueue];
    // finish ALL transactions in queue
    [currentQueue.transactions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [currentQueue finishTransaction:(SKPaymentTransaction *)obj];
    }];
    
    [[PurchaseManager sharedManager] itemProceedToPurchase:planProductId storeIdentifier:planProductId withDelegate:self];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //put progress hud here ...
    
    //Test Story as App//
//    [self updateBookProgress:0];
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
    

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int validUserSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
    if (path && validUserSubscription){
        
       /* LandPageChoiceViewController *myViewController;
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            
            myViewController = [[LandPageChoiceViewController alloc] initWithNibName:@"LandPageChoiceViewController_iPhone" bundle:nil];
        }
        else{
            myViewController = [[LandPageChoiceViewController alloc] initWithNibName:@"LandPageChoiceViewController" bundle:nil];
        }
    
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:myViewController];
        //[navigationController pushViewController:myViewController animated:YES];
        [self presentViewController:navigationController animated:YES completion:nil];*/
        [prefs setBool:YES forKey:@"SubscriptionSuccess"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadLandingPage" object:self];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    
    else{
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:@"Create, read and customize stories and turn reading into your child's favourite activity" delegate:self cancelButtonTitle:@"Start now" otherButtonTitles:nil, nil];
        //[alert show];
        if(!userEmail){
            [prefs setBool:YES forKey:@"SubscriptionSuccess"];
        }
        [self backButtonTapped:0];
        
    }
    
    
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
    
    if(![self connected])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please internet connection appears offline, please try later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
    [dimensions setObject:@"restore_purchase" forKey:PARAMETER_ACTION];
    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
    [dimensions setObject:@"Restore purchase" forKey:PARAMETER_EVENT_DESCRIPTION];
    if(userEmail){
        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
    }
    [delegate trackEventAnalytic:@"restore_purchase" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
//    [delegate trackMixpanelEvents:dimensions eventName:@"restore_purchase"];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int validSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
    
    if(!validSubscription){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:[CargoBay sharedManager]];
        [[CargoBay sharedManager] setPaymentQueueUpdatedTransactionsBlock:^(SKPaymentQueue *queue, NSArray *transactions) {
            NSLog(@"Updated Transactions: %@", transactions);
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
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
                        if(!transaction.originalTransaction.transactionIdentifier){
                            //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Restore Error" message:@"Product could not be restored, please try later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                            //[alert show];
                            return;
                        }
                        
                        [self validateReceipt:transaction.originalTransaction.payment.productIdentifier ForTransactionId:transaction.originalTransaction.transactionIdentifier amount:@"0" storeIdentifier:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] withDelegate:self];
                        if(path){
                            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                            [prefs setBool:YES forKey:@"ISSUBSCRIPTIONVALID"];
                        }
                        
                        [self updateBookProgress:0];
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
            [self backButtonTapped:0];
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
        
        /*else if ([[response objectForKey:@"resp"] integerValue] == 21007) {
            NSLog(@"SuccessResponse:%@", response);
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setBool:YES forKey:@"ISSUBSCRIPTIONVALID"];
            [prefs setBool:YES forKey:@"ISAPPLECHECK"];
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
            subscriptionInfoData.subscriptionExpireDate = @"11/11/2021";
            
            NSLog(@"Product value found as %d", [appDelegate.ejdbController insertOrUpdateObject:subscriptionInfoData]);
            
            if (appDelegate.subscriptionInfo) {
                [appDelegate.ejdbController deleteSubscriptionObject:appDelegate.subscriptionInfo];
            }
            
            [appDelegate.ejdbController insertOrUpdateObject:subscriptionInfoData];
            //if ([appDelegate.ejdbController insertOrUpdateObject:subscriptionInfo]) {
            appDelegate.subscriptionInfo = subscriptionInfoData;
            
            
            
        }*/

        
        else {
            NSLog(@"ReceiptError:%@", error);
            //[prefs setBool:NO forKey:@"ISSUBSCRIPTIONVALID"];
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
