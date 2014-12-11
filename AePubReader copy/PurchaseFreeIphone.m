//
//  PurchaseFreeIphone.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 10/12/12.
//
//

#import "PurchaseFreeIphone.h"
#import "Flurry.h"
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
    [_live.alertView dismissWithClickedButtonIndex:0 animated:YES];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_mutableData appendData:data];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    [dictionary setValue:@(_identity) forKey:@"identity"];
    [Flurry logEvent:@"Book registered" withParameters:dictionary];
    [_mutableData setLength:0];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSDictionary *dictionary=[NSJSONSerialization JSONObjectWithData:_mutableData options:NSJSONReadingAllowFragments error:nil];
    NSString *value=[[NSString alloc]initWithData:_mutableData encoding:NSUTF8StringEncoding];
    NSLog(@"data mutable %@",value );
    value= dictionary[@"message"];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    StoreBooks *book=[delegate.dataModel getBookById:@(_identity)];
    
    NSString *message=[NSString stringWithFormat:@"Do you wish to download book titled %@ now?",book.title ];

    [_live.alertView dismissWithClickedButtonIndex:0 animated:YES];
    if ([value isEqualToString:@"purchase successful!"]) {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Purchase Successful" message:message delegate:_live cancelButtonTitle:@"NO" otherButtonTitles: @"YES", nil];
        [alertView show];
        
        
    }else if([value isEqualToString:@"Already Purchased"]){

        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Already Purchased" message:message delegate:_live cancelButtonTitle:@"NO" otherButtonTitles: @"YES", nil];
        [alertView show];
    }
    
        else
    {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Could not register to user id" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

@end
