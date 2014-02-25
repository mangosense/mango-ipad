//
//  LibraryViewController.m
//  AePubReader
//
//  Created by Nikhil Dhavale on 24/09/12.
//
//

#import "LibraryViewController.h"

#import "ShadowButton.h"
#import "FileDownloader.h"
#import "ShareButton.h"
#import "ViewControllerMailCustom.h"
#import "ShowViewController.h"
#import "ViewController.h"
#import "ZipArchive.h"
#import "CustomNavViewController.h"
#import "ViewControllerBaseUrl.h"
#import "Flurry.h"
#import "StatsViewController.h"
#import "LandscapeTextBookViewController.h"
#import "CollectionViewLayout.h"
#import "LibraryOldCell.h"
#import "LibraryCell.h"
#import "CoverViewController.h"
#import "Constants.h"
#import <Parse/Parse.h>
#import "TimeRange.h"
#import "PopViewDetailsViewController.h"
@interface LibraryViewController ()

@property (nonatomic, strong) NSDate *openingTime;

@end

@implementation LibraryViewController

@synthesize openingTime;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.title=@"My Books";
        self.tabBarItem.image=[UIImage imageNamed:@"library.png"];
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        delegate.addControlEvents=YES;
        _downloadFailed=NO;
        _allowOptions=YES;
        _recordButtonShow=NO;
    }
    return self;
}
-(void)DownloadComplete:(Book *)book{
   // [book retain];
    NSString *value=@"Book downloading ";
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    [dictionary setValue:book.id forKey:@"identity"];
    [dictionary setValue:book.title forKey:@"title"];
    [Flurry logEvent:value withParameters:dictionary];
    [self.tabBarController setSelectedIndex:0];
    [self reloadData];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
      delegate.addControlEvents=NO;
   // [self BuildButtons];
    //int xmin=75,ymin=50;
    //CGRectMake(x, y, 140, 180);
    CGRect rect;
    book.downloaded=@YES;
    book.downloadedDate=[NSDate date];
    [delegate.dataModel saveData:book];
    NSArray *array= [delegate.dataModel getAllUserBooks];
    _epubFiles=[[NSMutableArray alloc]initWithArray:array];
    [_pstcollectionView reloadData];
    [_collectionView reloadData];

    NSLog(@"orientation %d",self.interfaceOrientation);
    //if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
        rect=CGRectMake(40, 160, 126, 40);

  /*  }else{
        rect=CGRectMake(50, 185, 126, 40);
   
    }*/
    _dataSource.array=_epubFiles;
    [self.pstcollectionView reloadData];
    [self.collectionView reloadData];
    UIProgressView *progress=[[UIProgressView alloc]initWithFrame:rect];
    [(self.navigationItem.rightBarButtonItems)[0] setEnabled:NO];
    [self.view addSubview:progress];
    FileDownloader *downloader=[[FileDownloader alloc]initWithViewController:self];
    downloader.progress=progress;
    downloader.book=book;
    
   // [progress release];
    NSString *url= book.sourceFileUrl;
    NSURLRequest *request=[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:url ]];
   // [self.navigationItem.rightBarButtonItem setEnabled:NO];
  //  [progress release];
     NSString *string=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *lastComp=[NSString stringWithFormat:@"%@.epub",book.id];
    string=[string stringByAppendingPathComponent:lastComp];
    downloader.loc=string;
    NSFileManager *manager=[NSFileManager defaultManager];
    if ([manager fileExistsAtPath:string]) {
        [manager removeItemAtPath:string error:nil];
    }
     [manager createFileAtPath:string contents:nil attributes:nil];
    NSError *error=nil;
    NSURL *urlFile=[NSURL fileURLWithPath:string];
     [urlFile setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (error) {
        NSLog(@"error %@",error);
    }
    downloader.handle=[NSFileHandle fileHandleForUpdatingAtPath:string];
   // [downloader.handle retain];
    
    float size=[book.size floatValue];
    if (size!=0) {
        downloader.value=[book.size floatValue];

    }else{
        downloader.value=1.0f;
    }
  
    _deleteButton=NO;
    _recordButton=NO;
    NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:downloader];
    
   // [request release];
 //   [downloader release];
 //   [connection autorelease];
    [connection start];
    CGPoint point;
    point.y=0;
 //   [book release];
   // [self.scrollView setContentOffset:point animated:YES];
}

