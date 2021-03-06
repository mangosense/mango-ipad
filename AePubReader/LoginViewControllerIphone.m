//
//  LoginViewControllerIphone.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 03/12/12.
//
//

#import "LoginViewControllerIphone.h"
#import "SignUpViewControllerIphone.h"
#import "MyBooksViewControlleriPhone.h"
#import "LiveViewControllerIphone.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "FacebookIphoneLogin.h"
#import <QuartzCore/QuartzCore.h>
#import "DownloadViewControlleriPhone.h"
#import "Flurry.h"
#import "RootViewController.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import "NewStoreControlleriPhone.h"
@interface LoginViewControllerIphone ()
@property(retain,nonatomic)DownloadViewControlleriPhone *downloadView;
@property(strong,nonatomic) LiveViewControllerIphone *liveController;
@property(retain,nonatomic) MyBooksViewControlleriPhone *myBook;
@end

@implementation LoginViewControllerIphone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _dataMutable=[[NSMutableData alloc]init];
        _fromSignUp=NO;
    }
    return self;
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [_dataMutable setLength:0];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_dataMutable appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSDictionary *diction=[NSJSONSerialization JSONObjectWithData:_dataMutable options:NSJSONReadingAllowFragments error:nil];
    
 //   [_alertView dismissWithClickedButtonIndex:0 animated:YES];
    [AePubReaderAppDelegate hideAlertView];
    NSString *temp=diction[@"user"];
    NSString *str=[[NSString alloc]initWithData:_dataMutable encoding:NSUTF8StringEncoding];
    NSLog(@"user %@",str);
    if (temp) {
        NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
        NSString *temp=diction[@"auth_token"];
        diction=diction[@"user"];
        NSNumber *number=diction[@"id"];
        NSLog(@"id %@",number);
        [userDefault setObject:diction[@"id"] forKey:@"id"];
        [userDefault setObject:temp forKey:@"auth_token"];
        [userDefault setObject:_email.text forKey:@"email"];
        [userDefault setObject:_password.text forKey:@"password"];
        
        [PFAnalytics trackEvent:EVENT_LOGIN_EMAIL dimensions:[NSDictionary dictionaryWithObjectsAndKeys:[userDefault objectForKey:@"email"], @"email", nil]];
        
        [self goToNext];
    
        
    }else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Either username or password is invalid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [Flurry logEvent:@"Login entered iphone "];
    if (_fromSignUp) {
        NSString *email=  [[NSUserDefaults standardUserDefaults]valueForKey:@"emailSignUp"];
        NSString *password=   [[NSUserDefaults standardUserDefaults]valueForKey:@"emailPassword"];
        _email.text=email;
        _password.text=password;
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"emailSignUp"];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"emailPassword"];
        
        _fromSignUp=NO;

    }
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.PortraitOrientation=NO;

    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        UIViewController *c=[[UIViewController alloc]init];
        c.view.backgroundColor=[UIColor clearColor];
        [self presentViewController:c animated:YES completion:^(){
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }

}
-(void)viewWillDisappear:(BOOL)animated{
   // [self viewWillDisappear:YES];
    [Flurry logEvent:@"Login exited iphone "];

}
- (IBAction)skipLogin:(id)sender {
    [self goToNext];
}

