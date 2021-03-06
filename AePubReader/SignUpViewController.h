//
//  SignUpViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 12/11/12.
//
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "MangoApiController.h"

@protocol PostSignupDelegate <NSObject>

- (void)goToNext;
- (void)saveUserInfo:(NSDictionary *)userInfoDict;

@end

@interface SignUpViewController : UIViewController<NSURLConnectionDataDelegate,UIAlertViewDelegate,UITextFieldDelegate, MangoPostApiProtocol, FBLoginViewDelegate>{
    
    NSString *userEmail;
    NSString *userDeviceID;
    NSString *ID;
    NSString *viewName;
}
- (IBAction)signUp:(id)sender;
- (IBAction)donePressed:(id)sender;

@property (retain, nonatomic) IBOutlet UITextField *nameFull;
@property (retain, nonatomic) IBOutlet UITextField *email;
@property (retain, nonatomic) IBOutlet UITextField *password;
@property (retain, nonatomic) IBOutlet UITextField *confirmPassword;
@property(retain,nonatomic) UIAlertView *alertView;
@property(retain,nonatomic)NSMutableData *data;
@property(assign,nonatomic)LoginViewController *loginViewController;

@property (nonatomic, assign) id <PostSignupDelegate> delegate;

@property (nonatomic, retain) IBOutlet UIView* settingsProbView;
@property (nonatomic, retain) IBOutlet UIView* settingsProbSupportView;
@property (nonatomic, retain) IBOutlet UITextField *textQuesSolution;

- (BOOL)validateEmailWithString:(NSString*)email;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil with:(LoginViewController *)loginViewController;

- (IBAction)displyParentalControlOrNot:(id)sender;
@end
