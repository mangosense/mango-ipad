//
//  LiveViewControllerIphone.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 05/12/12.
//
//

#import <UIKit/UIKit.h>
#import "StoreBooks.h"
#import <StoreKit/StoreKit.h>
#import "MyBooksViewController.h"
#import "DownloadViewController.h"
@interface LiveViewControllerIphone : UITableViewController<NSURLConnectionDataDelegate,SKPaymentTransactionObserver,UIAlertViewDelegate>
@property(nonatomic,assign)DownloadViewController *downloadViewController;
@property(nonatomic,retain)NSMutableData *data;
@property(nonatomic,retain)NSMutableArray *array;
@property(nonatomic,retain)UIAlertView *alertView;
-(void)requestBooksFromServer;
@property(retain,nonatomic)NSDecimalNumber *price;
@property(assign,nonatomic)NSInteger identity;
@property(assign,nonatomic)MyBooksViewController *myBooks;
@property(assign,nonatomic)NSInteger pageNumber;
@property(strong,nonatomic)NSError *error;
-(void)transactionFailed;
-(void)purchaseValidation:(SKPaymentTransaction *)transaction;
@end
