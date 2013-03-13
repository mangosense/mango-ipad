//
//  FacebookIphoneLogin.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 11/12/12.
//
//

#import "FacebookIphoneLogin.h"

@implementation FacebookIphoneLogin
-(id)initWithloginViewController:(LoginViewControllerIphone *)login{
    self=[super init];
    if (self) {
        _data=[[NSMutableData alloc]init];
        _loginViewController=login;
    }
    return  self;
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"%@",error);
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];

    [alert show];
    [alert release];
      [_loginViewController.alertView dismissWithClickedButtonIndex:0 animated:YES];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_data appendData:data];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [_data setLength:0];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSDictionary *diction=[NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingAllowFragments error:nil];
    NSString *authToken=[diction objectForKey:@"auth_token"];
    [[NSUserDefaults standardUserDefaults] setObject:authToken forKey:@"auth_token"];
    NSString *email=[diction objectForKey:@"email"];
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"email"];
    [[NSUserDefaults standardUserDefaults] setObject:diction[@"id"] forKey:@"id"];
//    [userDefault setObject:diction[@"id"] forKey:@"id"];
//    [userDefault setObject:temp forKey:@"auth_token"];
//    [userDefault setObject:_email.text forKey:@"email"];
//    [userDefault setObject:_password.text forKey:@"password"];
    [_loginViewController.alertView dismissWithClickedButtonIndex:0 animated:YES];
    [_loginViewController goToNext];
    
}
-(void)dealloc{
    NSLog(@"dealloc in facebookLogin");
    [_data release];
    [super dealloc];
}
@end
