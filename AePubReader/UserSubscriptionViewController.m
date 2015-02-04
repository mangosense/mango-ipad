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
    
    //NSString *extendedValue =  @"_";
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading Products";
    subscriptionProductId = [[NSArray alloc] initWithObjects:@"Week_EndlessStories", @"Month_EndlessStories", @"Year_EndlessStories", nil];
    subscriptionPlanName = [[NSArray alloc] initWithObjects:@"Monthly", @"Quarterly", @"Yearly", nil];
    
    [self subscriptionSetup];
    
    // Do any additional setup after loading the view from its nib.
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
                if(i==1){
                    _weeklyPrice.text = [NSString stringWithFormat:@"%@ /week", formattedString];
                }
                else if(i==0){
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
    
    NSString *planProductId = [subscriptionProductId objectAtIndex:[sender tag]-1];
    planPrice = [subscriptionPlanPrice objectAtIndex:[sender tag] -1];
    planName = [subscriptionPlanName objectAtIndex:[sender tag] -1];
    
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
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    SubscriptionInfo *subscriptionInfoData = [[SubscriptionInfo alloc] init];
    
    subscriptionInfoData.id = productID;
    
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
        
//        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//        [prefs setBool:YES forKey:@"USERSUBSCRIBED"];
//        [self.navigationController popViewControllerAnimated:YES];
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
    [self.navigationController popViewControllerAnimated:YES];
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
