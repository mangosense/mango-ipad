//
//  LoginViewController.m
//  AePubReader
//
//  Created by Nikhil Dhavale on 24/09/12.
//
//

#import "LoginViewController.h"

#import "StoreViewController.h"
#import <Foundation/Foundation.h>
#import "AePubReaderAppDelegate.h"
#import "WebViewController.h"
#import <QuartzCore/QuartzCore.h>
 #import <MessageUI/MessageUI.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import "LibraryViewController.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _data=[[NSMutableData alloc]init];
    }
    return self;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}
- (void)viewDidLoad
{
    [super viewDidLoad];
      [self.navigationController.navigationBar setHidden:YES];
    // Do any additional setup after loading the view from its nib.
    _password.secureTextEntry=YES;
//    [_signUp addTarget:self action:@selector(loadURL:) forControlEvents:UIControlEventTouchUpInside];
//    [_ForgotPassword addTarget:self action:@selector(loadURL:) forControlEvents:UIControlEventTouchUpInside];
 
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
  

    if ([userDefault objectForKey:@"email"]&&[userDefault objectForKey:@"password"]) {
        UITabBarController *tabBarController=[[[UITabBarController alloc]init]autorelease];
        LibraryViewController *library=[[LibraryViewController alloc]initWithNibName:@"LibraryViewController" bundle:nil];
        StoreViewController *store=[[StoreViewController alloc]initWithNibName:@"StoreViewController" bundle:nil];
        store.delegate=library;
        UINavigationController *navigation=[[UINavigationController alloc]initWithRootViewController:library];
        UINavigationController *navigationStore=[[UINavigationController alloc]initWithRootViewController:store];
        [library release];
        tabBarController.viewControllers=@[navigation ,navigationStore];
        [navigationStore release];
        [navigation release];
        [store release];
        [self.navigationController pushViewController:tabBarController animated:YES];

       
    }
    


    [_AboutUs addTarget:self action:@selector(popUpThenURL:) forControlEvents:UIControlEventTouchUpInside];
    
}
-(void)viewDidDisappear:(BOOL)animated{
   
}
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [controller dismissModalViewControllerAnimated:YES];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    switch (textField.tag) {
        case 0:
            //[textField resignFirstResponder];
            [_password becomeFirstResponder];
            break;
        case 1:
            [self Check:nil];
            break;
        default:
            break;
    }
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [_alertView dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    [alertView release];

}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [_data setLength:0];
  
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    NSDictionary *diction=[NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingAllowFragments error:nil];
   
    [_alertView dismissWithClickedButtonIndex:0 animated:YES];
    NSString *temp=diction[@"user"];
    
    if (temp) {
        NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
        NSString *temp=diction[@"auth_token"];
        [userDefault setObject:temp forKey:@"auth_token"];
        [userDefault setObject:_userName.text forKey:@"email"];
        [userDefault setObject:_password.text forKey:@"password"];
            UITabBarController *tabBarController=[[[UITabBarController alloc]init]autorelease];
            LibraryViewController *library=[[LibraryViewController alloc]initWithNibName:@"LibraryViewController" bundle:nil];
            StoreViewController *store=[[StoreViewController alloc]initWithNibName:@"StoreViewController" bundle:nil];
            store.delegate=library;
            UINavigationController *navigation=[[UINavigationController alloc]initWithRootViewController:library];
        UINavigationController *navigationStore=[[UINavigationController alloc]initWithRootViewController:store];
            [library release];
            tabBarController.viewControllers=@[navigation ,navigationStore];
        [navigationStore release];
            [navigation release];
            [store release];
            [self.navigationController pushViewController:tabBarController animated:YES];
           // [tabBarController release];
    }else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Either username or password is invalid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_data appendData:data];
}
- (IBAction)Check:(id)sender {

    NSString *loginURL=[[NSUserDefaults standardUserDefaults] objectForKey:@"baseurl"];
    
    loginURL=[loginURL stringByAppendingFormat:@"/users/sign_in?user[email]=%@&user[password]=%@",_userName.text,_password.text];
    NSMutableURLRequest *request=[[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:loginURL]]autorelease];
    [request setHTTPMethod:@"GET"];
    _connection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
    [_connection autorelease];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    _alertView =[[UIAlertView alloc]init];
    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(139.0f-18.0f, 40.0f, 37.0f, 37.0f)];
    [indicator startAnimating];
    [_alertView addSubview:indicator];
    [indicator release];
    [_alertView setTitle:@"Loading...."];
    [_alertView show];


}
- (void)dealloc {
    [_userName release];
    [_password release];
    [_ForgotPassword release];
    [_signUp release];
    [_AboutUs release];
    [_videoView release];
  //  [_webView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setUserName:nil];
    [self setPassword:nil];
    [self setForgotPassword:nil];
    [self setSignUp:nil];
    [self setAboutUs:nil];
    [self setVideoView:nil];
  //  [self setWebView:nil];
    [super viewDidUnload];
}
- (void)loadURL:(UIButton *)sender {
  
    NSURL *url=[NSURL URLWithString:@"http://www.mangoreader.com/"];
    [[UIApplication sharedApplication] openURL:url];
    
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"Index %d",buttonIndex);
//    if (buttonIndex==1) {
//      [self loadURL:nil];
//    }
    
    if(buttonIndex==1){
        MFMailComposeViewController *mail=[[MFMailComposeViewController alloc]init];
        [mail setMailComposeDelegate:self];
        [mail setSubject:@"Checkout  awesome reader Application"];
        [mail setMessageBody:@"http://www.mangoreader.com" isHTML:NO];
        mail.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:mail animated:YES];
        [mail release];
    }
        
}
- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskLandscape;
    
}

