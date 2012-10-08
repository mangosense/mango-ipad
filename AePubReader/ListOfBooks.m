//
//  ListOfBooks.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 01/10/12.
//
//

#import "ListOfBooks.h"

@implementation ListOfBooks
-(id)initWithViewController:(StoreViewController *)store{
    self=[super init];
    if (self) {
        _store=store;
        _dataMutable=[[NSMutableData alloc]init];
    }
    return self;
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"%@",error);
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [_store.navigationItem.rightBarButtonItem setEnabled:YES];
    [alert show];
    [alert release];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [_dataMutable setLength:0];
    
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{

        NSString *stringJsonData=[[NSString alloc]initWithData:_dataMutable encoding:NSUTF8StringEncoding];
        NSLog(@"String %@",stringJsonData);
       [stringJsonData release];
   [_store.navigationItem.rightBarButtonItem setEnabled:YES];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.dataModel insertIfNew:_dataMutable];
    //[_store.delegate DownloadComplete];
    
    [_store BuildButtons];
    
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_dataMutable appendData:data];
}
-(void)dealloc{
    [_dataMutable release];
    [super dealloc];
}
@end
