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
#import <Parse/Parse.h>
#import <Social/Social.h>
#import "FacebookLogin.h"

CGFloat animatedDistance;
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.35;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

@interface SignUpViewController ()

@property (nonatomic, assign) BOOL isLoginWithFb;

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
    
    [[PFFacebookUtils session] closeAndClearTokenInformation];
    [[PFFacebookUtils session] close];
    [[FBSession activeSession] closeAndClearTokenInformation];
    //[[FBSession.activeSession] close];
    [FBSession setActiveSession:nil];
    [PFUser logOut];
    
    viewName = @"Sign Up";
    [_password setSecureTextEntry:YES];
   // [_confirmPassword setSecureTextEntry:YES];
    
    FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"basic_info", @"email", @"user_likes"]];
    
    loginView.delegate = self;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        loginView.frame = CGRectMake(_password.frame.origin.x + _password.frame.size.width/2 - loginView.frame.size.width/2, 49, loginView.frame.size.width, loginView.frame.size.height);
        for (id obj in loginView.subviews)
        {
            if ([obj isKindOfClass:[UIButton class]])
            {
                UIButton * loginButton =  obj;
                UIImage *loginImage = [UIImage imageNamed:@"facebook_login.png"];
                [loginButton setBackgroundImage:loginImage forState:UIControlStateNormal];
                [loginButton setBackgroundImage:nil forState:UIControlStateSelected];
                [loginButton setBackgroundImage:nil forState:UIControlStateHighlighted];
                [loginButton setFrame:CGRectMake(34,20,150,28)];
                
            }
            if ([obj isKindOfClass:[UILabel class]])
            {
                UILabel * loginLabel =  obj;
                loginLabel.text = @"";
                //loginLabel.textAlignment = UITextAlignmentCenter;
                loginLabel.frame = CGRectMake(0,0,0,0);
            }

        }
    }
    else{
        loginView.frame = CGRectMake(_password.frame.origin.x + _password.frame.size.width/2 - loginView.frame.size.width/2, 165, loginView.frame.size.width, loginView.frame.size.height);
    }
    
    [self.view addSubview:loginView];
    
    _isLoginWithFb = NO;
    
    [self.view bringSubviewToFront:[_settingsProbSupportView superview]];
    [self.view bringSubviewToFront:[_settingsProbView superview]];
    [[_settingsProbSupportView superview] bringSubviewToFront:_settingsProbSupportView];
    [[_settingsProbView superview] bringSubviewToFront:_settingsProbView];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loginWithFacebook:(NSDictionary *)facebookDetailsDict {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
    apiController.delegate = self;
    [apiController loginWithFacebookDetails:facebookDetailsDict];
}


#pragma mark - Facebook Login Methods

// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    NSLog(@"%@", user);
    NSLog(@"FB Auth Token: %@", [[[FBSession activeSession] accessTokenData] accessToken]);
    
    NSMutableDictionary *facebookDict = [[NSMutableDictionary alloc] init];
    [facebookDict setObject:[user objectForKey:EMAIL] forKey:EMAIL];
    [facebookDict setObject:[user objectForKey:@"id"] forKey:@"id"];
    [facebookDict setObject:[[[FBSession activeSession] accessTokenData] accessToken] forKey:AUTH_TOKEN];
    [facebookDict setObject:[[[FBSession activeSession] accessTokenData] expirationDate] forKey:FACEBOOK_TOKEN_EXPIRATION_DATE];
    [facebookDict setObject:[user objectForKey:NAME] forKey:USERNAME];
    [facebookDict setObject:[user objectForKey:NAME] forKey:NAME];
    
    if (!_isLoginWithFb) {
        _isLoginWithFb = YES;
        [self loginWithFacebook:[NSDictionary dictionaryWithDictionary:facebookDict]];
    }
}

// Implement the loginViewShowingLoggedInUser: delegate method to modify your app's UI for a logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    
}

// Implement the loginViewShowingLoggedOutUser: delegate method to modify your app's UI for a logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    
}

// You need to override loginView:handleError in order to handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures since that happen outside of the app.
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
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
    if (_email.text.length==0 || _password.text.length==0 || _nameFull.text.length==0) {
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
            [self donePressed:nil];
            [_delegate goToNext];
            
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:[userDetailsDictionary objectForKey:@"statusMessage"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
    }
    else{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Some thing went wrong, please try later!!!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
}

#pragma facebook delegate method

- (void)saveFacebookDetails:(NSDictionary *)facebookDetailsDictionary {
    [self saveUserDetails:facebookDetailsDictionary];
     AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    ID = [facebookDetailsDictionary objectForKey:@"email"];
    
    NSDictionary *dimensions = @{
                                 PARAMETER_USER_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_FACEBOOK_ID : ID
                                 };
    [delegate trackEvent:[LOGIN_FACEBOOK valueForKey:@"description"]  dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[LOGIN_FACEBOOK valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject:[LOGIN_FACEBOOK valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    [userObject setObject:ID forKey:@"emailID"];
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [_delegate goToNext];
}

#pragma mark - User Info

- (void)saveUserInfo:(NSDictionary *)userInfoDict {
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UserInfo *userInfo = [[UserInfo alloc] init];
    userInfo.email = [userInfoDict objectForKey:EMAIL];
    userInfo.id = [userInfoDict objectForKey:@"id"];
    userInfo.authToken = [userInfoDict objectForKey:AUTH_TOKEN];
    userInfo.facebookExpirationDate = [userInfoDict objectForKey:FACEBOOK_TOKEN_EXPIRATION_DATE];
    userInfo.username = [userInfoDict objectForKey:USERNAME];
    userInfo.name = [userInfoDict objectForKey:NAME];
    
    [appDelegate.ejdbController insertOrUpdateObject:userInfo];
    appDelegate.loggedInUserInfo = userInfo;
}

#pragma mark - UITextField Delegate Methods

#define EMAIL_TAG 0
#define PASSWORD_TAG 1
#define CONFIRM_PASSWORD_TAG 2





- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
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
                UIAlertView *wrongPasswordAlert = [[UIAlertView alloc] initWithTitle:@"Weak Password Strength" message:@"Password field's length should be more than 7 characters" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                
                [wrongPasswordAlert show];
                _password.text = @"";
            }
            break;
            
        case CONFIRM_PASSWORD_TAG:
           /* if (![textField.text isEqualToString:_password.text]) {
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Passwords don't match" message:@"Password and Confirm Password don't match" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
                _confirmPassword.text = @"";
            }*/
            break;
            
        default:
            break;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    
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
 
}

#pragma display parental control

- (IBAction)displyParentalControlOrNot:(id)sender{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *yearString = [formatter stringFromDate:[NSDate date]];
    int parentalControlAge = ([yearString integerValue] - [_textQuesSolution.text integerValue]);
    [_textQuesSolution resignFirstResponder];
    if((parentalControlAge >= 13) && (parentalControlAge <=100)){
        //show subscription plans
        _settingsProbSupportView.hidden = YES;
        _settingsProbView.hidden = YES;
    }
    else{
        //close subscription plan
        [self donePressed:0];
    }
}

- (IBAction)backgroundTap:(id)sender {
    [_textQuesSolution resignFirstResponder];
    
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    switch (textField.tag) {
        case EMAIL_TAG:
            [_email becomeFirstResponder];
            break;
        case PASSWORD_TAG:
            [_password becomeFirstResponder];
            break;
       /* case CONFIRM_PASSWORD_TAG:
            [_confirmPassword becomeFirstResponder];
            break;*/
            
        case 3:
            [self signUp:nil];
            break;
            
        default:
            break;
    }
    return YES;
   
}

@end
