//
//  LoginViewController.h
//  AePubReader
//
//  Created by Nikhil Dhavale on 24/09/12.
//
//

#import <UIKit/UIKit.h>

#import <MessageUI/MessageUI.h>

@interface LoginViewController : UIViewController<UITextFieldDelegate,UIAlertViewDelegate,MFMailComposeViewControllerDelegate,NSURLConnectionDataDelegate>
- (IBAction)Check:(id)sender;
@property (retain, nonatomic) IBOutlet UITextField *userName;
- (IBAction)skipLogin:(id)sender;
@property (retain, nonatomic) IBOutlet UITextField *password;
@property (retain, nonatomic) IBOutlet UIButton *facebookButton;

- (IBAction)facebookLogin:(id)sender;
@property (retain, nonatomic) IBOutlet UIImageView *orImage;

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

@property(strong,nonatomic)NSMutableData *data;
@property(strong,nonatomic)UIAlertView *alertView;
-(void)goToNext;
@end
