//
//  LoginDirectly.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 15/10/12.
//
//

#import "LoginDirectly.h"

@implementation LoginDirectly
-(id)init{
   self= [super init];
    if (self) {
        _mutableData=[[NSMutableData alloc]init];
    }
    return self;
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    _alert =[[UIAlertView alloc]init];
    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(139.0f-18.0f, 40.0f, 37.0f, 37.0f)];
    [indicator startAnimating];
    [_alert addSubview:indicator];
    [indicator release];
    [_alert setTitle:@"Loading...."];
    [_alert show];
    [_mutableData setLength:0];

}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [_alert dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [_storeController.parentViewController.tabBarController setSelectedIndex:0];
    [alertView show];
    [alertView release];

}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_mutableData appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSDictionary *diction=[NSJSONSerialization JSONObjectWithData:_mutableData options:NSJSONReadingAllowFragments error:nil];
     [_alert dismissWithClickedButtonIndex:0 animated:YES];
     NSString *temp=diction[@"auth_token"];
    NSLog(@"diction %@",diction);
    if (temp) {
      
        NSLog(@"auth_token after invalid %@",temp);
        [[NSUserDefaults standardUserDefaults] setObject:temp forKey:@"auth_token"];
        //login is successful
        diction=diction[@"user"];
        [[NSUserDefaults standardUserDefaults]setObject:diction[@"id"] forKey:@"id"];
        [_storeController requestBooksFromServer];
      
         //  [_storeController.alert dismissWithClickedButtonIndex:0 animated:YES];
        return;
    }
   
    [_storeController.alert dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Either username or password is invalid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    [alertView release];
 [_storeController.parentViewController.navigationController popToRootViewControllerAnimated:YES];
    
    
}
-(void)dealloc{
    [_alert release];
    [super dealloc];
}

@end
