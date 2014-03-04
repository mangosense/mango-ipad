//
//  LoginNewViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 20/11/13.
//
//

#import "LoginNewViewController.h"
#import "LandPageChoiceViewController.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import "MBProgressHUD.h"
#import <Accounts/Accounts.h>
#import "FacebookLogin.h"
#import <StoreKit/StoreKit.h>
#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import "AePubReaderAppDelegate.h"

@interface LoginNewViewController ()

@property (nonatomic, assign) BOOL isLoginWithFb;

@end

@implementation LoginNewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden=YES;
    
    // Create a FBLoginView to log the user in with basic, email and likes permissions
    // You should ALWAYS ask for basic permissions (basic_info) when logging the user in
    FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"basic_info", @"email", @"user_likes"]];
    
    // Set this loginUIViewController to be the loginView button's delegate
    loginView.delegate = self;
    
    // Align the button in the center horizontally
    loginView.frame = CGRectMake(_passwordTextField.frame.origin.x + _passwordTextField.frame.size.width/2 - loginView.frame.size.width/2, 385, loginView.frame.size.width, loginView.frame.size.height);
    
    // Align the button in the center vertically
    //loginView.center = self.view.center;
    
    
    // Add the button to the view
    [self.view addSubview:loginView];
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *userInfoObjects = [appDelegate.ejdbController getAllUserInfoObjects];
    if ([userInfoObjects count] > 0) {
        appDelegate.loggedInUserInfo = [userInfoObjects lastObject];
        [self goToNext:nil];
    }
    
    _isLoginWithFb = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Facebook Login API

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
    [facebookDict setObject:[user objectForKey:USERNAME] forKey:USERNAME];
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

#pragma mark - Action Methods

- (IBAction)signIn:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
    apiController.delegate = self;
    [apiController loginWithEmail:_emailTextField.text AndPassword:_passwordTextField.text IsNew:NO Name:nil];
}

- (void)goToNext {
    LandPageChoiceViewController *landingPageViewController = [[LandPageChoiceViewController alloc]initWithNibName:@"LandPageChoiceViewController" bundle:nil];
    [self.navigationController pushViewController:landingPageViewController animated:YES];
}

- (IBAction)goToNext:(id)sender {
    LandPageChoiceViewController *landingPageViewController = [[LandPageChoiceViewController alloc]initWithNibName:@"LandPageChoiceViewController" bundle:nil];
    [self.navigationController pushViewController:landingPageViewController animated:YES];
}

- (IBAction)signUp:(id)sender {
    SignUpViewController *signupViewController = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:nil];
    signupViewController.delegate = self;
    signupViewController.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:signupViewController animated:YES completion:nil];
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

#pragma mark - API Delegate

- (void)saveFacebookDetails:(NSDictionary *)facebookDetailsDictionary {
    [self saveUserInfo:facebookDetailsDictionary];
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self goToNext:nil];
}

- (void)saveUserDetails:(NSDictionary *)userDetailsDictionary {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    if ([[userDetailsDictionary allKeys] containsObject:AUTH_TOKEN]) {
        [self saveUserInfo:userDetailsDictionary];
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self goToNext:nil];
    } else {
        UIAlertView *loginFailureAlert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Please check your email and password" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [loginFailureAlert show];
    }
}

@end
