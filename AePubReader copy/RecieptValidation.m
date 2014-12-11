//
//  RecieptValidation.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 17/11/12.
//
//

#import "RecieptValidation.h"
#import "StoreBooks.h"
#import "AePubReaderAppDelegate.h"
#import "DataModelControl.h"

@implementation RecieptValidation
-(id)initWithPop:(PopPurchaseViewController *)popPurchase LiveController:(LiveViewController *)liveViewController fileLink:(NSInteger)downloadLink transaction:(SKPaymentTransaction *)trans{ 
    self=[super init];
    if (self) {
        _identity=downloadLink;
        _popPurchase=popPurchase;
        _liveViewController=liveViewController;
        _transaction=trans;
        _mutableData=[[NSMutableData alloc]init];
    }
    return self;
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{

    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
   // [alertView release];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_mutableData appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (!_signedIn) {
        NSDictionary *dictionary=[NSJSONSerialization JSONObjectWithData:_mutableData options:NSJSONReadingAllowFragments error:nil];
        
        NSNumber *value= dictionary[@"status"];
        if (_popPurchase) {
            [_popPurchase.purchaseButton setEnabled:YES];
            if (_popPurchase.alertView) {
                [_popPurchase.alertView dismissWithClickedButtonIndex:0 animated:YES];
            }
        }
        if ([value integerValue]==0) {
     
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Purchase Successful" message:@"Do you want to download it now?" delegate:_liveViewController cancelButtonTitle:@"NO" otherButtonTitles: @"YES", nil];
            [alertView show];
         //   [alertView release];
            
            [[SKPaymentQueue defaultQueue]finishTransaction:_transaction];

        }else{
            if (_popPurchase) {
                [_popPurchase.purchaseButton setEnabled:YES];
                if (_popPurchase.alertView) {
                    [_popPurchase.alertView dismissWithClickedButtonIndex:0 animated:YES];
                }
            }
            
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Purchase failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
           // [alertView release];
            [[SKPaymentQueue defaultQueue]finishTransaction:_transaction];
        }
        return;
    }
    NSDictionary *dictionary=[NSJSONSerialization JSONObjectWithData:_mutableData options:NSJSONReadingAllowFragments error:nil];
   NSString *value= dictionary[@"message"];
    
    if ([value isEqualToString:@"purchase successful!"]) {

        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Purchase Successful" message:@"Do you want to download it now?" delegate:_liveViewController cancelButtonTitle:@"NO" otherButtonTitles: @"YES", nil];
        [alertView show];
      //  [alertView release];
       
        [[SKPaymentQueue defaultQueue]finishTransaction:_transaction];

    }else{
        if (_popPurchase) {
             [_popPurchase.purchaseButton setEnabled:YES];
        }
       
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Purchase failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
      //  [alertView release];
         [[SKPaymentQueue defaultQueue]finishTransaction:_transaction];
    }

}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"index %d",buttonIndex);//if it is yes
    // in both cases insert the book in the database;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSNumber *identity=@(_identity);
    StoreBooks *books=[delegate.dataModel getBookById:identity];
    
    
    
    
    
    
    if (buttonIndex==1) {// if yes is the case
        
        
        UINavigationController *nav=(UINavigationController *)(_liveViewController.tabBarController.viewControllers)[0];
        LibraryViewController *library=(LibraryViewController *)nav.topViewController;
        NSString *valu=[[NSString alloc]initWithFormat:@"%@.epub",identity ];
        Book *bookToDownload=[delegate.dataModel getBookOfId:valu];
      //  [valu release];
        if (!delegate.addControlEvents) {
            UIAlertView *down=[[UIAlertView alloc]initWithTitle:@"Downloading.." message:@"Cannot start downloading as previous download is not complete" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
            [down show];
        //    [down release];
         //   [identity release];
            [delegate.dataModel insertBookWithNo:books];
            return;
        }
        [delegate.dataModel insertBookWithYes:books ];
        [library DownloadComplete:bookToDownload];
    }else{// no case
        UINavigationController *nav=(UINavigationController *)(_liveViewController.tabBarController.viewControllers)[1];
        DownloadViewControlleriPad *storeViewController=(DownloadViewControlleriPad *)nav.topViewController;
        [delegate.dataModel insertBookWithNo:books];
        [storeViewController BuildButtons];
        
    }
    [_popPurchase.parentViewController dismissViewControllerAnimated:YES completion:nil];
 //   [identity release];

    
    
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [_mutableData setLength:0];
}
/*-(void)dealloc{
    [_mutableData release];
    [super dealloc];
}*/
@end
