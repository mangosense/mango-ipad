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
#import "AePubReaderAppDelegate.h"
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
    if([UIDevice currentDevice].systemVersion.integerValue>=7)
    {
        // iOS 7 code here
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setToolBar:nil];
    [self setName:nil];
    [self setEmail:nil];
    [self setPassword:nil];
    [self setConfirmPassword:nil];
    [super viewDidUnload];
}
-(void)viewDidAppear:(BOOL)animated{
    [AePubReaderAppDelegate adjustForIOS7:self.view];

    

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [Flurry logEvent:@"Iphone signup entered"];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];

    CGRect frame= _toolBar.frame;
    frame.size.width=screenBounds.size.height+50;
    _toolBar.frame=frame;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [Flurry logEvent:@"iphone singup exited"];
    
}
- (IBAction)done:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [AePubReaderAppDelegate hideAlertView];
  //  [_alertVew dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
 
    [alertView show];

}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_data appendData:data];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [_data setLength:0];
    
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
  //   [_alertVew dismissWithClickedButtonIndex:0 animated:YES];
    [AePubReaderAppDelegate hideAlertView];
    NSString *string=[[NSString alloc]initWithData:_data encoding:NSUTF8StringEncoding];
    NSDictionary *dictionary= [NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"json output %@",string);
    if (dictionary[@"user"]) {
        //sucess
        dictionary=dictionary[@"user"];
        if (dictionary[@"email"]==nil) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message: @"Email is either used or invalid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            return;
        }
        UIAlertView *alertViewSuccess=[[UIAlertView alloc]initWithTitle:@"Success" message:@"You have been sucessfully signed up" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertViewSuccess show];
        [Flurry logEvent:@"Iphone sucessful signup"];
        
    }
    else{
        dictionary=  dictionary[@"error"];
        NSArray *arrayError=dictionary[@"email"];
        if (arrayError!=nil) {
            NSString *stringError=[NSString stringWithFormat:@"email %@",arrayError[0] ];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message: stringError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }else{
            NSArray *arrayError=dictionary[@"password"];
            
            NSString *stringError= [ NSString stringWithFormat:@"password %@",arrayError[0]];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message: stringError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        
    }

}
- (IBAction)signUp:(id)sender {
    if (_email.text.length==0||_password.text.length==0||_confirmPassword.text.length==0||_name.text.length==0) {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Message" message:@"All fields are required" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
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

    [connection start];
   /* _alertVew =[[UIAlertView alloc]init];
    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(139.0f-18.0f, 40.0f, 37.0f, 37.0f)];
    [indicator startAnimating];
    [_alertVew addSubview:indicator];
    [_alertVew setTitle:@"Loading...."];

    [_alertVew show];*/
    [AePubReaderAppDelegate showAlertView];

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
