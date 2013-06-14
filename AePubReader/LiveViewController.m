//
//  LiveViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 14/11/12.
//
//

#import "LiveViewController.h"
#import "AePubReaderAppDelegate.h"
#import "DataModelControl.h"
#import "ShadowButton.h"
#import "StoreBooks.h"
#import "PopPurchaseViewController.h"
#import "PruchaseFree.h"
#import "Base64.h"
#import "RecieptValidation.h"
@interface LiveViewController ()

@end

@implementation LiveViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.title=@"Store";
        self.tabBarItem.image=[UIImage imageNamed:@"cart.png"];
        _currentPageNumber=1;
        _pg=1;
    }
   
    return self;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self performSelectorInBackground:@selector(requestBooksWithoutUIChange) withObject:nil];

    [self buildButtons];
 self.scrollView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"wood_pattern.png"]];
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo1.png"]];
    self.navigationItem.titleView=imageView;

    UIBarButtonItem *itemReferesh=[[UIBarButtonItem alloc]initWithTitle:@"Refresh" style:UIBarButtonItemStyleBordered target:self action:@selector(refreshButton:)];
    itemReferesh.tintColor=[UIColor grayColor];
    UIBarButtonItem *itemLeft=[[UIBarButtonItem alloc]initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(previousButton:)];
    itemLeft.tintColor=[UIColor grayColor];
    UIBarButtonItem *itemRight=[[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(nextButton:)];
    itemRight.tintColor=[UIColor grayColor];
    self.navigationItem.rightBarButtonItems=@[itemRight,itemReferesh];
    self.navigationItem.leftBarButtonItem=itemLeft;
    _ymax=768+80;

    
}
-(void)refreshButton:(id)sender{
   
  [self performSelectorInBackground:@selector(requestBooks) withObject:nil];
}