- (void)viewDidLoad
{
    openingTime = [NSDate date];
    
  //  self.navigationController.navigationBar.translucent = NO;
//    self.tabBarController.tabBar.translucent = NO;
    
    _emptyCellIndex=NSNotFound;
    [super viewDidLoad];
    UIBarButtonItem *editBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(DeleteButton:)];
    editBarButtonItem.tintColor=[UIColor grayColor];
    
    UIBarButtonItem *optionsItem=[[UIBarButtonItem alloc]initWithTitle:@"share" style:UIBarButtonItemStyleBordered target:self action:@selector(allowoptions:)];
    optionsItem.tintColor=[UIColor grayColor];
    UIBarButtonItem *recordButton=[[UIBarButtonItem alloc]initWithTitle:@"recording" style:UIBarButtonItemStyleBordered target:self action:@selector(showRecordButton:)];
    recordButton.tintColor=[UIColor grayColor];
    
    /*UIBarButtonItem *bookItem=[[UIBarButtonItem alloc]initWithTitle:@"stats" style:UIBarButtonItemStyleBordered target:self action:@selector(openStats:)];
    bookItem.tintColor=[UIColor grayColor];*/
   // NSLog(@"options retainCount %d",optionsItem.retainCount);
    _array=@[editBarButtonItem,optionsItem,recordButton];
   //  NSLog(@"options retainCount %d",optionsItem.retainCount);
  /*[recordButton release];
    [editBarButtonItem release];
    [optionsItem release];*/
    self.navigationItem.rightBarButtonItems=_array;

    //[_array release];
     if (![[NSUserDefaults standardUserDefaults]objectForKey:@"email"]) {
         
         UIBarButtonItem *leftLoginItem=[[UIBarButtonItem alloc]initWithTitle:@"Login" style:UIBarButtonItemStyleBordered target:self action:@selector(login:)];
         leftLoginItem.tintColor=[UIColor grayColor];
        /* UIBarButtonItem *settings=[[UIBarButtonItem alloc]initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(settings)];
         settings.tintColor=[UIColor grayColor];*/
         UIBarButtonItem *feedback=[[UIBarButtonItem alloc]initWithTitle:@"Feedback" style:UIBarButtonItemStyleBordered target:self action:@selector(feedback:)];
         feedback.tintColor=[UIColor grayColor];
         NSArray *aray=@[leftLoginItem/*,settings,*/,feedback];
         self.navigationItem.leftBarButtonItems=aray;
         [_signoutOrLogin setTitle:@"Login" forState:UIControlStateNormal];
     }else{
       /*  UIBarButtonItem *settings=[[UIBarButtonItem alloc]initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(settings)];
         settings.tintColor=[UIColor grayColor];*/
         UIBarButtonItem *feedback=[[UIBarButtonItem alloc]initWithTitle:@"Feedback" style:UIBarButtonItemStyleBordered target:self action:@selector(feedback:)];
         feedback.tintColor=[UIColor grayColor];
         self.navigationItem.leftBarButtonItems=@[feedback];
         [_signoutOrLogin setTitle:@"Sign Out" forState:UIControlStateNormal];
     }
  //  self.navigationItem.rightBarButtonItem.tintColor=[UIColor grayColor];
    _ymax=768+80;
    
  //  [self reloadData];

    _deleteButton=NO;
    _recordButton=NO;
    _showDeleteButton=NO;
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"wood_pattern.png"]];
    self.view.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo1.png"]];
    self.navigationItem.titleView=imageView;
  ///  [imageView release];
    self.navigationController.navigationBar.hidden=YES;
    // Do any additional setup after loading the view from its nib.
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.dataModel displayAllData];
    NSArray *temp=[delegate.dataModel getAllUserBooks];
    
    _epubFiles=[[NSArray alloc]initWithArray:temp];
    NSString *ver= [UIDevice currentDevice].systemVersion;
    CGRect frame=self.storeView.bounds;
    
  //  frame.size.height=1024;
   /* if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        frame.size.height=900;
        frame.size.width=1024;
        
    }else{
        frame.size.height=1024;
        frame.size.width=900;
    }*/
   // frame.size.height-=65;
    //frame.origin.y=65;
  //  self.storeView.autoresizesSubviews=YES;
  //  frame.origin.y=65;
    if([ver floatValue]>=6.0)
    {
    CollectionViewLayout *collectionViewLayout = [[CollectionViewLayout alloc] init];
        _collectionView =[[UICollectionView alloc]initWithFrame:frame collectionViewLayout:collectionViewLayout];

        [_collectionView registerClass:[LibraryCell class] forCellWithReuseIdentifier:@"Cell"];

    _collectionView.dataSource=self;
    _collectionView.delegate=self;
        _collectionView.backgroundColor= [UIColor scrollViewTexturedBackgroundColor];
        _collectionView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _collectionView.frame=frame;
  //  _collectionView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"wood_pattern.png"]];
        
    [self.storeView addSubview:_collectionView];
    }else{

        PSUICollectionViewFlowLayout *collectionViewFlowLayout=[[PSUICollectionViewFlowLayout alloc]init];
        [collectionViewFlowLayout setScrollDirection:PSTCollectionViewScrollDirectionVertical];
        [collectionViewFlowLayout setItemSize:CGSizeMake(140, 180)];
        [collectionViewFlowLayout setSectionInset:UIEdgeInsetsMake(30, 30, 30, 30)];
        [collectionViewFlowLayout setMinimumInteritemSpacing:50];
        [collectionViewFlowLayout setMinimumLineSpacing:50];
        _dataSource=[[PSTCollectionDataSource alloc]init];
        _dataSource.array=_epubFiles;
        _dataSource.controller=self;
        _dataSource.controllerCount=0;
        _pstcollectionView=[[PSUICollectionView alloc]initWithFrame:frame collectionViewLayout:collectionViewFlowLayout];
        [_pstcollectionView registerClass:[LibraryOldCell class] forCellWithReuseIdentifier:@"Cell"];
        
        _pstcollectionView.dataSource=_dataSource;
        _pstcollectionView.backgroundColor= [UIColor scrollViewTexturedBackgroundColor];
        _pstcollectionView.autoresizingMask=self.storeView.autoresizingMask;
        [self.storeView addSubview:_pstcollectionView];
   
       

       }
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"help"]){
        NSArray *array=@[@"large_one.png",@"large_two.png",@"large_three.png", @"large_four"];

        RootViewController *rootViewController=[[RootViewController alloc]initWithNibName:@"padContent" bundle:nil contentList:array] ;
        [self presentViewController:rootViewController animated:YES completion:nil];
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"help"];
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        delegate.PortraitOrientation=NO;
        delegate.LandscapeOrientation=YES;
    }
    _correctNavigation=NO;
    _nav=NO;
 
        [[self.tabBarController.view.subviews objectAtIndex:0] setFrame:CGRectMake(0, 0, 1024, 768)];
    
}

