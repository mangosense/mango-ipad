//
//  FileDownloader.m
//  AePubReader
//
//  Created by Nikhil Dhavale on 27/09/12.
//
//

#import "FileDownloader.h"
#import "LibraryViewController.h"
#define BYTE 1024
@implementation FileDownloader
-(id)initWithViewController:(LibraryViewController *)store{
    self=[super init];
    if (self) {
        _libViewController=store;
        _data=[[NSMutableData alloc]init];
     
       
        
    }
    return self;
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    //[error autorelease];
    
    [_handle release];
    [alert show];
    [alert release];
    [_progress removeFromSuperview];
    _libViewController.addControlEvents=YES;
    _progress=nil;
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    _book.downloaded=@NO;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.dataModel saveData:_book];
    UINavigationController *nav=(_libViewController.tabBarController.viewControllers)[1];
    StoreViewController *store=(StoreViewController *)[nav topViewController];
    [[_libViewController.navigationItem.rightBarButtonItems objectAtIndex:0] setEnabled:YES];
    [store BuildButtons];
  _libViewController.downloadFailed=YES;
    
    [_libViewController.tabBarController setSelectedIndex:1];
    [[NSFileManager defaultManager]removeItemAtPath:_loc error:nil];
   // [_buttonindicator setTitle:@"" forState:UIControlStateNormal];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [_data setLength:0];
    _sizeLenght=0;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

    
    NSLog(@"url %@",[connection.originalRequest.URL absoluteString]);
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_data appendData:data];
    _sizeLenght+=data.length;
    somethinRemains=YES;
    
    if (_data.length>BYTE) {
        somethinRemains=NO;
              
        if(_sizeLenght>_value){
            NSError *error=[[NSError alloc]initWithDomain:@"Download file corrupt" code:400 userInfo:nil];
            [connection cancel];
            [self connection:connection didFailWithError:error];
            [error release];
            return;
        }
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
        //[data release];
    }
//    NSDictionary *diction=[[NSFileManager defaultManager] attributesOfItemAtPath:_loc error:nil];
//    long long size=diction.fileSize+_data.length;
//    size=size/1024.0;
//    size=size/1024.0;
  //  NSLog(@"Size %@",[NSNumber numberWithLongLong:size]);
    
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    if (!_handle) {
        _handle=[NSFileHandle fileHandleForUpdatingAtPath:_loc];
    }
    if (somethinRemains) {
        [_handle writeData:_data];
    }
    [_handle release];
    NSDictionary *diction=[[NSFileManager defaultManager] attributesOfItemAtPath:_loc error:nil];
    float sizeLong=diction.fileSize;
    NSLog(@"total %f over %f",_value,sizeLong);
    NSURL *url=[[NSURL alloc]initFileURLWithPath:_loc];
    [url setResourceValue:[NSNumber numberWithBool: YES] forKey:NSURLIsExcludedFromBackupKey error:nil];
    _progress.progress=1.0;
    [_progress setAlpha:0.0];
    [_libViewController.tabBarController setSelectedIndex:0];

    
[_progress removeFromSuperview];
    [_loc release];
    
    _libViewController.addControlEvents=YES;

     [[_libViewController.navigationItem.rightBarButtonItems objectAtIndex:0] setEnabled:YES];

}

-(void)defunct:(id)sender{
    
}
@end
