//
//  LiveViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 14/11/12.
//
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "StoreViewController.h"
@interface LiveViewController : UIViewController<NSURLConnectionDataDelegate,UIAlertViewDelegate,SKPaymentTransactionObserver>

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
-(void)requestBooks;
@property(assign,nonatomic)NSInteger pageNumber;
@property(retain,nonatomic)NSMutableData *data;
@property(assign,nonatomic)NSInteger ymax;
@property(retain,nonatomic)UIAlertView *alertView;
@property(assign,nonatomic)NSInteger totalNumberOfBooks;
@property(assign,nonatomic)NSInteger pages;
@property(assign,nonatomic)NSInteger identity;
@property(assign,nonatomic)NSDecimalNumber *price;
@property(assign,nonatomic)StoreViewController *storeViewController;
@property(assign,nonatomic)UIInterfaceOrientation interfaceOrientationChanged;
@end
