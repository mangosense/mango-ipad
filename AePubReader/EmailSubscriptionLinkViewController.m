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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
    [apiController linkSubscriptionWithEmail:_emailTextField.text];
    apiController.delegate = self;
}

- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (void)getEmailLinkLoginDetails:(NSDictionary *)responseDictionary{
    
    if(responseDictionary){
        
        if([responseDictionary objectForKey:@"transaction_id"]){
            [self skipClick:0];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!!" message:[responseDictionary objectForKey:@"errors"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
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
   
    //dismiss the view
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self.view endEditing:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
