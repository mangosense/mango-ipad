//
//  ListOfPurchasedBooks.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 04/12/12.
//
//

#import "ListOfPurchasedBooks.h"
#import "AePubReaderAppDelegate.h"
#import "LoginDirectly.h"
@implementation ListOfPurchasedBooks
-(id)initWithViewController:(DownloadViewController *)store{
     self=[super init];
    if (self) {
        _store=store;
        _dataMutable=[[NSMutableData alloc]init];
    }
    return self;
}-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"%@",error);
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [_store.navigationItem.rightBarButtonItem setEnabled:YES];
  //  [_store BuildButtons];
    [alert show];
    [alert release];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [_dataMutable setLength:0];
    
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    NSString *stringJsonData=[[NSString alloc]initWithData:_dataMutable encoding:NSUTF8StringEncoding];
    NSLog(@"String %@",stringJsonData);
   
    id dict=[NSJSONSerialization JSONObjectWithData:_dataMutable options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"dict %@",[dict class]);
    if ([[dict class] isSubclassOfClass:[NSArray class]]) {
        NSLog(@"arry ");
    }
    else if ([dict objectForKey:@"error"]) {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Session invalid" message:@"The session is invalid. Please signout and sign in again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
        [stringJsonData release];
        return;
    }
    [_store.navigationItem.rightBarButtonItem setEnabled:YES];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    [_store.alert dismissWithClickedButtonIndex:0 animated:YES];
    
    //[_store.delegate DownloadComplete];
  //  id jsonObject=[NSJSONSerialization JSONObjectWithData:_dataMutable options:NSJSONReadingAllowFragments error:nil];
    
//    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
//        NSLog(@"invalid token");
//        
//        LoginDirectly *directly=[[LoginDirectly alloc]init];
//        NSString *loginURL=[[NSUserDefaults standardUserDefaults] objectForKey:@"baseurl"];
//        NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
//        loginURL=[loginURL stringByAppendingFormat:@"users/sign_in?user[email]=%@&user[password]=%@",[userDefault objectForKey:@"email"],[userDefault objectForKey:@"password"]];
//        NSLog(@"loginurl %@",loginURL);
//        NSURL *url=[[NSURL alloc]initWithString:loginURL];
//        NSURLRequest *request=[[NSURLRequest alloc]initWithURL:url];
//        [url release];
//        
//        directly.storeController=_store;
//        NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:directly];
//        [directly release];
//        [request release];
//        [connection autorelease];
//        return;
//    }
    
    [delegate.dataModel insertIfNew:_dataMutable];
    [_store getPurchasedDataFromDataBase];
//    if (_shouldBuild) {
//        [_store BuildButtons];
//    }else{
//        
//    }
    
     [stringJsonData release];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_dataMutable appendData:data];
}
-(void)dealloc{
    [_dataMutable release];
    [super dealloc];
}
@end