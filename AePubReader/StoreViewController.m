//
//  StoreViewController.m
//  AePubReader
//
//  Created by Nikhil Dhavale on 24/09/12.
//
//

#import "StoreViewController.h"
#import <Foundation/Foundation.h>
#import "Book.h"
#import "DataModelControl.h"
#import "Book.h"
#import "FileDownloader.h"
#import "ShadowButton.h"
#import "ListOfBooks.h"
#import "PopViewDetailsViewController.h"
#import "SyncIpadConnection.h"
#import "LoginDirectly.h"
#import "Flurry.h"
@interface StoreViewController ()

@end

@implementation StoreViewController
-(void)setListOfBooks:(NSArray *)listOfBooks{
   // _listOfBooks=nil;
    _listOfBooks=[[NSMutableArray alloc]initWithArray:listOfBooks];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.title=@"Downloads";
        self.tabBarItem.image=[UIImage imageNamed:@"purchased.png"];
        _purchase=YES;
        
     
    }
    return self;
}
-(void)requestBooksFromServerinit{
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"email"]) {
        return;
    }
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    NSString *temp;
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    temp=[userDefaults stringForKey:@"email"];
    [dictionary setValue:temp forKey:@"email"];
    temp=[userDefaults stringForKey:@"auth_token"];
    [dictionary setValue:temp forKey:@"auth_token"];
    NSLog(@"auth_token %@",temp);
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
   // [dictionary release];
    NSString *connectionString=[userDefaults objectForKey:@"baseurl"];
    connectionString=[connectionString stringByAppendingFormat:@"book_purchase"];
    connectionString=[connectionString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Connection String %@",connectionString);
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:connectionString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    //  [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    ListOfBooks *books=[[ListOfBooks alloc]initWithViewController:self];
    books.shouldBuild=YES;
    _connection=[[NSURLConnection alloc]initWithRequest:request delegate:books];
   // [request release];
   // [books release];
    _purchase=YES;
    
    
}
-(void)showActivityIndicator{
    UIApplication *app=[UIApplication sharedApplication];
    app.networkActivityIndicatorVisible=YES;
    [_networkActivityIndicator startAnimating];
    
}
-(void)hideActivityIndicator{
    UIApplication *app=[UIApplication sharedApplication];
    app.networkActivityIndicatorVisible=NO;
    [_networkActivityIndicator stopAnimating];
    if (_error) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[_error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}
-(void)requestBooksFromServer{
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"email"]) {
        [self BuildButtons];
        return;
    }
/*    _alert =[[UIAlertView alloc]init];

    UIImage *image=[UIImage imageNamed:@"loading.png"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-40, -160, 391, 320)];
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;
    
    imageView.image=image;
    [_alert addSubview:imageView];
  //  [imageView release];
    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(125, 25, 66.0f, 66.0f)];
    indicator.color=[UIColor blackColor];
    [indicator startAnimating];
    [_alert addSubview:indicator];

  //  [indicator release];

    
    [_alert show];
   // [_alert release];*/
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    NSString *temp;
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    temp=[userDefaults stringForKey:@"email"];
    [dictionary setValue:temp forKey:@"email"];
    temp=[userDefaults stringForKey:@"auth_token"];
    [dictionary setValue:temp forKey:@"auth_token"];
     NSLog(@"auth_token %@",temp);
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
  //  NSString *jsonInput=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
   // NSLog(@"%@",jsonInput);
    NSString *connectionString=[userDefaults objectForKey:@"baseurl"];
  //  [jsonInput autorelease];
   connectionString=[connectionString stringByAppendingFormat:@"book_purchase"];
    connectionString=[connectionString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Connection String %@",connectionString);
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:connectionString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
  
  //  [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

  //  ListOfBooks *books=[[ListOfBooks alloc]initWithViewController:self];
   // _connection=[[NSURLConnection alloc]initWithRequest:request delegate:books];
    NSURLResponse *response;
    NSData *data;
    NSError *error;
    [self performSelectorOnMainThread:@selector(showActivityIndicator) withObject:nil waitUntilDone:NO];
    data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"data %@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
    if (error) {
        _error=error;
    }else{
        
        //Data
        id jsonObject=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
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
            
            directly.storeController=self;
            NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:directly];
            [connection start];
            // [directly release];
            // [request release];
            //[connection autorelease];
            return;
        }
     //   NSLog(@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
        _data=[[NSMutableData alloc]initWithData:data];
        [delegate.dataModel insertIfNew:_data];
        [self BuildButtons];
    }
    [self performSelectorOnMainThread:@selector(hideActivityIndicator) withObject:nil waitUntilDone:NO];
    _purchase=YES;

 
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"%@",error);
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{

     [self.parentViewController.navigationController popToRootViewControllerAnimated:YES];

    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
   // [_mainSpinner startAnimating];
   // _spinner.hidesWhenStopped=YES;
    _ymax=768+80;
    self.scrollView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"wood_pattern.png"]];
    //CGSize size=self.scrollView.contentSize;
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"email"]) {
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"Login" style:UIBarButtonItemStyleBordered target:self action:@selector(signOut:)];
    }else{
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"Sign Out" style:UIBarButtonItemStyleBordered target:self action:@selector(signOut:)];
    }

    self.navigationItem.rightBarButtonItem.tintColor=[UIColor grayColor];
    UIBarButtonItem *barButtonRefresh=[[UIBarButtonItem alloc]initWithTitle:@"Refresh" style:UIBarButtonItemStyleBordered target:self action:@selector(refreshButton:)];
    UIBarButtonItem *restore=[[UIBarButtonItem alloc]initWithTitle:@"Restore" style:UIBarButtonItemStyleBordered target:self action:@selector(restore:)];
    UIBarButtonItem *sync=[[UIBarButtonItem alloc]initWithTitle:@"Sync" style:UIBarButtonItemStyleBordered target:self action:@selector(sync:)];
    barButtonRefresh.tintColor=[UIColor grayColor];
    restore.tintColor=[UIColor grayColor];
    sync.tintColor=[UIColor grayColor];
    NSArray *array=@[barButtonRefresh,restore,sync];
    self.navigationItem.leftBarButtonItems=array;
   // [restore release];
   // [barButtonRefresh release];
   // [sync release];
 
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo1.png"]];
    self.navigationItem.titleView=imageView;
   // [imageView release];
    //[self DrawShelf];
  
    [self BuildButtons];
    
}