-(void)openStats:(id)sender{
    StatsViewController *stats=[[StatsViewController alloc]initWithNibName:@"StatsViewController" bundle:nil];
    [self presentViewController:stats animated:YES completion:nil];
    
}
-(IBAction)feedback:(id)sender{
    MFMailComposeViewController *mail;
    mail=[[MFMailComposeViewController alloc]init];
    [mail setSubject:@"Feed back for the App"];
    mail.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
    
    [mail setMailComposeDelegate:self];
    [mail setToRecipients:@[@"ios@mangosense.com"]];
   // [mail setMessageBody:body isHTML:NO];
    [self presentModalViewController:mail animated:YES];

    
}
- (IBAction)showStoreViewController:(id)sender {
    NewStoreCoverViewController *controller=[[NewStoreCoverViewController alloc]initWithNibName:@"NewStoreCoverViewController" bundle:nil];
  //  UINavigationController *navigationStore=[[UINavigationController alloc]initWithRootViewController:controller];
    //navigationStore.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
   // [self presentViewController:navigationStore animated:YES completion:nil];
    [UIView beginAnimations:@"View Flip" context:nil];
    [UIView setAnimationDuration:0.80];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                           forView:self.navigationController.view cache:NO];
    
    [self.navigationController pushViewController:controller animated:YES];
    [UIView commitAnimations];

    
}
-(void)settings{
    ViewControllerBaseUrl *viewController=[[ViewControllerBaseUrl alloc]initWithNibName:@"ViewControllerBaseUrl" bundle:nil];
    [self presentViewController:viewController animated:YES completion:nil];
}
-(void)login:(id)sender{
        [self.parentViewController.navigationController popToRootViewControllerAnimated:YES];
}
-(IBAction)showRecordButton:(id)sender{
    NSLog(@"record Button");
    
    if (!_recordButtonShow) {// if not shown
        UIBarButtonItem *item=_array[2];
        [item setTitle:@"Done"];
        [item setTintColor:[UIColor blueColor]];
        item=_array[0];
        [item setEnabled:NO];
        item=_array[1];
        [item setEnabled:NO];
        for (UITabBarItem *item in self.tabBarController.tabBar.items) {
            item.enabled=NO;
        }
        for (UIView *view in self.scrollView.subviews) {
            if([view isKindOfClass:[ShadowButton class]]){
                NSString *path=[[NSUserDefaults standardUserDefaults] objectForKey:@"recordingDirectory"];
             
                NSLog(@"%@",path);
               Book *book=  _epubFiles[view.tag];
                   path =[path stringByAppendingFormat:@"/%@",book.id];
                /*
                 Check if recording exists
                 */
               if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                    [[view.subviews lastObject] setHidden:NO];
                }
                
            }
        }
        if ([sender isMemberOfClass:[UIButton class]]) {
            UIButton *button=(UIButton *)sender;
            [button setTitle:@"Done" forState:UIControlStateNormal];
        }
    }else{ // if shown
        /*
        
         */
        UIBarButtonItem *item=_array[2];
        [item setTitle:@"Recording"];
        [item setTintColor:[UIColor grayColor]];
        item=_array[0];
        [item setEnabled:YES];
        item=_array[1];
        [item setEnabled:YES];
        for (UITabBarItem *item in self.tabBarController.tabBar.items) {
            item.enabled=YES;
        }
        /*for (UIView *view in self.scrollView.subviews) {
            if([view isKindOfClass:[ShadowButton class]]){


                [[view.subviews lastObject ] setHidden:YES];
            }
        }*/
        if ([sender isMemberOfClass:[UIButton class]]) {
            UIButton *button=(UIButton *)sender;
            [button setTitle:@"Recording" forState:UIControlStateNormal];
        }
    }
    _recordButton=YES;
    _recordButtonShow=!_recordButtonShow;

    [_collectionView reloadData];
    [_pstcollectionView reloadData];
}
-(void)allowoptions:(UIBarButtonItem *)sender{
  //   NSLog(@"options retainCount %d",_array.retainCount);
    if (_allowOptions) {
        UIBarButtonItem *item=_array[1];
        [item setTitle:@"Done"];
        [item setTintColor:[UIColor blueColor]];
        item=_array[0];
        [item setEnabled:NO];
        item=_array[2];
        [item setEnabled:NO];
       /* for (UIView *view in self.scrollView.subviews) {
            if ([view isKindOfClass:[ShadowButton class]]) {
              //  ShareButton *button=(ShareButton *)view;
                NSLog(@"Button views %d",view.subviews.count);
                [(view.subviews)[1] setHidden:NO];
            }
            
        }*/
        
        for (UITabBarItem *item in self.tabBarController.tabBar.items) {
            item.enabled=NO;
        }
    }else{
       /* for (UIView *view in self.scrollView.subviews) {
            if ([view isKindOfClass:[ShadowButton class]]) {
               // ShareButton *button=(ShareButton *)view;
                [(view.subviews)[1] setHidden:YES];
            }
            
        }*/
      [(self.navigationController.navigationItem.rightBarButtonItems)[0] setEnabled:NO];
        UIBarButtonItem *item=_array[1];
        [item setTitle:@"Share"];
        [item setTintColor:[UIColor grayColor]];
        item=_array[0];
        [item setEnabled:YES];
        item=_array[2];
        [item setEnabled:YES];

        for (UITabBarItem *item in self.tabBarController.tabBar.items) {
            item.enabled=YES;
        }
    }
    
    _allowOptions=!_allowOptions;
    [_pstcollectionView reloadData];
    [_collectionView reloadData];
   // UIActivityViewController *controller=[[UIActivityViewController alloc]init];
    
}

- (IBAction)switchTabs:(id)sender {
    UISegmentedControl *control=(UISegmentedControl *)sender;
    [self.tabBarController setSelectedIndex:control.selectedSegmentIndex];
}

