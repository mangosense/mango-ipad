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
#import "CoverViewControllerBetterBookType.h"


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

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    currentPage = @"login_screen";
    self.navigationController.delegate = self;
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden=YES;
    
    // Create a FBLoginView to log the user in with basic, email and likes permissions
    // You should ALWAYS ask for basic permissions (basic_info) when logging the user in
    FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"basic_info", @"email", @"user_likes"]];
    
    // Set this loginUIViewController to be the loginView button's delegate
    loginView.delegate = self;

    
    // Align the button in the center horizontally
    
  /*  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        loginView.frame = CGRectMake(_passwordTextField.frame.origin.x + _passwordTextField.frame.size.width/2 - loginView.frame.size.width/2, 175, loginView.frame.size.width, loginView.frame.size.height);
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
        loginView.frame = CGRectMake(_passwordTextField.frame.origin.x + _passwordTextField.frame.size.width/2 - loginView.frame.size.width/2, 385, loginView.frame.size.width, loginView.frame.size.height);
    }*/
    
    // Align the button in the center vertically
    //loginView.center = self.view.center;
    
    // Add the button to the view
    //[self.view addSubview:loginView];
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSArray *userInfoObjects = [appDelegate.ejdbController getAllUserInfoObjects];
    if ([userInfoObjects count] > 0) {
        appDelegate.loggedInUserInfo = [userInfoObjects lastObject];
        [self goToNext];
    }
    _isLoginWithFb = NO;

    
    //if(!notFirstTimeHelpDisplay){
        
      //  [prefs setBool:YES forKey:@"FIRSTTIMEHELPDISPLAY"];
        [self loadHelpImagesScroll];
    //}
    
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController viewWillAppear:animated];
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated{
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *dimensions = @{
                                 
                                 PARAMETER_ACTION : @"login_screen",
                                 PARAMETER_CURRENT_PAGE : currentPage,
                                 PARAMETER_EVENT_DESCRIPTION : @"login_screen",
                                 };
    [delegate trackEventAnalytic:@"login_screen" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
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
/*- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
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
}*/

// Implement the loginViewShowingLoggedInUser: delegate method to modify your app's UI for a logged-in user experiencez
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
    NSLog(@"Lengths are %d -- %d", _emailTextField.text.length, _passwordTextField.text.length);
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    if((_emailTextField.text.length < 1) || (_passwordTextField.text.length < 1)){
        
        UIAlertView *loginAlertError = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"All fields are required" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [loginAlertError show];
        return;
    }
    else{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        NSDictionary *dimensions = @{
                                     PARAMETER_USER_EMAIL_ID : _emailTextField.text,
                                     PARAMETER_ACTION : @"login",
                                     PARAMETER_CURRENT_PAGE : currentPage,
                                     PARAMETER_EVENT_DESCRIPTION : @"Login button click",
                                     };
        [delegate trackEventAnalytic:@"login" dimensions:dimensions];
        [delegate eventAnalyticsDataBrowser:dimensions];
    
        MangoApiController *apiController = [MangoApiController sharedApiController];
        apiController.delegate = self;
        [apiController loginWithEmail:_emailTextField.text AndPassword:_passwordTextField.text IsNew:NO Name:nil];
    }
}

- (void)goToNext {
    
        LandPageChoiceViewController *landingPageViewController;
    
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
            landingPageViewController = [[LandPageChoiceViewController alloc]initWithNibName:@"LandPageChoiceViewController_iPhone" bundle:nil];
        }
        else{
            landingPageViewController = [[LandPageChoiceViewController alloc]initWithNibName:@"LandPageChoiceViewController" bundle:nil];
        }
        [self.navigationController pushViewController:landingPageViewController animated:YES];

}