-(void)restore:(id)sender{

    // [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    if (delegate.completedStorePopulation) {
       // [delegate insertInStore];
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
        [self showActivityIndicator];
    }else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Message" message:@"Please wait till the information for books in the store are retrived" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }

    
}
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    UIAlertView *alertFailed;
    NSNumber *number;
    StoreBooks *books;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStateFailed:
                alertFailed =[[UIAlertView alloc]initWithTitle:@"Error"message:@"Payment not performed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertFailed show];
               // [alertFailed release];
                [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchased:
                
                
                break;
            case SKPaymentTransactionStateRestored:
                number=@(transaction.payment.productIdentifier.integerValue);
                books= [delegate.dataModel getBookById:number];
                [delegate.dataModel insertBookWithNo:books];
               // [number release];
                
                [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
                //restored=YES;
                //[_alert dismissWithClickedButtonIndex:0 animated:YES];
                //_alert=nil;
                break;
        }
    }///end for


}
-(void)transactionRestore{
    [self BuildButtons];
    [self hideActivityIndicator];
}
-(void)transactionFailed{
    [self hideActivityIndicator];
}
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    [_alert dismissWithClickedButtonIndex:0 animated:YES];
   
//    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message: @"Cannot connect to iTunes store" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//    [alertView show];
    //[alertView release];
    //_alert=nil;
}
- (void)signOut:(id)sender {
    NSString *signout=[[NSUserDefaults standardUserDefaults] objectForKey:@"baseurl"];
    signout =[signout stringByAppendingPathComponent:@"users/sign_out"];
    signout =[signout stringByAppendingFormat:@"?user[email]=%@&auth_token=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"email"],[[NSUserDefaults standardUserDefaults] objectForKey:@"auth_token"]];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:signout]];
    [request setHTTPMethod:@"GET"];
    NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
    [connection start];
   // [request release];
  //  [connection autorelease];
    
    [self.parentViewController.navigationController popToRootViewControllerAnimated:YES];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"email"];
}
-(void)sync:(id)sender{
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"email"]) {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Login" message:@"Do you wish to sign in or sign up to sync your books" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        alertView.tag=50;
        [alertView show];
      //  [alertView release];
    }else{
        NSMutableURLRequest *request=[[NSMutableURLRequest alloc]init];
         NSString *url=[[NSUserDefaults standardUserDefaults] objectForKey:@"baseurl"];
        url =[url stringByAppendingString:@"apple_register_users_books.json"];
      //  url=@"http://192.168.2.29:3000/api/v1/apple_register_users_books.json";
        [request setURL:[NSURL URLWithString:url ]];
        SyncIpadConnection *syncIpad=[[SyncIpadConnection alloc]init];
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        NSArray *stor=[[NSArray alloc]initWithArray:[delegate.dataModel getStoreBooksPurchased]];
        NSMutableDictionary *diction=[[NSMutableDictionary alloc]init];
        NSMutableArray *arryMutable=[[NSMutableArray alloc]init];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSNumber *number=[defaults objectForKey:@"id"];
       // number=[NSNumber numberWithInteger:297];
        [diction setValue:number forKey:@"user_id"];
       
        NSString *auth_token=[defaults objectForKey:@"auth_token"];
        [diction setValue:auth_token forKey:@"auth_token"];
        
        for (StoreBooks *books in stor) {
            NSNumber *bookId=books.productIdentity;
            NSNumber *amount=books.amount;
            NSArray *array=@[bookId,amount];
            [arryMutable addObject:array];
       //     [array release];
            
        }
//        [arryMutable removeAllObjects];
//        number=[NSNumber numberWithInteger:229];
//        
//        NSArray *array=[NSArray arrayWithObjects:number,[NSNumber numberWithInteger:0], nil];
//        number=[NSNumber numberWithInteger:212];
//        NSArray *arrayaother=[NSArray arrayWithObjects:number,[NSNumber numberWithInteger:0], nil];
//        [arryMutable addObject:array];
//        [arryMutable addObject:arrayaother];
        [diction setValue:arryMutable forKey:@"books"];
        NSData *json=[NSJSONSerialization dataWithJSONObject:diction options:NSJSONWritingPrettyPrinted error:nil];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:json];
        NSString *string=[[NSString alloc]initWithData:json encoding:NSUTF8StringEncoding];
        NSLog(@"%@",string);
         [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:syncIpad];
        [connection start];
       // [syncIpad release];
       // [request release];
        //[string release];
        //[connection autorelease];
       // [arryMutable release];
       // [diction release];
       // [stor release];
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"email"]){
    
        return;
    }
    if (!_purchase) {
        [self BuildButtons];
    }
   
    [Flurry logEvent:@"Downloads entered"];
    
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
   //  [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [Flurry logEvent:@"Downloads exited"];

}