-(IBAction)shareButtonClicked:(id)sender{
    ShareButton *buttonShadow=(ShareButton *)sender;

    NSString *ver= [UIDevice currentDevice].systemVersion;
  
    if([ver floatValue]>5.1){
        NSString *textToShare=[buttonShadow.stringLink stringByAppendingString:@" great bk from MangoReader"];
        
        
        UIImage *image=[UIImage imageWithContentsOfFile:buttonShadow.imageLocalLocation];
        NSArray *activityItems=@[textToShare,image];
        
        UIActivityViewController *activity=[[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
        activity.excludedActivityTypes=@[UIActivityTypeCopyToPasteboard,UIActivityTypePostToWeibo,UIActivityTypeAssignToContact,UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll];
        _popOverShare=[[UIPopoverController alloc]initWithContentViewController:activity];
        
      //  [activity release];
        [_popOverShare presentPopoverFromRect:buttonShadow.frame inView:buttonShadow.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
       
        return;
    }
    MFMailComposeViewController *mail;
    
    mail=[[MFMailComposeViewController alloc]init];
    [mail setSubject:@"Found this awesome interactive book on MangoReader"];
    mail.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
    [mail setMailComposeDelegate:self];
    NSString *body=[NSString stringWithFormat:@"Hi,\n%@",buttonShadow.stringLink];
    body =[body stringByAppendingString:@"\nI found this cool book on mangoreader - we bring books to life.The book is interactive with the characters moving on touch and movement, which makes it fun and engaging.The audio and text highlight syncing will make it easier for kids to learn and understand pronunciation.Not only this, I can play cool games in the book, draw and make puzzles and share my scores.\nDownload the MangoReader app from the appstore and try these awesome books."];
    [mail setMessageBody:body isHTML:NO];
    [self presentModalViewController:mail animated:YES];
   // [mail release];


}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
  
    [controller dismissModalViewControllerAnimated:YES];
    
}
-(IBAction)DeleteButton:(id)sender{
    NSLog(@"Edit Button clicked");
    if (_showDeleteButton) {
      /*  for (UIView *view in self.scrollView.subviews) {
            if ([view isKindOfClass:[UIButton class]]&&![view isKindOfClass:[ShadowButton class]]) {
                [view removeFromSuperview];
            }
           
        }*/
        _showDeleteButton=NO;
       // [self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
        for (UITabBarItem *item in self.tabBarController.tabBar.items) {
            item.enabled=YES;
        }
        UIBarButtonItem *item=_array[0];
        [item setTitle:@"Edit"];
        item=_array[1];
        [item setEnabled:YES];
        item=_array[2];
        [item setEnabled:YES];
        [_collectionView reloadData];
        [_pstcollectionView reloadData];
        _deleteButton=YES;
        return;/// end of exceution
    }
    if (_epubFiles.count!=0) {
        for (UITabBarItem *item in self.tabBarController.tabBar.items) {
            item.enabled=NO;
        }
    }
    _deleteButton=YES;
    [_pstcollectionView reloadData];
    [_collectionView reloadData];
    NSLog(@"Total %d",_epubFiles.count);
    
  //  [self addDeleteButton];

      _showDeleteButton=YES;
    UIBarButtonItem *item=_array[0];
    [item setTitle:@"Done"];
    item=_array[1];
    [item setEnabled:NO];
    item=_array[2];
    [item setEnabled:NO];
    
}
-(void)addDeleteButton{
    int xmin=60,ymin=40;
    int xinc=190;
    int perrow=5;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        xmin-=25;
        ymin-=20;
        xinc=180;
        perrow=4;
    }
    int x=xmin;
    int y=ymin;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    for (int i=1; i<=_epubFiles.count; i++) {
       
        if (i==1&&!delegate.addControlEvents) {
         
            return;
        }
         UIButton *button=[[UIButton alloc]init];
    [button setImage:[UIImage imageNamed:@"closebutton.png"] forState:UIControlStateNormal];
        button.frame=CGRectMake(x, y, 48, 48);
       
        x=x+xinc;
        if (i%perrow==0&&i!=0) {
            x=xmin;
            y=y+210+40;
        }
        
        button.tag=i-1;
        [button addTarget:self action:@selector(DeleteBook:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.scrollView addSubview:button];
    }

}
-(void)AddShareButton:(id)sender{
    
}
-(void)DeleteBook:(UIButton *)book{
  
    
    
   Book *bk= _epubFiles[book.tag];
    _index=book.tag;
    NSLog(@"Index %d",_index);
    NSString *alertViewMessage=[NSString stringWithFormat:@"Do you wish to delete book titled %@ ?",bk.title ];
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Delete Book" message:alertViewMessage delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    alertView.tag=300;
    [alertView show];
    
  }
-(void)DrawShelf{
    
    
    UIImage *image=[UIImage imageNamed:@"book-shelf.png"];
    int xmin=27,ymin=50+175;
    float width=974;
      UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation)){
        xmin=10;
        ymin=30+175;
        width=748;
        
    }
    else if(self.interfaceOrientation==0&&UIInterfaceOrientationIsPortrait(orientation)){
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
-(void)sigOut:(UIBarButtonItem *)button{
    NSString *signout=[[NSUserDefaults standardUserDefaults] objectForKey:@"baseurl"];
    signout =[signout stringByAppendingPathComponent:@"users/sign_out"];
    signout =[signout stringByAppendingFormat:@"?user[email]=%@&auth_token=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"email"],[[NSUserDefaults standardUserDefaults] objectForKey:@"auth_token"]];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:signout]];
    [request setHTTPMethod:@"GET"];
    NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
    [connection start];

      
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"%@",error);
    
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{

    
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{

    [self.parentViewController.navigationController popViewControllerAnimated:YES];
    
    
    
}
-(void)tap:(UIGestureRecognizer*)gesture{
    UITapGestureRecognizer *gest=(UITapGestureRecognizer *)gesture;
    NSLog(@" %d",gest.numberOfTapsRequired);
    if (_allowOptions) {
        [self singleTap:gesture];
        return;
    }
    NSString *ver= [UIDevice currentDevice].systemVersion;
     _buttonTapped=(ShadowButton *)gesture.view;
    ShadowButton *buttonShadow=(ShadowButton *)gesture.view;
    if([ver floatValue]>5.1){
        NSString *textToShare=[buttonShadow.stringLink stringByAppendingString:@" great bk from MangoReader"];
        
        
        UIImage *image=[UIImage imageWithContentsOfFile:buttonShadow.imageLocalLocation];
        NSArray *activityItems=@[textToShare,image];
        
        UIActivityViewController *activity=[[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
        activity.excludedActivityTypes=@[UIActivityTypeCopyToPasteboard,UIActivityTypePostToWeibo,UIActivityTypeAssignToContact,UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll];
        UIPopoverController *pop=[[UIPopoverController alloc]initWithContentViewController:activity];
        
      //  [activity release];
        [pop presentPopoverFromRect:_buttonTapped.frame inView:self.scrollView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        //[pop release];
        return;
    }
    ViewControllerMailCustom *mail;
  
    mail=[[ViewControllerMailCustom alloc]init];
    [mail setSubject:@"Found this awesome interactive book on MangoReader"];
    mail.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
    
    [mail setMailComposeDelegate:self];
    NSString *body=[NSString stringWithFormat:@"Hi,\n%@",buttonShadow.stringLink];
    body =[body stringByAppendingString:@"\nI found this cool book on mangoreader - we bring books to life.The book is interactive with the characters moving on touch and movement, which makes it fun and engaging.The audio and text highlight syncing will make it easier for kids to learn and understand pronunciation.Not only this, I can play cool games in the book, draw and make puzzles and share my scores.\nDownload the MangoReader app from the appstore and try these awesome books."];
    [mail setMessageBody:body isHTML:NO];
    [self presentModalViewController:mail animated:YES];

}


-(void)reloadData{

    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.dataModel displayAllData];
    NSArray *temp=[delegate.dataModel getAllUserBooks];

    _epubFiles=[[NSArray alloc]initWithArray:temp];
  /*  if (_epubFiles.count==0) {

        _showDeleteButton=NO;
        [(self.navigationItem.rightBarButtonItems)[0] setTitle:@"Edit"];
        for (UITabBarItem *item in self.tabBarController.tabBar.items) {
            item.enabled=YES;
        }
        [self.tabBarController setSelectedIndex:1];
    }
    UIInterfaceOrientation orientation=[[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        _ymax=1024+80;
        if (_epubFiles.count>16) {
            NSInteger extra=_epubFiles.count-16;
            if (extra%4!=0) {
                extra=extra/4;
                extra++;
            }else{
                extra=extra/4;
                
            }
            _ymax+=(260*extra);
        }
    }else if(self.interfaceOrientation==0&&UIInterfaceOrientationIsPortrait(orientation)){
        _ymax=1024+80;
        if (_epubFiles.count>16) {
            NSInteger extra=_epubFiles.count-16;
            if (extra%4!=0) {
                extra=extra/4;
                extra++;
            }else{
                extra=extra/4;
                
            }
            _ymax+=(260*extra);
        }

    }
    else {//landscape
    _ymax=768+200;
    if (_epubFiles.count>15) {
        NSInteger extra=_epubFiles.count-15;
        
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
    NSLog(@"Ymax %d",_ymax);
    [self.scrollView setContentSize:size];*/

}
-(void)setDownloadFailed:(BOOL)downloadFailed{
    if (downloadFailed) {
        [self reloadData];
      //  [self BuildButtons];
    }
    _downloadFailed=downloadFailed;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    UIInterfaceOrientation orientation=UIInterfaceOrientationIsPortrait(self.interfaceOrientation);
    orientation=[UIApplication sharedApplication].statusBarOrientation;
    if (_correctNavigation||UIInterfaceOrientationIsPortrait(self.interfaceOrientation)||UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        UIViewController *c=[[UIViewController alloc]init];
        c.view.backgroundColor=[UIColor clearColor];
        [self presentViewController:c animated:YES completion:^(void){
            [c dismissViewControllerAnimated:YES completion:nil];
        }];
        _correctNavigation=NO;
    }
    [_segmentedControl setSelectedSegmentIndex:0];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.PortraitOrientation=NO;
    delegate.LandscapeOrientation=YES;
  //  [UIViewController attemptRotationToDeviceOrientation];
    [[self.tabBarController.view.subviews objectAtIndex:0] setFrame:CGRectMake(0, 0, 1024, 768)];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

  /*  CGRect frame=self.view.bounds;
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        frame.size.height=911;
        frame.size.width=768;
    }else{
        frame.size.height=655;
        frame.size.width=1024;
    }
    _collectionView.frame=frame;
    _pstcollectionView.frame=frame;*/
    [self.tabBarController.tabBar setHidden:YES];
    self.navigationController.navigationBarHidden=YES;
    self.navigationController.navigationBar.hidden=YES;
  //  [AePubReaderAppDelegate hideTabBar:self.tabBarController];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [Flurry logEvent:@"Library entered"];
}
-(void)delay{

}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [Flurry logEvent:@"Library exited"];
    NSDate *closingTime = [NSDate date];
    NSTimeInterval timeOnView = [closingTime timeIntervalSinceDate:openingTime];
    
    NSString *timeRange = [TimeRange getTimeRangeForTime:timeOnView];
    NSDictionary *dimesionsDict = [NSDictionary dictionaryWithObjectsAndKeys:timeRange, PARAMETER_TIME_RANGE, VIEW_MY_BOOKS_FOR_ANALYTICS, PARAMETER_VIEW_NAME, nil];
    [PFAnalytics trackEvent:EVENT_TIME_ON_VIEW dimensions:dimesionsDict];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    NSLog(@"library width %f %f",self.scrollView.frame.size.width,self.scrollView.frame.origin.x);
    // [self BuildButtons];
    if (_showDeleteButton) {
        [self addDeleteButton];
    }

}
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    /*CGRect frame=self.view.bounds;

    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        frame.size.height=911;
        frame.size.width=768;
    } else {
        frame.size.height=655;
        frame.size.width=1024;
    }
    _collectionView.frame=frame;
    _pstcollectionView.frame=frame;*/
    if (_showDeleteButton) {
        [self addDeleteButton];
    }
}
-(void)viewDidDisappear:(BOOL)animated{
  /*  if (_alertView) {
        [_alertView dismissWithClickedButtonIndex:0 animated:YES];
        //_alertView=nil;
    }*/
    [AePubReaderAppDelegate hideAlertView];
   
}
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return _epubFiles.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    LibraryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    Book *book=_epubFiles[indexPath.row];
    cell.button.storeViewController=nil;
    cell.button.libraryViewController=self;
    cell.button.stringLink=book.link;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;

    if (indexPath==0&&delegate.addControlEvents) {
        cell.button.downloading=YES;
    }
    NSLog(@"title %@",book.title);
    NSString *title=[NSString stringWithFormat:@"%@.jpg",book.id];
    NSString  *value=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];

    title=[value stringByAppendingPathComponent:title];
    UIImage *image=[UIImage imageWithContentsOfFile:title];
    cell.button.imageLocalLocation=title;
    cell.button.tag=indexPath.row;
    [cell.button setImage:image forState:UIControlStateNormal];
    if (book.downloaded.boolValue) {
        
        [cell.button addTarget:self action:@selector(showBookButton:) forControlEvents:UIControlEventTouchUpInside];
  
    }else{
        [cell.button addTarget:self action:@selector(showPopupToDownload:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    cell.button.downloaded=book.downloaded.boolValue;

    cell.button.bookId=book.id.integerValue;
    cell.shareButton.hidden=YES;
    cell.buttonDelete.hidden=YES;
    if (!_allowOptions) {
    
        cell.shareButton.imageLocalLocation=title;
        cell.shareButton.tag=indexPath.row;
        
       
  
        cell.shareButton.stringLink=book.link;
        [cell.shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.shareButton setHidden:NO];
    

          
    }else if(_allowOptions){
        cell.shareButton.hidden=YES;
    }
    if (_recordButton) {
        
      
        if (_recordButtonShow) {
            NSString *path=[[NSUserDefaults standardUserDefaults] objectForKey:@"recordingDirectory"];
            
            NSLog(@"%@",path);
            
            path =[path stringByAppendingFormat:@"/%@",book.id];
            /*
             Check if recording exists
             */
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            

             cell.showRecording.tag=[book.id integerValue];
            [cell.showRecording addTarget:self action:@selector(RecordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            cell.showRecording.hidden=NO;}
        }else{
            cell.showRecording.hidden=YES;
        }
       
    }
    if(_deleteButton){
        if(_showDeleteButton){
            cell.buttonDelete.tag=indexPath.row;
            [cell.buttonDelete addTarget:self action:@selector(DeleteBook:) forControlEvents:UIControlEventTouchUpInside];
            cell.buttonDelete.hidden=NO;
        }else{
            cell.buttonDelete.hidden=YES;
            
        }
    }
    if(_epubFiles.count-1==indexPath.row){
    _recordButton=NO;
        _deleteButton=NO;
    }
    return cell;
}
-(void)showPopupToDownload:(id)sender{
    _buttonTappedToDownload=(UIButton *)sender;
    ShadowButton *shadow=(ShadowButton *)sender;
    if (shadow.downloaded) {
        return;
    }
    PopViewDetailsViewController *controller=[[PopViewDetailsViewController alloc]initWithNibName:@"PopViewDetailsViewController" bundle:nil imageLocation:shadow.imageLocalLocation indentity:shadow.bookId];

    controller.view.frame=CGRectMake(50, 60, 300, 300);
    controller.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    controller.modalPresentationStyle=UIModalPresentationFormSheet;
    controller.controller=self;
    
   // controller.bookId=shadow.bookId;
      //controller.imageLocation=shadow.imageLocalLocation;
  //  controller.store=self;
    
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:controller];
    nav.modalPresentationStyle=UIModalPresentationFormSheet;
    nav.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:nav animated:YES];
    
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"indexpath %d",indexPath.row);
    
    
}
-(void)BuildButtons{
    UIProgressView *prog=nil;
    for (UIView *view in self.scrollView.subviews) {
        if (![view isKindOfClass:[UIProgressView class]]) {
            [view removeFromSuperview];   
        }
        else{
             prog=(UIProgressView *)view;
            CGRect rect;
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
               rect =CGRectMake(73, 195, 126, 40);
               
            }else{
           
           rect=CGRectMake(45, 185, 126, 40);
           
            }
             prog.frame=rect;
        }
       
       
    }// remove alll views if any
    // add all views if any
    [self reloadData];  
 //   [self DrawShelf];
    int xmin=65,ymin=50;
    int x,y;
    int xinc=190;
    x=xmin;
    y=ymin;

    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    NSLog(@"orientation %d",orientation);
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        
        //here xmax will reduce
        xmin-=25;
        x=xmin;
        y-=20;
        xinc=180;
        
    }
    if (self.interfaceOrientation==0&&UIInterfaceOrientationIsPortrait(orientation)) {
        xmin-=25;
        x=xmin;
        y-=20;
        xinc=180;
    }
   
          NSString  *value=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    for (int i=0;i<_epubFiles.count;i++) {
        CGRect rect=CGRectMake(x, y, 140, 180);
        ShadowButton *button=[[ShadowButton alloc]init];
        Book *book=_epubFiles[i];
        button.storeViewController=nil;
        button.libraryViewController=self;
        button.frame=rect;
        button.tag=i;
        button.stringLink=book.link;
        
          if (i==0&&delegate.addControlEvents) {
            button.downloading=YES;
        }
        
        
        //NSLog(@" x= %d",x);
               
        NSString *title=[NSString stringWithFormat:@"%@.jpg",book.id];
       
        
        title=[value stringByAppendingPathComponent:title];
        UIImage *image=[UIImage imageWithContentsOfFile:title];
        button.imageLocalLocation=title;
        ShareButton *shareButton=[[ShareButton alloc]init];
        shareButton.imageLocalLocation=title;
        shareButton.tag=i;
         [button setImage:image forState:UIControlStateNormal];
        image=[UIImage imageNamed:@"actions.png"];
        shareButton.frame=CGRectMake(40, 70, 72, 72);
        [shareButton setImage:image forState:UIControlStateNormal];
        [shareButton setHidden:YES];
        shareButton.stringLink=book.link;
        [shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [button addSubview:shareButton];
      //  [shareButton release];
        image=[UIImage imageNamed:@"bookshadow.png"];
        [button setBackgroundColor:[UIColor colorWithPatternImage:image]];
        UIButton *showRecording=[[UIButton alloc]initWithFrame:CGRectMake(40, 70, 66, 66)];
        image=[UIImage imageNamed:@"record-control.png"];
        [showRecording setImage:image forState:UIControlStateNormal];
        [showRecording setHidden:YES];
        showRecording.tag=[book.id integerValue];
        [showRecording addTarget:self action:@selector(RecordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [button addSubview:showRecording];

          NSLog(@"File name %@",title);

        x=x+xinc;
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)&&x+140>1024) {
            x=xmin;
            y=y+250;
        }else if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation)&&x+140>780){
            x=xmin;
            y=y+250;
        }else
        {
            if(self.interfaceOrientation==0&&UIInterfaceOrientationIsPortrait(orientation)&&x+140>780){
            x=xmin;
            y=y+250;
        }
        else if(self.interfaceOrientation==0&&x+140>1024){
            x=xmin;
            y=y+250;
        }
        }
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
              [button addGestureRecognizer:tap];
      
        [self.scrollView addSubview:button];

      
    }
    if (prog) {
        [self.scrollView bringSubviewToFront:prog];
    }
 
    
}
-(void)RecordButtonClicked:(id)sender{
    UIButton *button=(UIButton *)sender;

    ShowViewController *showViewController=[[ShowViewController alloc]initWithNibName:@"ShowViewController" bundle:nil with:button.tag ];
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:showViewController];
   _popRecording=[[UIPopoverController alloc]initWithContentViewController:nav];
    showViewController.pop=_popRecording;
 
    [_popRecording presentPopoverFromRect:button.frame inView:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}
