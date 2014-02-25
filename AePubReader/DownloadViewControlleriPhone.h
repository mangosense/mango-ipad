//
//  DownloadViewControlleriPhone.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 07/11/13.
//
//

#import <UIKit/UIKit.h>
#import "MyBooksViewControlleriPhone.h"

@interface DownloadViewControlleriPhone : UIViewController<NSURLConnectionDataDelegate,UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,SKPaymentTransactionObserver>
@property(nonatomic,retain)NSURLConnection *connection;
@property(nonatomic,retain)UIAlertView *alert;
@property(assign,nonatomic)BOOL purchase;
@property(nonatomic,retain) NSMutableArray *array;
@property(assign,nonatomic)MyBooksViewControlleriPhone *myBook;
@property(strong,nonatomic)NSError *error;
- (IBAction)library:(id)sender;
-(void)getPurchasedDataFromDataBase;
-(void)transactionRestored;
- (IBAction)refresh:(id)sender;
- (IBAction)restore:(id)sender;
- (IBAction)signout:(id)sender;
- (IBAction)sync:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
-(void)transactionFailed;
@end