-(void)DrawShelf{
    UIImage *image=[UIImage imageNamed:@"book-shelf.png"];
    
    int xmin=27,ymin=50+175;
    float width=974;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        xmin=10;
        ymin=30+175;
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
//- (NSUInteger)supportedInterfaceOrientations {
//    
//    return UIInterfaceOrientationMaskAll;
//    
//}
//
//
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self BuildButtons];
}
-(void)BuildButtons{
    for (UIView *view in self.scrollView.subviews) {
        
              [view removeFromSuperview];
        
      
    }// remove alll views if any
    // add all views if any
    int xmin=65,ymin=50;
    int x,y;
    int xinc;
    x=xmin;
    y=ymin;
    xinc=190;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
   _listOfBooks= [delegate.dataModel getDataNotDownloaded];
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
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
    }
    else
    {
        _ymax=768+80;
    if (_listOfBooks.count>15) {
        NSInteger extra=_listOfBooks.count-15;
        
            if (extra%5!=0) {
                extra=extra/5;
                extra++;
            }else{
            extra=extra/5;
            }
        
        _ymax=_ymax+(260*extra);
       
        }
    }
    CGSize size=self.scrollView.contentSize;
    size.height=_ymax;
    [self.scrollView setContentSize:size];

    [self DrawShelf];
    for (int i=0;i<_listOfBooks.count;i++) {
         Book *book=_listOfBooks[i];
        CGRect rect=CGRectMake(x, y, 140, 180);
        ShadowButton *button=[[ShadowButton alloc]init];
        button.storeViewController=self;
        button.frame=rect;
        button.tag=i;
        button.stringLink=book.link;
        button.frame=rect;
        
        button.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"bookshadow.png"]];
        button.tag=[book.id integerValue];
        
       // [button setupView];
    //    NSLog(@"localPath %@",book.localPathImageFile);
        UIImage *image=[UIImage imageWithContentsOfFile:book.localPathImageFile];
        button.imageLocalLocation=book.localPathImageFile;
        [button setImage:image forState:UIControlStateNormal];
        //[button addTarget:button action:@selector(DownloadBook:) forControlEvents:UIControlEventTouchUpInside];
        [button setAlpha:0.7];
