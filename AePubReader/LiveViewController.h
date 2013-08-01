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
#import "FooterView.h"
#import "PSTCollectionDataSource.h"
#import "PSTCollectionView.h"
#import "OldCell.h"
#import "OldFooterView.h"
@interface LiveViewController : UIViewController<NSURLConnectionDataDelegate,UIAlertViewDelegate,SKPaymentTransactionObserver,UICollectionViewDataSource,UICollectionViewDelegate>

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
-(void)requestBooks;
@property(assign,nonatomic)NSInteger pg;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property(assign,nonatomic)NSInteger currentPageNumber;
@property(retain,nonatomic)NSMutableData *data;
@property(assign,nonatomic)NSInteger ymax;
@property(retain,nonatomic)UIAlertView *alertView;
@property(assign,nonatomic)NSInteger totalNumberOfBooks;
@property(assign,nonatomic)NSInteger pages;
@property(assign,nonatomic)NSInteger identity;
- (IBAction)leftbutton:(id)sender;
@property(strong,nonatomic)NSDecimalNumber *price;
- (IBAction)rightButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *networkIndicator;
//@property(assign,nonatomic)StoreViewController *storeViewController;
@property(assign,nonatomic)UIInterfaceOrientation interfaceOrientationChanged;
@property(strong,nonatomic) NSError *error;
@property(strong,nonatomic)NSMutableArray *listOfBooks;
@property(strong,nonatomic)UICollectionView *collectionView;
@property(strong,nonatomic)FooterView *footerView;
@property(strong,nonatomic)OldFooterView *oldFootView;
@property(strong,nonatomic) PSUICollectionView *pstCollectionView;
@property(strong,nonatomic)PSTCollectionDataSource *dataSource;
-(void)purchaseValidation:(SKPaymentTransaction *)transaction;
-(void)transactionFailed;
-(void)requestBooksWithoutUIChange;
@end
