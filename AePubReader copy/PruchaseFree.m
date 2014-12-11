//
//  PruchaseFree.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 19/11/12.
//
//

#import "PruchaseFree.h"
#import "AePubReaderAppDelegate.h"
#import "LibraryViewController.h"

@implementation PruchaseFree
-(id)initWithPop:(PopPurchaseViewController *)popPurchase LiveController:(LiveViewController *)liveViewController fileLink:(NSInteger)downloadLink{
    self=[super init];
    if (self) {
        _identity=downloadLink;
        _popPurchase=popPurchase;
        _liveViewController=liveViewController;
        _mutableData=[[NSMutableData alloc]init];
    }
    return self;
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
  //  [alertView release];
    [_liveViewController.alertView dismissWithClickedButtonIndex:0 animated:YES];
    [_popPurchase dismissViewControllerAnimated:YES completion:nil];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_mutableData appendData:data];
}
/*-(void)dealloc{
    _mutableData=nil;
    _downLoadLink=nil;
    [super dealloc];
   
}*/
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSDictionary *dictionary=[NSJSONSerialization JSONObjectWithData:_mutableData options:NSJSONReadingAllowFragments error:nil];
    NSString *value=[[NSString alloc]initWithData:_mutableData encoding:NSUTF8StringEncoding];
    NSLog(@"data mutable %@",value );
  //  [value autorelease];
    value= dictionary[@"message"];
    [_liveViewController.alertView dismissWithClickedButtonIndex:0 animated:YES];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    StoreBooks *books=[delegate.dataModel getBookById:@(_identity)];
    NSString *message=[NSString stringWithFormat:@"Do you wish to download the book titled %@ now?",books.title ];
    if ([value isEqualToString:@"purchase successful!"]) {
        
        // insert the value
     //   AlertViewDelegateInApp *alertViewDelegate=[[AlertViewDelegateInApp alloc] initWithPop:_popPurchase LiveController:_liveViewController fileLink:_identity];
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Purchase Successful" message:message delegate:_liveViewController cancelButtonTitle:@"NO" otherButtonTitles: @"YES", nil];
       // [alertViewDelegate autorelease];
        [alertView show];
   
    }else if([value isEqualToString:@"Already Purchased"]){

        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Already purchased" message:message delegate:_liveViewController cancelButtonTitle:@"NO" otherButtonTitles: @"YES", nil];
        // [alertViewDelegate autorelease];
        [alertView show];
    }else{
  UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Warning" message:message delegate:_liveViewController cancelButtonTitle:@"NO" otherButtonTitles: @"YES", nil];
          [alertView show];
    }
    
    /*
     
     {"message":"Purchase Successful!"}
     
     
     on failure :
     {"message":"Purchase Unsuccessful!"}*/
    //
    //
    //
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [_mutableData setLength:0];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
     NSLog(@"index %d",buttonIndex);//if it is yes
    // in both cases insert the book in the database;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSNumber *identity=@(_identity);
    StoreBooks *books=[delegate.dataModel getBookById:identity];
    
    

    
    [_popPurchase.parentViewController dismissViewControllerAnimated:YES completion:nil];
      
    if (buttonIndex==1) {// if yes is the case
        
     [delegate.dataModel insertBookWithYes:books];
        UINavigationController *nav=(UINavigationController *)(_liveViewController.tabBarController.viewControllers)[0];
        LibraryViewController *library=(LibraryViewController *)nav.topViewController;
        NSString *valu=[[NSString alloc]initWithFormat:@"%@.epub",identity ];
        Book *bookToDownload=[delegate.dataModel getBookOfId:valu];
      //  [valu release];
        if (!delegate.addControlEvents) {
            UIAlertView *down=[[UIAlertView alloc]initWithTitle:@"Downloading.." message:@"Cannot start downloading as previous download is not complete" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
            [down show];
        //    [down release];
        //    [identity release];
            return;
        }

        [library DownloadComplete:bookToDownload];
    }else{
        UINavigationController *nav=(UINavigationController *)(_liveViewController.tabBarController.viewControllers)[1];
        DownloadViewControlleriPad *storeViewController=(DownloadViewControlleriPad *)nav.topViewController;
 [storeViewController refreshButton:nil];
        
    }
    //[identity release];
//    if (buttonIndex==1) {
//        
//    }
//    else{
//        // if no then you can dismiss the purchase controller
//            }
    
    
}
@end
