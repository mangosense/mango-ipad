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
        _pageNumber=1;

        
    }
    return self;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
  
    [self buildButtons];
 self.scrollView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"wood_pattern.png"]];
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo1.png"]];
    self.navigationItem.titleView=imageView;
    [imageView release];
   // UIBarButtonItem *itemLeftPrevious=[[UIBarButtonItem alloc]initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(previousButton:)];
   // UIBarButtonItem *itemRightNext=[[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(nextButton:)];
  // itemLeftPrevious.tintColor=[UIColor grayColor];
   // itemRightNext.tintColor=[UIColor grayColor];
    UIBarButtonItem *itemReferesh=[[UIBarButtonItem alloc]initWithTitle:@"Refresh" style:UIBarButtonItemStyleBordered target:self action:@selector(refreshButton:)];
    itemReferesh.tintColor=[UIColor grayColor];
    self.navigationItem.rightBarButtonItems=@[/*itemRightNext,*/itemReferesh];
   // self.navigationItem.leftBarButtonItem=itemLeftPrevious;
  //  [itemRightNext release];
   // [itemLeftPrevious release];
    [itemReferesh release];
    _ymax=768+80;
 //   [self DrawShelf];
//    CGSize contentSize=self.scrollView.contentSize;
//    contentSize.height=_ymax+170;
//    self.scrollView.contentSize=contentSize;
    
}
-(void)refreshButton:(id)sender{
   
    [self requestBooks];
}

