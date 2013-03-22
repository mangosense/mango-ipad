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

@interface LibraryViewController ()


@end

@implementation LibraryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.title=@"My Books";
        self.tabBarItem.image=[UIImage imageNamed:@"library.png"];
        _addControlEvents=YES;
        _downloadFailed=NO;
        _allowOptions=YES;
        _recordButtonShow=NO;
    }
    return self;
}
-(void)DownloadComplete:(Book *)book{
   // [book retain];
    [self.tabBarController setSelectedIndex:0];
    [self reloadData];
    _addControlEvents=NO;
    [self BuildButtons];
    //int xmin=75,ymin=50;
    //CGRectMake(x, y, 140, 180);
    CGRect rect;
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
        rect=CGRectMake(75, 195, 126, 40);

    }else{
        rect=CGRectMake(20, 185, 126, 40);
        
    }
    UIProgressView *progress=[[UIProgressView alloc]initWithFrame:rect];
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setEnabled:NO];
    [self.scrollView addSubview:progress];
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
    NSLog(@"string %@",string);
    NSFileManager *manager=[NSFileManager defaultManager];
    if ([manager fileExistsAtPath:string]) {
        [manager removeItemAtPath:string error:nil];
    }
     [manager createFileAtPath:string contents:nil attributes:nil];
    NSError *error=nil;
    NSURL *urlFile=[NSURL fileURLWithPath:string];
     [urlFile setResourceValue:[NSNumber numberWithBool: YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (error) {
        NSLog(@"error %@",error);
    }
    downloader.handle=[NSFileHandle fileHandleForUpdatingAtPath:string];
   // [downloader.handle retain];
    
    NSLog(@"floatvalue %f id %@",[book.size floatValue],book.id);
    downloader.value=[book.size floatValue];
  
    
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
    [super viewDidLoad];
    UIBarButtonItem *editBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(DeleteButton:)];
    editBarButtonItem.tintColor=[UIColor grayColor];
   
    UIBarButtonItem *optionsItem=[[UIBarButtonItem alloc]initWithTitle:@"share" style:UIBarButtonItemStyleBordered target:self action:@selector(allowoptions:)];
    optionsItem.tintColor=[UIColor grayColor];
    UIBarButtonItem *recordButton=[[UIBarButtonItem alloc]initWithTitle:@"recording" style:UIBarButtonItemStyleBordered target:self action:@selector(showRecordButton:)];
    recordButton.tintColor=[UIColor grayColor];
   // NSLog(@"options retainCount %d",optionsItem.retainCount);
    _array=[[NSArray alloc]initWithObjects:editBarButtonItem,optionsItem,recordButton, nil];
   //  NSLog(@"options retainCount %d",optionsItem.retainCount);
  /*[recordButton release];
    [editBarButtonItem release];
    [optionsItem release];*/
    self.navigationItem.rightBarButtonItems=_array;
    //[_array release];
    
  //  self.navigationItem.rightBarButtonItem.tintColor=[UIColor grayColor];
    _ymax=768+80;
    
  //  [self reloadData];

    
  
    _showDeleteButton=NO;
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"wood_pattern.png"]];
    self.view.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo1.png"]];
    self.navigationItem.titleView=imageView;
  ///  [imageView release];
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    // Do any additional setup after loading the view from its nib.

   
}
-(void)showRecordButton:(id)sender{
    NSLog(@"record Button");
    
    if (!_recordButtonShow) {// if not shown
        UIBarButtonItem *item=[_array objectAtIndex:2];
        [item setTitle:@"Done"];
        [item setTintColor:[UIColor blueColor]];
        item=[_array objectAtIndex:0];
        [item setEnabled:NO];
        item=[_array objectAtIndex:1];
        [item setEnabled:NO];
        for (UITabBarItem *item in self.tabBarController.tabBar.items) {
            item.enabled=NO;
        }
    for (UIView *view in self.scrollView.subviews) {
        if([view isKindOfClass:[ShadowButton class]]){
            [[view.subviews lastObject] setHidden:NO]; 
        }
    }
    }else{ // if shown
        /*
        
         */
        UIBarButtonItem *item=[_array objectAtIndex:2];
        [item setTitle:@"Recording"];
        [item setTintColor:[UIColor grayColor]];
        item=[_array objectAtIndex:0];
        [item setEnabled:YES];
        item=[_array objectAtIndex:1];
        [item setEnabled:YES];
        for (UITabBarItem *item in self.tabBarController.tabBar.items) {
            item.enabled=YES;
        }
        for (UIView *view in self.scrollView.subviews) {
            if([view isKindOfClass:[ShadowButton class]]){
                [[view.subviews lastObject ] setHidden:YES];
            }
        }
    }
    _recordButtonShow=!_recordButtonShow;
}
-(void)allowoptions:(UIBarButtonItem *)sender{
  //   NSLog(@"options retainCount %d",_array.retainCount);
    if (_allowOptions) {
        UIBarButtonItem *item=[_array objectAtIndex:1];
        [item setTitle:@"Done"];
        [item setTintColor:[UIColor blueColor]];
        item=[_array objectAtIndex:0];
        [item setEnabled:NO];
        item=[_array objectAtIndex:2];
        [item setEnabled:NO];
        for (UIView *view in self.scrollView.subviews) {
            if ([view isKindOfClass:[ShadowButton class]]) {
              //  ShareButton *button=(ShareButton *)view;
                NSLog(@"Button views %d",view.subviews.count);
                [[view.subviews objectAtIndex:1] setHidden:NO];
            }
            
        }
        
        for (UITabBarItem *item in self.tabBarController.tabBar.items) {
            item.enabled=NO;
        }
    }else{
        for (UIView *view in self.scrollView.subviews) {
            if ([view isKindOfClass:[ShadowButton class]]) {
               // ShareButton *button=(ShareButton *)view;
                [[view.subviews objectAtIndex:1] setHidden:YES];
            }
            
        }
      [[self.navigationController.navigationItem.rightBarButtonItems objectAtIndex:0] setEnabled:NO];
        UIBarButtonItem *item=[_array objectAtIndex:1];
        [item setTitle:@"Share"];
        [item setTintColor:[UIColor grayColor]];
        item=[_array objectAtIndex:0];
        [item setEnabled:YES];
        item=[_array objectAtIndex:2];
        [item setEnabled:YES];

        for (UITabBarItem *item in self.tabBarController.tabBar.items) {
            item.enabled=YES;
        }
    }
    
    _allowOptions=!_allowOptions;
   
    
   // UIActivityViewController *controller=[[UIActivityViewController alloc]init];
    
}

