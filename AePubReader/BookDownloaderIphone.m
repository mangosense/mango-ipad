//
//  BookDownloaderIphone.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 04/12/12.
//
//

#import "BookDownloaderIphone.h"
#import "DownloadViewController.h"
#define BYTE 1024
@implementation BookDownloaderIphone
-(id)initWithViewController:(MyBooksViewController *)store{
    self=[super init];
    if (self) {
        _myBookViewController=store;
        _data=[[NSMutableData alloc]init];
    }
    return self;
}
-(void)setBook:(Book *)book{
    
    _book=book;
    //[_book retain];
}
/*-(void)dealloc{
    _data=nil;
    _loc=nil;
    _progress=nil;
    _book=nil;
    [_handle release];
    [super dealloc];
}*/
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    //[error autorelease];
    
 //   [_handle release];
    [alert show];
  //  [alert release];
    [_progress removeFromSuperview];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    _book.downloaded=@NO;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.dataModel saveData:_book];
    [_myBookViewController.tableView reloadData];
    UINavigationController *nav=(_myBookViewController.tabBarController.viewControllers)[1];
    DownloadViewController *store=(DownloadViewController *)[nav topViewController];
    [[_myBookViewController.navigationItem.rightBarButtonItems objectAtIndex:0] setEnabled:YES];
    [store getPurchasedDataFromDataBase];
    //_myBookViewController.downloadFailed=YES;
    delegate.downloadBook=NO;
    [_myBookViewController.tabBarController setSelectedIndex:1];
    [[NSFileManager defaultManager]removeItemAtPath:_loc error:nil];


}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [_data setLength:0];
    _sizeLenght=0;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_data appendData:data];
    _sizeLenght+=data.length;
    somethinRemains=YES;
    
    if (_data.length>BYTE) {
        somethinRemains=NO;
        
        //        if(_sizeLenght>_value){
        //            NSError *error=[[NSError alloc]initWithDomain:@"Download file corrupt" code:400 userInfo:nil];
        //            [connection cancel];
        //            [self connection:connection didFailWithError:error];
        //            [error release];
        //            return;
        //        }
        if (!_handle) {
            
            _handle=[NSFileHandle fileHandleForUpdatingAtPath:_loc];
        }
        [_handle writeData:_data];
        NSDictionary *diction=[[NSFileManager defaultManager] attributesOfItemAtPath:_loc error:nil];
        
        float sizeLong=diction.fileSize;
        NSLog(@"downloaded %@ total %f",[NSNumber numberWithLong:_sizeLenght],_value);
        
        sizeLong=sizeLong/_value;
        [_progress setProgress:sizeLong animated:YES];
        
        // NSLog(@"size %@ MB url %@ ",[NSNumber numberWithFloat:sizeLong],connection.originalRequest.URL.absoluteString);
        _data=nil;
        _data=[[NSMutableData alloc]initWithLength:0];

    }
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    if (!_handle) {
        _handle=[NSFileHandle fileHandleForUpdatingAtPath:_loc];
    }
    if (somethinRemains) {
        [_handle writeData:_data];
    }
   // [_handle release];
    NSDictionary *diction=[[NSFileManager defaultManager] attributesOfItemAtPath:_loc error:nil];
    float sizeLong=diction.fileSize;
    NSLog(@"total %f over %f",_value,sizeLong);
    NSLog(@"total %f over %f",_value,sizeLong);
    NSURL *url=[[NSURL alloc]initFileURLWithPath:_loc];
    [url setResourceValue:[NSNumber numberWithBool: YES] forKey:NSURLIsExcludedFromBackupKey error:nil];
    _progress.progress=1.0;
    [_myBookViewController.tabBarController setSelectedIndex:0];

    [_progress removeFromSuperview];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *value=[[_loc lastPathComponent] stringByDeletingPathExtension];
    [delegate unzipAndSaveFile:_loc with:value.integerValue];
    
    delegate.location=[_loc stringByDeletingPathExtension];
    [delegate removeBackDirectory];
    [[NSFileManager defaultManager]removeItemAtPath:_loc error:nil];
    delegate.downloadBook=NO;
    [_progress setAlpha:0.0];

    [_myBookViewController.tableView reloadData];
}
@end