-(void)nextButton:(id)sender{
    if (_pageNumber>=_pages) {
        return;
    }
    _pageNumber++;
    [self requestBooks];
    
}
-(void)previousButton:(id)sender{
    if (_pageNumber>1) {
        _pageNumber--;
    }
    [self requestBooks];
    
}
-(void)requestBooks{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    //http://staging.mangoreader.com/api/v1/page/:page/store_books.json
    NSString *stringUrl=[[NSString alloc]initWithFormat:@"%@page/%d/ipad_android_books.json",[defaults stringForKey:@"baseurl"],_pageNumber];
    NSLog(@"URL %@",stringUrl);
    //stringUrl=@"http://192.168.2.29:3000/api/v1/page/1/books.json";
    NSURL *url=[[NSURL alloc]initWithString:stringUrl];
    [stringUrl release];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"GET"];
      [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
    [connection autorelease];
      [_storeViewController requestBooksFromServerinit];
    _data=[[NSMutableData alloc]init];
     _alertView =[[UIAlertView alloc]init];
    UIImage *image=[UIImage imageNamed:@"loading.png"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-40, -160, 391, 320)];
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;
    
    imageView.image=image;
    [_alertView addSubview:imageView];
    [imageView release];
    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(125, 25, 66.0f, 66.0f)];
    indicator.color=[UIColor blackColor];
    [indicator startAnimating];
    [_alertView addSubview:indicator];
    [indicator release];
    
    
    [_alertView setDelegate:self];
    [_alertView show];
    

    [url release];
    [request release];

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
    [alert release];
    [_alertView dismissWithClickedButtonIndex:0 animated:YES];
    _alertView=nil;

}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [_data setLength:0];
    
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *lengthTotal=[[NSString alloc]initWithData:_data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",lengthTotal);
    [lengthTotal release];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
_totalNumberOfBooks=[delegate.dataModel insertStoreBooks:_data withPageNumber:_pageNumber];
    [self buildButtons];
    _pages=_totalNumberOfBooks/20;
    if (_totalNumberOfBooks%20!=0) {
        _pages++;
    }
    [_alertView dismissWithClickedButtonIndex:0 animated:YES];
    _alertView=nil;
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
        [imageView release];
    }
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    _interfaceOrientationChanged=toInterfaceOrientation;
   
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
     [self buildButtons];
}
-(void)buildButtons{
    for (UIView *view in self.scrollView.subviews) {
        
        [view removeFromSuperview];
        
        
    }// remove alll views if any
    // add all views if any
    int xmin=65,ymin=50;
    int x,y;
    x=xmin;
    y=ymin;
    int xinc=190;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSArray *_listOfBooks= [delegate.dataModel getForPage:_pageNumber];
    [_listOfBooks retain];
    _ymax=768+80;
    if (_listOfBooks.count==0) {
        
        [_listOfBooks release];
        return;
    }
   
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
        
        UIImage *image=[UIImage imageWithContentsOfFile:book.localImage];
        button.imageLocalLocation=book.localImage;
        [button setImage:image forState:UIControlStateNormal];
        //[button addTarget:button action:@selector(DownloadBook:) forControlEvents:UIControlEventTouchUpInside];
        [button setAlpha:0.7];
        //        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        //        tap.numberOfTouchesRequired=2;
        //        [button addGestureRecognizer:tap];
        //
        //        [tap release];
        NSURL *url=[[NSURL alloc]initFileURLWithPath:book.localImage];
        NSError *error=nil;
        [url setResourceValue:[NSNumber numberWithBool: YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
        [url release];
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
        //        UILongPressGestureRecognizer *longPress=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(LongPress:)];
        //        [button addGestureRecognizer:longPress];
        // [button setupView];
        //  button.viewController=self;
        // NSLog(@"viewcontroller retain count %d",[button.viewController retainCount]);
        [self.scrollView addSubview:button];
        [button release];
    }
    if (_alertView) {
        [ _alertView dismissWithClickedButtonIndex:0 animated:YES];
    }
    [_listOfBooks release];
    _alertView=nil;
    
}
-(void)tap:(id)sender{
    ShadowButton *button=(ShadowButton *)sender;
     AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSNumber *number=[[NSNumber alloc]initWithInteger:button.tag];
    if([delegate.dataModel checkIfIdExists:number]){
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Book purchased" message:@"You have already purchased the book" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
    }
    else{
        _identity=button.tag;
        PopPurchaseViewController *popPurchaseController=[[PopPurchaseViewController alloc]initWithNibName:@"PopPurchaseViewController" bundle:nil Identity:button.tag live:self ];
        popPurchaseController.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
        popPurchaseController.modalPresentationStyle=UIModalPresentationFormSheet;
        UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:popPurchaseController];
        nav.modalPresentationStyle=UIModalPresentationFormSheet;
        nav.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:nav animated:YES];
        [popPurchaseController release];
        [nav release];
    
}
    [number release];
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSNumber *identity=[[NSNumber alloc]initWithInteger:_identity];
    StoreBooks *books=[delegate.dataModel getBookById:identity];

    if (buttonIndex==1) {// if yes is the case
        
        UINavigationController *nav=self.tabBarController.viewControllers[0];
        LibraryViewController *library=(LibraryViewController *)nav.topViewController;
        NSString *valu=[[NSString alloc]initWithFormat:@"%@.epub",identity ];
        Book *bookToDownload=[delegate.dataModel getBookOfId:valu];
        [valu release];
        if (!library.addControlEvents) {
            UIAlertView *down=[[UIAlertView alloc]initWithTitle:@"Downloading.." message:@"Cannot start downloading as previous download is not complete" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
            [down show];
            [down release];
            bookToDownload.downloaded=[NSNumber numberWithBool:NO];
            [delegate.dataModel saveData:bookToDownload];
            [identity release];
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
        [delegate.dataModel insertBookWithNo:books];
        [storeViewController BuildButtons];
       // [storeViewController refreshButton:nil];
         [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
    [identity release];
    
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    UIAlertView *alertFailed;
    NSMutableURLRequest *request;
    NSMutableDictionary *dictionary;
    NSNumber *userid;
    NSData *jsonData;
    RecieptValidation *recieptValidation;
    NSString *valueJson;
    // VerificationController *verification=[[VerificationController alloc]init];
   
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStateFailed:
                NSLog(@"error %@",transaction.error);
                alertFailed =[[UIAlertView alloc]initWithTitle:@"Error"message:[transaction.error debugDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertFailed show];
                [alertFailed release];
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
                [dictionary setValue:[NSNumber numberWithInteger:_identity ] forKey:@"book_id"];
                [dictionary setValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"auth_token"] forKey:@"auth_token"];
                [dictionary setValue:_price forKey:@"amount"];
                NSData *transactionReciept=transaction.transactionReceipt;
                NSString *encode=[Base64 encode:transactionReciept];
                [dictionary setValue:encode forKey:@"receipt_data"];
                jsonData=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
                
                valueJson=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
                NSLog(@"value json request %@",valueJson);
                [valueJson release];
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
                [recieptValidation release];
                [connection autorelease];
                [request release];
                [dictionary release];
                       [[SKPaymentQueue defaultQueue]removeTransactionObserver:self];
            }else{// no user id
                
               
                request=[[NSMutableURLRequest alloc]init];
                dictionary=[[NSMutableDictionary alloc]init];
               // [dictionary setValue:_price forKey:@"amount"];
                
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
                [recieptValidation release];
                [connection autorelease];
                [request release];
                [dictionary release];
                [valueJson release];
                  [[SKPaymentQueue defaultQueue]removeTransactionObserver:self];
                
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
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSArray *array=[delegate.dataModel getForPage:1];
    if (array.count==0) {
        [self requestBooks];
    }
}
- (void)dealloc {
    [_scrollView release];
    _price=nil;
    [super dealloc];
}
- (void)viewDidUnload {
    [self setScrollView:nil];
    [super viewDidUnload];
}
@end