-(void)singleTap:(UIGestureRecognizer *)singleTap{
    _buttonTapped=(UIButton *)singleTap.view;
  
    [self showBookButton:_buttonTapped];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showBookButton:(id)sender {
    if (_showDeleteButton||_recordButtonShow) {
        return;
    }
    _buttonTapped=(UIButton *)sender;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    if (_buttonTapped.tag==0&&delegate.addControlEvents==NO) {
        return;
    }
   /* _alertView =[[UIAlertView alloc]init];

    delegate.alertView=_alertView;
    [_alertView setDelegate:self];
   
    UIImage *image=[UIImage imageNamed:@"loading.png"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-40, -160, 391, 320)];
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;
    
    imageView.image=image;
    [_alertView addSubview:imageView];
    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(125, 25, 66.0f, 66.0f)];
    indicator.color=[UIColor blackColor];
        [indicator startAnimating];
       [_alertView addSubview:indicator];

    [_alertView show];
    _alertView.tag=2;*/
    [AePubReaderAppDelegate showAlertViewiPad];
    [AePubReaderAppDelegate getAlertView].tag=2;
    [[AePubReaderAppDelegate getAlertView] setDelegate:self];
    Book *iden=_epubFiles[_buttonTapped.tag];
    _index=_buttonTapped.tag;
    [[NSUserDefaults standardUserDefaults] setInteger:[iden.id integerValue] forKey:@"bookid"];
    _index=_buttonTapped.tag;
    
}

- (IBAction)switchTabButtonClick:(id)sender {
    UIButton *button=(UIButton *)sender;
    [self.tabBarController setSelectedIndex:button.tag];

}

- (IBAction)refreshWithLatest:(id)sender {
    [self performSelectorInBackground:@selector(requestBooksFromServer) withObject:nil];
}
/*Function Name : getRootFilePath
 *Return Type   : NSString - Returns the path to container.xml
 *Parameters    : nil
 *Purpose       : To find the path to container.xml.This file contains the file name which holds the epub informations
 */

- (NSString*)getRootFilePath{
	
	//check whether root file path exists
	NSFileManager *filemanager=[[NSFileManager alloc] init];
    NSInteger iden=[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"];

    
    NSString *strFilePath=[NSString stringWithFormat:@"%@/%d/META-INF/container.xml",[self applicationDocumentsDirectory],iden];
	if ([filemanager fileExistsAtPath:strFilePath]) {
		
		//valid ePub
		NSLog(@"Parse now");

		
		return strFilePath;
	}
	else {
		
		//Invalid ePub file
		UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error"
													  message:@"Delete the book and download it again"
													 delegate:self
											cancelButtonTitle:@"OK"
											otherButtonTitles:nil];
		[alert show];
			
	}
	filemanager=nil;
	return @"";
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    
    return YES;
}
- (void)foundRootPath:(NSString*)rootPath{
	
	//Found the path of *.opf file
	
	//get the full path of opf file

    NSInteger iden=[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"];
    
    NSString *strOpfFilePath=[NSString stringWithFormat:@"%@/%d/%@",[self applicationDocumentsDirectory],iden,rootPath];
	NSFileManager *filemanager=[[NSFileManager alloc] init];
	
	self.rootPath=[strOpfFilePath stringByReplacingOccurrencesOfString:[strOpfFilePath lastPathComponent] withString:@""];
	
	if ([filemanager fileExistsAtPath:strOpfFilePath]) {
		
		//Now start parse this file
		[_xmlhandler parseXMLFileAt:strOpfFilePath];
	}
	else {
		
		UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error"
													  message:@"OPF File not found"
													 delegate:self
											cancelButtonTitle:@"OK"
											otherButtonTitles:nil];
		[alert show];

	}

	
}
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? paths[0] : nil;
    return basePath;
}
/*Function Name : unzipAndSaveFile
 *Return Type   : void
 *Parameters    : nil
 *Purpose       : To unzip the epub file to documents directory
 */