-(void)shareButtonClicked:(id)sender{
    NSString *ver= [UIDevice currentDevice].systemVersion;
  
    ShareButton *buttonShadow=(ShareButton *)sender;
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
    
    mail=[[MFMailComposeViewController alloc]initWithRootViewController:self.navigationController];
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
-(void)DeleteButton:(id)sender{
    NSLog(@"Edit Button clicked");
    if (_showDeleteButton) {
        for (UIView *view in self.scrollView.subviews) {
            if ([view isKindOfClass:[UIButton class]]&&![view isKindOfClass:[ShadowButton class]]) {
                [view removeFromSuperview];
            }
           
        }
        _showDeleteButton=NO;
       // [self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
        for (UITabBarItem *item in self.tabBarController.tabBar.items) {
            item.enabled=YES;
        }
        UIBarButtonItem *item=[_array objectAtIndex:0];
        [item setTitle:@"Edit"];
        item=[_array objectAtIndex:1];
        [item setEnabled:YES];
        item=[_array objectAtIndex:2];
        [item setEnabled:YES];

        return;/// end of exceution
    }
    if (_epubFiles.count!=0) {
        for (UITabBarItem *item in self.tabBarController.tabBar.items) {
            item.enabled=NO;
        }
    }
  
    NSLog(@"Total %d",_epubFiles.count);
    
    [self addDeleteButton];
    //[self.navigationItem.rightBarButtonItem setTitle:@"Done"];
      _showDeleteButton=YES;
    UIBarButtonItem *item=[_array objectAtIndex:0];
    [item setTitle:@"Done"];
    item=[_array objectAtIndex:1];
    [item setEnabled:NO];
    item=[_array objectAtIndex:2];
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
    
    for (int i=1; i<=_epubFiles.count; i++) {
       
        if (i==1&&!_addControlEvents) {
         
            return;
        }
         UIButton *button=[[UIButton alloc]init];
    [button setImage:[UIImage imageNamed:@"closebutton.png"] forState:UIControlStateNormal];
        button.frame=CGRectMake(x, y, 48, 48);
        //NSLog(@"x =%d",x);
       
        x=x+xinc;
        if (i%perrow==0&&i!=0) {
            x=xmin;
            y=y+210+40;
        }
        
        button.tag=i-1;
        [button addTarget:self action:@selector(DeleteBook:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.scrollView addSubview:button];
     //   [button release];
    }

}
-(void)AddShareButton:(id)sender{
    
}
-(void)DeleteBook:(UIButton *)book{
  
    
    
   Book *bk= _epubFiles[book.tag];
    _index=book.tag;
    NSString *alertViewMessage=[NSString stringWithFormat:@"Do you wish to delete book titled %@ ?",bk.title ];
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Delete Book" message:alertViewMessage delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    alertView.tag=300;
    [alertView show];
 //   [alertView release];
    
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
     //   [imageView release];
    }
}
-(void)sigOut:(UIBarButtonItem *)button{
    NSString *signout=[[NSUserDefaults standardUserDefaults] objectForKey:@"baseurl"];
    signout =[signout stringByAppendingPathComponent:@"users/sign_out"];
    signout =[signout stringByAppendingFormat:@"?user[email]=%@&auth_token=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"email"],[[NSUserDefaults standardUserDefaults] objectForKey:@"auth_token"]];
    //NSLog(@"signout %@",signout);
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:signout]];
    [request setHTTPMethod:@"GET"];
    NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
    [connection start];
//    [request release];
//    [connection autorelease];
      
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"%@",error);
    
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{

    
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    //    NSString *stringJsonData=[[NSString alloc]initWithData:_mutableData encoding:NSUTF8StringEncoding];
    //    NSLog(@"String %@",stringJsonData);
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
   // [mail release];

}
//- (NSUInteger)supportedInterfaceOrientations {
//    
//    return UIInterfaceOrientationMaskAll;
//    
//}


