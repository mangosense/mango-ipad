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
#import "MyBooksViewControlleriPhone.h"
#import "DownloadViewControlleriPhone.h"
@interface LiveViewControllerIphone : UITableViewController<NSURLConnectionDataDelegate,SKPaymentTransactionObserver,UIAlertViewDelegate>
@property(nonatomic,assign)DownloadViewControlleriPhone *downloadViewController;
@property(nonatomic,retain)NSMutableData *data;
@property(nonatomic,retain)NSMutableArray *array;
@property(nonatomic,retain)UIAlertView *alertView;
-(void)requestBooksFromServer;
@property(retain,nonatomic)NSDecimalNumber *price;
@property(assign,nonatomic)MyBooksViewControlleriPhone *myBooks;
@property(assign,nonatomic)NSInteger pageNumber;
@property(strong,nonatomic)NSError *error;
@property(assign,nonatomic)NSInteger totalNoOfBooks;
@property(assign,nonatomic)NSInteger pages;
@property(assign,nonatomic)NSInteger pg;
-(void)transactionFailed;
-(void)purchaseValidation:(SKPaymentTransaction *)transaction;
@end
