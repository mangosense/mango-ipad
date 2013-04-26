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
#import "SignUpViewController.h"
#import <QuartzCore/QuartzCore.h>
 #import <MessageUI/MessageUI.h>
#import "SignUpViewController.h"
#import "LibraryViewController.h"
#import "LiveViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "FacebookLogin.h"
#import "CustomTabViewController.h"
#import "Flurry.h"
@interface LoginViewController ()
@property(strong,nonatomic)StoreViewController *store;
@property(strong,nonatomic)LiveViewController *liveViewController;
@property(nonatomic,strong)LibraryViewController *library;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _data=[[NSMutableData alloc]init];
        _getFromSignUp=NO;
    }
    return self;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}
-(void)viewWillAppear:(BOOL)animated{
    if (_getFromSignUp) {
      NSString *email=  [[NSUserDefaults standardUserDefaults]valueForKey:@"emailSignUp"];
     NSString *password=   [[NSUserDefaults standardUserDefaults]valueForKey:@"emailPassword"];
        _userName.text=email;
        _password.text=password;
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"emailSignUp"];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"emailPassword"];
      
        _getFromSignUp=NO;
    }

    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.PortraitOrientation=NO;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        UIViewController *c=[[UIViewController alloc]init];
        c.view.backgroundColor=[UIColor clearColor];
        [self presentViewController:c animated:YES completion:^(){
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
     //   [c release];
    }
    [Flurry logEvent:@"Login entered"];

}
-(void)viewDidAppear:(BOOL)animated{
  //    [self dismissViewControllerAnimated:NO completion:nil];
}
-(void)goToNext{
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.PortraitOrientation=YES;

    UITabBarController *tabBarController=[[UITabBarController alloc]init];
    _library=[[LibraryViewController alloc]initWithNibName:@"LibraryViewController" bundle:nil];
    _store=[[StoreViewController alloc]initWithNibName:@"StoreViewController" bundle:nil];
    _store.delegate=_library;
    
    _liveViewController=[[LiveViewController alloc]initWithNibName:@"LiveViewController" bundle:nil];
    UINavigationController *navigation=[[UINavigationController alloc]initWithRootViewController:_library];
    UINavigationController *navigationPurchase=[[UINavigationController alloc]initWithRootViewController:_store];
    UINavigationController *navigationStore=[[UINavigationController alloc]initWithRootViewController:_liveViewController];
    tabBarController.viewControllers=@[navigation ,navigationPurchase,navigationStore];

    [self.navigationController pushViewController:tabBarController animated:YES];
}
-(void)insertInStore{
  //  _liveViewController performSelectorInBackground:@selector() withObject:<#(id)#>
    [_liveViewController performSelectorInBackground:@selector(requestBooksWithoutUIChange) withObject:nil];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
  
    
    [self.navigationController.navigationBar setHidden:YES];
    _password.secureTextEntry=YES;
   NSString *ver= [UIDevice currentDevice].systemVersion;
    if ([ver floatValue]<6.0) {
        [_facebookButton removeFromSuperview];
        [_orImage removeFromSuperview];
    }
    [self goToNext];
    [_AboutUs addTarget:self action:@selector(popUpThenURL:) forControlEvents:UIControlEventTouchUpInside];
    
}
-(void)transactionFailed{
    [_liveViewController transactionFailed];
    
}
-(void)restoreFailed{
    [_store transactionFailed];
}
-(void)transactionRestored{
    [_store transactionRestore];
    
}
-(void)transactionPurchaseValidation:(SKPaymentTransaction *)transaction{
    [_liveViewController purchaseValidation:transaction];
    
}
-(void)liveViewControllerDismiss{
    [_liveViewController dismissViewControllerAnimated:YES completion:nil];
}
-(void)refreshDownloads{
    [_store BuildButtons];
}
-(BOOL)downloadBook:(Book *)book{
    BOOL didCall;
    if (_library) {
          [_library DownloadComplete:book];
        didCall=YES;
    }else{
        didCall=NO;
    }
    return didCall;
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    [Flurry logEvent:@"Login exited"];

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
 //   [alertView release];

}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [_data setLength:0];
  
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    NSDictionary *diction=[NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingAllowFragments error:nil];
   
    [_alertView dismissWithClickedButtonIndex:0 animated:YES];
    NSString *temp=diction[@"user"];
    NSString *str=[[NSString alloc]initWithData:_data encoding:NSUTF8StringEncoding];
    NSLog(@"user %@",str);
   // [str release];
    if (temp) {
        NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
        NSString *temp=diction[@"auth_token"];
        diction=diction[@"user"];
        NSNumber *number=diction[@"id"];
        NSLog(@"id %@",number);
        [userDefault setObject:diction[@"id"] forKey:@"id"];
        [userDefault setObject:temp forKey:@"auth_token"];
        [userDefault setObject:_userName.text forKey:@"email"];
        [userDefault setObject:_password.text forKey:@"password"];
            UITabBarController *tabBarController=[[UITabBarController alloc]init];
            LibraryViewController *library=[[LibraryViewController alloc]initWithNibName:@"LibraryViewController" bundle:nil];
            StoreViewController *store=[[StoreViewController alloc]initWithNibName:@"StoreViewController" bundle:nil];
            store.delegate=library;
            UINavigationController *navigation=[[UINavigationController alloc]initWithRootViewController:library];
        UINavigationController *navigationPurchase=[[UINavigationController alloc]initWithRootViewController:store];
         LiveViewController *liveViewController=[[LiveViewController alloc]initWithNibName:@"LiveViewController" bundle:nil];
        //    [library release];
        UINavigationController *navigationStore=[[UINavigationController alloc]initWithRootViewController:liveViewController];
        //[liveViewController release];
            tabBarController.viewControllers=@[navigation ,navigationPurchase,navigationStore];
       // [navigationStore release];
       // [navigationPurchase release];
       //     [navigation release];
       //     [store release];
            [self.navigationController pushViewController:tabBarController animated:YES];
           // [tabBarController release];
    }else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Either username or password is invalid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
       // [alertView release];
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_data appendData:data];
}
- (IBAction)Check:(id)sender {

    NSString *loginURL=[[NSUserDefaults standardUserDefaults] objectForKey:@"baseurl"];
   // loginURL=@"http://192.168.2.29:3000/api/v1/";
    loginURL=[loginURL stringByAppendingFormat:@"users/sign_in?user[email]=%@&user[password]=%@",_userName.text,_password.text];
    NSLog(@"login url %@",loginURL);
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:loginURL]];
    [request setHTTPMethod:@"GET"];
    _connection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
   // [_connection autorelease];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    _alertView =[[UIAlertView alloc]init];
