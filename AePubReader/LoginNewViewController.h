//
//  LoginNewViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 20/11/13.
//
//

#import <UIKit/UIKit.h>
#import "MangoApiController.h"

@interface LoginNewViewController : UIViewController <MangoPostApiProtocol>
- (IBAction)signIn:(id)sender;
- (IBAction)goToNext:(id)sender;
- (IBAction)signUp:(id)sender;

@property (nonatomic, strong) IBOutlet UITextField *emailTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;

@end
