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
    MangoApiController *apiController = [MangoApiController sharedApiController];
    apiController.delegate = self;
    [apiController loginWithEmail:_emailTextField.text AndPassword:_passwordTextField.text];
}

- (IBAction)goToNext:(id)sender {
    LandPageChoiceViewController *landingPageViewController = [[LandPageChoiceViewController alloc]initWithNibName:@"LandPageChoiceViewController" bundle:nil];
    [self.navigationController pushViewController:landingPageViewController animated:YES];
}

- (IBAction)signUp:(id)sender {
    
}

#pragma mark - API Delegate

- (void)saveUserDetails:(NSDictionary *)userDetailsDictionary {
    [PFAnalytics trackEvent:EVENT_LOGIN_EMAIL dimensions:[NSDictionary dictionaryWithObject:_emailTextField.text forKey:@"email"]];
    NSUserDefaults *appDefaults = [NSUserDefaults standardUserDefaults];
    [appDefaults setObject:[userDetailsDictionary objectForKey:AUTH_TOKEN] forKey:AUTH_TOKEN];
    [self goToNext:nil];
}

@end
