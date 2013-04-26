//
//  LiveViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 14/11/12.
//
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "Flurry.h"
@interface LiveViewController : UIViewController<NSURLConnectionDataDelegate,UIAlertViewDelegate,SKPaymentTransactionObserver>

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
-(void)requestBooks;
@property(assign,nonatomic)NSInteger pg;
@property(assign,nonatomic)NSInteger currentPageNumber;
@property(retain,nonatomic)NSMutableData *data;
@property(assign,nonatomic)NSInteger ymax;
@property(retain,nonatomic)UIAlertView *alertView;
@property(assign,nonatomic)NSInteger totalNumberOfBooks;
@property(assign,nonatomic)NSInteger pages;
@property(assign,nonatomic)NSInteger identity;
@property(strong,nonatomic)NSDecimalNumber *price;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *networkIndicator;
//@property(assign,nonatomic)StoreViewController *storeViewController;
@property(assign,nonatomic)UIInterfaceOrientation interfaceOrientationChanged;
@property(strong,nonatomic) NSError *error;
-(void)purchaseValidation:(SKPaymentTransaction *)transaction;
-(void)transactionFailed;
-(void)requestBooksWithoutUIChange;
@end
