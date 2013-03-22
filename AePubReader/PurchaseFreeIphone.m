//
//  PurchaseFreeIphone.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 10/12/12.
//
//

#import "PurchaseFreeIphone.h"

@implementation PurchaseFreeIphone
-(id)initWithDetails:(DetailStoreViewController *)detail live:(LiveViewControllerIphone *)live identity:(NSInteger)identity{
    self=[super init];
    if (self) {
        _live=live;
        _detail=detail;
        _identity=identity;
        _mutableData=[[NSMutableData alloc]init];
    }
    return  self;
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
  //  [alertView release];
    [_live.alertView dismissWithClickedButtonIndex:0 animated:YES];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_mutableData appendData:data];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [_mutableData setLength:0];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSDictionary *dictionary=[NSJSONSerialization JSONObjectWithData:_mutableData options:NSJSONReadingAllowFragments error:nil];
    NSString *value=[[NSString alloc]initWithData:_mutableData encoding:NSUTF8StringEncoding];
    NSLog(@"data mutable %@",value );
 //   [value autorelease];
    value= [dictionary objectForKey:@"message"];
    [_live.alertView dismissWithClickedButtonIndex:0 animated:YES];
    if ([value isEqualToString:@"purchase successful!"]) {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Purchase Successful" message:@"Do you want to download it now?" delegate:_live cancelButtonTitle:@"NO" otherButtonTitles: @"YES", nil];
        // [alertViewDelegate autorelease];
        [alertView show];
     //   [alertView release];
        
        
    }else if([value isEqualToString:@"Already Purchased"]){
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Already Purchased" message:@"Do you want to download it now?" delegate:_live cancelButtonTitle:@"NO" otherButtonTitles: @"YES", nil];
        // [alertViewDelegate autorelease];
        [alertView show];
    }
    
        else
    {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Could not register to user id" message:@"Do you want to download it now?" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
 //       [alertView release];
    }
}
/*-(void)dealloc{
    _mutableData=nil;
    [super dealloc];
}*/
@end
