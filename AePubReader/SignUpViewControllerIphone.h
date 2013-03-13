//
//  SignUpViewControllerIphone.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 03/12/12.
//
//

#import <UIKit/UIKit.h>
#import "LoginViewControllerIphone.h"
@interface SignUpViewControllerIphone : UIViewController<NSURLConnectionDataDelegate,UIAlertViewDelegate,UITextFieldDelegate>
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIToolbar *toolBar;
- (IBAction)done:(id)sender;
@property(retain,nonatomic)NSMutableData *data;
@property (retain, nonatomic) IBOutlet UITextField *email;
@property (retain, nonatomic) IBOutlet UITextField *password;
- (IBAction)signUp:(id)sender;
@property (retain, nonatomic) IBOutlet UITextField *name;
@property (retain, nonatomic) IBOutlet UITextField *confirmPassword;
@property(retain,nonatomic)UIAlertView *alertVew;
@property(assign,nonatomic) LoginViewControllerIphone *loginViewControllerIphone;
@end