-(void)goToNext{
    UITabBarController *tabBarController=[[UITabBarController alloc]init];
    _myBook=[[MyBooksViewControlleriPhone alloc]initWithNibName:@"MyBooksViewControlleriPhone" bundle:nil];
    UINavigationController *navLib=[[UINavigationController alloc]initWithRootViewController:_myBook];
   
    _downloadView=[[DownloadViewControlleriPhone alloc]initWithNibName:@"DownloadViewControlleriPhone" bundle:nil];
    
    _downloadView.myBook=_myBook;
    _downloadView.hidesBottomBarWhenPushed=YES;
    _myBook.hidesBottomBarWhenPushed=YES;
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:_downloadView];
  //  _liveController=[[LiveViewControllerIphone alloc]initWithStyle:UITableViewStyleGrouped];
  
    
    _liveController.myBooks=_myBook;
    _liveController.downloadViewController=_downloadView;
    tabBarController.viewControllers=@[navLib,nav];//,navigationLive];
    tabBarController.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:tabBarController animated:YES];

    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.PortraitOrientation=YES;
    
}
-(void)LiveDismissPresentedController{
    [_liveController dismissViewControllerAnimated:YES completion:nil];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    switch (textField.tag) {
        case 1:
            [_password becomeFirstResponder];
            break;
        case 2:
            [self signIn:nil];
        default:
            break;
    }
    
        return YES;
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
 //   [_alertView dismissWithClickedButtonIndex:0 animated:YES];
    [AePubReaderAppDelegate hideAlertView];
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
//    [alertView release];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:YES];
    [_password setSecureTextEntry:YES];
    NSString *ver= [UIDevice currentDevice].systemVersion;
    if ([ver floatValue]<6.0) {
        [_faceBookId removeFromSuperview];
        [_orImage removeFromSuperview];
    }
//    if([UIDevice currentDevice].systemVersion.integerValue>=7)
//    {
//        // iOS 7 code here
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//    }
  //  self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern.png" ]];
     CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    if (screenHeight>500.0) {
        CGRect frame= _backgroundImage.frame;
        frame.size.height=screenRect.size.width-20;
        frame.size.width=screenHeight;
        UIImage *image=[UIImage imageNamed:@"backimageiphonen.png"];
        _backgroundImage.frame=frame;
        _backgroundImage.image=image;
      frame=  _email.frame;
        frame.origin.x+=60;
        _email.frame=frame;
        frame=_password.frame;
        frame.origin.x+=60;
        _password.frame=frame;
        frame= _signIn.frame;
        frame.origin.y+=15;
        frame.origin.x+=60;
        _signIn.frame=frame;
        frame=_signUp.frame;
        frame.origin.x+=60;
        frame.origin.y+=15;
        _signUp.frame=frame;
        frame=_orImage.frame;
        frame.origin.x+=20;
        _orImage.frame=frame;
        frame=_faceBookId.frame;
        frame.origin.x+=10;
        _faceBookId.frame=frame;
    }
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
   //                              ];
    if ([userDefault objectForKey:@"email"]&&[userDefault objectForKey:@"password"]) {
        
        [self goToNext];
    }else if(![userDefault boolForKey:@"help"]){
            NSArray *array=@[@"large_one.png",@"large_two.png",@"large_three.png",@"large_five.png",@"large_six.png"];
        RootViewController *rootViewController=[[RootViewController alloc]initWithNibName:@"PhoneContent" bundle:nil contentList:array] ;
        [self presentViewController:rootViewController animated:YES completion:nil];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"help"];

    }
    // Do any additional setup after loading the view from its nib.
    self.tabBarController.hidesBottomBarWhenPushed=YES;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)email:(id)sender {
}

