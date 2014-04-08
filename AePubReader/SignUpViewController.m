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

CGFloat animatedDistance;
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.35;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

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
        
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        userEmail = delegate.loggedInUserInfo.email;
        userDeviceID = delegate.deviceId;
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    viewName = @"Sign Up";
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self.view endEditing:NO];
    }
}

- (IBAction)signUp:(id)sender {
    [self.view endEditing:NO];
    if (_email.text.length==0 || _password.text.length==0 || _confirmPassword.text.length==0 || _nameFull.text.length==0) {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Message" message:@"All fields are required" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        return;
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
        
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        if(![userDetailsDictionary objectForKey:@"statusMessage"]){
        [_delegate saveUserInfo:userDetailsDictionary];
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self donePressed:nil];
        [_delegate goToNext];
            
        NSDictionary *dimensions = @{
                                    PARAMETER_USER_ID :delegate.deviceId,
                                    PARAMETER_DEVICE: IOS,
                                    PARAMETER_SIGNUP_EMAIL : _email.text
                                         
                                         };
        [delegate trackEvent:[SIGN_UP_USER valueForKey:@"description"] dimensions:dimensions];
            PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
            [userObject setObject:[SIGN_UP_USER valueForKey:@"value"] forKey:@"eventName"];
            [userObject setObject: [SIGN_UP_USER valueForKey:@"description"] forKey:@"eventDescription"];
            [userObject setObject:viewName forKey:@"viewName"];
            [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
            [userObject setObject:delegate.country forKey:@"deviceCountry"];
            [userObject setObject:delegate.language forKey:@"deviceLanguage"];
            [userObject setObject:_email.text forKey:@"emailID"];
            [userObject setObject:IOS forKey:@"device"];
            [userObject saveInBackground];
            
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:[userDetailsDictionary objectForKey:@"statusMessage"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
    }
    else{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Please check your internet connection, you are offline !!!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
}

#pragma mark - UITextField Delegate Methods

#define EMAIL_TAG 0
#define PASSWORD_TAG 1
#define CONFIRM_PASSWORD_TAG 2





- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    
    
        CGRect textFieldRect =
        [self.view.window convertRect:textField.bounds fromView:textField];
        CGRect viewRect =
        [self.view.window convertRect:self.view.bounds fromView:self.view];
        
        CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
        CGFloat numerator =
        midline - viewRect.origin.y
        - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
        CGFloat denominator =
        (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
        * viewRect.size.height;
        CGFloat heightFraction = numerator / denominator;
        
        if (heightFraction < 0.0)
        {
            heightFraction = 0.0;
        }
        else if (heightFraction > 1.0)
        {
            heightFraction = 1.0;
        }
        
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
        
        CGRect viewFrame = self.view.frame;
        
        if (orientation == UIInterfaceOrientationLandscapeLeft)
        {
            viewFrame.origin.x -= animatedDistance;
        }
        if (orientation == UIInterfaceOrientationLandscapeRight)
        {
            viewFrame.origin.x += animatedDistance;
        }
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        
        [self.view setFrame:viewFrame];
        [UIView commitAnimations];
    
}
// scrolls the view down if the view was scrolled up
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    
    switch (textField.tag) {
        case EMAIL_TAG:
            if ((![self validateEmailWithString:textField.text]) && (textField.text.length > 0)) {
                textField.text = @"";
                UIAlertView *wrongEmailAlert = [[UIAlertView alloc] initWithTitle:@"Wrong Email" message:@"Please enter a valid email address" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [wrongEmailAlert show];
            }
            break;
            
        case PASSWORD_TAG:
            if((textField.text.length < 8)&&(textField.text.length > 0)){
                UIAlertView *wrongPasswordAlert = [[UIAlertView alloc] initWithTitle:@"Weak Password Strength" message:@"Password field's length should be more than 7" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                
                [wrongPasswordAlert show];
                _password.text = @"";
            }
            break;
            
        case CONFIRM_PASSWORD_TAG:
            if (![textField.text isEqualToString:_password.text]) {
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Passwords don't match" message:@"Password and Confirm Password don't match" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
                _confirmPassword.text = @"";
            }
            break;
            
        default:
            break;
    }
    
    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight)
    {
        CGRect viewFrame = self.view.frame;
        
        if (orientation == UIInterfaceOrientationLandscapeLeft)
        {
            viewFrame.origin.x += animatedDistance;
        }
        if (orientation == UIInterfaceOrientationLandscapeRight)
        {
            viewFrame.origin.x -= animatedDistance;
        }
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        
        [self.view setFrame:viewFrame];
        [UIView commitAnimations];
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
