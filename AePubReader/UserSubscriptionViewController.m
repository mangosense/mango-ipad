//
//  UserSubscriptionViewController.m
//  MangoReader
//
//  Created by Harish on 1/22/15.
//
//

#import "UserSubscriptionViewController.h"
#import "Constants.h"
#import "CargoBay.h"
#import "SubscriptionInfo.h"
#import "AePubReaderAppDelegate.h"
#import "SubscriptionInfo.h"

@interface UserSubscriptionViewController ()

@end

@implementation UserSubscriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentPage = @"settingSubscriptionScreen";
    //NSString *extendedValue =  @"_";
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading Products";
    subscriptionProductId = [[NSArray alloc] initWithObjects:@"536904b169702d6159090001_weekly", @"536904b169702d6159090002_monthly", @"536904b169702d6159090003_yearly", nil];
    subscriptionPlanName = [[NSArray alloc] initWithObjects:@"Weekly", @"Monthly", @"Yearly", nil];
    
    [self subscriptionSetup];
    
    // Do any additional setup after loading the view from its nib.
}

- (void) viewDidAppear:(BOOL)animated{
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *dimensions = @{
                                 
                                 PARAMETER_ACTION : @"settingSubscriptionScreen",
                                 PARAMETER_CURRENT_PAGE : currentPage,
                                 PARAMETER_EVENT_DESCRIPTION : @"Setting Subscription Screen open",
                                 };
    [delegate trackEventAnalytic:@"settingSubscriptionScreen" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"settingSubscriptionScreen"];
}


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
                    _weeklyPrice.text = [NSString stringWithFormat:@"%@ /week", formattedString];
                }
                else if(i==1){
                    _monthlyPrice.text = formattedString;
                    float perMonthPrice = [product.price floatValue]/4;
                    NSString *formattedStringPerMonth = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:perMonthPrice]];
                    _monthlyPerPrice.text = [NSString stringWithFormat:@"%@ /week", formattedStringPerMonth];
                }
                else if(i==2){
                    _yearlyPrice.text = formattedString;
                    float perMonthPrice = [product.price floatValue]/52;
                    NSString *formattedStringPerMonth = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:perMonthPrice]];
                    _yearlyPerPrice.text = [NSString stringWithFormat:@"%@ /week", formattedStringPerMonth];
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
        
    }];
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

- (IBAction)subscribeButtonTapped:(id)sender {
    // UIButton *button = (UIButton *)sender;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int validUserSubscription = [prefs boolForKey:@"USERSUBSCRIBED"];
    
    if(validUserSubscription){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Subscription Error" message:@"You are already subscribed" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    NSString *planName;
    NSString *planPrice;
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
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
    
    NSString *planProductId = [subscriptionProductId objectAtIndex:[sender tag]-1];
    planPrice = [subscriptionPlanPrice objectAtIndex:[sender tag] -1];
    planName = [subscriptionPlanName objectAtIndex:[sender tag] -1];
    
    NSDictionary *dimensions = @{
                                 PARAMETER_ACTION : @"subscribeClick",
                                 PARAMETER_CURRENT_PAGE : currentPage,
                                 PARAMETER_SUBSCRIPTION_PLAN_NAME : planName,
                                 PARAMETER_EVENT_DESCRIPTION : @"click on subscribe now",
                                 };
    [appDelegate trackEventAnalytic:@"subscribeClick" dimensions:dimensions];
    [appDelegate eventAnalyticsDataBrowser:dimensions];
    [appDelegate trackMixpanelEvents:dimensions eventName:@"subscribeClick"];
    
    // take current payment queue
    SKPaymentQueue* currentQueue = [SKPaymentQueue defaultQueue];
    // finish ALL transactions in queue
    [currentQueue.transactions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [currentQueue finishTransaction:(SKPaymentTransaction *)obj];
    }];
    
    [[PurchaseManager sharedManager] itemProceedToPurchase:planProductId storeIdentifier:planProductId withDelegate:self];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
}