- (void)viewDidUnload {
    [self setEmail:nil];
    [self setPassword:nil];
    [self setFaceBookId:nil];
    [self setOrImage:nil];
    [self setBackgroundImage:nil];
    [self setSignIn:nil];
    [self setSignUp:nil];
    [super viewDidUnload];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [AePubReaderAppDelegate adjustForIOS7:self.view];
}
- (IBAction)signUp:(id)sender {
    SignUpViewControllerIphone *signUp=[[SignUpViewControllerIphone alloc]initWithNibName:@"SignUpViewControllerIphone" bundle:nil];
    signUp.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
    signUp.loginViewControllerIphone=self;
    [self presentViewController:signUp animated:YES completion:nil];
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}
- (IBAction)signIn:(id)sender {
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]init];
    NSString *loginURL=[[NSUserDefaults standardUserDefaults] objectForKey:@"baseurl"];
    // loginURL=@"http://192.168.2.29:3000/api/v1/";
    loginURL=[loginURL stringByAppendingFormat:@"users/sign_in?user[email]=%@&user[password]=%@",_email.text,_password.text];
    NSURL *url=[NSURL URLWithString:loginURL];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
    [connection start];

  /*  _alertView =[[UIAlertView alloc]init];
    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(139.0f-18.0f, 40.0f, 37.0f, 37.0f)];
    [indicator startAnimating];
    [_alertView addSubview:indicator];
   // [indicator release];
    [_alertView setTitle:@"Loading...."];

 

    [_alertView show];*/
    [AePubReaderAppDelegate showAlertView];


}
-(void)dismissStoreViewController{
    [_liveController.presentedViewController dismissViewControllerAnimated:YES completion:nil];

}
-(void)liveDismissViewController{
    [_myBook dismissViewControllerAnimated:YES completion:nil];
}
-(void)downloadComplete:(NSInteger) identity{
    [_liveController.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    [_myBook downloadComplete:identity];
}
-(void)downloadViewControllerRefreshUI{
    [_downloadView getPurchasedDataFromDataBase];
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
    NSLog(@"Connection String %@",connectionString);
    
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:connectionString ]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
   
     [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
   
    FacebookIphoneLogin *facebook=[[FacebookIphoneLogin alloc]initWithloginViewController:self];
    NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:facebook startImmediately:YES];
    [connection start];


}
- (IBAction)faceBookLogin:(id)sender {

          /*      _alertView =[[UIAlertView alloc]init];
                UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(139.0f-18.0f, 40.0f, 37.0f, 37.0f)];
                [indicator startAnimating];
                [_alertView addSubview:indicator];
            //    [indicator autorelease];
                [_alertView setTitle:@"Loading...."];
               [_alertView show];*/
    [AePubReaderAppDelegate showAlertView];

    ACAccountStore *accountStore=[[ACAccountStore alloc]init];
  
    ACAccountType *facebookAccountType=[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary *options=@{@"ACFacebookAppIdKey" : @"199743376733034",@"ACFacebookPermissionsKey":@[@"email",@"user_about_me"]};

        [accountStore requestAccessToAccountsWithType:facebookAccountType options:options completion:^(BOOL granted,NSError *e){
            if (e) {
                _error=e;
                if ([e.domain hasPrefix:@"com.apple.account"]) {
                    [self performSelectorOnMainThread:@selector(errorFacebook) withObject:nil waitUntilDone:NO];
                    
                }
                else{
                    [self performSelectorOnMainThread:@selector(errorOther) withObject:nil waitUntilDone:NO];
                    //  [_error retain];
                }
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
                    NSLog(@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
                    NSLog(@"%@",dict[@"name"]);
                    if (!dict[@"name"]) {
                         [[NSUserDefaults standardUserDefaults] setObject:@"NA" forKey:@"FullName"];
                    }else{
                    [[NSUserDefaults standardUserDefaults] setObject:dict[@"name"] forKey:@"FullName"];
                    }
                    [self performSelectorOnMainThread:@selector(facebookRequest) withObject:nil waitUntilDone:NO];
                    
                }];
            }else{
               // [_alertView dismissWithClickedButtonIndex:0 animated:YES];
                [AePubReaderAppDelegate hideAlertView];
            }
            
        }];



  
}
-(void)errorOther{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[_error debugDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];

    //[_alertView dismissWithClickedButtonIndex:0 animated:YES];
    [AePubReaderAppDelegate hideAlertView];
}
-(void)errorFacebook{
    
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter facebook credentials in system preferences" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
   
    
    _error=nil;
  //  [_alertView dismissWithClickedButtonIndex:0 animated:YES];
    [AePubReaderAppDelegate hideAlertView];
}
-(void)transactionRestored{
    [_downloadView transactionRestored];
    
}
-(void)restoreFailed{
    [_downloadView transactionFailed];
}
-(void)transactionFailed{
    [_liveController transactionFailed];

}
-(void)purchaseValidation:(SKPaymentTransaction *)transaction{
    [_liveController purchaseValidation:transaction];
}
- (IBAction)dismissKeyboard:(id)sender {
    [_email resignFirstResponder];
    [_password resignFirstResponder];
}
@end
