//
//  LibraryViewController.m
//  AePubReader
//
//  Created by Nikhil Dhavale on 24/09/12.
//
//

#import "LibraryViewController.h"
#import "EPubViewController.h"
#import "ShadowButton.h"
#import "FileDownloader.h"
@interface LibraryViewController ()


@end

@implementation LibraryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.title=@"Library";
        self.tabBarItem.image=[UIImage imageNamed:@"library.png"];
        _addControlEvents=YES;
        _downloadFailed=NO;
        _allowOptions=YES;
    }
    return self;
}
-(void)DownloadComplete:(Book *)book{
    [self.tabBarController setSelectedIndex:0];
    [self reloadData];
    _addControlEvents=NO;
    [self BuildButtons];
    //int xmin=75,ymin=50;
    //CGRectMake(x, y, 140, 180);
    CGRect rect=CGRectMake(82, 195, 126, 40);
    UIProgressView *progress=[[UIProgressView alloc]initWithFrame:rect];
    
    [self.scrollView addSubview:progress];
    FileDownloader *downloader=[[FileDownloader alloc]initWithViewController:self];
    downloader.progress=progress;
    downloader.book=book;
    
    NSString *url= book.sourceFileUrl;
    NSURLRequest *request=[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:url ]];
   // [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [progress release];
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
    downloader.handle=[NSFileHandle fileHandleForUpdatingAtPath:string];
    [downloader.handle retain];
    
    NSLog(@"floatvalue %f id %@",[book.size floatValue],book.id);
    downloader.value=[book.size floatValue];
    [downloader.handle retain];
    
    NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:downloader];
    [downloader release];
    [connection autorelease];
    CGPoint point;
    point.y=0;
    
    [self.scrollView setContentOffset:point animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *barButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(DeleteButton:)];
    barButtonItem.tintColor=[UIColor grayColor];
   
    UIBarButtonItem *optionsItem=[[UIBarButtonItem alloc]initWithTitle:@"share" style:UIBarButtonItemStyleBordered target:self action:@selector(allowoptions:)];
    optionsItem.tintColor=[UIColor grayColor];
    NSArray *array=[NSArray arrayWithObjects:barButtonItem,optionsItem, nil];
    self.navigationItem.rightBarButtonItems=array;
    [barButtonItem release];
    [optionsItem release];
    self.navigationItem.rightBarButtonItem.tintColor=[UIColor grayColor];
    _ymax=768+80;
    [self reloadData];
    // [self DrawShelf];
    
    [self BuildButtons];
    _showDeleteButton=NO;
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"wood_pattern.png"]];
    UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo1.png"]];
    self.navigationItem.titleView=imageView;
    [imageView release];
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    // Do any additional setup after loading the view from its nib.
   
}
-(void)allowoptions:(UIBarButtonItem *)sender{
    if (_allowOptions) {
        [sender setTitle:@"Done"];
    }else{
        [sender setTitle:@"share"];
    }
    
    _allowOptions=!_allowOptions;
   
    
   // UIActivityViewController *controller=[[UIActivityViewController alloc]init];
    
}
-(void)DeleteButton:(id)sender{
   
    if (_showDeleteButton) {
        for (UIView *view in self.scrollView.subviews) {
            if ([view isKindOfClass:[UIButton class]]&&![view isKindOfClass:[ShadowButton class]]) {
                [view removeFromSuperview];
            }
           
        }
        _showDeleteButton=NO;
        [self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
        for (UITabBarItem *item in self.tabBarController.tabBar.items) {
            item.enabled=YES;
        }
        return;
    }
    for (UITabBarItem *item in self.tabBarController.tabBar.items) {
        item.enabled=NO;
    }
    NSLog(@"Total %d",_epubFiles.count);
    [self addDeleteButton];
    [self.navigationItem.rightBarButtonItem setTitle:@"Done"];
      _showDeleteButton=YES;

    
}
-(void)addDeleteButton{
    int xmin=60,ymin=40;
    int x=xmin;
    int y=ymin;
    for (int i=1; i<=_epubFiles.count; i++) {
        UIButton *button=[[UIButton alloc]init];
        if (i==1&&!_addControlEvents) {
            return;
        }
    [button setImage:[UIImage imageNamed:@"closebutton.png"] forState:UIControlStateNormal];
        button.frame=CGRectMake(x, y, 48, 48);
        //NSLog(@"x =%d",x);
        x=x+190;
        if (i%5==0&&i!=0) {
            x=xmin;
            y=y+210+40;
        }
        
        button.tag=i-1;
        [button addTarget:self action:@selector(DeleteBook:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.scrollView addSubview:button];
        [button release];
    }

}
-(void)DeleteBook:(UIButton *)book{
    NSString *val=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
   Book *bk= _epubFiles[book.tag];
    NSString *bkl=[NSString stringWithFormat:@"%@.epub",bk.id];
    val =[val stringByAppendingPathComponent:bkl];
    [[NSFileManager defaultManager]removeItemAtPath:val error:nil];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    bkl=[NSString stringWithFormat:@"%@",bk.id];
    bk=[delegate.dataModel getBookOfId:bkl ];
    NSLog(@"book deleted :%@",bk.title);
    bk.downloaded=@NO;
    [delegate.dataModel saveData:bk];
    [self reloadData];
    [self BuildButtons];
    _showDeleteButton=NO;
    for (UIView *view in self.scrollView.subviews) {
        if ([view isKindOfClass:[UIButton class]]&&![view isKindOfClass:[ShadowButton class]]) {
            [view removeFromSuperview];
        }
        
    }
    [self DeleteButton:nil];
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
-(void)sigOut:(UIBarButtonItem *)button{
    NSString *signout=[[NSUserDefaults standardUserDefaults] objectForKey:@"baseurl"];
    signout =[signout stringByAppendingPathComponent:@"users/sign_out"];
    signout =[signout stringByAppendingFormat:@"?user[email]=%@&auth_token=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"email"],[[NSUserDefaults standardUserDefaults] objectForKey:@"auth_token"]];
    //NSLog(@"signout %@",signout);
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:signout]];
    [request setHTTPMethod:@"GET"];
    NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
    [request release];
    [connection autorelease];
      
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
    if (_allowOptions) {
        [self singleTap:gesture];
        return;
    }
    UIMenuController *_menuController=[UIMenuController sharedMenuController];
        if (_menuController.menuVisible) {
            [_menuController setMenuVisible:NO animated:YES];
            return;
        }
    _buttonTapped=(UIButton *)gesture.view;
    [gesture.view becomeFirstResponder];
    UIMenuItem *menuItem=[[UIMenuItem alloc]initWithTitle:@"email" action:@selector(share:)];
  //  UIMenuItem *downloadOrShow;
    
    //downloadOrShow=[[UIMenuItem alloc]initWithTitle:@"open" action:@selector(ViewBook:)];
    
    // _menuController=[UIMenuController sharedMenuController];
    UIMenuItem *message=[[UIMenuItem alloc]initWithTitle:@"message" action:@selector(message:)];
     [_menuController setMenuItems:@[/*downloadOrShow,*/menuItem,message]];
    [message release];
    [menuItem release];
   // [downloadOrShow release];
    CGRect frame=gesture.view.frame;
    frame.origin.x-=10;
    frame.origin.y-=10;
    [_menuController setTargetRect:frame inView:self.scrollView];
    [_menuController setMenuVisible:YES animated:YES];
}
- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskLandscape;
    
}

- (BOOL)shouldAutorotate {
    
    return YES;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}
-(void)reloadData{
//    NSFileManager *manager=[NSFileManager defaultManager];
//    NSString  *value=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSArray *files=[manager contentsOfDirectoryAtPath:value error:nil];
//    _epubFiles=[[NSArray alloc]initWithArray:[files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.epub'"]]];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    _epubFiles=[[NSArray alloc]initWithArray:[delegate.dataModel getDataDownloaded]];
    if (_epubFiles.count==0) {
        [self.tabBarController setSelectedIndex:1];
    }
    else if (_epubFiles.count>15) {
        NSInteger extra=_epubFiles.count-15;
        
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
    [self.tabBarController.tabBar setHidden:NO];
     [self.navigationController.navigationBar setHidden:NO];
  
//    [self reloadData];
//    [self BuildButtons];
}
-(void)viewWillDisappear:(BOOL)animated{
 
}
-(void)viewDidDisappear:(BOOL)animated{
    if (_alertView) {
        [_alertView dismissWithClickedButtonIndex:0 animated:YES];
        _alertView=nil;
    }
   
}
-(void)BuildButtons{
    for (UIView *view in self.scrollView.subviews) {
      
           [view removeFromSuperview];  
       
       
    }// remove alll views if any
    // add all views if any
    [self DrawShelf];
    int xmin=75,ymin=50;
    int x,y;
    x=xmin;
    y=ymin;
   
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
        [button setImage:image forState:UIControlStateNormal];
        image=[UIImage imageNamed:@"bookshadow.png"];
        [button setBackgroundColor:[UIColor colorWithPatternImage:image]];
        
       // NSLog(@"viewcontroller retain count %d",[button.viewController retainCount]);
      //  label.text=[title substringToIndex:3];
          NSLog(@"File name %@",title);
       // label.textAlignment=NSTextAlignmentLeft;
        //[label sizeToFit];
        x=x+190;
        
        if (x+140>1024) {
            x=xmin;
            y=y+210+40;
        }
        
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        UITapGestureRecognizer *doubleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        doubleTap.numberOfTapsRequired=2;
        [button addGestureRecognizer:tap];
        [button addGestureRecognizer:doubleTap];
        [self.scrollView addSubview:button];
        //[self.view bringSubviewToFront:button];
        [button release];
        //[self.view addSubview:label];
        //[label release];
        [tap release];
       // [doubleTap release];
    }
    
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
    if (_showDeleteButton) {
        return;
    }
    if (_buttonTapped.tag==0&&_addControlEvents==NO) {
        return;
    }
    _alertView =[[UIAlertView alloc]init];
    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(139.0f-18.0f, 40.0f, 37.0f, 37.0f)];
    [indicator startAnimating];
    [_alertView addSubview:indicator];
    [indicator release];
    [_alertView setTitle:@"Loading...."];
    [_alertView setDelegate:self];
    [_alertView show];
    Book *iden=_epubFiles[_buttonTapped.tag];
   
[[NSUserDefaults standardUserDefaults] setInteger:[iden.id integerValue] forKey:@"bookid"];
    _index=_buttonTapped.tag;
    }
-(void)didPresentAlertView:(UIAlertView *)alertView{
  
    NSString  *value=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    Book *bk=_epubFiles[_index];
    NSString *epubString=[NSString stringWithFormat:@"%@.epub",bk.id];
    value=[value stringByAppendingPathComponent:epubString];
    NSLog(@"Path value: %@",value);
    
    EpubReaderViewController *reader=[[EpubReaderViewController alloc]initWithNibName:@"View" bundle:nil];
    reader._strFileName=value;
    
    self.tabBarController.hidesBottomBarWhenPushed=YES;
    reader.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:reader animated:YES];
    [reader release];
}
-(void)dealloc{
    [_epubFiles release];
    [_scrollView release];
    
    [super dealloc];
}
- (void)viewDidUnload {
    [self setScrollView:nil];
    [super viewDidUnload];
}
@end
