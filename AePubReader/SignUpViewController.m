//
//  SignUpViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 12/11/12.
//
//

#import "SignUpViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Flurry.h"
#import "AePubReaderAppDelegate.h"
#import "Constants.h"
#import "LandPageChoiceViewController.h"
#import "MBProgressHUD.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil with:(LoginViewController *)loginViewController
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //_data=[[NSMutableData alloc]init];
        _loginViewController=loginViewController;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_password setSecureTextEntry:YES];
    [_confirmPassword setSecureTextEntry:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (IBAction)signUp:(id)sender {
    if (_email.text.length==0 || _password.text.length==0 || _confirmPassword.text.length==0 || _nameFull.text.length==0) {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Message" message:@"All fields are required" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
    [apiController loginWithEmail:_email.text AndPassword:_password.text IsNew:YES Name:_nameFull.text];
    apiController.delegate = self;
}

- (IBAction)donePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void) {
        
    }];
}

- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark - PostAPI Delegate Method

- (void)saveUserDetails:(NSDictionary *)userDetailsDictionary {
    if (userDetailsDictionary) {        
        [_delegate saveUserInfo:userDetailsDictionary];
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self donePressed:nil];
        [_delegate goToNext];
    }
}

#pragma mark - UITextField Delegate Methods

#define EMAIL_TAG 0
#define PASSWORD_TAG 1
#define CONFIRM_PASSWORD_TAG 2

- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case EMAIL_TAG:
            if (![self validateEmailWithString:textField.text]) {
                textField.text = @"";
                UIAlertView *wrongEmailAlert = [[UIAlertView alloc] initWithTitle:@"Wrong Email" message:@"Please enter a valid email address" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [wrongEmailAlert show];
            }
            break;
            
        case PASSWORD_TAG:
            
            break;
            
        case CONFIRM_PASSWORD_TAG:
            if (![textField.text isEqualToString:_password.text]) {
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Passwords don't match" message:@"Password and Confirm Password don't match" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
            }
            break;
            
        default:
            break;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    switch (textField.tag) {
        case EMAIL_TAG:
            [_email becomeFirstResponder];
            break;
        case PASSWORD_TAG:
            [_password becomeFirstResponder];
            break;
        case CONFIRM_PASSWORD_TAG:
            [_confirmPassword becomeFirstResponder];
            break;
            
        case 3:
            [self signUp:nil];
            break;
            
        default:
            break;
    }
    return YES;
   
}

@end
