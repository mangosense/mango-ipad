//
//  SignUpViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 12/11/12.
//
//

#import "SignUpViewController.h"
#import <QuartzCore/QuartzCore.h>
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
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    [_password setSecureTextEntry:YES];
    [_confirmPassword setSecureTextEntry:YES];
//    self.navigationItem.leftBarButtonItem.tintColor=[UIColor grayColor];
//    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}
- (IBAction)signUp:(id)sender {
//    if (_nameFull.text.length==0||_password.text.length==0||_confirmPassword.text.length==0||_email.text.length==0) {
//        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"No fields should be blank" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        
//        [alertView show];
//        [alertView release];
//        return;
//    }
    if (![_password.text isEqualToString:_confirmPassword.text]) {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"password and confirm password don't match" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
       // [alertView release];
        return;
    }
//    if (![self validateEmailWithString:_email.text]) {
//        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Invalid Email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        
//        [alertView show];
//        [alertView release];
//        return;
//    }
    //actual signup
    if (_email.text.length==0||_password.text.length==0||_confirmPassword.text.length==0||_nameFull.text.length==0) {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Message" message:@"All fields are required" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
      //  [alertView release];
        return;
    }
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *baseUrl=[userDefaults objectForKey:@"baseurl"];
    //baseUrl=@"http://staging.mangoreader.com/api/v1/";
    baseUrl =[baseUrl stringByAppendingString:@"users/sign_up.json?user[email]="];
    NSLog(@"production baseurl %@",baseUrl);
   // baseUrl=@"http://192.168.2.29:3000/api/v1/users/sign_up.json?user[email]=";
    NSString *parameter=[NSString stringWithFormat:@"%@&user[password]=%@&user[password_confirmation]=%@&user[name]=%@",_email.text,_password.text,_confirmPassword.text,_nameFull.text];
    baseUrl=[baseUrl stringByAppendingString:parameter];
    NSLog(@"staging baseurl %@",baseUrl);
//    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
//    [dictionary setValue:_email.text forKey:@"user[email]"];
//    [dictionary setValue:_password.text forKey:@"user[password]"];
//    [dictionary setValue:_confirmPassword.text forKey:@"user[password_confirmation]"];
//    [dictionary setValue:_nameFull.text forKey:@"user[name]"];
//    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
//   
//    NSString *stringJson=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
//    NSLog(@"JSON %@",stringJson);
  
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:baseUrl]];
 //   [request setHTTPMethod:@"POST"];
    [request setHTTPMethod:@"POST"];
   // [request setHTTPBody:jsonData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
    [connection start];
   // [connection autorelease];
    //[request release];
//    NSString *string=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
//    NSLog(@"json data %@",string);
//    [string release];
    _alertView =[[UIAlertView alloc]init];
//    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(139.0f-18.0f, 40.0f, 37.0f, 37.0f)];
//    [indicator startAnimating];
//    [_alertView addSubview:indicator];
//    [indicator release];
//
    
    UIImage *image=[UIImage imageNamed:@"loading.png"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-40, -160, 391, 320)];
    
    
    imageView.image=image;
    [_alertView addSubview:imageView];
   // [imageView release];
    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(125, 25, 66.0f, 66.0f)];
    indicator.color=[UIColor blackColor];
    [indicator startAnimating];
    [_alertView addSubview:indicator];
    //[indicator release];

    [_alertView show];
   // [_alertView release];
 //[dictionary release];
  //    [stringJson release];
   // _data=nil;
    _data=[[NSMutableData alloc]init];
}

- (IBAction)donePressed:(id)sender {
      [self dismissModalViewControllerAnimated:YES];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_data appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [_alertView dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    //[alert release];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
     [_alertView dismissWithClickedButtonIndex:0 animated:YES];
    NSString *string=[[NSString alloc]initWithData:_data encoding:NSUTF8StringEncoding];
   NSDictionary *dictionary= [NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"json output %@",string);
  //  [string release];
    if ([dictionary objectForKey:@"user"]) {
        //sucess
        dictionary=[dictionary objectForKey:@"user"];
        if ([dictionary objectForKey:@"email"]==nil) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message: @"Email is either used or invalid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alert show];
                      //  [alert release];
            return;
        }
        UIAlertView *alertViewSuccess=[[UIAlertView alloc]initWithTitle:@"Success" message:@"You have been sucessfully signed up" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertViewSuccess show];
     //   [alertViewSuccess release];
   
    }
    else{
      dictionary=  [dictionary objectForKey:@"error"];
        NSArray *arrayError=[dictionary objectForKey:@"email"];
        if (arrayError!=nil) {
            NSString *stringError=[NSString stringWithFormat:@"email %@",[arrayError objectAtIndex:0] ];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message: stringError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
          //  [alert release];
        }else{
            NSArray *arrayError=[dictionary objectForKey:@"password"];

            NSString *stringError= [ NSString stringWithFormat:@"password %@",[arrayError objectAtIndex:0]];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message: stringError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
           // [alert release];
        }
     
    }
   // _data=nil;
    
    
}
- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
/*- (void)dealloc {
    [_nameFull release];
    [_email release];
    [_password release];
    
    [_confirmPassword release];
    _alertView=nil;
    [super dealloc];
}*/
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    [[NSUserDefaults standardUserDefaults]setValue:_email.text forKey:@"emailSignUp"];
    [[NSUserDefaults standardUserDefaults]setValue:_password.text forKey:@"emailPassword"];
    _loginViewController.getFromSignUp=YES;
    [self donePressed:nil];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    switch (textField.tag) {
        case 0:
            [_email becomeFirstResponder];
            break;
        case 1:
            [_password becomeFirstResponder];
            break;
        case 2:
            
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
- (void)viewDidUnload {
    [self setNameFull:nil];
    [self setEmail:nil];
    [self setPassword:nil];
    [self setConfirmPassword:nil];
    [super viewDidUnload];
}
@end
