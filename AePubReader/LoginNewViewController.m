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

@interface LoginNewViewController ()

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signIn:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
    apiController.delegate = self;
    [apiController loginWithEmail:_emailTextField.text AndPassword:_passwordTextField.text IsNew:NO];
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

#pragma mark - API Delegate

- (void)saveUserDetails:(NSDictionary *)userDetailsDictionary {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    if ([[userDetailsDictionary allKeys] containsObject:AUTH_TOKEN]) {
        [PFAnalytics trackEvent:EVENT_LOGIN_EMAIL dimensions:[NSDictionary dictionaryWithObject:_emailTextField.text forKey:@"email"]];
        NSUserDefaults *appDefaults = [NSUserDefaults standardUserDefaults];
        [appDefaults setObject:[userDetailsDictionary objectForKey:AUTH_TOKEN] forKey:AUTH_TOKEN];
        [appDefaults setObject:[userDetailsDictionary objectForKey:@"id"] forKey:USER_ID];
        [self goToNext:nil];
    } else {
        UIAlertView *loginFailureAlert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Please check your email and password" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [loginFailureAlert show];
    }
}

@end