//        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
//        tap.numberOfTouchesRequired=2;
//        [button addGestureRecognizer:tap];
//        
//        [tap release];
        NSURL *url=[[NSURL alloc]initFileURLWithPath:book.localPathImageFile];
        NSError *error=nil;
        [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
       // [url release];
        UITapGestureRecognizer *Singletap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [button addGestureRecognizer:Singletap];
       // [Singletap release];
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
       // [button release];
    }
    if (_alert) {
          [ _alert dismissWithClickedButtonIndex:0 animated:YES];
    }
 
    //_alert=nil;
    
}
-(void)singleTap:(UIGestureRecognizer *)gesture{
    _buttonTapped=(UIButton *)gesture.view;
    [self DownloadBook:_buttonTapped];
}
-(void)tap:(UIGestureRecognizer*)gesture{
       UIMenuController *_menuController=[UIMenuController sharedMenuController];
    if (_menuController.menuVisible) {
        [_menuController setMenuVisible:NO animated:YES];
        return;
    }
  

    _buttonTapped=(UIButton *)gesture.view;
    ShadowButton *shadow=(ShadowButton *)gesture.view;
    PopViewDetailsViewController *controller=[[PopViewDetailsViewController alloc]initWithNibName:@"PopViewDetailsViewController" bundle:nil imageLocation:shadow.imageLocalLocation indentity:shadow.tag];
    controller.view.frame=CGRectMake(50, 60, 300, 300);
    controller.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    controller.modalPresentationStyle=UIModalPresentationFormSheet;

    //controller.imageLocation=shadow.imageLocalLocation;
    controller.store=self;
    
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:controller];
    nav.modalPresentationStyle=UIModalPresentationFormSheet;
    nav.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:nav animated:YES];
   // [controller release];
   // [nav release];
    
    
    //    [gesture.view becomeFirstResponder];
//    UIMenuItem *menuItem=[[UIMenuItem alloc]initWithTitle:@"share" action:@selector(share:)];
//   UIMenuItem *downloadOrShow=[[UIMenuItem alloc]initWithTitle:@"download" action:@selector(DownloadBook:)];
//
//   // _menuController=[UIMenuController sharedMenuController];
//     
//    [_menuController setMenuItems:@[downloadOrShow,menuItem]];
//    [menuItem release];
//    [downloadOrShow release];
//    CGRect frame=gesture.view.frame;
//    frame.origin.x-=10;
//    frame.origin.y-=10;
//    [_menuController setTargetRect:frame inView:self.scrollView];
//    [_menuController setMenuVisible:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)DownloadBook:(id)sender {
    
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *) [UIApplication sharedApplication].delegate;
    if (!delegate.addControlEvents) {
        UIAlertView *down=[[UIAlertView alloc]initWithTitle:@"Downloading.." message:@"Cannot start downloading as previous download is not complete" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [down show];
     //   [down release];
        
        return;
    }
  

    
    _listOfBooks=[delegate.dataModel getDataNotDownloaded];
    for (Book *bk in _listOfBooks) {
        if ([bk.id integerValue]==_buttonTapped.tag) {
            _book=bk;
            
            break;
        }
    }
    
    self.book.downloaded=@YES;
    self.book.downloadedDate=[NSDate date];
      [delegate.dataModel saveData:self.book];
    _purchase=NO;
    [_delegate DownloadComplete:self.book];
    [self BuildButtons];
   
}


/*- (void)dealloc {

    
    [_scrollView release];
    [super dealloc];
    _listOfBooks=nil;
    _connection=nil;
}*/
- (void)viewDidUnload {

   
    [self setScrollView:nil];
    [self setNetworkActivityIndicator:nil];
    [super viewDidUnload];
}
- (void)refreshButton:(id)sender {
    [self performSelectorInBackground:@selector(requestBooksFromServer) withObject:nil];
  //  [self requestBooksFromServer];
  //  [self BuildButtons];
}

-(void)defunct:(id)sender{
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==50) {
        if (buttonIndex==1) {//yes
            [self.parentViewController.navigationController popToRootViewControllerAnimated:YES];
            
        }else{
            
            [self.tabBarController setSelectedIndex:0];
        }
        return;
    }
    if (buttonIndex==1) {
        [self.tabBarController setSelectedIndex:0];
        return;
    }

    if (buttonIndex==1) {
        [self.tabBarController setSelectedIndex:0];
        return;
    }
[self performSelectorInBackground:@selector(requestBooksFromServer) withObject:nil];
}

@end
