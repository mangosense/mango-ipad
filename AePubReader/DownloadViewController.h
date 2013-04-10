//
//  DownloadViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 03/12/12.
//
//

#import <UIKit/UIKit.h>
#import "MyBooksViewController.h"
#import <StoreKit/StoreKit.h>
@interface DownloadViewController : UITableViewController<NSURLConnectionDataDelegate,UIAlertViewDelegate,SKPaymentTransactionObserver>
@property(nonatomic,retain)NSURLConnection *connection;
@property(nonatomic,retain)UIAlertView *alert;
@property(assign,nonatomic)BOOL purchase;
@property(nonatomic,retain) NSMutableArray *array;
@property(assign,nonatomic)MyBooksViewController *myBook;
@property(strong,nonatomic)NSError *error;
- (void)refreshButton:(id)sender ;
-(void)getPurchasedDataFromDataBase;
-(void)transactionRestored;
-(void)transactionFailed;
@end
