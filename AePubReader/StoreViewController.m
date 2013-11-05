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
#import "CollectionViewLayout.h"
#import "Cell.h"
#import "OldCell.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import "TimeRange.h"

@interface StoreViewController ()

@property (nonatomic, strong) NSDate *openingTime;

@end

@implementation StoreViewController

@synthesize openingTime;

-(void)setListOfBooks:(NSArray *)listOfBooks{
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

    _purchase=YES;
    
    
}
-(void)showActivityIndicator{
    UIApplication *app=[UIApplication sharedApplication];
    app.networkActivityIndicatorVisible=YES;
    [self.view bringSubviewToFront:_networkActivityIndicator];
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
  //  [self BuildButtons];
}
-(void)requestBooksFromServer{
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"email"]) {
      //  [self BuildButtons];
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
  //  NSString *jsonInput=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
   // NSLog(@"%@",jsonInput);
    NSString *connectionString=[userDefaults objectForKey:@"baseurl"];
   connectionString=[connectionString stringByAppendingFormat:@"book_purchase"];
    connectionString=[connectionString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Connection String %@",connectionString);
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:connectionString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
  
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

 
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
          
            return;
        }
     //   NSLog(@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
        _data=[[NSMutableData alloc]initWithData:data];
        [delegate.dataModel insertIfNew:_data];
       // [self BuildButtons];
        _listOfBooks=[delegate.dataModel getDataNotDownloaded];
    }
    [self performSelectorOnMainThread:@selector(hideActivityIndicator) withObject:nil waitUntilDone:NO];
    _purchase=YES;
    
    [_collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    [_pstCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
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
    
    openingTime = [NSDate date];
    
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.translucent = NO;
//    self.tabBarController.tabBar.translucent = NO;

     _ymax=768+80;
    self.scrollView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"wood_pattern.png"]];
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

    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo1.png"]];
    self.navigationItem.titleView=imageView;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.dataModel displayAllData];
    NSArray *temp=[delegate.dataModel getDataNotDownloaded];
    _listOfBooks=[[NSArray alloc]initWithArray:temp];
    CollectionViewLayout *collectionViewLayout = [[CollectionViewLayout alloc] init];
    collectionViewLayout.footerReferenceSize=CGSizeMake(0, 0);
    CGRect frame=self.view.bounds;
    NSString *ver= [UIDevice currentDevice].systemVersion;

    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        frame.size.height=911;
        frame.size.width=768;

      }else{
          frame.size.height=655;
          frame.size.width=1024;
    }
    if([ver floatValue]>=6.0){
    _collectionView =[[UICollectionView alloc]initWithFrame:frame collectionViewLayout:collectionViewLayout];
    
    
    NSLog(@"viewdidload %f %f",_collectionView.frame.size.width,_collectionView.frame.size.height);

        [_collectionView registerClass:[Cell class] forCellWithReuseIdentifier:@"Cell"];
    _collectionView.dataSource=self;
    _collectionView.delegate=self;
        _collectionView.backgroundColor= [UIColor scrollViewTexturedBackgroundColor];
    [self.view addSubview:_collectionView];
    }else{
        PSUICollectionViewFlowLayout *collectionViewFlowLayout=[[PSUICollectionViewFlowLayout alloc]init];
        [collectionViewFlowLayout setScrollDirection:PSTCollectionViewScrollDirectionVertical];
        [collectionViewFlowLayout setItemSize:CGSizeMake(140, 180)];
        [collectionViewFlowLayout setSectionInset:UIEdgeInsetsMake(30, 30, 30, 30)];
        [collectionViewFlowLayout setMinimumInteritemSpacing:50];
        [collectionViewFlowLayout setMinimumLineSpacing:50];
        _dataSource=[[PSTCollectionDataSource alloc]init];
        _dataSource.array=_listOfBooks;
        _dataSource.controller=self;
        _dataSource.controllerCount=1;
        _pstCollectionView=[[PSUICollectionView alloc]initWithFrame:frame collectionViewLayout:collectionViewFlowLayout];
        [_pstCollectionView registerClass:[OldCell class] forCellWithReuseIdentifier:@"Cell"];

        _pstCollectionView.dataSource=_dataSource;
        _pstCollectionView.backgroundColor= [UIColor scrollViewTexturedBackgroundColor];
        [self.view addSubview:_pstCollectionView];
        /*
         self.itemSize = CGSizeMake(140, 180);
         self.scrollDirection = UICollectionViewScrollDirectionVertical;
         self.sectionInset = UIEdgeInsetsMake(30, 30.0, 30.0, 30.0);
         self.minimumLineSpacing = 50.0;
         self.minimumInteritemSpacing=50.0;
         self.footerReferenceSize=CGSizeMake(300, 300);
         */
  /*      _gridView= [[AQGridView alloc]initWithFrame:frame];
//        _gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _gridView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"wood_pattern.png"]];
        _gridView.contentInset=UIEdgeInsetsMake(20, 20.0, 20.0, 20.0);
        _gridView.layoutDirection=AQGridViewLayoutDirectionVertical;
////        _gridView.leftContentInset=30;
////        _gridView.rightContentInset=30; 
////        [_gridView setTopContentInset:30];
////        [_gridView setButtomContentInset:30];
        _gridView.dataSource=self;
        
       // _gridView.resizesCellWidthToFit=YES;
        _gridView.separatorStyle=AQGridViewCellSeparatorStyleEmptySpace;
       _gridView.bouncesZoom=NO;
        _gridView.bounces=NO;
//        
      //  _gridView.scrollEnabled=NO;
        [self.view addSubview:_gridView];
        [_gridView reloadData];
        _PsCollectionView=[[PSCollectionView alloc]initWithFrame:frame];
        _PsCollectionView.collectionViewDataSource=self;
        _PsCollectionView.collectionViewDelegate=self;
        
        _PsCollectionView.numColsLandscape=4;
        _PsCollectionView.numColsPortrait=3;
        
        [self.view addSubview:_PsCollectionView];
        [_PsCollectionView reloadData];*/
    }
  //  [self BuildButtons];
    if([UIDevice currentDevice].systemVersion.integerValue>=7)
    {
        // iOS 7 code here
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

-(void)restore:(id)sender{

    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    if (delegate.completedStorePopulation) {
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
                [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchased:
                
                
                break;
            case SKPaymentTransactionStateRestored:
                number=@(transaction.payment.productIdentifier.integerValue);
                books= [delegate.dataModel getBookById:number];
                [delegate.dataModel insertBookWithNo:books];
                
                [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
           
                break;
        }
    }///end for


}
-(void)transactionRestore{
    //[self BuildButtons];
    [self hideActivityIndicator];
}
-(void)transactionFailed{
    [self hideActivityIndicator];
}
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    [_alert dismissWithClickedButtonIndex:0 animated:YES];
    [AePubReaderAppDelegate hideAlertView];

}
- (void)signOut:(id)sender {
    NSString *signout=[[NSUserDefaults standardUserDefaults] objectForKey:@"baseurl"];
    signout =[signout stringByAppendingPathComponent:@"users/sign_out"];
    signout =[signout stringByAppendingFormat:@"?user[email]=%@&auth_token=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"email"],[[NSUserDefaults standardUserDefaults] objectForKey:@"auth_token"]];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:signout]];
    [request setHTTPMethod:@"GET"];
    NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
    [connection start];

    
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

        [diction setValue:arryMutable forKey:@"books"];
        NSData *json=[NSJSONSerialization dataWithJSONObject:diction options:NSJSONWritingPrettyPrinted error:nil];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:json];
        NSString *string=[[NSString alloc]initWithData:json encoding:NSUTF8StringEncoding];
        NSLog(@"%@",string);
         [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:syncIpad];
        [connection start];

    }
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"email"]){
    
        return;
    }
    if (!_purchase) {
      //  [self BuildButtons];
    }
      [Flurry logEvent:@"Downloads entered"];
    CGRect frame=self.view.bounds;
    
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        frame.size.height=911;
        frame.size.width=768;
    }else{
        frame.size.height=655;
        frame.size.width=1024;
    }
    _collectionView.frame=frame;
    _pstCollectionView.frame=frame;

}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    [Flurry logEvent:@"Downloads exited"];

    NSDate *closingTime = [NSDate date];
    NSTimeInterval timeOnView = [closingTime timeIntervalSinceDate:openingTime];
    NSString *timeOnViewString = [TimeRange getTimeRangeForTime:timeOnView];
    
    NSDictionary *dimensionDict = [NSDictionary dictionaryWithObjectsAndKeys:timeOnViewString, PARAMETER_TIME_RANGE, VIEW_STORE_FOR_ANALYTICS, PARAMETER_VIEW_NAME, nil];
    [PFAnalytics trackEvent:EVENT_TIME_ON_VIEW dimensions:dimensionDict];
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
    }
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
 //   [self BuildButtons];
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    //NSLog(@"library width %f %f",self.scrollView.frame.size.width,self.scrollView.frame.origin.x);
    //_interfaceOrientation=toInterfaceOrientation;
      
}
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    CGRect frame=self.view.bounds;

    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        frame.size.height=911;
        frame.size.width=768;
      
    }else{
        frame.size.height=655;
        frame.size.width=1024;

    }
    _collectionView.frame=frame;
    _pstCollectionView.frame=frame;

}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _listOfBooks.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
     Cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    Book *book=_listOfBooks[indexPath.row];
    
    cell.button.storeViewController=self;
    cell.button.libraryViewController=nil;
    cell.button.stringLink=book.link;
    cell.button.tag=[book.id integerValue];
          UIImage *image=[UIImage imageWithContentsOfFile:book.localPathImageFile];
     cell.button.imageLocalLocation=book.localPathImageFile;
    [ cell.button setImage:image forState:UIControlStateNormal];
    [ cell.button setAlpha:0.7];
    [cell.button addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    @try{
        NSURL *url=[[NSURL alloc]initFileURLWithPath:book.localPathImageFile];
        NSError *error=nil;
        [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
        // [url release];
    }@catch (NSException *e) {
        
    }
    return cell;
}

/*-(AQGridViewCell *)gridView:(AQGridView *)gridView cellForItemAtIndex:(NSUInteger)index{
    static NSString * EmptyIdentifier = @"EmptyIdentifier";
    static NSString * CellIdentifier = @"CellIdentifier";
    if ( index == NSNotFound )
    {
        NSLog( @"Loading empty cell at index %u", index );
        AQGridViewCell * hiddenCell = [gridView dequeueReusableCellWithIdentifier: EmptyIdentifier];
        if ( hiddenCell == nil )
        {
            // must be the SAME SIZE AS THE OTHERS
            // Yes, this is probably a bug. Sigh. Look at -[AQGridView fixCellsFromAnimation] to fix
            hiddenCell = [[AQGridViewCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 72.0, 72.0)
                                               reuseIdentifier: EmptyIdentifier];
        }
        
        hiddenCell.hidden = YES;
        return ( hiddenCell );
    }
    OldCell *cell=(OldCell *)[gridView dequeueReusableCellWithIdentifier: CellIdentifier];
    if (cell==nil) {
        cell=[[OldCell alloc]initWithFrame:CGRectMake(0, 0,140, 180)];
    }
    Book *book=_listOfBooks[index];
    cell.button.storeViewController=self;
    cell.button.libraryViewController=nil;
    cell.button.stringLink=book.link;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (index==0&&delegate.addControlEvents) {
        cell.button.downloading=YES;
    }
    
    NSString *title=[NSString stringWithFormat:@"%@.jpg",book.id];
    NSString  *value=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    
    title=[value stringByAppendingPathComponent:title];
    UIImage *image=[UIImage imageWithContentsOfFile:title];
    cell.button.imageLocalLocation=title;
    cell.button.tag=[book.id integerValue];
    [cell.button setImage:image forState:UIControlStateNormal];
    [cell.button addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    return cell;

   // return  nil;
}*/
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
        
        NSLog(@"%@",book.localPathImageFile);
        UIImage *image=[UIImage imageWithContentsOfFile:book.localPathImageFile];
        button.imageLocalLocation=book.localPathImageFile;
        [button setImage:image forState:UIControlStateNormal];
        [button setAlpha:0.7];
        @try{
        NSURL *url=[[NSURL alloc]initFileURLWithPath:book.localPathImageFile];
        NSError *error=nil;
        [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
       // [url release];
        }@catch (NSException *e) {
            
        }
        UITapGestureRecognizer *Singletap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [button addGestureRecognizer:Singletap];
    
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
    if (_alert) {
          [ _alert dismissWithClickedButtonIndex:0 animated:YES];
    }
    [AePubReaderAppDelegate hideAlertView];
    
}
-(void)singleTap:(UIGestureRecognizer *)gesture{
    _buttonTapped=(UIButton *)gesture.view;
    [self DownloadBook:_buttonTapped];
}
-(void)tap:(id)gesture{
       UIMenuController *_menuController=[UIMenuController sharedMenuController];
    if (_menuController.menuVisible) {
        [_menuController setMenuVisible:NO animated:YES];
        return;
    }
  

    _buttonTapped=(UIButton *)gesture;
    ShadowButton *shadow=(ShadowButton *)gesture;
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
  //  [self BuildButtons];
    _listOfBooks=[delegate.dataModel getDataNotDownloaded];
    _dataSource.array=_listOfBooks;
    [_collectionView reloadData];
    
    [_pstCollectionView reloadData];
   
}


- (void)viewDidUnload {

   
    [self setScrollView:nil];
    [self setNetworkActivityIndicator:nil];
    [super viewDidUnload];
}
- (void)refreshButton:(id)sender {
    [self performSelectorInBackground:@selector(requestBooksFromServer) withObject:nil];

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
