//
//  BookDownloaderIphone.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 04/12/12.
//
//

#import "BookDownloaderIphone.h"
#import "DownloadViewController.h"
#import "Flurry.h"
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
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];

    [alert show];
    [_progress removeFromSuperview];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    _book.downloaded=@NO;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.dataModel saveData:_book];
    [_myBookViewController.tableView reloadData];
    UINavigationController *nav=(_myBookViewController.tabBarController.viewControllers)[1];
    DownloadViewController *store=(DownloadViewController *)[nav topViewController];
    [(_myBookViewController.navigationItem.rightBarButtonItems)[0] setEnabled:YES];
    [store getPurchasedDataFromDataBase];
    delegate.downloadBook=NO;
    [_myBookViewController.tabBarController setSelectedIndex:1];
    [[NSFileManager defaultManager]removeItemAtPath:_loc error:nil];
    NSString *flurry=@"Download failed";
    NSMutableDictionary *diction=[[NSMutableDictionary alloc]init];
    [diction setValue:_book.id forKey:@"identity"];
    [diction setValue:_book.title forKey:@"book title"];
    [Flurry logEvent:flurry withParameters:diction];

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
        

        if (!_handle) {
            
            _handle=[NSFileHandle fileHandleForUpdatingAtPath:_loc];
        }
        [_handle writeData:_data];
        NSDictionary *diction=[[NSFileManager defaultManager] attributesOfItemAtPath:_loc error:nil];
        
        float sizeLong=diction.fileSize;
        
        sizeLong=sizeLong/_value;
        [_progress setProgress:sizeLong animated:YES];
    
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
    NSDictionary *diction=[[NSFileManager defaultManager] attributesOfItemAtPath:_loc error:nil];
    float sizeLong=diction.fileSize;
    NSLog(@"total %f over %f",_value,sizeLong);
    NSLog(@"total %f over %f",_value,sizeLong);
    NSURL *url=[[NSURL alloc]initFileURLWithPath:_loc];
    [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:nil];
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
    NSString *flurry=@"Download sucessful";
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    [ dictionary setValue:_book.id forKey:@"Identity"];
    [dictionary setValue:_book.title forKey:@"Title"];
    [Flurry logEvent:flurry withParameters:dictionary];
}
@end