- (IBAction)goToNextSkip:(id)sender {
    
    NSString *alertMessage = @"Are you sure you want to skip unlimited access to interactive books!";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Skip Signin" message:alertMessage delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (IBAction)signUp:(id)sender {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    //ID = _udid;
   /* NSDictionary *dimensions = @{
                                 PARAMETER_USER_EMAIL_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 
                                 };
    [delegate trackEvent:[SIGN_UP_VIEW valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[SIGN_UP_VIEW valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [SIGN_UP_VIEW valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:ID forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];*/
    
    NSDictionary *dimensions = @{
                                 PARAMETER_ACTION : @"signup_btn",
                                 PARAMETER_CURRENT_PAGE : currentPage,
                                 PARAMETER_EVENT_DESCRIPTION : @"Signup button click",
                                 };
    [delegate trackEventAnalytic:@"signup_btn" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    
    SignUpViewController *signupViewController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        signupViewController = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController_iPhone" bundle:nil];
    }
    else{
        signupViewController = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:nil];
    }

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
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    //ID = [facebookDetailsDictionary objectForKey:@"email"];
    
   /* NSDictionary *dimensions = @{
                                 PARAMETER_USER_EMAIL_ID : ID,
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
    [userObject saveInBackground];*/
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self goToNext];
}

- (void)saveUserDetails:(NSDictionary *)userDetailsDictionary {
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    if (userDetailsDictionary.count) {
        if ([[userDetailsDictionary allKeys] containsObject:AUTH_TOKEN]) {
            [self saveUserInfo:userDetailsDictionary];
            //NSString *emailId = [userDetailsDictionary objectForKey:@"email"];
            /*NSDictionary *dimensions = @{
                                         PARAMETER_USER_EMAIL_ID : emailId,
                                         };
            [delegate trackEventAnalytic:[SIGN_IN valueForKey:@"eventDescription"] dimensions:dimensions];
            
            PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
            [userObject setObject:[SIGN_IN valueForKey:@"value"] forKey:@"eventName"];
            [userObject setObject: [SIGN_IN valueForKey:@"description"] forKey:@"eventDescription"];
            [userObject setObject:viewName forKey:@"viewName"];
            [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
            [userObject setObject:delegate.country forKey:@"deviceCountry"];
            [userObject setObject:delegate.language forKey:@"deviceLanguage"];
            [userObject setObject:ID forKey:@"emailID"];
            [userObject setObject:IOS forKey:@"device"];
            [userObject saveInBackground];*/
            
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self goToNext];
        } else {
            NSDictionary *dimensions = @{
                                         PARAMETER_USER_EMAIL_ID : _emailTextField.text,
                                         PARAMETER_ACTION : @"login_fail",
                                         PARAMETER_CURRENT_PAGE : currentPage,
                                         PARAMETER_EVENT_DESCRIPTION : @"Failed login attempt",
                                         };
            [delegate trackEventAnalytic:@"login_fail" dimensions:dimensions];
            [delegate eventAnalyticsDataBrowser:dimensions];
            UIAlertView *loginFailureAlert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:[userDetailsDictionary objectForKey:@"message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [loginFailureAlert show];
        }
    }
    else{
        UIAlertView *responseError = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Your internet status appears to be offline" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [responseError show];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self.view endEditing:YES];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    if([alertView.title isEqualToString:@"Skip Signin"]){
        
        if(buttonIndex == 1){
            
            AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
            
            NSDictionary *dimensions = @{
                                         
                                         PARAMETER_ACTION : @"skip_btn",
                                         PARAMETER_CURRENT_PAGE : currentPage,
                                         PARAMETER_EVENT_DESCRIPTION : @"Skip button click",
                                         PARAMETER_PASS : @"TRUE"
                                         };
            [delegate trackEventAnalytic:@"skip_btn" dimensions:dimensions];
            [delegate eventAnalyticsDataBrowser:dimensions];
            
            /*ID = _udid;
            
            NSDictionary *dimensions = @{
                                         PARAMETER_USER_EMAIL_ID : ID,
                                         PARAMETER_DEVICE: IOS,
                                         
                                         };
            [delegate trackEvent:[SKIP_SIGN_IN valueForKey:@"description"] dimensions:dimensions];
            PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
            [userObject setObject:[SKIP_SIGN_IN valueForKey:@"value"] forKey:@"eventName"];
            [userObject setObject: [SKIP_SIGN_IN valueForKey:@"description"] forKey:@"eventDescription"];
            [userObject setObject:viewName forKey:@"viewName"];
            [userObject setObject:ID forKey:@"deviceIDValue"];
            [userObject setObject:delegate.country forKey:@"deviceCountry"];
            [userObject setObject:delegate.language forKey:@"deviceLanguage"];
            [userObject setObject:IOS forKey:@"device"];
            [userObject saveInBackground];*/
            
                LandPageChoiceViewController *landingPageViewController;
            
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                
                    landingPageViewController = [[LandPageChoiceViewController alloc]initWithNibName:@"LandPageChoiceViewController_iPhone" bundle:nil];
                }
                else{
                    landingPageViewController = [[LandPageChoiceViewController alloc]initWithNibName:@"LandPageChoiceViewController" bundle:nil];
                }
            
                [self.navigationController pushViewController:landingPageViewController animated:YES];
        
        }
        else{
            
            NSDictionary *dimensions = @{
                                         
                                         PARAMETER_ACTION : @"skip_btn",
                                         PARAMETER_CURRENT_PAGE : currentPage,
                                         PARAMETER_EVENT_DESCRIPTION : @"Skip button click",
                                         PARAMETER_PASS : @"FALSE"
                                         };
            [delegate trackEventAnalytic:@"skip_btn" dimensions:dimensions];
            [delegate eventAnalyticsDataBrowser:dimensions];
        }
    }
}

