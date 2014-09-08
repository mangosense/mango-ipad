//
//  EmailSubscriptionLinkViewController.m
//  MangoReader
//
//  Created by Harish on 8/8/14.
//
//

#import "EmailSubscriptionLinkViewController.h"


@interface EmailSubscriptionLinkViewController ()

@end

@implementation EmailSubscriptionLinkViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
         //self.preferredContentSize = CGSizeMake(1, 110);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    storyasAppPath = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.view.superview.backgroundColor = nil;
}

- (IBAction)signUpClick:(id)sender{
    
    BOOL emailNotValid = [self validateEmailWithString:_emailTextField.text];
    
    if(_emailTextField.text.length == 0){
        
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Message" message:@"Please enter email id to signup!!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    if(!emailNotValid){
        
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Message" message:@"Please enter a valid email id to signup!!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    NSString *alertMessage = [NSString stringWithFormat:@"Are you sure want to create an account with this email %@", _emailTextField.text];
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Alert" message:alertMessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
    [alertView show];
    
}

- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (void)getEmailLinkLoginDetails:(NSDictionary *)responseDictionary{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.emailTextField resignFirstResponder];
    if(responseDictionary){
        
        if([[responseDictionary objectForKey:@"status"]integerValue] == 200){
            [self skipClick:0];
        }
        else{
            if(storyasAppPath){//for story as app success subscription
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!!" message:[responseDictionary objectForKey:@"errors"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
            }
            else{//for main app success subscription
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!!" message:[responseDictionary objectForKey:@"errors"] delegate:self cancelButtonTitle:@"Change" otherButtonTitles:@"Signin", nil];
                [alert show];
            }
        }
    }
    else{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Some thing went wrong, please try later!!!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
}

- (IBAction)skipClick:(id)sender{
   
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self.emailTextField resignFirstResponder];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if([alertView.title isEqualToString:@"Alert"]){
        if(buttonIndex == 0){
            _emailTextField.text = @"";
        }
        else{
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            MangoApiController *apiController = [MangoApiController sharedApiController];
            apiController.delegate = self;
            [apiController linkSubscriptionWithEmail:_emailTextField.text];
        }
    }
    
    if([alertView.title isEqualToString:@"Sorry!!"]){
        
        if(buttonIndex == 0){
            //clear email field
            _emailTextField.text = @"";
        }
        else{
            //redirect user to signin page by setting another flag value
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setBool:YES forKey:@"SubscriptionEmailToSignIn"];
            self.modalPresentationStyle = UIModalPresentationNone;
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