//- (BOOL)shouldAutorotate {
//    
//    return YES;
//}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    return YES;
//    }
//

-(void)reloadData{

    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.dataModel displayAllData];
    NSArray *temp=[delegate.dataModel getDataDownloaded];

    _epubFiles=[[NSArray alloc]initWithArray:temp];
    if (_epubFiles.count==0) {

        _showDeleteButton=NO;
        [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setTitle:@"Edit"];
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
    [self.scrollView setContentSize:size];

}
-(void)setDownloadFailed:(BOOL)downloadFailed{
    if (downloadFailed) {
        [self reloadData];
        [self BuildButtons];
    }
    _downloadFailed=downloadFailed;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.tabBarController.tabBar setHidden:NO];
    [self.navigationController.navigationBar setHidden:NO];

    AePubReaderAppDelegate  *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;


    UIViewController *vc=[[UIViewController alloc]init];
    LibraryViewController *lib=self;
    [self presentViewController:vc animated:NO completion:^(void){
        
        [lib dismissViewControllerAnimated:NO completion:^(void){ delegate.LandscapeOrientation=YES;
            delegate.PortraitOrientation=YES;
        }];
    }];

  [self BuildButtons];

 

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];

}
-(void)delay{

}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];

}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    NSLog(@"library width %f %f",self.scrollView.frame.size.width,self.scrollView.frame.origin.x);
     _interfaceOrientation=toInterfaceOrientation;
   
   
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    NSLog(@"library width %f %f",self.scrollView.frame.size.width,self.scrollView.frame.origin.x);
     [self BuildButtons];
    if (_showDeleteButton) {
        [self addDeleteButton];
    }

}
-(void)viewDidDisappear:(BOOL)animated{
    if (_alertView) {
        [_alertView dismissWithClickedButtonIndex:0 animated:YES];
        //_alertView=nil;
    }
   
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
    [self DrawShelf];
    int xmin=65,ymin=50;
    int x,y;
    int xinc=190;
    x=xmin;
    y=ymin;
//    UIDeviceOrientation device=[UIDevice currentDevice].orientation;
//    NSLog(@"device %d",device);
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
    
    for (int i=0;i<_epubFiles.count;i++) {
        CGRect rect=CGRectMake(x, y, 140, 180);
        ShadowButton *button=[[ShadowButton alloc]init];
        Book *book=_epubFiles[i];
        button.storeViewController=nil;
        button.libraryViewController=self;
        button.frame=rect;
        button.tag=i;
        button.stringLink=book.link;
        
        //[button setupView];
        //[button addTarget:button action:@selector(showBookButton:) forControlEvents:UIControlEventTouchUpInside];
        if (i==0&&_addControlEvents) {
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
        //[showRecording release];
       // NSLog(@"viewcontroller retain count %d",[button.viewController retainCount]);
      //  label.text=[title substringToIndex:3];
          NSLog(@"File name %@",title);
       // label.textAlignment=NSTextAlignmentLeft;
        //[label sizeToFit];
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
        //[self.view bringSubviewToFront:button];
      //  [button release];
        //[self.view addSubview:label];
        //[label release];
      //  [tap release];
      
    }
    if (prog) {
        [self.scrollView bringSubviewToFront:prog];
    }
 
    
}
-(void)RecordButtonClicked:(id)sender{
    UIButton *button=(UIButton *)sender;
   // RecordViewController *recordViewController=[[RecordViewController alloc]initWithStyle:UITableViewStyleGrouped forValue:button.tag];
    ShowViewController *showViewController=[[ShowViewController alloc]initWithNibName:@"ShowViewController" bundle:nil with:button.tag ];
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:showViewController];
   _popRecording=[[UIPopoverController alloc]initWithContentViewController:nav];
    showViewController.pop=_popRecording;
   // [nav release];
   // [showViewController release];
    
   // UIBarButtonItem *item=[_array objectAtIndex:2];
   // [pop presentPopoverFromBarButtonItem:item permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
    if (_buttonTapped.tag==0&&_addControlEvents==NO) {
        return;
    }
    _alertView =[[UIAlertView alloc]init];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.alertView=_alertView;
   // [_alertView setTitle:@"Loading...."];
    [_alertView setDelegate:self];
   // NSLog(@"alertView ht %f  wd %f",_alertView.frame.size.height,_alertView.frame.size.width);
    UIImage *image=[UIImage imageNamed:@"loading.png"];
    
UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-40, -160, 391, 320)];
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;
    
    imageView.image=image;
    [_alertView addSubview:imageView];
    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(125, 25, 66.0f, 66.0f)];
    indicator.color=[UIColor blackColor];
        [indicator startAnimating];
  //  [imageView release];
       [_alertView addSubview:indicator];
   //    [indicator release];
