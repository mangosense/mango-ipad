//
//  LoginViewController.h
//  AePubReader
//
//  Created by Nikhil Dhavale on 24/09/12.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <StoreKit/StoreKit.h>
#import "Book.h"
#import <FacebookSDK/FacebookSDK.h>

@interface LoginViewController : UIViewController<UITextFieldDelegate,UIAlertViewDelegate,MFMailComposeViewControllerDelegate,NSURLConnectionDataDelegate, FBLoginViewDelegate>
- (IBAction)Check:(id)sender;
@property (retain, nonatomic) IBOutlet UITextField *userName;
- (IBAction)skipLogin:(id)sender;
@property (retain, nonatomic) IBOutlet UITextField *password;
@property (retain, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundimage;

- (IBAction)facebookLogin:(id)sender;
@property (retain, nonatomic) IBOutlet UIImageView *orImage;
@property (weak, nonatomic) IBOutlet UIToolbar *topToolbar;

@property(strong,nonatomic) NSURLConnection *connection;
@property (retain, nonatomic) IBOutlet UIView *videoView;
- (void)loadURL:(UIButton *)sender;
- (void)popUpThenURL:(UIButton *)sender;
@property (retain, nonatomic) IBOutlet UIButton *ForgotPassword;
@property (retain, nonatomic) IBOutlet UIButton *signUp;
- (IBAction)showVideo:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *AboutUs;
- (IBAction)forgotPassword:(id)sender;
- (IBAction)signUp:(id)sender;
@property(nonatomic,assign)BOOL getFromSignUp;
-(void)insertInStore;

@property(strong,nonatomic)NSMutableData *data;
@property(strong,nonatomic)UIAlertView *alertView;
@property(strong,nonatomic)UITabBarController *tabBarController;
-(void)goToNext;
-(void)transactionRestored;
-(void)transactionFailed;
-(void)transactionPurchaseValidation:(SKPaymentTransaction *)transaction;
-(void)restoreFailed;
-(void)liveViewControllerDismiss;
-(BOOL)downloadBook:(Book *)book;
-(void)refreshDownloads;
@end
