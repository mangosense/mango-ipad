//
//  LoginViewControllerIphone.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 03/12/12.
//
//

#import "LoginViewControllerIphone.h"
#import "SignUpViewControllerIphone.h"
#import "MyBooksViewController.h"
#import "LiveViewControllerIphone.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "FacebookIphoneLogin.h"
#import <QuartzCore/QuartzCore.h>
#import "DownloadViewController.h"
#import "Flurry.h"
@interface LoginViewControllerIphone ()
@property(retain,nonatomic)DownloadViewController *downloadView;
@property(strong,nonatomic) LiveViewControllerIphone *liveController;
@property(retain,nonatomic) MyBooksViewController *myBook;

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
    
    [_alertView dismissWithClickedButtonIndex:0 animated:YES];
   
    NSString *temp=diction[@"user"];
    NSString *str=[[NSString alloc]initWithData:_dataMutable encoding:NSUTF8StringEncoding];
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
        [userDefault setObject:_email.text forKey:@"email"];
        [userDefault setObject:_password.text forKey:@"password"];
        [self goToNext];
    
        
    }else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Either username or password is invalid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        //[alertView release];
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
     //   [c release];
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
    _myBook=[[MyBooksViewController alloc]initWithStyle:UITableViewStyleGrouped];
    UINavigationController *navLib=[[UINavigationController alloc]initWithRootViewController:_myBook];
   
    _downloadView=[[DownloadViewController alloc]initWithStyle:UITableViewStyleGrouped];
    _downloadView.myBook=_myBook;
 //    [myBook release];
    
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:_downloadView];
  //  [downloadView release];
    _liveController=[[LiveViewControllerIphone alloc]initWithStyle:UITableViewStyleGrouped];
    UINavigationController *navigationLive=[[UINavigationController alloc]initWithRootViewController:_liveController];
    _liveController.myBooks=_myBook;
    _liveController.downloadViewController=_downloadView;
    tabBarController.viewControllers=@[navLib,nav,navigationLive];
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
    [_alertView dismissWithClickedButtonIndex:0 animated:YES];
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
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)email:(id)sender {
}
/*- (void)dealloc {
    _error=nil;
    [_email release];
    [_password release];
    [_faceBookId release];
    _alertView=nil;
    [_orImage release];
    [_backgroundImage release];
    [_signIn release];
    [_signUp release];
    [super dealloc];
}*/
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
- (IBAction)signUp:(id)sender {
    SignUpViewControllerIphone *signUp=[[SignUpViewControllerIphone alloc]initWithNibName:@"SignUpViewControllerIphone" bundle:nil];
    signUp.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
    signUp.loginViewControllerIphone=self;
    [self presentViewController:signUp animated:YES completion:nil];
   // [signUp release];
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
  //  [request release];
  //  [connection autorelease];
    _alertView =[[UIAlertView alloc]init];
    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(139.0f-18.0f, 40.0f, 37.0f, 37.0f)];
    [indicator startAnimating];
    [_alertView addSubview:indicator];
   // [indicator release];
    [_alertView setTitle:@"Loading...."];
//    UIImage *image=[UIImage imageNamed:@"loading.png"];
//    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-40, -160, 391, 320)];
//    
//    
//    imageView.image=image;
//    [_alertView addSubview:imageView];
//    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(125, 25, 66.0f, 66.0f)];
//    indicator.color=[UIColor blackColor];
//    [indicator startAnimating];
//    [_alertView addSubview:indicator];
//    [indicator release];
    
 

    [_alertView show];


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
    
    [dictionary setObject:[userDefaults objectForKey:@"FacebookUsername"]  forKey:@"email"];
  
    [dictionary setObject:[userDefaults objectForKey:@"FullName"] forKey:@"name"];
  
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonValue=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"json String %@",jsonValue);
    NSString *connectionString=[userDefaults objectForKey:@"baseurl"];
    connectionString =[connectionString stringByAppendingString:@"facebookapplogin.json"];
   // connectionString=[connectionString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Connection String %@",connectionString);
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:connectionString ]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
   
     [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
   
    FacebookIphoneLogin *facebook=[[FacebookIphoneLogin alloc]initWithloginViewController:self];
    NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:facebook startImmediately:YES];
   // [facebook release];
    [connection start];
    //[request release];
    //[connection autorelease];
    //[dictionary release];
    //[jsonValue autorelease];

}
- (IBAction)faceBookLogin:(id)sender {
//    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"FullName"]) {
//        [self facebookRequest];
//        return;
//    }
                _alertView =[[UIAlertView alloc]init];
                UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(139.0f-18.0f, 40.0f, 37.0f, 37.0f)];
                [indicator startAnimating];
                [_alertView addSubview:indicator];
            //    [indicator autorelease];
                [_alertView setTitle:@"Loading...."];
               [_alertView show];
  //  UIImage *image=[UIImage imageNamed:@"loading.png"];
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-40, -160, 391, 320)];
    
    
//    imageView.image=image;
//    [_alertView addSubview:imageView];
//    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(125, 25, 66.0f, 66.0f)];
//    indicator.color=[UIColor blackColor];
//    [indicator startAnimating];
//    [_alertView addSubview:indicator];
//    [indicator release];

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
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"name"] forKey:@"FullName"];
                    [self performSelectorOnMainThread:@selector(facebookRequest) withObject:nil waitUntilDone:NO];
                    
                }];
            }else{
                [_alertView dismissWithClickedButtonIndex:0 animated:YES];
            }
            
        }];



  
}
-(void)errorOther{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[_error debugDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
   // [alert release];
   // [_error release];
    [_alertView dismissWithClickedButtonIndex:0 animated:YES];
    
}
-(void)errorFacebook{
    
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter facebook credentials in system preferences" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
               // [alert release];
   
    
    _error=nil;
    [_alertView dismissWithClickedButtonIndex:0 animated:YES];

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