//   [imageView release];

//    for (UIView *view in _alertView.subviews ) {
//        view.backgroundColor=[UIColor clearColor];
//    }
//    _alertView.backgroundColor=[UIColor clearColor];
//     image=[UIImage imageNamed:@"icon.png"];
//    UIImageView *iconImage=[[UIImageView alloc]initWithImage:image];
//    iconImage.frame=CGRectMake(139.0f-18.0f, 20, 50.0f, 66.0f);
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    [animation setFromValue:[NSNumber numberWithFloat:1.0]];
//    [animation setToValue:[NSNumber numberWithFloat:0.0]];
//    [animation setDuration:0.5f];
//    [animation setTimingFunction:[CAMediaTimingFunction
//                                  functionWithName:kCAMediaTimingFunctionLinear]];
//    [animation setAutoreverses:YES];
//    [animation setRepeatCount:20000];
//    [[iconImage layer] addAnimation:animation forKey:@"opacity"];
//   // [animation release];
//    [_alertView addSubview:iconImage];
//    [iconImage release];
    [_alertView show];
  //  [_alertView release];
    _alertView.tag=2;
    Book *iden=_epubFiles[_buttonTapped.tag];
   
[[NSUserDefaults standardUserDefaults] setInteger:[iden.id integerValue] forKey:@"bookid"];
    _index=_buttonTapped.tag;
    
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
	//NSString *strFilePath=[NSString stringWithFormat:@"%@/UnzippedEpub/META-INF/container.xml",[self applicationDocumentsDirectory]];
    
    NSString *strFilePath=[NSString stringWithFormat:@"%@/%d/META-INF/container.xml",[self applicationDocumentsDirectory],iden];
	if ([filemanager fileExistsAtPath:strFilePath]) {
		
		//valid ePub
		NSLog(@"Parse now");
		
		//[filemanager release];
		//filemanager=nil;
		
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
		//[alert release];
		//alert=nil;
		
	}
	//[filemanager release];
	filemanager=nil;
	return @"";
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}
- (void)foundRootPath:(NSString*)rootPath{
	
	//Found the path of *.opf file
	
	//get the full path of opf file
	//NSString *strOpfFilePath=[NSString stringWithFormat:@"%@/UnzippedEpub/%@",[self applicationDocumentsDirectory],rootPath];
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
	//	[alert release];
	//	alert=nil;
	}
