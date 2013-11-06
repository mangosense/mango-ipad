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
#import "RootViewController.h"
#import "EditorViewController.h"
#import "StoriesViewController.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import "TimeRange.h"
#import "NewStoreCoverViewController.h"
#import "NewStoreViewControlleriPad.h"
@interface LoginViewController ()
@property(strong,nonatomic)StoreViewController *store;
@property(strong,nonatomic)LiveViewController *liveViewController;
@property(nonatomic,strong)LibraryViewController *library;
@property (nonatomic, strong) EditorViewController *editorViewController;
@property (nonatomic, strong) StoriesViewController *storiesViewController;
@property (nonatomic, strong) NSDate *currentTime;
//@property(nonatomic,strong)NewStoreCoverViewController *storeNewViewController;
@property(nonatomic,strong) NewStoreViewControlleriPad *storeViewControlleriPad;
@end

@implementation LoginViewController

@synthesize editorViewController;
@synthesize storiesViewController;
@synthesize currentTime;

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
    [super viewWillAppear:animated];
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
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)&&![[NSUserDefaults standardUserDefaults]objectForKey:@"email"]) {
        UIViewController *c=[[UIViewController alloc]init];
        c.view.backgroundColor=[UIColor clearColor];
        [self presentViewController:c animated:YES completion:^(){
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    [Flurry logEvent:@"Login entered"];
    
    currentTime = [NSDate date];

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
-(void)goToNext{
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.PortraitOrientation=NO;

    _tabBarController=[[UITabBarController alloc]init];
    _library=[[LibraryViewController alloc]initWithNibName:@"LibraryViewController" bundle:nil];
    _store=[[StoreViewController alloc]initWithNibName:@"StoreViewController" bundle:nil];
    _store.delegate=_library;
    _liveViewController=[[LiveViewController alloc]initWithNibName:@"LiveViewController" bundle:nil];
    editorViewController = [[EditorViewController alloc] initWithNibName:@"EditorViewController" bundle:nil];
    storiesViewController = [[StoriesViewController alloc] initWithNibName:@"StoriesViewController" bundle:nil];
   // _storeNewViewController=[[NewStoreCoverViewController alloc]initWithNibName:@"NewStoreCoverViewController" bundle:nil];
    _storeViewControlleriPad=[[NewStoreViewControlleriPad alloc]initWithStyle:UITableViewStylePlain];
    UINavigationController *navigation=[[UINavigationController alloc]initWithRootViewController:_library];
    UINavigationController *navigationPurchase=[[UINavigationController alloc]initWithRootViewController:_store];
  /*  iCarouselExampleViewController *controller=[[iCarouselExampleViewController alloc]initWithNibName:@"iCarouselExampleViewController" bundle:nil];*/
    NewStoreCoverViewController *controller=[[NewStoreCoverViewController alloc]initWithNibName:@"NewStoreCoverViewController" bundle:nil];
    UINavigationController *navigationStore=[[UINavigationController alloc]initWithRootViewController:controller];
   /* UINavigationController *editorNavigationController = [[UINavigationController alloc] initWithRootViewController:editorViewController];*/
    
    UINavigationController *storiesNavigationController = [[UINavigationController alloc] initWithRootViewController:storiesViewController];
    
    _tabBarController.viewControllers=@[storiesNavigationController, navigation, navigationPurchase, navigationStore];

    [self.navigationController pushViewController:_tabBarController animated:YES];
}
-(void)insertInStore{
    [_liveViewController performSelectorInBackground:@selector(requestBooksWithoutUIChange) withObject:nil];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
  
    currentTime = [NSDate date];
    
    [self.navigationController.navigationBar setHidden:YES];
    _password.secureTextEntry=YES;
   NSString *ver= [UIDevice currentDevice].systemVersion;
    if ([ver floatValue]<6.0) {
        [_facebookButton removeFromSuperview];
        [_orImage removeFromSuperview];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"email"]) {
        [self goToNext];

    }else if( ![[NSUserDefaults standardUserDefaults] boolForKey:@"help"]){
        NSArray *array=@[@"large_one.png",@"large_two.png",@"large_three.png", @"large_four.png",@"large_five.png",@"large_six.png"];
        RootViewController *rootViewController=[[RootViewController alloc]initWithNibName:@"padContent" bundle:nil contentList:array] ;
        [self presentViewController:rootViewController animated:YES completion:nil];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"help"];
    }
    [_AboutUs addTarget:self action:@selector(popUpThenURL:) forControlEvents:UIControlEventTouchUpInside];
    if([UIDevice currentDevice].systemVersion.integerValue>=7)
    {
        // iOS 7 code here
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }else{
      CGRect frame=  _topToolbar.frame;
        frame.origin.y=0;
        _topToolbar.frame=frame;
      frame=  _backgroundimage.frame;
        frame.origin.y=_topToolbar.frame.size.height+1;
        _backgroundimage.frame=frame;
    }

    
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
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

    NSDate *exitTime = [NSDate date];
    NSTimeInterval timeOnLoginPage = [exitTime timeIntervalSinceDate:currentTime];
    NSString *timeRange = [TimeRange getTimeRangeForTime:timeOnLoginPage];
    NSLog(@"%f", timeOnLoginPage);
    
    NSDictionary *timeOnPageDict = [NSDictionary dictionaryWithObjectsAndKeys:timeRange, PARAMETER_TIME_RANGE, VIEW_LOGIN, PARAMETER_VIEW_NAME, nil];
    [PFAnalytics trackEvent:EVENT_TIME_ON_VIEW dimensions:timeOnPageDict];

}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [controller dismissViewControllerAnimated:YES completion:^(void) {
        
    }];
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
   // [_alertView dismissWithClickedButtonIndex:0 animated:YES];
    [AePubReaderAppDelegate hideAlertView];
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
    [AePubReaderAppDelegate hideAlertView];
  //  [_alertView dismissWithClickedButtonIndex:0 animated:YES];
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
        UINavigationController *navigationStore=[[UINavigationController alloc]initWithRootViewController:liveViewController];
        
        /*EditorViewController *editorViewController = [[EditorViewController alloc] initWithNibName:@"EditorViewController" bundle:nil];
        UINavigationController *editorNavigationController = [[UINavigationController alloc] initWithRootViewController:editorViewController];*/
        
        storiesViewController = [[StoriesViewController alloc] initWithNibName:@"StoriesViewController" bundle:nil];
        UINavigationController *storiesNavigationController = [[UINavigationController alloc] initWithRootViewController:storiesViewController];

        tabBarController.viewControllers=@[storiesNavigationController, navigation , navigationPurchase, navigationStore];
        [self.navigationController pushViewController:tabBarController animated:YES];
        
        [PFAnalytics trackEvent:EVENT_LOGIN_EMAIL dimensions:[NSDictionary dictionaryWithObjectsAndKeys:[userDefault objectForKey:@"email"], @"email", nil]];
    }else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Either username or password is invalid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
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
    
 /*   _alertView =[[UIAlertView alloc]init];

    
    UIImage *image=[UIImage imageNamed:@"loading.png"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-40, -160, 391, 320)];
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;
    
    imageView.image=image;
    [_alertView addSubview:imageView];
    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(125, 25, 66.0f, 66.0f)];
    indicator.color=[UIColor blackColor];
    [indicator startAnimating];
    [_alertView addSubview:indicator];*/
    [AePubReaderAppDelegate showAlertViewiPad];


}

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




