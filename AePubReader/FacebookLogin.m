//
//  FacebookLogin.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 11/12/12.
//
//

#import "FacebookLogin.h"
#import <Parse/Parse.h>
#import "Constants.h"

@implementation FacebookLogin
-(id)initWithloginViewController:(LoginNewViewController *)login{
    self=[super init];
    if (self) {
        _data = [[NSMutableData alloc]init];
        _loginViewController = login;
    }
    return  self;
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"%@",error);
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [alert show];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_data appendData:data];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [_data setLength:0];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSDictionary *diction=[NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingAllowFragments error:nil];
    NSString *authToken=diction[@"auth_token"];
    [[NSUserDefaults standardUserDefaults] setObject:authToken forKey:@"auth_token"];
    NSString *email=diction[@"email"];
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"email"];
    [[NSUserDefaults standardUserDefaults] setObject:diction[@"id"] forKey:@"id"];

    [_loginViewController goToNext];
    
    NSMutableDictionary *facebookLoginEventDictionary = [[NSMutableDictionary alloc] init];
    [facebookLoginEventDictionary setObject:[diction objectForKey:@"email"] forKey:@"email"];
    [facebookLoginEventDictionary setObject:[NSString stringWithFormat:@"%d", [[diction objectForKey:@"id"] intValue]] forKey:@"id"];
    [PFAnalytics trackEvent:EVENT_LOGIN_FACEBOOK dimensions:facebookLoginEventDictionary];
    
}

/*-(void)dealloc{
    [_data release];
    [super dealloc];
}*/

@end