//    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(139.0f-18.0f, 40.0f, 37.0f, 37.0f)];
//    [indicator startAnimating];
//    [_alertView addSubview:indicator];
//    [indicator release];
//    [_alertView setTitle:@"Loading...."];
    
    UIImage *image=[UIImage imageNamed:@"loading.png"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-40, -160, 391, 320)];
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;
    
    imageView.image=image;
    [_alertView addSubview:imageView];
  //  [imageView release];
    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(125, 25, 66.0f, 66.0f)];
    indicator.color=[UIColor blackColor];
    [indicator startAnimating];
    [_alertView addSubview:indicator];
  //  [indicator release];
    [_alertView show];
   // [_alertView release];

}
/*- (void)dealloc {
    [_userName release];
    [_password release];
    [_ForgotPassword release];
    [_signUp release];
    [_AboutUs release];
    [_videoView release];
  //  [_webView release];
    [_facebookButton release];
    [_orImage release];
    [super dealloc];
}*/
- (void)viewDidUnload {
    [self setUserName:nil];
    [self setPassword:nil];
    [self setForgotPassword:nil];
    [self setSignUp:nil];
    [self setAboutUs:nil];
    [self setVideoView:nil];
  //  [self setWebView:nil];
    [self setFacebookButton:nil];
    [self setOrImage:nil];
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
       // [mail release];
    }
        
}
//- (NSUInteger)supportedInterfaceOrientations {
//    
//    return UIInterfaceOrientationMaskAll;
//    
//}