- (void)unzipAndSaveFile:(NSString *)epubLoc{
	//[epubLoc retain];
	ZipArchive* za = [[ZipArchive alloc] init];
	if( [za UnzipOpenFile:epubLoc] ){
        NSInteger iden=[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"];
		NSString *strPath=[NSString stringWithFormat:@"%@/%d",[self applicationDocumentsDirectory],iden];
        //Delete all the previous files
		NSFileManager *filemanager=[[NSFileManager alloc] init];
		if ([filemanager fileExistsAtPath:strPath]) {
			
			NSError *error;
			[filemanager removeItemAtPath:strPath error:&error];
		}
		//start unzip
		BOOL ret = [za UnzipFileTo:[NSString stringWithFormat:@"%@/",strPath] overWrite:YES];
		if( NO==ret ){
			// error handler here
			UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error"
														  message:@"An unknown error occured"
														 delegate:self
												cancelButtonTitle:@"OK"
												otherButtonTitles:nil];
			[alert show];
		}
		[za UnzipCloseFile];
	}
}
-(void)didPresentAlertView:(UIAlertView *)alertView{
    if (alertView.tag==300) {
        return;
    }
    _nav=YES;
    _correctNavigation=YES;
       Book *bk=_epubFiles[_index];
    NSString  *value;
    NSString *epubString;
    ViewController *viewController;
    EpubReaderViewController *reader;
    AePubReaderAppDelegate *delegate;
    LandscapeTextBookViewController *landscapeTextBook;
    NSLog(@"title %@",bk.title);
    if (!bk.textBook) {
        delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        delegate.PortraitOrientation=NO;
        delegate.LandscapeOrientation=YES;
        
        value=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
        epubString=[NSString stringWithFormat:@"%@.epub",bk.id];
        value=[value stringByAppendingPathComponent:epubString];
        NSLog(@"Path value: %@",value);
        reader=[[EpubReaderViewController alloc]initWithNibName:@"View" bundle:nil];
        reader._strFileName=value;
        
        ShadowButton *button=(ShadowButton *)_buttonTapped;
        reader.imageLocation=button.imageLocalLocation;
        reader.url=button.stringLink;
        self.tabBarController.hidesBottomBarWhenPushed=YES;
        reader.hidesBottomBarWhenPushed=YES;
        reader.titleOfBook=bk.title;
        [self.navigationController pushViewController:reader animated:YES];
        if ([UIDevice currentDevice].systemVersion.integerValue<6) {
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
        }

        return;
    }
    ShadowButton *button;
    CoverViewController *coverViewController;
    NSLog(@"id %d",bk.textBook.integerValue);
    switch (bk.textBook.integerValue) {
        case 1://storyBooks
        {
            NSDictionary *bookTappedDimensions = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", [bk.id intValue]], PARAMETER_BOOK_ID, bk.title, PARAMETER_BOOK_TITLE, VIEW_MY_BOOKS_FOR_ANALYTICS, PARAMETER_VIEW_NAME, nil];
            [PFAnalytics trackEvent:EVENT_BOOK_TAPPED dimensions:bookTappedDimensions];
            
            delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
            delegate.PortraitOrientation=NO;
            delegate.LandscapeOrientation=YES;
            
            value=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            
            epubString=[NSString stringWithFormat:@"%@.epub",bk.id];
            value=[value stringByAppendingPathComponent:epubString];
            NSLog(@"Path value: %@",value);
            /*       reader=[[EpubReaderViewController alloc]initWithNibName:@"View" bundle:nil];
            reader._strFileName=value;
          
            button=(ShadowButton *)_buttonTapped;
            if (button.imageLocalLocation) {
                reader.imageLocation=button.imageLocalLocation;
            }
            
            reader.url=button.stringLink;
            self.tabBarController.hidesBottomBarWhenPushed=YES;
            reader.hidesBottomBarWhenPushed=YES;
            reader.titleOfBook=bk.title;
            [self.navigationController pushViewController:reader animated:YES];*/
            coverViewController=[[CoverViewController alloc]initWithNibName:@"CoverViewController" bundle:nil];
            coverViewController._strFileName=value;
            button=(ShadowButton *)_buttonTapped;

            if (button.imageLocalLocation) {
                coverViewController.imageLocation=button.imageLocalLocation;
                
            }
            coverViewController.url=button.stringLink;
          //      self.tabBarController.hidesBottomBarWhenPushed=YES;
            //coverViewController.hidesBottomBarWhenPushed=YES;
            coverViewController.titleOfBook=bk.title;
            [self.navigationController pushViewController:coverViewController animated:YES];
            if ([UIDevice currentDevice].systemVersion.integerValue<6) {
                [alertView dismissWithClickedButtonIndex:0 animated:YES];
            }
    }

            break;
        case 2://textBooks
           delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
            delegate.LandscapeOrientation=NO;
            delegate.PortraitOrientation=YES;
            value=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            
            epubString=[NSString stringWithFormat:@"%@.epub",bk.id];
            value=[value stringByAppendingPathComponent:epubString];
            NSLog(@"Path value: %@",value);
            viewController=[[ViewController alloc]initWithNibName:@"ViewController" bundle:nil WithString:value];
            viewController.titleOfBook=bk.title;
            viewController.identity=bk.id.integerValue;
            self.tabBarController.hidesBottomBarWhenPushed=YES;
            viewController.hidesBottomBarWhenPushed=YES;
            self.navigationController.navigationBarHidden=YES;
                [self.navigationController pushViewController:viewController animated:YES];
            if ([UIDevice currentDevice].systemVersion.integerValue<6) {
                [alertView dismissWithClickedButtonIndex:0 animated:YES];
            }
            
            break;
        case 3:
            delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
            delegate.LandscapeOrientation=YES;
            delegate.PortraitOrientation=NO;
            value=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            
            epubString=[NSString stringWithFormat:@"%@.epub",bk.id];
            value=[value stringByAppendingPathComponent:epubString];
            landscapeTextBook=[[LandscapeTextBookViewController alloc]initWithNibName:@"LandscapeTextBookViewController" bundle:nil WithString:value];
            landscapeTextBook.titleOfBook=bk.title;
            landscapeTextBook.identity=bk.id.integerValue;
            self.tabBarController.hidesBottomBarWhenPushed=YES;
            landscapeTextBook.hidesBottomBarWhenPushed=YES;
            self.navigationController.navigationBarHidden=YES;
            [self.navigationController pushViewController:landscapeTextBook animated:YES];
            if ([UIDevice currentDevice].systemVersion.integerValue<6) {
                [alertView dismissWithClickedButtonIndex:0 animated:YES];
            }
        default:
            break;
    }
    [AePubReaderAppDelegate hideAlertView];

  }

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==300&&buttonIndex==1) {
        Book *bk=_epubFiles[_index];
        NSString *val=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *bkl=[NSString stringWithFormat:@"%@",bk.id];
        val =[val stringByAppendingPathComponent:bkl];
        if ([[NSFileManager defaultManager] fileExistsAtPath:val]) {
             [[NSFileManager defaultManager]removeItemAtPath:val error:nil];
        }
        val=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        bkl=[NSString stringWithFormat:@"%@.epub",bk.id];
        val=[val stringByAppendingPathComponent:bkl];
        if ([[NSFileManager defaultManager]fileExistsAtPath:val]) {
             [[NSFileManager defaultManager]removeItemAtPath:val error:nil];
        }
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        bkl=[NSString stringWithFormat:@"%@",bk.id];
        bk=[delegate.dataModel getBookOfId:bkl ];
        NSLog(@"book deleted :%@",bk.title);
        bk.downloaded=@NO;
        [delegate.dataModel saveData:bk];
        _epubFiles=[delegate.dataModel getDataDownloaded];

            _deleteButton=YES;
   
        _dataSource.array=_epubFiles;
        [_pstcollectionView reloadData];
        [_collectionView reloadData];
  
    }
       

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
   // [self performSelectorOnMainThread:@selector(showActivityIndicator) withObject:nil waitUntilDone:NO];
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
            
          //  directly.storeController=self;
            NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:directly];
            [connection start];
            
            return;
        }
        //   NSLog(@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
        _data=[[NSMutableData alloc]initWithData:data];
        [delegate.dataModel insertIfNew:_data];
        // [self BuildButtons];
       // _listOfBooks=[delegate.dataModel getDataNotDownloaded];
        _epubFiles=[delegate.dataModel getAllUserBooks];
    }
   // [self performSelectorOnMainThread:@selector(hideActivityIndicator) withObject:nil waitUntilDone:NO];
   // _purchase=YES;

    [_collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    [_pstcollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(resetTabBar) withObject:nil waitUntilDone:NO];

}
-(void)resetTabBar{
    [[self.tabBarController.view.subviews objectAtIndex:0] setFrame:CGRectMake(0, 0, 1024, 768)];

}
- (void)viewDidUnload {
    [self setScrollView:nil];
    [super viewDidUnload];
}
- (IBAction)loginOrSignout:(id)sender {
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"email"]) {
        [self login:sender];
    }else{
        [self sigOut:nil];
    }
}
@end
