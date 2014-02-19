//
//  LoginNewViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 20/11/13.
//
//

#import <UIKit/UIKit.h>
#import "MangoApiController.h"
#import "SignUpViewController.h"

@interface LoginNewViewController : UIViewController <MangoPostApiProtocol, PostSignupDelegate>
- (IBAction)signIn:(id)sender;
- (IBAction)goToNext:(id)sender;
- (IBAction)signUp:(id)sender;
- (IBAction)facebookSignIn:(id)sender;

@property (nonatomic, strong) IBOutlet UITextField *emailTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;

@end
