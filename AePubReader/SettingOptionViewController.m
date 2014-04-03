//
//  SettingOptionViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 20/11/13.
//
//

#import "SettingOptionViewController.h"
#import "Constants.h"
#import "AePubReaderAppDelegate.h"
#import "EJDBController.h"
#import "UserInfo.h"
#import "BooksCollectionViewController.h"
#import "PurchaseManager.h"
#import "CargoBay.h"

@interface SettingOptionViewController ()

@end

@implementation SettingOptionViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _array=[[NSArray alloc]initWithObjects:@"Logout", @"Restore In-App Purchases",@"Analytics", nil];
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        userEmail = delegate.loggedInUserInfo.email;
        userDeviceID = delegate.deviceId;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    if(!userEmail){
        ID = userDeviceID;
    }
    else{
        ID = userEmail;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text=[_array objectAtIndex:indexPath.row];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dimensions = @{
                                 PARAMETER_USER_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_SETTINGS_VALUE: [_array objectAtIndex:indexPath.row]
                                 };
    [PFAnalytics trackEvent:SETTINGS_VALUE dimensions:dimensions];
    
    switch (indexPath.row) {
        case 0:
        {
            [self.controller popToRootViewControllerAnimated:YES];
            [_dismissDelegate dismissPopOver];
            
            //Removing User-Id; Added when user logged In with Email-Password
            /*[[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_ID];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:AUTH_TOKEN];
            [[NSUserDefaults standardUserDefaults] synchronize];*/
            
            AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
            if (appDelegate.loggedInUserInfo) {
                UserInfo *loggedInUserInfo = [appDelegate.ejdbController getUserInfoForId:appDelegate.loggedInUserInfo.id];
                [appDelegate.ejdbController deleteObject:loggedInUserInfo];
                
                appDelegate.loggedInUserInfo = nil;
            }
            
        }
            break;
            
        case 1:
        {
            //Restore Purchases
            /*SKReceiptRefreshRequest *refreshReceiptRequest = [[SKReceiptRefreshRequest alloc] init];
            refreshReceiptRequest.delegate = self;
            [refreshReceiptRequest start];*/
            
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
                            AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
                            Book *bk=[appDelegate.dataModel getBookOfEJDBId:transaction.originalTransaction.payment.productIdentifier];
                            if (!bk) {
                                if ([[[transaction.originalTransaction.payment.productIdentifier componentsSeparatedByCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]] componentsJoinedByString:@""] length] == 0) {
                                    NSLog(@"%@", transaction.originalTransaction.payment.productIdentifier);
                                    MangoApiController *apiController = [MangoApiController sharedApiController];
                                    [apiController getObject:[NSString stringWithFormat:OLD_STORY_INFO, transaction.originalTransaction.payment.productIdentifier] ForParameters:[NSDictionary dictionaryWithObject:transaction forKey:@"transaction"] WithDelegate:self];
                                } else {
                                    [self validateReceipt:transaction.originalTransaction.payment.productIdentifier ForTransactionId:transaction.originalTransaction.transactionIdentifier amount:@"0" storeIdentifier:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] withDelegate:self];
                                }
                            }
                        }
                            break;
                            
                        default:
                            break;
                    }
                }
            }];
            [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
        }
            break;
            
        case 2:{
            [_dismissDelegate dismissPopOver];
            //handle analytics view
            MangoAnalyticsViewController *analyticsViewController = [[MangoAnalyticsViewController alloc] initWithNibName:@"MangoAnalyticsViewController" bundle:nil];
             analyticsViewController.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
             [self presentViewController:analyticsViewController animated:YES completion:nil];
            
        }
            break;
            
        default:
            break;
    }
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

- (void)reloadWithObject:(NSDictionary *)responseObject ForType:(NSString *)type {
    SKPaymentTransaction *transaction = [responseObject objectForKey:@"transaction"];

    if ([type isEqualToString:[NSString stringWithFormat:OLD_STORY_INFO, transaction.originalTransaction.payment.productIdentifier]]) {
        
        [self validateReceipt:[responseObject objectForKey:@"id"] ForTransactionId:transaction.originalTransaction.transactionIdentifier amount:@"0" storeIdentifier:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] withDelegate:self];
    }
}

#pragma mark - Purchased Manager Call Back

- (void)itemReadyToUse:(NSString *)productId ForTransaction:(NSString *)transactionId {
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    Book *bk=[appDelegate.dataModel getBookOfEJDBId:productId];
    if (!bk) {
        MangoApiController *apiController = [MangoApiController sharedApiController];
        [apiController downloadBookWithId:productId withDelegate:self ForTransaction:transactionId];
    }
}

#pragma mark - Receipt Refresh Delegate

- (void)requestDidFinish:(SKRequest *)request {
    if([request isKindOfClass:[SKReceiptRefreshRequest class]])
    {
        //SKReceiptRefreshRequest
        NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[receiptUrl path]]) {
            NSLog(@"App Receipt exists");

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
                            [self validateReceipt:transaction.originalTransaction.payment.productIdentifier ForTransactionId:transaction.originalTransaction.transactionIdentifier amount:nil storeIdentifier:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] withDelegate:self];
                        }
                            break;
                            
                        default:
                            break;
                    }
                }
            }];
            [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
        } else {
            NSLog(@"Receipt request done but there is no receipt");
            
            // This can happen if the user cancels the login screen for the store.
            // If we get here it means there is no receipt and an attempt to get it failed because the user cancelled the login.
            //[self trackFailedAttempt];
        }
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"Request %@", request);
    NSLog(@"Response %@", response);
    NSLog(@"Products %@", response.products);
}

@end
