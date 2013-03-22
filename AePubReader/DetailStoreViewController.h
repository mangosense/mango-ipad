//
//  DetailStoreViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 05/12/12.
//
//

#import <UIKit/UIKit.h>
#import "StoreBooks.h"
#import "AePubReaderAppDelegate.h"
#import "DataModelControl.h"
#import "LiveViewControllerIphone.h"
#import <StoreKit/StoreKit.h>
@interface DetailStoreViewController : UIViewController<SKProductsRequestDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;

@property (retain, nonatomic) IBOutlet UILabel *sizeLabel;
@property (retain, nonatomic) IBOutlet UILabel *priceLabel;
@property(assign,nonatomic)NSInteger identity;
@property(retain,nonatomic)StoreBooks *bookStore;
@property(assign,nonatomic) LiveViewControllerIphone *live;
@property(retain,nonatomic)UIAlertView *alertView;
@property(retain,nonatomic)SKProduct *product;
@property (retain, nonatomic) IBOutlet UIToolbar *toolBarTop;
@property (retain, nonatomic) IBOutlet UIButton *purchaseButton;
@property(assign,nonatomic)BOOL isFree;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *toolBar;
- (IBAction)backButton:(id)sender;
- (IBAction)purchase:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil with:(NSInteger)identity;
@end