- (void)popUpThenURL:(UIButton *)sender {
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Mango Reader" message:@"MangoReader - we bring books to life by making them engaging and fun using videos, animation, quizzes, maps, graphics and interactivity. Publishers, Authors and Educators can reach new audiences using mobiles, tablets and online reader and generate more revenue. Readers get better books and a great learning experience and can collaborate with friends, take notes and use learning tools such as dictionary, search and quizzes. We are not only redefining books and publishing, but reinventing the way people learn." delegate:self cancelButtonTitle:@"Done" otherButtonTitles:@"Share", nil];
    CGRect frame=alert.frame;
    frame.size.height=frame.size.height+100;
    frame.size.width=frame.size.width+300;
    alert.frame=frame;

    [alert show];
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

    SignUpViewController *signUp=[[SignUpViewController alloc]initWithNibName:@"SignUpViewController" bundle:nil with:self];
    signUp.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:signUp animated:YES completion:nil];
    [Flurry logEvent:@"Goto to signUp"];
    
    [PFAnalytics trackEvent:EVENT_REDIRECT_TO_SIGNUP];
}
- (IBAction)showVideo:(id)sender {
     WebViewController *webView;
    NSURL *url=[NSURL URLWithString:@"http://www.youtube.com/embed/CyXxt0WSLWE"];
    webView =[[WebViewController alloc]initWithNibName:@"WebViewController" bundle:nil URL:url];
    webView.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
    
    [self presentViewController:webView animated:YES completion:nil];
    
    [PFAnalytics trackEvent:EVENT_VIDEO];
}
-(void)facebookRequest{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    
    dictionary[@"email"] = [userDefaults objectForKey:@"FacebookUsername"];
    
    dictionary[@"name"] = [userDefaults objectForKey:@"FullName"];
    
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
                        } else {
                          //  [_alertView dismissWithClickedButtonIndex:0 animated:YES];
                            [AePubReaderAppDelegate hideAlertView];
                        }
                    }];
                }else{
                    [[NSUserDefaults standardUserDefaults] setObject:dict[@"name"] forKey:@"FullName"];
                    [self performSelectorOnMainThread:@selector(facebookRequest) withObject:nil waitUntilDone:NO];
                }
            }];
            
        }else{
          //  [_alertView dismissWithClickedButtonIndex:0 animated:YES];
            [AePubReaderAppDelegate hideAlertView];
        }
        
    }];
}

- (IBAction)facebookLogin:(id)sender {
          /*      _alertView =[[UIAlertView alloc]init];

    UIImage *image=[UIImage imageNamed:@"loading.png"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-40, -160, 391, 320)];
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;
    
    imageView.image=image;
    [_alertView addSubview:imageView];
    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(125, 25, 66.0f, 66.0f)];
    indicator.color=[UIColor blackColor];
    [indicator startAnimating];
    [_alertView addSubview:indicator];
    [_alertView show];*/
    [AePubReaderAppDelegate showAlertViewiPad];
    
    [self getFacebookAccess];

}
-(void)facebookError{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter facebook credentials in system preferences" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
  //  [_alertView dismissWithClickedButtonIndex:0 animated:YES];
    [AePubReaderAppDelegate hideAlertView];
}
- (IBAction)skipLogin:(id)sender {
    [self goToNext];
    [PFAnalytics trackEvent:EVENT_SKIP_LOGIN];
}
@end
