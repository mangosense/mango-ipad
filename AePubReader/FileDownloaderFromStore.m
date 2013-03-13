//
//  FileDownloaderFromStore.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 21/11/12.
//
//

#import "FileDownloaderFromStore.h"

@implementation FileDownloaderFromStore
-(id)initWithLiveViewController:(LiveViewController *)liveViewController andWith:(PopPurchaseViewController *)PopPurchaseViewController{
    self=[super init];
    if (self) {
        _liveController=liveViewController;
        _popPurchaseController=PopPurchaseViewController;
    }
    return self;
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    [alertView release];
    [_popPurchaseController dismissViewControllerAnimated:YES completion:nil];

}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    [_mutableData appendData:data];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    _mutableData=nil;
    _mutableData=[[NSMutableData alloc]init];
    
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
}
@end
