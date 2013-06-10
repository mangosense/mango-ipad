//
//  RecieptValidationIphone.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 10/12/12.
//
//

#import "RecieptValidationIphone.h"

@implementation RecieptValidationIphone
-(id)initWithDetails:(DetailStoreViewController *)detail live:(LiveViewControllerIphone *)live identity:(NSInteger)indentity withTrans:(SKPaymentTransaction *)trans{
    self=[super init];
    if (self) {
        _transaction=trans;
        _dataMutable=[[NSMutableData alloc]init];
        _live=live;
        _detail=detail;
    }
    return self;
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    [_live.alertView dismissWithClickedButtonIndex:0 animated:YES];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [_dataMutable setLength:0];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_dataMutable appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSDictionary *dictionary=[NSJSONSerialization JSONObjectWithData:_dataMutable options:NSJSONReadingAllowFragments error:nil];
    NSString *value=[[NSString alloc]initWithData:_dataMutable encoding:NSUTF8StringEncoding];
    NSLog(@"data mutable %@",value );
   
    [_live.alertView dismissWithClickedButtonIndex:0 animated:YES];
    if (!_signIn) {
        
       NSNumber *status= dictionary[@"status"];
        if ([status integerValue]==0) {
            
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Purchase Successful" message:@"Do you want to download it now?" delegate:_live cancelButtonTitle:@"NO" otherButtonTitles: @"YES", nil];
            [alertView show];
            
            [[SKPaymentQueue defaultQueue]finishTransaction:_transaction];
            
        }else{
           
            
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Purchase failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            [[SKPaymentQueue defaultQueue]finishTransaction:_transaction];
        }

        
        return;
    }
     value= dictionary[@"message"];
    if ([value isEqualToString:@"purchase successful!"]) {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Purchase Successful" message:@"Do you want to download it now?" delegate:_live cancelButtonTitle:@"NO" otherButtonTitles: @"YES", nil];
        [alertView show];
        
        
    }else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Purchase failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];

         [_detail backButton:nil];
       
    }
    if (_transaction) {
        [[SKPaymentQueue defaultQueue]finishTransaction:_transaction];
    }
    

}

@end