//- (BOOL)shouldAutorotate {
//    
//    return YES;
//}

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
  //  [alert release];
}
- (IBAction)forgotPassword:(id)sender {
    NSURL *url=nil;
    WebViewController *webView;
    url=[NSURL URLWithString:@"http://www.mangoreader.com/users/password/new"];
    webView=[[WebViewController alloc]initWithNibName:@"WebViewController" bundle:nil URL:url];
    webView.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:webView animated:YES completion:nil ];
   // [webView release];
}

- (IBAction)signUp:(id)sender {
//    NSURL *url=nil;
//    WebViewController *webView;
//
//    url=[NSURL URLWithString:@"http://www.mangoreader.com/users/signup"];
//    webView=[[WebViewController alloc]initWithNibName:@"WebViewController" bundle:nil URL:url];
//    webView.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
//     [self presentViewController:webView animated:YES completion:nil ];
//    [webView release];
    SignUpViewController *signUp=[[SignUpViewController alloc]initWithNibName:@"SignUpViewController" bundle:nil with:self];
    signUp.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:signUp animated:YES completion:nil];
  //  [signUp release];
}
- (IBAction)showVideo:(id)sender {
     WebViewController *webView;
    NSURL *url=[NSURL URLWithString:@"http://www.youtube.com/embed/CyXxt0WSLWE"];
    webView =[[WebViewController alloc]initWithNibName:@"WebViewController" bundle:nil URL:url];
    webView.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:webView animated:YES completion:nil];
   // [webView release];
    
}
-(void)facebookRequest{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    
    [dictionary setObject:[userDefaults objectForKey:@"FacebookUsername"]  forKey:@"email"];
    
    [dictionary setObject:[userDefaults objectForKey:@"FullName"] forKey:@"name"];
    
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonValue=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"json String %@",jsonValue);
    NSString *connectionString=[userDefaults objectForKey:@"baseurl"];
    connectionString =[connectionString stringByAppendingString:@"facebookapplogin.json"];
    connectionString=[connectionString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Connection String %@",connectionString);
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:connectionString ]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
  
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    FacebookLogin *facebook=[[FacebookLogin alloc]initWithloginViewController:self];
    NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:facebook startImmediately:YES];
 //   [facebook release];
    [connection start];
   // [request release];
   // [connection autorelease];
   // [dictionary release];
}
- (IBAction)facebookLogin:(id)sender {
                _alertView =[[UIAlertView alloc]init];
//                UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(139.0f-18.0f, 40.0f, 37.0f, 37.0f)];
//                [indicator startAnimating];
//                [_alertView addSubview:indicator];
//                [indicator autorelease];
//                [_alertView setTitle:@"Loading...."];
    UIImage *image=[UIImage imageNamed:@"loading.png"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-40, -160, 391, 320)];
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;
    
    imageView.image=image;
    [_alertView addSubview:imageView];
 //   [imageView release];
    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(125, 25, 66.0f, 66.0f)];
    indicator.color=[UIColor blackColor];
    [indicator startAnimating];
    [_alertView addSubview:indicator];
  //  [indicator release];
    [_alertView show];
  //  [_alertView release];
    ACAccountStore *accountStore=[[ACAccountStore alloc]init];
    
    ACAccountType *facebookAccountType=[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary *options=@{@"ACFacebookAppIdKey" : @"199743376733034",@"ACFacebookPermissionsKey":@[@"email",@"user_about_me"]};
    [accountStore requestAccessToAccountsWithType:facebookAccountType options:options completion:^(BOOL granted,NSError *e){
        if (e) {
           [ self performSelectorOnMainThread:@selector(facebookError) withObject:nil waitUntilDone:NO];
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
                
                [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"name"] forKey:@"FullName"];
                [self performSelectorOnMainThread:@selector(facebookRequest) withObject:nil waitUntilDone:NO];
                
            }];
        }else{
            [_alertView dismissWithClickedButtonIndex:0 animated:YES];
        }
        
    }];

}
-(void)facebookError{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter facebook credentials in system preferences" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
  //  [alert release];
    [_alertView dismissWithClickedButtonIndex:0 animated:YES];
}
- (IBAction)skipLogin:(id)sender {
    [self goToNext];
}
@end
