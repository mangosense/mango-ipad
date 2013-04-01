//
//  PopPurchaseViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 14/11/12.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <StoreKit/StoreKit.h>
#import "LiveViewController.h"
@interface PopPurchaseViewController : UIViewController<MFMailComposeViewControllerDelegate,SKProductsRequestDelegate,UIAlertViewDelegate>
@property (retain, nonatomic) IBOutlet UIButton *purchaseButton;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;

@property (retain, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property(retain,nonatomic) SKProduct *products;
@property(retain,nonatomic)SKPayment *payment;
@property(assign,nonatomic)NSInteger identity;
@property(retain,nonatomic) UIAlertView *alertView;
@property(retain,nonatomic)NSString *value;
@property(assign,nonatomic)BOOL isFree;
@property(assign,nonatomic)LiveViewController *liveViewController;
@property (retain, nonatomic) IBOutlet UIWebView *detailsWebView;
@property (weak, nonatomic) IBOutlet UILabel *freeSpace;

- (IBAction)purchaseAndDownload:(id)sender;
- (IBAction)toPurchase:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *purchaseLabel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil Identity:(NSInteger)indentity live:(LiveViewController *)liveController ;
@end
