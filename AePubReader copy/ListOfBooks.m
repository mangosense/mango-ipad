//
//  ListOfBooks.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 01/10/12.
//
//

#import "ListOfBooks.h"
#import "LoginDirectly.h"
@implementation ListOfBooks
-(id)initWithViewController:(DownloadViewControlleriPad *)store{
    self=[super init];
    if (self) {
        _store=store;
        _dataMutable=[[NSMutableData alloc]init];
        _shouldBuild=YES;
    }
    return self;
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"%@",error);
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [_store.navigationItem.rightBarButtonItem setEnabled:YES];
    [_store BuildButtons];
    [alert show];
    //[alert release];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [_dataMutable setLength:0];
    
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{

        NSString *stringJsonData=[[NSString alloc]initWithData:_dataMutable encoding:NSUTF8StringEncoding];
    NSLog(@"String %@",stringJsonData);
    //   [stringJsonData release];
   [_store.navigationItem.rightBarButtonItem setEnabled:YES];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    
    //[_store.delegate DownloadComplete];
id jsonObject=[NSJSONSerialization JSONObjectWithData:_dataMutable options:NSJSONReadingAllowFragments error:nil];
    
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        NSLog(@"invalid token");
        
        LoginDirectly *directly=[[LoginDirectly alloc]init];
        NSString *loginURL=[[NSUserDefaults standardUserDefaults] objectForKey:@"baseurl"];
        NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
        loginURL=[loginURL stringByAppendingFormat:@"users/sign_in?user[email]=%@&user[password]=%@",[userDefault objectForKey:@"email"],[userDefault objectForKey:@"password"]];
        NSLog(@"loginurl %@",loginURL);
        NSURL *url=[[NSURL alloc]initWithString:loginURL];
        NSURLRequest *request=[[NSURLRequest alloc]initWithURL:url];
      //  [url release];
        
        directly.storeController=_store;
        NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:directly];
        [connection start];
       // [directly release];
       // [request release];
        //[connection autorelease];
        return;
    }
    [delegate.dataModel insertIfNew:_dataMutable];
    
   
     [_store BuildButtons];   
            
    
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_dataMutable appendData:data];
}
/*-(void)dealloc{
    [_dataMutable release];
    [super dealloc];
}*/
@end
