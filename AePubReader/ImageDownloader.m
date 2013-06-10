//
//  ImageDownloader.m
//  MangoReader
//
//  Created by Nikhil D on 16/10/12.
//
//

#import "ImageDownloader.h"

@implementation ImageDownloader
-(id)init{
    self=[super init];
    if (self) {
        _dataMutable=[[NSMutableData alloc]init];
    }
    return self;
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_dataMutable appendData:data];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [_dataMutable setLength:0];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
   // NSLog(@"LocalLocation %@",_localImageLocation);
    NSFileManager *manager=[NSFileManager defaultManager];
    if ([manager fileExistsAtPath:_localImageLocation ]) {
        [manager removeItemAtPath:_localImageLocation error:nil];
    }
    [manager createFileAtPath:_localImageLocation contents:nil attributes:nil];

    [NSFileHandle fileHandleForWritingAtPath:_localImageLocation];
    
}
/*-(void)dealloc{
    _dataMutable=nil;
    _localImageLocation=nil;
    [super dealloc];
}*/
@end