//	[filemanager release];
//	filemanager=nil;
	
}
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
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
		//NSString *strPath=[NSString stringWithFormat:@"%@/UnzippedEpub",[self applicationDocumentsDirectory]];
		NSString *strPath=[NSString stringWithFormat:@"%@/%d",[self applicationDocumentsDirectory],iden];
        //Delete all the previous files
		NSFileManager *filemanager=[[NSFileManager alloc] init];
		if ([filemanager fileExistsAtPath:strPath]) {
			
			NSError *error;
			[filemanager removeItemAtPath:strPath error:&error];
		}
	//	[filemanager release];
	//	filemanager=nil;
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
	//		[alert release];
	//		alert=nil;
		}
		[za UnzipCloseFile];
	}
   // [epubLoc release];
//	[za release];
}
-(void)didPresentAlertView:(UIAlertView *)alertView{
    if (alertView.tag==300) {
        return;
    }
       Book *bk=_epubFiles[_index];
    NSString  *value;
    NSString *epubString;
    ViewController *viewController;
    EpubReaderViewController *reader;
    AePubReaderAppDelegate *delegate;
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
        
        [self.navigationController pushViewController:reader animated:YES];
    //    [reader release];
        if ([UIDevice currentDevice].systemVersion.integerValue<6) {
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
         //   _alertView=nil;
        }

        return;
    }
    ShadowButton *button;
    switch (bk.textBook.integerValue) {
        case 1://storyBooks
            delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
            delegate.PortraitOrientation=NO;
            delegate.LandscapeOrientation=YES;
            
            value=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            
            epubString=[NSString stringWithFormat:@"%@.epub",bk.id];
            value=[value stringByAppendingPathComponent:epubString];
            NSLog(@"Path value: %@",value);
                   reader=[[EpubReaderViewController alloc]initWithNibName:@"View" bundle:nil];
            reader._strFileName=value;
          
            button=(ShadowButton *)_buttonTapped;
            reader.imageLocation=button.imageLocalLocation;
            reader.url=button.stringLink;
            self.tabBarController.hidesBottomBarWhenPushed=YES;
            reader.hidesBottomBarWhenPushed=YES;
            
            [self.navigationController pushViewController:reader animated:YES];
         //   [reader release];
            if ([UIDevice currentDevice].systemVersion.integerValue<6) {
                [alertView dismissWithClickedButtonIndex:0 animated:YES];
            //    _alertView=nil;
            }

            break;
        case 2://textBooks
           delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
            delegate.LandscapeOrientation=NO;

            value=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            
            epubString=[NSString stringWithFormat:@"%@.epub",bk.id];
            value=[value stringByAppendingPathComponent:epubString];
            NSLog(@"Path value: %@",value);
            viewController=[[ViewController alloc]initWithNibName:@"ViewController" bundle:nil WithString:value];
        
            
            self.tabBarController.hidesBottomBarWhenPushed=YES;
            viewController.hidesBottomBarWhenPushed=YES;
            self.navigationController.navigationBarHidden=YES;
                [self.navigationController pushViewController:viewController animated:YES];
           // [viewController release];
            if ([UIDevice currentDevice].systemVersion.integerValue<6) {
                [alertView dismissWithClickedButtonIndex:0 animated:YES];
            //    _alertView=nil;
            }
            
            break;
        default:
            break;
    }
  }

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==300&&buttonIndex==1) {
        Book *bk=_epubFiles[_index];
        NSString *val=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *bkl=[NSString stringWithFormat:@"%@.epub",bk.id];
        val =[val stringByAppendingPathComponent:bkl];
        [[NSFileManager defaultManager]removeItemAtPath:val error:nil];
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        bkl=[NSString stringWithFormat:@"%@",bk.id];
        bk=[delegate.dataModel getBookOfId:bkl ];
        NSLog(@"book deleted :%@",bk.title);
        bk.downloaded=@NO;
        [delegate.dataModel saveData:bk];
       
        [self BuildButtons];
        _showDeleteButton=NO;
        for (UIView *view in self.scrollView.subviews) {
            if ([view isKindOfClass:[UIButton class]]&&![view isKindOfClass:[ShadowButton class]]) {
                [view removeFromSuperview];
            }
            
        }
        [self DeleteButton:nil];
    }
       
    

}
/*-(void)dealloc{
    _array=nil;
    
    [_epubFiles release];
    [_scrollView release];
    
    [super dealloc];
}*/
- (void)viewDidUnload {
    [self setScrollView:nil];
    [super viewDidUnload];
}
@end
