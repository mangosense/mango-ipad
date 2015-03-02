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
#import "MangoEditorViewController.h"
#import "HomePageViewController.h"

//NewApp
#import "AgeDetailsViewController.h"


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
    
//    NSArray *userInfoObjects = [appDelegate.ejdbController getAllUserInfoObjects];
    
//    if ([userInfoObjects count] > 0) {
//        appDelegate.loggedInUserInfo = [userInfoObjects lastObject];
//        [self goToNext];
//    }
    
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
    
    if(_pushNoteBookId || _pushSubscribe){
        
        [self goToNext];
    }
    
    
    _isLoginWithFb = NO;
    
    if(_pushCreateStory){
        
        [self goToNext];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        width = 88.0;
        height = 107.0;
    }
    else{
        width = 217.0;
        height = 295.0;
    }
    [self addAnimationToView];
    
}


- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

/*- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController viewWillAppear:animated];
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController viewDidAppear:animated];
}*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:YES];
    
    [self performSelector:@selector(moveToAgeGrouoSelection:) withObject:self afterDelay:4.0];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *dimensions = @{
                                 
                                 PARAMETER_ACTION : @"initialScreen",
                                 PARAMETER_CURRENT_PAGE : @"initialScreen",
                                 PARAMETER_EVENT_DESCRIPTION : @"initial Screen open",
                                 };
    [delegate trackEventAnalytic:@"initialScreen" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"initialScreen"];
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
        landingPageViewController.pushCreateStory = _pushCreateStory;
        landingPageViewController.pushNoteBookId = _pushNoteBookId;
        landingPageViewController.pushSubscribe = _pushSubscribe;
        [self.navigationController pushViewController:landingPageViewController animated:NO];

}

- (IBAction)goToNextSkip:(id)sender {
    
    NSString *alertMessage = @"Are you sure you want to skip unlimited access to interactive books!";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Skip Signin" message:alertMessage delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (IBAction)signUp:(id)sender {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    //ID = _udid;
    
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
            
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self goToNext];
        } else {
            
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
            
            
        }
    }
}

//images for scroll view


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

- (void) viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    NSString *soundFilePath = [NSString stringWithFormat:@"%@/animationaudio.mp3",
                               [[NSBundle mainBundle] resourcePath]];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL
                                                     error:nil];
    _player.numberOfLoops = -1; //Infinite
    
    [_player play];
}



- (IBAction)showHelpPageView:(id)sender{
    _imageHelpView.hidden = NO;
}

- (IBAction) moveToAgeGrouoSelection:(id)sender{
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDictionary *dimensions = @{
                                 PARAMETER_ACTION : @"startButtonClick",
                                 PARAMETER_CURRENT_PAGE : @"initialScreen",
                                 PARAMETER_EVENT_DESCRIPTION : @"click on start",
                                 };
    [appDelegate trackEventAnalytic:@"startButtonClick" dimensions:dimensions];
    [appDelegate eventAnalyticsDataBrowser:dimensions];
    [appDelegate trackMixpanelEvents:dimensions eventName:@"startButtonClick"];
    
    NSArray *userAgeObjects = [appDelegate.ejdbController getAllUserAgeValue];
    
    if ([userAgeObjects count] > 0) {
        appDelegate.userInfoAge = [userAgeObjects lastObject];
        HomePageViewController *homePageView;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            homePageView = [[HomePageViewController alloc]initWithNibName:@"HomePageViewController_iPhone" bundle:nil];
        }
        else{
            homePageView = [[HomePageViewController alloc]initWithNibName:@"HomePageViewController" bundle:nil];
        }
        
        [self.navigationController pushViewController:homePageView animated:NO];
        
    }
    else{
        AgeDetailsViewController *ageGroupSelectionView;
    
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
            ageGroupSelectionView = [[AgeDetailsViewController alloc]initWithNibName:@"AgeDetailsViewController_iPhone" bundle:nil];
        }
        else{
            ageGroupSelectionView = [[AgeDetailsViewController alloc]initWithNibName:@"AgeDetailsViewController" bundle:nil];
        }
    
        [self.navigationController pushViewController:ageGroupSelectionView animated:NO];
    }
}

//add animation here
- (void) addAnimationToView{
    
    UIImageView *animationView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0.0,width,height)];
    UIImageView *animationView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0.0,width,height)];
    UIImageView *animationView3 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0.0,width,height)];
    UIImageView *animationView4 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0.0,width,height)];
    UIImageView *animationView5 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0.0,width,height)];
    
    NSMutableArray* imageArray = [[NSMutableArray alloc] initWithCapacity:10];
    
    [imageArray addObject:[UIImage imageNamed: @"load1.png"]];
    [imageArray addObject:[UIImage imageNamed: @"load2.png"]];
    [imageArray addObject:[UIImage imageNamed: @"load3.png"]];
    [imageArray addObject:[UIImage imageNamed: @"load6.png"]];
    [imageArray addObject:[UIImage imageNamed: @"load5.png"]];
    [imageArray addObject:[UIImage imageNamed: @"load4.png"]];
    [imageArray addObject:[UIImage imageNamed: @"load7.png"]];
    [imageArray addObject:[UIImage imageNamed: @"load10.png"]];
    [imageArray addObject:[UIImage imageNamed: @"load8.png"]];
    [imageArray addObject:[UIImage imageNamed: @"load9.png"]];
    
    
    animationView1.animationImages = [NSArray arrayWithArray:imageArray];
    [animationView1 setAnimationDuration:1.9];
    animationView1.animationRepeatCount = 0;
    
    animationView2.animationImages = [NSArray arrayWithArray:imageArray];
    [animationView2 setAnimationDuration:0.6];
    animationView2.animationRepeatCount = 0;
    
    animationView3.animationImages = [NSArray arrayWithArray:imageArray];
    [animationView3 setAnimationDuration:0.55];
    animationView3.animationRepeatCount = 0;
    
    animationView4.animationImages = [NSArray arrayWithArray:imageArray];
    [animationView4 setAnimationDuration:0.4];
    animationView4.animationRepeatCount = 0;
    
    animationView5.animationImages = [NSArray arrayWithArray:imageArray];
    [animationView5 setAnimationDuration:0.63];
    animationView5.animationRepeatCount = 0;
    
    [_animationButton addSubview: animationView1];
    
    //    [btnType2 addSubview: animationView2];
    //
    //    [btnType3 addSubview: animationView3];
    //
    //    [btnType4 addSubview: animationView4];
    //
    //    [btnType5 addSubview: animationView5];
    
    [animationView1 startAnimating];
    [animationView2 startAnimating];
    [animationView3 startAnimating];
    [animationView4 startAnimating];
    [animationView5 startAnimating];
    //[self addButterfly2];
}

-(void) viewDidDisappear:(BOOL)animated{
    
    _player = nil;
}


@end