-(void)nextButton:(id)sender{
    if (_currentPageNumber>=_pages) {
        return;
    }
    _currentPageNumber++;
    [self performSelectorInBackground:@selector(requestBooks) withObject:nil];

    
}
-(void)previousButton:(id)sender{
    if (_currentPageNumber>1) {
        _currentPageNumber--;
    }
    [self performSelectorInBackground:@selector(requestBooks) withObject:nil];

    
}
-(void)showActivityIndicator{
    UIApplication *app=[UIApplication sharedApplication];
    app.networkActivityIndicatorVisible=YES;
    [_networkIndicator bringSubviewToFront:_scrollView];
    [_networkIndicator startAnimating];
    
    
}
-(void)hideActivityIndicator{
    UIApplication *app=[UIApplication sharedApplication];
  
    app.networkActivityIndicatorVisible=NO;
    [_networkIndicator stopAnimating];
    if (_error) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[_error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    [self buildButtons];
}
-(void)requestBooksWithoutUIChange{
    [self performSelectorOnMainThread:@selector(showActivityIndicator) withObject:nil waitUntilDone:NO];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.completedStorePopulation=NO;
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    //http://staging.mangoreader.com/api/v1/page/:page/store_books.json
    NSString *stringUrl=[[NSString alloc]initWithFormat:@"%@page/%d/ipad_android_books.json",[defaults stringForKey:@"baseurl"],_pg];
    NSLog(@"URL %@",stringUrl);
    //stringUrl=@"http://192.168.2.29:3000/api/v1/page/1/books.json";
    NSURL *url=[[NSURL alloc]initWithString:stringUrl];
    //[stringUrl release];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLResponse *response;
    NSError *error;
    [self performSelectorOnMainThread:@selector(showActivityIndicator) withObject:nil waitUntilDone:NO];
    NSData *data= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    _data=[[NSMutableData alloc]initWithData:data];
    NSString *lengthTotal=[[NSString alloc]initWithData:_data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",lengthTotal);
    
    _totalNumberOfBooks=[delegate.dataModel insertStoreBooks:_data withPageNumber:_pg];
    _pages=_totalNumberOfBooks/20;
    if (_totalNumberOfBooks%20!=0) {
        _pages++;
    }
    if (_pg<_pages) {
        _pg++;
        [self performSelectorInBackground:@selector(requestBooksWithoutUIChange) withObject:nil];
    }else{
        [self performSelectorOnMainThread:@selector(hideActivityIndicator) withObject:nil waitUntilDone:NO];
        delegate.completedStorePopulation=YES;
    }

}
-(void)requestBooks{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    //http://staging.mangoreader.com/api/v1/page/:page/store_books.json
    NSString *stringUrl=[[NSString alloc]initWithFormat:@"%@page/%d/ipad_android_books.json",[defaults stringForKey:@"baseurl"],_currentPageNumber];
    NSLog(@"URL %@",stringUrl);
    //stringUrl=@"http://192.168.2.29:3000/api/v1/page/1/books.json";
    NSURL *url=[[NSURL alloc]initWithString:stringUrl];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"GET"];
      [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLResponse *response;
    NSError *error;
    [self performSelectorOnMainThread:@selector(showActivityIndicator) withObject:nil waitUntilDone:NO];
   NSData *data= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    _data=[[NSMutableData alloc]initWithData:data];
_error=error;
       
    if(error){
        
    }
    else {
        
  
        NSString *lengthTotal=[[NSString alloc]initWithData:_data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",lengthTotal);
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        _totalNumberOfBooks=[delegate.dataModel insertStoreBooks:_data withPageNumber:_currentPageNumber];
        [self buildButtons];
        _pages=_totalNumberOfBooks/20;
        if (_totalNumberOfBooks%20!=0) {
            _pages++;
        }
 
    }
    [self performSelectorOnMainThread:@selector(hideActivityIndicator) withObject:nil waitUntilDone:NO];



}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_data appendData:data];
    
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];

    [alert show];
  [self performSelectorOnMainThread:@selector(hideActivityIndicator) withObject:nil waitUntilDone:NO];


}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [_data setLength:0];
    
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *lengthTotal=[[NSString alloc]initWithData:_data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",lengthTotal);
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
_totalNumberOfBooks=[delegate.dataModel insertStoreBooks:_data withPageNumber:_currentPageNumber];
    [self buildButtons];
    _pages=_totalNumberOfBooks/20;
    if (_totalNumberOfBooks%20!=0) {
        _pages++;
    }
 [self performSelectorOnMainThread:@selector(hideActivityIndicator) withObject:nil waitUntilDone:NO];

}
-(void)DrawShelf{
    UIImage *image=[UIImage imageNamed:@"book-shelf.png"];
    
    int xmin=27,ymin=50+175;
    float width=974;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        xmin=10;ymin=30+175;
        width=748;
    }
    while (ymin<_ymax) {
        UIImageView *imageView =[[UIImageView alloc]initWithImage:image];
        CGRect frame=CGRectMake(xmin, ymin, width, imageView.frame.size.height);
        ymin+=210+40;
        imageView.frame=frame;
        [self.scrollView addSubview:imageView];
      //  [imageView release];
    }
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    _interfaceOrientationChanged=toInterfaceOrientation;
   
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
     [self buildButtons];
}
-(void)buildButtons{
       // add all views if any
    int xmin=65,ymin=50;
    int x,y;
    x=xmin;
    y=ymin;
    int xinc=190;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSArray *_listOfBooks= [delegate.dataModel getForPage:_currentPageNumber];
    _ymax=768+80;
    if (_listOfBooks.count==0) {
        
        return;
    }
    for (UIView *view in self.scrollView.subviews) {
        
        [view removeFromSuperview];
        
        
    }// remove alll views if any

    if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation)){
        _ymax=1024+80;
        if (_listOfBooks.count>16) {
            NSInteger extra=_listOfBooks.count-16;
            if (extra%4!=0) {
                extra=extra/4;
                extra++;
            }else{
                extra=extra/4;
            }
            _ymax+=(260*extra);
        }
        xmin-=25;
        x=xmin;
        y-=20;
        xinc=180;
    }else{
        x=xmin;
        y=ymin;
    if (_listOfBooks.count>15) {
        NSInteger extra=_listOfBooks.count-15;
        
        if (extra%5!=0) {
            extra=extra/5;
            extra++;
        }else{
            extra=extra/5;
        }
            _ymax=768+80;
            _ymax=_ymax+(260*extra);
        
        }
        xinc=190;
    }
    CGSize size=self.scrollView.contentSize;
    size.height=_ymax;
    [self.scrollView setContentSize:size];
    
    [self DrawShelf];
    for (int i=0;i<_listOfBooks.count;i++) {
        StoreBooks *book=_listOfBooks[i];
        CGRect rect=CGRectMake(x, y, 140, 180);
        ShadowButton *button=[[ShadowButton alloc]init];
        //button.storeViewController=self;
        button.frame=rect;
        button.tag=i;
        button.stringLink=book.bookLink;
        button.frame=rect;
        
        button.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"bookshadow.png"]];
        button.tag=[book.productIdentity integerValue];
        // [button setupView];
        NSLog(@"local image%@",book.localImage);
        UIImage *image=[UIImage imageWithContentsOfFile:book.localImage];
        button.imageLocalLocation=book.localImage;
        [button setImage:image forState:UIControlStateNormal];
        [button setAlpha:0.7];
        @try {
            NSURL *url=[[NSURL alloc]initFileURLWithPath:book.localImage];
            NSError *error=nil;
            [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];

        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
                [button addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        //NSLog(@" x= %d",x);
        x=x+xinc;
        
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)&&x+140>1024) {
            x=xmin;
            y=y+210+40;
        }else if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation)&&x+140>780){
            x=xmin;
            y+=+250;
        }

        [self.scrollView addSubview:button];
    }
    if (_alertView) {
        [ _alertView dismissWithClickedButtonIndex:0 animated:YES];
    }

    [self.view bringSubviewToFront:_previousButton];
    [self.view bringSubviewToFront:_nextButton];
}
-(void)tap:(id)sender{
    ShadowButton *button=(ShadowButton *)sender;
     AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSNumber *number=@(button.tag);
    if([delegate.dataModel checkIfIdExists:number]){
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Book purchased" message:@"You have already purchased the book" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    else{
        _identity=button.tag;
        delegate.identity=button.tag;
        PopPurchaseViewController *popPurchaseController=[[PopPurchaseViewController alloc]initWithNibName:@"PopPurchaseViewController" bundle:nil Identity:button.tag live:self ];
        popPurchaseController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
        popPurchaseController.modalPresentationStyle=UIModalPresentationFormSheet;
        UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:popPurchaseController];
        nav.modalPresentationStyle=UIModalPresentationFormSheet;
        nav.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:nav animated:YES];
       
}
    
}
-(uint64_t)getFreeDiskspace {
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = dictionary[NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = dictionary[NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    return totalFreeSpace;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSNumber *identity=@(_identity);
    StoreBooks *books=[delegate.dataModel getBookById:identity];
    float size=[books.size floatValue];
    //  [image release];
    NSLog(@"%@",[NSNumber numberWithLongLong:size] );
    size=size/1024.0f;
    NSLog(@"%@",[NSNumber numberWithLongLong:size] );
    size=size/1024.0f;
    NSLog(@"%@",[NSNumber numberWithLongLong:size] );
    if (buttonIndex==1) {// if yes is the case
        if (size>[self getFreeDiskspace]) {

            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"There is no sufficient space in your device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            UINavigationController *nav=self.tabBarController.viewControllers[1];
            StoreViewController *storeViewController=(StoreViewController *)nav.topViewController;
            [delegate.dataModel insertBookWithNo:books];
            [storeViewController BuildButtons];
            
            [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        
        UINavigationController *nav=self.tabBarController.viewControllers[0];
        LibraryViewController *library=(LibraryViewController *)nav.topViewController;
        NSString *valu=[[NSString alloc]initWithFormat:@"%@.epub",identity ];
        Book *bookToDownload=[delegate.dataModel getBookOfId:valu];
        if (!delegate.addControlEvents) {
            UIAlertView *down=[[UIAlertView alloc]initWithTitle:@"Downloading.." message:@"Cannot start downloading as previous download is not complete" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
            [down show];
            bookToDownload.downloaded=@NO;
            [delegate.dataModel saveData:bookToDownload];
            [delegate.dataModel insertBookWithNo:books];
            
            return;
        }
        [delegate.dataModel insertBookWithYes:books];
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        [library DownloadComplete:bookToDownload];
    }else{
        [delegate.dataModel insertBookWithNo:books];
        UINavigationController *nav=self.tabBarController.viewControllers[1];
        StoreViewController *storeViewController=(StoreViewController *)nav.topViewController;
        [storeViewController BuildButtons];
         [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    UIAlertView *alertFailed;
    NSMutableURLRequest *request;
    NSMutableDictionary *dictionary;
    NSNumber *userid;
    NSData *jsonData;
    RecieptValidation *recieptValidation;
    NSString *valueJson;
   
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStateFailed:
                NSLog(@"error %@",transaction.error);
                alertFailed =[[UIAlertView alloc]initWithTitle:@"Error"message:[transaction.error debugDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertFailed show];
                [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
                [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
                break;
            case SKPaymentTransactionStatePurchased:
                if ([[NSUserDefaults standardUserDefaults]objectForKey:@"email"])
                {
                    request=[[NSMutableURLRequest alloc]init];
                dictionary=[[NSMutableDictionary alloc]init];
                userid=[[NSUserDefaults standardUserDefaults]objectForKey:@"id"];
                [dictionary setValue:userid forKey:@"user_id"];
                [dictionary setValue:@(_identity) forKey:@"book_id"];
                [dictionary setValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"auth_token"] forKey:@"auth_token"];
                [dictionary setValue:_price forKey:@"amount"];
                NSData *transactionReciept=transaction.transactionReceipt;
                NSString *encode=[Base64 encode:transactionReciept];
                [dictionary setValue:encode forKey:@"receipt_data"];
                jsonData=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
                
                valueJson=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
                NSLog(@"value json request %@",valueJson);
                [request setHTTPMethod:@"POST"];
                [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [request setHTTPBody:jsonData];
                recieptValidation=[[RecieptValidation alloc]initWithPop:(PopPurchaseViewController *)self.presentedViewController LiveController:self fileLink:_identity transaction:transaction];
                NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
                 recieptValidation.signedIn=YES;
                NSString *urlString=[NSString stringWithFormat:@"%@receipt_validate",[defaults objectForKey:@"baseurl"] ];
                //   urlString=@"http://192.168.2.29:3000/api/v1/receipt_validate";
                NSLog(@"reciept validation %@",urlString);
                [request setURL:[NSURL URLWithString:urlString]];
                NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:recieptValidation];

                    [connection start];
            }else{// no user id
                
               
                request=[[NSMutableURLRequest alloc]init];
                dictionary=[[NSMutableDictionary alloc]init];
                
                NSData *transactionReciept=transaction.transactionReceipt;
                NSString *encode=[Base64 encode:transactionReciept];
                 [dictionary setValue:encode forKey:@"receipt_data"];
                jsonData=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
                
                valueJson=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
                NSLog(@"value json request %@",valueJson);
                
                [request setHTTPMethod:@"POST"];
                [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [request setHTTPBody:jsonData];
                UINavigationController *nav=(UINavigationController *)self.presentedViewController;
                
                recieptValidation=[[RecieptValidation alloc]initWithPop:(PopPurchaseViewController *)[nav.viewControllers lastObject] LiveController:self fileLink:_identity transaction:transaction];
                NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
                
                NSString *urlString=[NSString stringWithFormat:@"%@receipt_validate_without_signed_in.json",[defaults objectForKey:@"baseurl"] ];
                //   urlString=@"http://192.168.2.29:3000/api/v1/receipt_validate";
                NSLog(@"reciept validation %@",urlString);
                [request setURL:[NSURL URLWithString:urlString]];
                recieptValidation.signedIn=NO;
                NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:recieptValidation];

                [connection start];
                
            }
        
                break;
            case SKPaymentTransactionStateRestored:
                // [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
                
            default:
                break;
        }
        
    }//end for
  
    //   [verification release];
}
-(void)transactionFailed{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];

}
-(void)purchaseValidation:(SKPaymentTransaction *)transaction{
        RecieptValidation *recieptValidation;
    NSMutableURLRequest *request;
    NSMutableDictionary *dictionary;
    NSNumber *userid;
    NSData *jsonData;

    NSString *valueJson;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"email"])
    {
        request=[[NSMutableURLRequest alloc]init];
        dictionary=[[NSMutableDictionary alloc]init];
        userid=[[NSUserDefaults standardUserDefaults]objectForKey:@"id"];
        [dictionary setValue:userid forKey:@"user_id"];
        [dictionary setValue:@(_identity) forKey:@"book_id"];
        [dictionary setValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"auth_token"] forKey:@"auth_token"];
        [dictionary setValue:_price forKey:@"amount"];
        NSData *transactionReciept=transaction.transactionReceipt;
        NSString *encode=[Base64 encode:transactionReciept];
        [dictionary setValue:encode forKey:@"receipt_data"];
        jsonData=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        
        valueJson=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"value json request %@",valueJson);
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:jsonData];
        recieptValidation=[[RecieptValidation alloc]initWithPop:(PopPurchaseViewController *)self.presentedViewController LiveController:self fileLink:_identity transaction:transaction];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        recieptValidation.signedIn=YES;
        NSString *urlString=[NSString stringWithFormat:@"%@receipt_validate",[defaults objectForKey:@"baseurl"] ];
        //   urlString=@"http://192.168.2.29:3000/api/v1/receipt_validate";
        NSLog(@"reciept validation %@",urlString);
        [request setURL:[NSURL URLWithString:urlString]];
        NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:recieptValidation];

        [connection start];
    }else{// no user id
        request=[[NSMutableURLRequest alloc]init];
        dictionary=[[NSMutableDictionary alloc]init];        
        NSData *transactionReciept=transaction.transactionReceipt;
        NSString *encode=[Base64 encode:transactionReciept];
        [dictionary setValue:encode forKey:@"receipt_data"];
        jsonData=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        
        valueJson=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"value json request %@",valueJson);
        
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:jsonData];
        UINavigationController *nav=(UINavigationController *)self.presentedViewController;
        
        recieptValidation=[[RecieptValidation alloc]initWithPop:(PopPurchaseViewController *)[nav.viewControllers lastObject] LiveController:self fileLink:_identity transaction:transaction];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        
        NSString *urlString=[NSString stringWithFormat:@"%@receipt_validate_without_signed_in.json",[defaults objectForKey:@"baseurl"] ];
        //   urlString=@"http://192.168.2.29:3000/api/v1/receipt_validate";
        NSLog(@"reciept validation %@",urlString);
        [request setURL:[NSURL URLWithString:urlString]];
        recieptValidation.signedIn=NO;
        NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:recieptValidation];

        [connection start];
    
        
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSArray *array=[delegate.dataModel getForPage:1];
    if (array.count==0) {
        
        [self DrawShelf];
        [self performSelectorInBackground:@selector(requestBooks) withObject:nil];
   
    }
    [Flurry logEvent:@"Store entered"];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [Flurry logEvent:@"Store exited"];

}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setNetworkIndicator:nil];
    [self setPreviousButton:nil];
    [self setNextButton:nil];
    [super viewDidUnload];
}
- (IBAction)leftbutton:(id)sender {
    [self previousButton:nil];
}
- (IBAction)rightButton:(id)sender {
    [self nextButton:nil];
}
@end
