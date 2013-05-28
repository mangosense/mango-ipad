//
//  SignUpViewControllerIphone.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 03/12/12.
//
//

#import "SignUpViewControllerIphone.h"
#import <QuartzCore/QuartzCore.h>
#import "Flurry.h"
@interface SignUpViewControllerIphone ()

@end

@implementation SignUpViewControllerIphone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _data=[[NSMutableData alloc]init];
    }
    return self;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}
- (void)viewDidLoad
{
    CGSize size= _scrollView.contentSize;
    size.height=400;
    _toolBar.tintColor=[UIColor blackColor];
    [_scrollView setContentSize:size];
    [super viewDidLoad];
    [_password setSecureTextEntry:YES];
    [_confirmPassword setSecureTextEntry:YES];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*- (void)dealloc {
    [_scrollView release];
    [_toolBar release];
    [_data release];
    [_name release];
    [_email release];
    [_password release];
    [_confirmPassword release];
    [super dealloc];
}*/
- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setToolBar:nil];
    [self setName:nil];
    [self setEmail:nil];
    [self setPassword:nil];
    [self setConfirmPassword:nil];
    [super viewDidUnload];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [Flurry logEvent:@"Iphone signup entered"];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [Flurry logEvent:@"iphone singup exited"];
    
}
- (IBAction)done:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [_alertVew dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
 
    [alertView show];
 //   [alertView release];

}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_data appendData:data];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [_data setLength:0];
    
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
     [_alertVew dismissWithClickedButtonIndex:0 animated:YES];
    
   // [self done:nil];
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
    //        [alert release];
            return;
        }
        UIAlertView *alertViewSuccess=[[UIAlertView alloc]initWithTitle:@"Success" message:@"You have been sucessfully signed up" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertViewSuccess show];
        [Flurry logEvent:@"Iphone sucessful signup"];
      //  [alertViewSuccess release];
        
    }
    else{
        dictionary=  [dictionary objectForKey:@"error"];
        NSArray *arrayError=[dictionary objectForKey:@"email"];
        if (arrayError!=nil) {
            NSString *stringError=[NSString stringWithFormat:@"email %@",[arrayError objectAtIndex:0] ];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message: stringError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
       //     [alert release];
        }else{
            NSArray *arrayError=[dictionary objectForKey:@"password"];
            
            NSString *stringError= [ NSString stringWithFormat:@"password %@",[arrayError objectAtIndex:0]];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message: stringError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
       //     [alert release];
        }
        
    }

}
- (IBAction)signUp:(id)sender {
    if (_email.text.length==0||_password.text.length==0||_confirmPassword.text.length==0||_name.text.length==0) {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Message" message:@"All fields are required" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
   //     [alertView release];
        return;
    }
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *baseUrl=[userDefaults objectForKey:@"baseurl"];
   // baseUrl=@"http://staging.mangoreader.com/api/v1/";
    baseUrl =[baseUrl stringByAppendingString:@"users/sign_up.json?user[email]="];
    NSLog(@"production baseurl %@",baseUrl);
    // baseUrl=@"http://192.168.2.29:3000/api/v1/users/sign_up.json?user[email]=";
    NSString *parameter=[NSString stringWithFormat:@"%@&user[password]=%@&user[password_confirmation]=%@&user[name]=%@",_email.text,_password.text,_confirmPassword.text,_name.text];
   parameter= [parameter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    baseUrl=[baseUrl stringByAppendingString:parameter];
    NSLog(@"staging baseurl %@",baseUrl);
    
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:baseUrl]];

    [request setHTTPMethod:@"POST"];

    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
   // [connection autorelease];
  //  [request release];
    [connection start];
    _alertVew =[[UIAlertView alloc]init];
    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(139.0f-18.0f, 40.0f, 37.0f, 37.0f)];
    [indicator startAnimating];
    [_alertVew addSubview:indicator];
    //[indicator release];
    [_alertVew setTitle:@"Loading...."];

    [_alertVew show];
    //[_alertVew release];

   // _data=nil;
    _data=[[NSMutableData alloc]init];

    
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    [[NSUserDefaults standardUserDefaults]setValue:_email.text forKey:@"emailSignUp"];
    [[NSUserDefaults standardUserDefaults]setValue:_password.text forKey:@"emailPassword"];
    _loginViewControllerIphone.fromSignUp=YES;
    [self done:nil];
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
@end