//images for scroll view

- (void)loadHelpImagesScroll{
    
    pageControlBeingUsed = NO;
   // _imageHelpView.hidden = NO;
  //  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
 //   int notFirstTimeHelpDisplay = [[prefs valueForKey:@"FIRSTTIMEHELPDISPLAY"] integerValue];
   // if(!notFirstTimeHelpDisplay){
    
     // [prefs setBool:YES forKey:@"FIRSTTIMEHELPDISPLAY"];
  //      _imageHelpView.hidden = NO;
   // }
    
    
	
	NSArray *colors = [NSArray arrayWithObjects:[UIImage imageNamed:@"dashboard.jpg"], [UIImage imageNamed:@"createstory.jpg"], [UIImage imageNamed:@"readbar.jpg"],  [UIImage imageNamed:@"readpage.jpg"],  [UIImage imageNamed:@"store.jpg"],  [UIImage imageNamed:@"subscribe.jpg"], nil];
	for (int i = 0; i < colors.count; i++) {
		CGRect frame;
		frame.origin.x = self.scrollView.frame.size.width * i;
		frame.origin.y = 0;
		frame.size = self.scrollView.frame.size;
		
		UIImageView *subview = [[UIImageView alloc] initWithFrame:frame];
		//subview.backgroundColor = [colors objectAtIndex:i];
        subview.image = [colors objectAtIndex:i];
		[self.scrollView addSubview:subview];
		
	}
	
	self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * colors.count, self.scrollView.frame.size.height);
	
	self.pageControl.currentPage = 0;
	self.pageControl.numberOfPages = colors.count;
    
    [self.view bringSubviewToFront:[_imageHelpView superview]];
    [[_imageHelpView superview] bringSubviewToFront:_imageHelpView];
    
}


- (void)scrollViewDidScroll:(UIScrollView *)sender {
	if (!pageControlBeingUsed) {
		// Switch the indicator when more than 50% of the previous/next page is visible
		CGFloat pageWidth = self.scrollView.frame.size.width;
		int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
		self.pageControl.currentPage = page;
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	pageControlBeingUsed = NO;
}

- (IBAction)changePage {
	// Update the scroll view to the appropriate page
	CGRect frame;
	frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
	frame.origin.y = 0;
	frame.size = self.scrollView.frame.size;
	[self.scrollView scrollRectToVisible:frame animated:YES];
	
	// Keep track of when scrolls happen in response to the page control
	// value changing. If we don't do this, a noticeable "flashing" occurs
	// as the the scroll delegate will temporarily switch back the page
	// number.
	pageControlBeingUsed = YES;
}

- (IBAction)skipHelpPageView:(id)sender{
    
    _imageHelpView.hidden = YES;
    
}

- (IBAction)showHelpPageView:(id)sender{
    _imageHelpView.hidden = NO;
}

@end
