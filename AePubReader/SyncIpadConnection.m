//
//  SyncIpadConnection.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 20/12/12.
//
//

#import "SyncIpadConnection.h"
#import <Foundation/Foundation.h>

@implementation SyncIpadConnection
-(id)init{
    self=[super init];
    if (self) {
        
        _data=[[NSMutableData  alloc]init];
    }
    return  self;
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [_data setLength:0];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Problem with connection. Sync failed try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
  //  [alertView release];
    
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_data appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
//    ///Case Success:
//    {message: "purchase successful!"}
//    
//    Case Failure:
//    {message: "purchase unsuccessful!"}
//
    NSDictionary *dictionary=[NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingAllowFragments error:nil];
    NSString *valu=[[NSString alloc]initWithData:_data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",valu);
    NSString *value= [dictionary objectForKey:@"message"];  
    if ([value isEqualToString:@"purchase successful!"]) {
      //  [_store requestBooksFromServer];
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Message" message:@"Sync successful" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
      //  [alertView release];
    }else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Sync failed try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
      //  [alertView release];
        
    }
    //[valu release];
}
/*-(void)dealloc{
    [_data release];
    [super dealloc];
}*/
@end
