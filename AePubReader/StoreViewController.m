//
//  StoreViewController.m
//  AePubReader
//
//  Created by Nikhil Dhavale on 24/09/12.
//
//

#import "StoreViewController.h"
#import "ASIHTTPRequest.h"
#import "AePubReaderAppDelegate.h"
#import <Foundation/Foundation.h>
#import "Book.h"
#import "AePubReaderAppDelegate.h"
#import "DataModelControl.h"
#import "Book.h"
#import "FileDownloader.h"
#import "ShadowButton.h"
#import "ListOfBooks.h"
#import "PopViewDetailsViewController.h"

@interface StoreViewController ()

@end

@implementation StoreViewController
-(void)setListOfBooks:(NSArray *)listOfBooks{
    _listOfBooks=nil;
    _listOfBooks=[[NSMutableArray alloc]initWithArray:listOfBooks];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.title=@"Purchased";
        self.tabBarItem.image=[UIImage imageNamed:@"purchased.png"];
        //[self requestBooksFromServer];
       //   _delegateApp=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        _purchase=NO;
        
    }
    return self;
}
-(void)requestBooksFromServer{
    
    _alert =[[UIAlertView alloc]init];
    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(139.0f-18.0f, 40.0f, 37.0f, 37.0f)];
    [indicator startAnimating];
    [_alert addSubview:indicator];
    [indicator release];
    [_alert setTitle:@"Loading...."];
    [_alert show];
    [_alert release];
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    NSString *temp;
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    temp=[userDefaults stringForKey:@"email"];
    [dictionary setValue:temp forKey:@"email"];
    temp=[userDefaults stringForKey:@"auth_token"];
    [dictionary setValue:temp forKey:@"auth_token"];
     NSLog(@"auth_token %@",temp);
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    [dictionary release];
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
    _connection=[[NSURLConnection alloc]initWithRequest:request delegate:books];
    [request release];
    [books release];
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
    
    self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc]initWithTitle:@"Sign Out" style:UIBarButtonItemStyleBordered target:self action:@selector(signOut:)]autorelease];
    self.navigationItem.rightBarButtonItem.tintColor=[UIColor grayColor];
    self.navigationItem.leftBarButtonItem=[[[UIBarButtonItem alloc]initWithTitle:@"Refresh" style:UIBarButtonItemStyleBordered target:self action:@selector(refreshButton:)]autorelease];
    self.navigationItem.leftBarButtonItem.tintColor=[UIColor grayColor];
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo1.png"]];
    self.navigationItem.titleView=imageView;
    [imageView release];
    //[self DrawShelf];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    if (!_purchase) {
        [self requestBooksFromServer];
    }
    
//    if (_alert) {
//        [_alert show];
//    }
   // [self requestBooksFromServer];
    
}
-(void)viewDidDisappear:(BOOL)animated{

}
-(void)DrawShelf{
    UIImage *image=[UIImage imageNamed:@"book-shelf.png"];
    
    int xmin=38.5,ymin=50+175;
    while (ymin<_ymax) {
        UIImageView *imageView =[[UIImageView alloc]initWithImage:image];
        CGRect frame=CGRectMake(xmin, ymin, imageView.frame.size.width, imageView.frame.size.height);
        ymin+=210+40;
        imageView.frame=frame;
        [self.scrollView addSubview:imageView];
        [imageView release];
    }
}
- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskLandscape;
    
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

-(void)BuildButtons{
    for (UIView *view in self.scrollView.subviews) {
        
              [view removeFromSuperview];
        
      
    }// remove alll views if any
    // add all views if any
    int xmin=75,ymin=50;
    int x,y;
    x=xmin;
    y=ymin;
 
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
   _listOfBooks= [delegate.dataModel getDataNotDownloaded];
    
    
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
        [url setResourceValue:[NSNumber numberWithBool: YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
        [url release];
        UITapGestureRecognizer *Singletap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [button addGestureRecognizer:Singletap];
        [Singletap release];
        //NSLog(@" x= %d",x);
               x=x+190;
        
        if (x+140>1024) {
            x=xmin;
            y=y+210+40;
        }
//        UILongPressGestureRecognizer *longPress=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(LongPress:)];
//        [button addGestureRecognizer:longPress];
     // [button setupView];
      //  button.viewController=self;
       // NSLog(@"viewcontroller retain count %d",[button.viewController retainCount]);
        [self.scrollView addSubview:button];
        [button release];
    }
    if (_alert) {
          [ _alert dismissWithClickedButtonIndex:0 animated:YES];
    }
 
    _alert=nil;
    
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
    [controller release];
    
    
    
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
    
    LibraryViewController *lib=(LibraryViewController *)_delegate;
    if (!lib.addControlEvents) {
        UIAlertView *down=[[UIAlertView alloc]initWithTitle:@"Downloading.." message:@"Cannot start downloading as previous download is not complete" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [down show];
        [down release];
        
        return;
    }
  
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *) [UIApplication sharedApplication].delegate;
    
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


- (void)dealloc {

    
    [_scrollView release];
    [super dealloc];
    _listOfBooks=nil;
    _connection=nil;
}
- (void)viewDidUnload {

   
    [self setScrollView:nil];
    [super viewDidUnload];
}
- (void)refreshButton:(id)sender {

    [self requestBooksFromServer];
    [self BuildButtons];
}
- (void)signOut:(id)sender {
    
    NSString *signout=[[NSUserDefaults standardUserDefaults] objectForKey:@"baseurl"];
    signout =[signout stringByAppendingPathComponent:@"users/sign_out"];
    signout =[signout stringByAppendingFormat:@"?user[email]=%@&auth_token=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"email"],[[NSUserDefaults standardUserDefaults] objectForKey:@"auth_token"]];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:signout]];
    [request setHTTPMethod:@"GET"];
    NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
    [request release];
    [connection autorelease];
}
-(void)defunct:(id)sender{
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        [self.tabBarController setSelectedIndex:0];
        return;
    }
    [self requestBooksFromServer];
}

@end
