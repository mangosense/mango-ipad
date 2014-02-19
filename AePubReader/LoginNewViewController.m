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

#pragma mark - Facebook Login Methods

-(void)facebookError{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter facebook credentials in system preferences" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

-(void)facebookRequest{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    
    dictionary[@"email"] = [userDefaults objectForKey:@"FacebookUsername"];
    dictionary[@"name"] = [userDefaults objectForKey:@"FullName"];
    
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonValue=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"json String %@",jsonValue);
    
    NSString *connectionString = [userDefaults objectForKey:@"baseurl"];
    connectionString = [connectionString stringByAppendingString:@"facebookapplogin.json"];
    connectionString = [connectionString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Connection String %@",connectionString);
    
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:connectionString ]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    FacebookLogin *facebook = [[FacebookLogin alloc] initWithloginViewController:self];
    
    NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:facebook startImmediately:YES];
    [connection start];
}

- (void)getFacebookAccess {
    ACAccountStore *accountStore=[[ACAccountStore alloc]init];
    
    ACAccountType *facebookAccountType=[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary *options=@{@"ACFacebookAppIdKey" : @"199743376733034",@"ACFacebookPermissionsKey":@[@"email",@"user_about_me"]};
    [accountStore requestAccessToAccountsWithType:facebookAccountType options:options completion:^(BOOL granted,NSError *e){
        if (e) {
            [self performSelectorOnMainThread:@selector(facebookError) withObject:nil waitUntilDone:NO];
        }
        else if (granted) {
            
            NSArray *accounts=[accountStore accountsWithAccountType:facebookAccountType];
            ACAccount *account=[accounts lastObject];
            
            NSLog(@"%@", account.username);
            [[NSUserDefaults standardUserDefaults] setObject:account.username forKey:@"FacebookUsername"];
            NSURL *requestURL=[NSURL URLWithString:@"https://graph.facebook.com/me"];
            SLRequest *request=[SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:requestURL parameters:nil];
            request.account=account;
            
            [request performRequestWithHandler:^(NSData *data,NSHTTPURLResponse *response,NSError *error){
                NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                NSLog(@"%@", dict);
                if (!dict[@"name"]) {
                    [accountStore renewCredentialsForAccount:account completion:^(ACAccountCredentialRenewResult renewresult,NSError *error){
                        if (renewresult != ACAccountCredentialRenewResultRejected) {
                            [self getFacebookAccess];
                        }
                    }];
                }else{
                    [[NSUserDefaults standardUserDefaults] setObject:dict[@"name"] forKey:@"FullName"];
                    [self performSelectorOnMainThread:@selector(facebookRequest) withObject:nil waitUntilDone:NO];
                }
            }];
            
        }
    }];
}

#pragma mark - Action Methods

- (IBAction)facebookSignIn:(id)sender {
    [self getFacebookAccess];
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