- (BOOL)shouldAutorotate {
    
    return YES;
}

- (void)popUpThenURL:(UIButton *)sender {
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Mango Reader" message:@"MangoReader - we bring books to life by making them engaging and fun using videos, animation, quizzes, maps, graphics and interactivity. Publishers, Authors and Educators can reach new audiences using mobiles, tablets and online reader and generate more revenue. Readers get better books and a great learning experience and can collaborate with friends, take notes and use learning tools such as dictionary, search and quizzes. We are not only redefining books and publishing, but reinventing the way people learn." delegate:self cancelButtonTitle:@"Done" otherButtonTitles:@"Share", nil];
    CGRect frame=alert.frame;
    frame.size.height=frame.size.height+100;
    frame.size.width=frame.size.width+300;
    alert.frame=frame;
//    UIImage *image=[UIImage imageNamed:@"logo1.png"];
//      UIImageView *imageView=[[UIImageView alloc]initWithImage:image];
//    imageView.frame=CGRectMake(50.0f, 0, 210.0f, 52.0f);
//    [alert addSubview:imageView];
//    
  //  [imageView release];
    [alert show];
    [alert release];
}
- (IBAction)forgotPassword:(id)sender {
    NSURL *url=nil;
    WebViewController *webView;
    url=[NSURL URLWithString:@"http://www.mangoreader.com/users/password/new"];
    webView=[[WebViewController alloc]initWithNibName:@"WebViewController" bundle:nil URL:url];
    webView.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:webView animated:YES completion:nil ];
    [webView release];
}

- (IBAction)signUp:(id)sender {
    NSURL *url=nil;
    WebViewController *webView;

    url=[NSURL URLWithString:@"http://www.mangoreader.com/users/signup"];
    webView=[[WebViewController alloc]initWithNibName:@"WebViewController" bundle:nil URL:url];
    webView.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
     [self presentViewController:webView animated:YES completion:nil ];
    [webView release];
}
- (IBAction)showVideo:(id)sender {
     WebViewController *webView;
    NSURL *url=[NSURL URLWithString:@"http://www.youtube.com/embed/CyXxt0WSLWE"];
    webView =[[WebViewController alloc]initWithNibName:@"WebViewController" bundle:nil URL:url];
    webView.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:webView animated:YES completion:nil];
    [webView release];
    
}
@end