- (void)itemReadyToUse:(NSString *)productID ForTransaction:(NSString *)transactionId withReciptData:(NSData*)recipt Amount:(NSString *)amount  andExpireDate:(NSString *)exp_Date{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if(!recipt){
        return;
    }
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDate *expireDate;
    NSDate *today = [NSDate date];
    
    if([productID isEqualToString:@"536904b169702d6159090001_weekly"]){
        
        expireDate = [today dateByAddingTimeInterval:60*60*24*7];
    }
    else if([productID isEqualToString:@"536904b169702d6159090002_monthly"]){
        
        expireDate = [today dateByAddingTimeInterval:60*60*24*30];
    }
    else{
        
        expireDate = [today dateByAddingTimeInterval:60*60*24*365];
    }
    
    NSDictionary *dimensions = @{
                                 PARAMETER_ACTION : @"subscription_success",
                                 PARAMETER_CURRENT_PAGE : currentPage,
                                 PARAMETER_SUBSCRIPTION_PLAN_NAME : productID,
                                 PARAMETER_SUBSCRIPTION_TRANSACTION_ID : transactionId,
                                 PARAMETER_EVENT_DESCRIPTION : @"user successfully subscribe",
                                 };
    [appDelegate trackEventAnalytic:@"subscription_success" dimensions:dimensions];
    [appDelegate eventAnalyticsDataBrowser:dimensions];
    [appDelegate trackMixpanelEvents:dimensions eventName:@"subscription_success"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *myCurrentDateExpireString = [dateFormatter stringFromDate:expireDate];
    
    SubscriptionInfo *subscriptionInfoData = [[SubscriptionInfo alloc] init];
    
    //subscriptionInfoData.id = productID; //cause error in saving at ejdb need to be proper id like book
    subscriptionInfoData.id = productID;
    
    subscriptionInfoData.subscriptionProductId = productID;
    subscriptionInfoData.subscriptionTransctionId = transactionId;
    subscriptionInfoData.subscriptionReceiptData = recipt;
    subscriptionInfoData.subscriptionAmount = amount;
    subscriptionInfoData.subscriptionExpireDate = myCurrentDateExpireString;
    
    if (appDelegate.subscriptionInfo) {
        [appDelegate.ejdbController deleteSubscriptionObject:appDelegate.subscriptionInfo];
    }
    
    NSLog(@"Product value found as %d", [appDelegate.ejdbController insertOrUpdateObject:subscriptionInfoData]);
    [appDelegate.ejdbController insertOrUpdateObject:subscriptionInfoData];
    if ([appDelegate.ejdbController insertOrUpdateObject:subscriptionInfoData]) {
        appDelegate.subscriptionInfo = subscriptionInfoData;
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:YES forKey:@"USERSUBSCRIBED"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateBookProgress:(int)progress{
    //after successful subscrption
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) backToHomePage:(id)sender{
    
    //[self.tabBarController dismissViewControllerAnimated:YES completion:nil];
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDictionary *dimensions = @{
                                 PARAMETER_ACTION : @"homeButtonClick",
                                 PARAMETER_CURRENT_PAGE : currentPage,
                                 PARAMETER_EVENT_DESCRIPTION : @"back to home click",
                                 };
    [appDelegate trackEventAnalytic:@"homeButtonClick" dimensions:dimensions];
    [appDelegate eventAnalyticsDataBrowser:dimensions];
    [appDelegate trackMixpanelEvents:dimensions eventName:@"homeButtonClick"];

    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)restorePurchase:(id)sender{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int validUserSubscription = [prefs boolForKey:@"USERSUBSCRIBED"];
    
    if(validUserSubscription){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Subscription Error" message:@"You are already subscribed" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if(![self connected])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please internet connection appears offline, please try later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *dimensions = @{
                                 PARAMETER_ACTION : @"restorePurchaseClick",
                                 PARAMETER_CURRENT_PAGE : currentPage,
                                 PARAMETER_EVENT_DESCRIPTION : @"restore purchase click",
                                 };
    [delegate trackEventAnalytic:@"restorePurchaseClick" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"restorePurchaseClick"];
    
    //NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int validSubscription = [[prefs valueForKey:@"USERSUBSCRIBED"] integerValue];
    
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
                        
                        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                        //[self validateReceipt:transaction.originalTransaction.payment.productIdentifier ForTransactionId:transaction.originalTransaction.transactionIdentifier amount:@"0" storeIdentifier:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] withDelegate:self];
                        [self itemReadyToUse:transaction.originalTransaction.payment.productIdentifier
                              ForTransaction:transaction.originalTransaction.transactionIdentifier withReciptData:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] Amount:@"" andExpireDate:@"6/6/2020"];
                        //[prefs setBool:YES forKey:@"USERSUBSCRIBED"];
                        
                        
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
            //[self backButtonTapped:0];
        }];
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
        
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Restore Error" message:@"You are already subscribed, there no need to restore!!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
