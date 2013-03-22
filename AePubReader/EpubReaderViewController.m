
#import "EpubReaderViewController.h"
#import "NotesHighlightViewController.h"
#import "AePubReaderAppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "WebViewController.h"
#import <AudioToolbox/AudioServices.h>
#import "UIWebView+SearchWebView.h"

@implementation EpubReaderViewController
@synthesize _ePubContent;
@synthesize _rootPath;
@synthesize _strFileName;
-(void)removeZoom:(UIView *)view{
    for (UIView *v in [view subviews])
    {
        if (v != view)
        {
            [self removeZoom:v];
        }
    }
    for (UIGestureRecognizer *reco in [view gestureRecognizers])
    {
        if ([reco isKindOfClass:[UITapGestureRecognizer class]])
        {
            if ([(UITapGestureRecognizer *)reco numberOfTapsRequired] == 2)
            {
                NSLog(@"Remove zoom");
                [view removeGestureRecognizer:reco];
            }
        }
    }


}
-(void)goToPage:(id)sender{
    UIButton *button=(UIButton *)sender;
    NSLog(@"tag %d",button.tag);
    if (button.tag==_pageNumber) {
        return;
    }
    _pageNumber=button.tag;
    [self loadPage];
    
    
}
-(void)addThumbnails{
    NSLog(@"file location %@",_rootPath);
 

    NSFileManager *defaultManager=[NSFileManager defaultManager];
      NSInteger index;
  //  UIImage *image=[UIImage imageNamed:@"footer-bg.png"];
 //   _scrollViewForThumnails.backgroundColor= [UIColor colorWithPatternImage:image];
   // self.view.backgroundColor=[UIColor colorWithPatternImage:image];
    NSString *thumbNailLocation=[_rootPath stringByAppendingPathComponent:@"thumbnails"];
    if ( [defaultManager fileExistsAtPath:thumbNailLocation]) {
       NSArray *array= [defaultManager contentsOfDirectoryAtPath:thumbNailLocation error:nil];
        NSLog(@"count %d",array.count);
        NSMutableArray *arrayMutable=[[NSMutableArray alloc]initWithCapacity:array.count];
        
        for (index=0; index<_ePubContent._spine.count; index++) {
           // NSString *val=[[NSString alloc]initWithFormat:@"pg%d.jpg",index+1 ];
            NSString  *actual=[self._ePubContent._manifest valueForKey:[self._ePubContent._spine objectAtIndex:index]];
            actual =[actual stringByDeletingPathExtension];
            NSString *val=[actual stringByAppendingString:@".png"];
             NSLog(@"spine at %d %@ %@",index,val,[self._ePubContent._spine objectAtIndex:index]);
            [arrayMutable addObject:val];
            //[val release];
        }
        array=[NSArray arrayWithArray:arrayMutable];
      //  [arrayMutable release];
        //  array=  [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
      CGSize size=  _scrollViewForThumnails.contentSize;
        CGFloat width=array.count *200;
        //NSString *deviceType=[UIDevice currentDevice].model;
        NSInteger widthThum;
        NSInteger heightThum;
        NSInteger x;
        NSInteger y;
      
        NSInteger increment;
        for (UIView *view in _scrollViewForThumnails.subviews) {
            [view removeFromSuperview];
        }
        
//_scrollViewForThumnails.backgroundColor=[UIColor blackColor]; topbottom.png
        UIImage *image=[UIImage imageNamed:@"footer-bg.png"];
        _scrollViewForThumnails.backgroundColor= [UIColor colorWithPatternImage:image];

     //   [_scrollViewForThumnails setHidden:YES];
         increment=100;
        if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
            width=array.count;
            size.width=width*increment;
            _scrollViewForThumnails.contentSize=size;
            widthThum=85;
            heightThum=66;
            y=10;
            x=20;
        }else{
            increment=150;
            width=array.count;
            width=width*increment;
            if (width>1024) {
                size.width=width;
                _scrollViewForThumnails.contentSize=size;
            }
            widthThum=135;//170
            heightThum=105;//132
            y=15;
            x=20;
        }
        for (index=0;index<_ePubContent._spine.count;index++) {
            NSString *imageLoc=[array objectAtIndex:index];
            CGRect rect=CGRectMake(x, y, widthThum, heightThum);
            UIButton *button=[[UIButton alloc]initWithFrame:rect];
            imageLoc=[thumbNailLocation stringByAppendingPathComponent:imageLoc];
            UIImage *image=[[UIImage alloc]initWithContentsOfFile:imageLoc];
            //NSLog(@"location %@",imageLoc);
            [button setImage:image forState:UIControlStateNormal];
            [button addTarget:self action:@selector(goToPage:) forControlEvents:UIControlEventTouchUpInside];
            if (index==_pageNumber) {
                [[button layer] setBorderWidth:4.0f];
                float red=81.0/255.0;
                float green=156.0/255.0;
                
                UIColor *color=[UIColor colorWithRed:red green:green blue:0 alpha:1.0];
                
                [[button layer]setBorderColor:color.CGColor];
            }
            else{
                [[button layer] setBorderWidth:1.0f];
                float red=166.0/255.0;
                float green=131.0/255.0;
                UIColor *color=[UIColor colorWithRed:red green:green blue:0 alpha:1.0];
                
                [[button layer]setBorderColor:color.CGColor];
            }
            [_scrollViewForThumnails addSubview:button];
            button.tag=index;
           // [button release];
           // [image release];
            x+=increment;
            
        }

        
    }
    
    
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{

    return UIInterfaceOrientationLandscapeLeft;
}
- (void)viewDidLoad {
	
    [super viewDidLoad];

    UIImage *image=[UIImage imageNamed:@"top.png"];
    UIColor *color=[UIColor colorWithPatternImage:image];
    _imageToptoolbar.backgroundColor=color;
    image=[UIImage imageNamed:@"side.png"];
   color=[UIColor colorWithPatternImage:image];
    _recordBackgroundview.backgroundColor=color;
    _hide=YES;
     // [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
	//[self setBackButton];
	[_webview setBackgroundColor:[UIColor clearColor]];
	//First unzip the epub file to documents directory
	[self unzipAndSaveFile];
	_xmlHandler=[[XMLHandler alloc] init];
	_xmlHandler.delegate=self;
	[_xmlHandler parseXMLFileAt:[self getRootFilePath]];
    //[_webview removeFromSuperview];
      [self removeZoom:_webview];
    UISwipeGestureRecognizer *left=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftOrRightGesture:)];
    left.direction=UISwipeGestureRecognizerDirectionRight;
    UISwipeGestureRecognizer *right=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftOrRightGesture:)];
    right.direction=UISwipeGestureRecognizerDirectionLeft;
    [_webview.scrollView addGestureRecognizer:left];
    [_webview.scrollView addGestureRecognizer:right];
  
    UITapGestureRecognizer *top=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(DoubleTap:)];
    UILongPressGestureRecognizer *longPress=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    [_webview.scrollView addGestureRecognizer:longPress];
   // [longPress release];
  //  top.direction=UISwipeGestureRecognizerDirectionDown;
    top.numberOfTapsRequired=2;
    top.numberOfTouchesRequired=1;
    
    [top setDelegate:self];
// [[UIDevice currentDevice] setOrientation:UIInterfaceOrientationLandscapeLeft];
    [_webview.scrollView addGestureRecognizer:top];
    
  /*  [top release];
    [right release];
    [left release];*/
 //   [_Done setTintColor:[UIColor grayColor]];
    [_shareButton setTintColor:[UIColor lightGrayColor]];
    [self.navigationController.navigationBar addSubview:_textField];
//    [_hide setTintColor:[UIColor grayColor]];
//    [_hide setEnabled:NO];
    //[_textField release];
    [self.navigationController.navigationBar setHidden:YES];
        [self.tabBarController.tabBar setHidden:YES];
    [_webview setDelegate:self];
    //self.wantsFullScreenLayout=YES;
    //[self.view addSubview:_webview];
    NSLog(@"height %f",_webview.frame.size.height);
    NSString *temp=[_strFileName stringByDeletingPathExtension];
    if([[NSFileManager defaultManager]fileExistsAtPath:temp]){
        [[NSURL URLWithString:temp] setResourceValue:[NSNumber numberWithBool: YES] forKey:NSURLIsExcludedFromBackupKey error:nil];
    }
    NSString *gameLink=[_rootPath stringByAppendingPathComponent:@"game.html"];
    if ([[NSFileManager defaultManager]fileExistsAtPath:gameLink]) {
        [_gameButton setEnabled:YES];
        _gameLink=[[NSString alloc]initWithString:gameLink];
    }else{
        [_gameButton setEnabled:NO];
    }
    NSLog(@"superview ht %f",self.view.frame.size.height);
    _webview.scrollView.bounces=NO;
    _webview.scrollView.alwaysBounceHorizontal=NO;

    
    _webview.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"wood_pattern.png"]];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [_doneButton setTintColor:[UIColor lightGrayColor]];
   

    
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
        _topToolbar.tintColor=[UIColor blackColor];
    }
    CGRect screenRect = [[UIScreen mainScreen] bounds];
   // CGFloat screenWidth=screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
   // CGFloat screenWidht=screenRect.size.width;
    if (screenHeight>500.0&& [[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
      CGRect rect=  _imageToptoolbar.frame;
        rect.size.width=1136.0;
        _imageToptoolbar.frame=rect;
       rect= _recordBackgroundview.frame;
        rect.origin.x=568.0;
        _recordBackgroundview.frame=rect;
        rect=_scrollViewForThumnails.frame;
        rect.size.width=1136.0;
        _scrollViewForThumnails.frame=rect;
        rect=_nextButton.frame;
        rect.origin.x=521.0;//433
        _nextButton.frame=rect;
        rect=_showRecordButton.frame;
        rect.origin.x=rect.origin.x+98;
        _showRecordButton.frame=rect;
        rect=_playPauseControl.frame;
        rect.origin.x=rect.origin.x+98;
        _playPauseControl.frame=rect;
        rect=_gameButton.frame;
        rect.origin.x=rect.origin.x+98;
        _gameButton.frame=rect;
        
        
    }
    _wasFirstInPortrait=NO;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        NSLog(@"still in portrat");
     //   AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        UIViewController *c=[[UIViewController alloc]init];
   //     [self presentModalViewController:c animated:NO ];
        [self presentViewController:c animated:NO completion:^(void){
            [self dismissModalViewControllerAnimated:YES];
        }];
        
//        CGAffineTransform landscapeTransform=CGAffineTransformMakeRotation(M_PI/2);
//        [self.view setTransform:landscapeTransform];
   //     [[UIDevice currentDevice]setOrientation:UIDeviceOrientationLandscapeLeft];
        _wasFirstInPortrait=YES;
     //   [c release];

    }else{
    
        NSLog(@"landscape");
    }
  

    _hide=YES;
    _record=NO;
    _topToolbar.hidden=YES;
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shakeEvent) name:@"shake" object:nil];
    // Enabled monitoring of the sensor
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled==YES) {
        // Set up an observer for proximity changes
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)
                                                     name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    }
   /* if( [UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront ])
    {
        if(!_videoCamera){
            _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
            _filter=[[GPUImageLuminosity alloc]init];
            [_videoCamera addTarget:_filter];
            [_filter setLuminosityProcessingFinishedBlock:^(CGFloat luminosity, CMTime frameTime) {
                // Do something with the luminosity
                NSLog(@"%f",luminosity);
                if (luminosity>0.1) {
                    if (!_DayOrNight) {
                        
                    
                        [self performSelectorOnMainThread:@selector(showNight) withObject:nil waitUntilDone:NO];
                    }
                }else{
                    if (_DayOrNight) {
                        [self performSelectorOnMainThread:@selector(showDay) withObject:nil waitUntilDone:NO];
                    }
                     
                }
               
            }];
            [_videoCamera startCameraCapture];
        }
        
        //        videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        
    }*/

}
-(void)showDay{
    _DayOrNight=YES;
     [_webview stringByEvaluatingJavaScriptFromString:@"showDay()"];
}
-(void)showNight{
    _DayOrNight=NO;
     [_webview stringByEvaluatingJavaScriptFromString:@"showNight()"];
}
//- (IBAction)checkluminosity:(id)sender {
//    [_videoCamera startCameraCapture];
//}

-(void)shakeEvent{
    
}
-(void)sensorStateChange:(NSNotification *)notification
{
    if ([[UIDevice currentDevice]proximityState]==YES) {
        
        
    }else{
        
    }
}
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action==@selector(highlight:)) {
        return NO;
    }
    if (action==@selector(notes:)) {
        return NO;
    }
    return  [super canPerformAction:action withSender:sender];
}
-(void)longPress:(id)sender{
    [[UIMenuController sharedMenuController] setMenuVisible:YES];
}
-(BOOL)canBecomeFirstResponder{
    return YES;
}

//-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
//    if (@selector(select:)==action) {
//        return YES;
//    }
//    return [super canPerformAction:action withSender:sender];
//}

-(void)notes:(id)sender{
    
    //UIPopoverController *pop=[[UIPopoverController alloc]initWithContentViewController:<#(UIViewController *)#> removeHighlight()

}
-(IBAction)removeHighlight:(id)sender{
[_webview stringByEvaluatingJavaScriptFromString:@"uiWebview_RemoveAllHighlights()"];
}
-(IBAction)highlight:(id)sender{
  
    // The JS File
    NSString *filePath  = [[NSBundle mainBundle] pathForResource:@"HighlightedString" ofType:@"js" inDirectory:@""];
    NSData *fileData    = [NSData dataWithContentsOfFile:filePath];
    NSString *jsString  = [[NSMutableString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    [_webview stringByEvaluatingJavaScriptFromString:jsString];
    NSString *selectedText   = [NSString stringWithFormat:@"window.getSelection().toString()"];
    NSString * highlightedString = [_webview stringByEvaluatingJavaScriptFromString:selectedText];
    // The JS Function
    NSString *startSearch   = [NSString stringWithFormat:@"stylizeHighlightedString()"];
    [_webview stringByEvaluatingJavaScriptFromString:startSearch];
    //[jsString release];
    if (selectedText.length>2) {
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate.dataModel insertNoteOFHighLight:YES book:[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"] page:_pageNumber string:highlightedString];
    }

    // The JS File
      
    // The JS Function
//   startSearch   = [NSString stringWithFormat:@"getHighlightedString()"];
//    [_webview stringByEvaluatingJavaScriptFromString:startSearch];
    
//    NSString *selectedText   = [NSString stringWithFormat:@"selectedText"];
//    NSString * highlightedString = [_webview stringByEvaluatingJavaScriptFromString:selectedText];
//    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication];
//    [delegate.dataModel insertNoteOFHighLight:YES book:[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"] page:_pageNumber string:highlightedString];
    
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]||
        [gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]
        ) {
        return YES;
    }
return NO;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
//    if (_alertView) {
//        [_alertView dismissWithClickedButtonIndex:0 animated:YES];
//        _alertView=nil;
//
    NSLog(@"%@",error);
}
-(void) scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x > 0)
        scrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y);
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSLog(@"request %@",[[request URL]absoluteString]);
    if ([[[request URL]absoluteString]hasPrefix:@"playingcompleted:"]) {
        [self playingEnded];
        return NO;
    }
    if ([[[request URL] absoluteString]hasPrefix:@"startplaying"]) {
        UIImage *image=[UIImage imageNamed:@"pause-control.png"];
        [_playPauseControl setImage:image forState:UIControlStateNormal];
        NSString *jsCode=@"$('#jquery_jplayer').jPlayer('play')";
        [_webview stringByEvaluatingJavaScriptFromString:jsCode];
        return NO;
    }
    if ([[[request URL] absoluteString] hasPrefix:@"checkevaluate"]) {
        [self readyState];
        return NO;
        
    }
    return YES;
}
-(void)readyState{

   NSString  *jsCode=[_webview stringByEvaluatingJavaScriptFromString:@"function tryout(){if(document.getElementById('jquery_jplayer')){return true}} tryout()"];
  
    NSLog(@" %@",jsCode);
    if ([jsCode isEqualToString:@"true"]) {
        
        if (_shouldAutoPlay) {
            
            
//            jsCode= @"$('#jquery_jplayer').bind($.jPlayer.event.ready, function(event) {  window.location =\"startPlaying:myObjectiveCFunction\";});";
            jsCode=@"$('#jquery_jplayer').jPlayer('play')";
            UIImage *image=[UIImage imageNamed:@"pause-control.png"];
            [_playPauseControl setImage:image forState:UIControlStateNormal];
            [_webview stringByEvaluatingJavaScriptFromString:jsCode];
            _isPlaying=YES;
            //EpubReaderViewController
        }
        else{
            _isPlaying=NO;
        }
        jsCode=@" $('#jquery_jplayer').bind($.jPlayer.event.ended, function(event) {  window.location = \"playingCompleted:myObjectiveCFunction\";});";
        [_webview stringByEvaluatingJavaScriptFromString:jsCode];
        
        [_playPauseControl setEnabled:YES];
    }else{
        [_playPauseControl setEnabled:NO];
    }
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{

    NSString *jsCode;
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {

        webView.scrollView.bounces=NO;
       // [webView.scrollView setScrollEnabled:NO];
        jsCode=@"<meta name=\"viewport\" content=\"width=device-width\" />";
        [webView stringByEvaluatingJavaScriptFromString:jsCode];
        webView.scrollView.delegate=self;
     
    }
    _isPlaying=NO;
    jsCode=[_webview stringByEvaluatingJavaScriptFromString:@"localStorage.autoPlay"];
    NSLog(@"autoPlay value %@",jsCode);
    if ([jsCode isEqualToString:@"1"]) {
        _shouldAutoPlay=YES;
        
    }else if([jsCode isEqualToString:@"0"]){
        _shouldAutoPlay=NO;
    }
//    jsCode=@"document.onreadystatechange = function () {if (document.readyState == \"complete\") {window.location =\"checkevaluate:check\" ;}}";
//    NSLog(@"jscode %@",jsCode);
//    [_webview stringByEvaluatingJavaScriptFromString:jsCode];
    
    [self performSelector:@selector(readyState) withObject:nil afterDelay:1];
    NSLog(@"pageNumber %d",_pageNumber);
    CGSize size=webView.scrollView.contentSize;
    size.width=1024;
    [webView.scrollView setContentSize:size];
    NSString *page=[[webView.request.URL absoluteString] lastPathComponent];
    NSLog(@"path %@",page);
    for (int i=0;i<_ePubContent._spine.count;i++) {
        NSString *temp=[_ePubContent._manifest valueForKey:[self._ePubContent._spine objectAtIndex:i]];
        //NSLog(@"temp %@",temp);
        if ([temp isEqualToString:page]) {
            if (i!=_pageNumber) {
                _pageNumber=i;
                NSLog(@"pagenumber %d",_pageNumber);
            }
            break;
        }
        
    }
    [self addThumbnails];
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
        NSString *height=[_webview stringByEvaluatingJavaScriptFromString:@"document.body.clientHeight"];

        if (height.integerValue<800) {
            _webview.scrollView.scrollEnabled=NO;
        }
        
    }
   // _pagesPath=[NSString stringWithFormat:@"%@/%@",self._rootPath,[self._ePubContent._manifest valueForKey:[self._ePubContent._spine objectAtIndex:_pageNumber]]];
	//[_webview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:_pagesPath]]];
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
   
//    _alertView =[[UIAlertView alloc]init];
//    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(139.0f-18.0f, 40.0f, 37.0f, 37.0f)];
//    [indicator startAnimating];
//    [_alertView addSubview:indicator];
//    [indicator release];
//    [_alertView setTitle:@"Loading...."];
//    [_alertView show];
}
-(void)viewDidDisappear:(BOOL)animated{
   
    [self.tabBarController.tabBar setHidden:NO];
    NSString *value=[_strFileName stringByDeletingPathExtension];
    [[NSUserDefaults standardUserDefaults]setValue:value forKey:@"locDirectory"];
    if ([_anAudioPlayer isPlaying]) {
        [_anAudioPlayer stop];
    }
    
}
/*Function Name : setTitlename
 *Return Type   : void
 *Parameters    : NSString- Text to set as title
 *Purpose       : To set the title for the view
 */

- (void)setTitlename:(NSString*)titleText{
	
	// this will appear as the title in the navigation bar
	CGRect frame = CGRectMake(0, 0, 200, 44);
	UILabel *label = [[UILabel alloc] initWithFrame:frame] ;
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:17.0];
	label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	label.textAlignment = NSTextAlignmentCenter;
	label.numberOfLines=0;
	label.textColor=[UIColor whiteColor];
	self.navigationItem.titleView = label;
	label.text=titleText;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
 
   
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
       [self becomeFirstResponder];
}


/*Function Name : unzipAndSaveFile
 *Return Type   : void
 *Parameters    : nil
 *Purpose       : To unzip the epub file to documents directory
*/

- (void)unzipAndSaveFile{
	
	ZipArchive* za = [[ZipArchive alloc] init];
	if( [za UnzipOpenFile:_strFileName] ){
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
		filemanager=nil;
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
			alert=nil;
		}
		[za UnzipCloseFile];
	}
	//[za release];
    
}

/*Function Name : applicationDocumentsDirectory
 *Return Type   : NSString - Returns the path to documents directory
 *Parameters    : nil
 *Purpose       : To find the path to documents directory
 */

- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
   // [self removeAllHighlights];
      [searchBar resignFirstResponder];
    NSLog(@"search Button Clicked");
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
		filemanager=nil;
		
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
	//	[alert release];
		alert=nil;
		
	}
	//[filemanager release];
	filemanager=nil;
	return @"";
}

- (IBAction)backButtonOrNextButton:(id)sender {
    UIButton *btnClicked=(UIButton*)sender;
	if (btnClicked.tag==0) {
		
		if (_pageNumber>0) {
			
			_pageNumber--;
			[self loadPage];
		}else{
      [self onBack:nil];
        }

	}
	else {
		
		if ([self._ePubContent._spine count]-1>_pageNumber) {
			
			_pageNumber++;
			[self loadPage];
		}
	}

}
/*
 HighLight occuerances of content in the webview
 */
//- (NSInteger)highlightAllOccurencesOfString:(NSString*)str {
//    [_hide setEnabled:YES];
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"SearchWebView" ofType:@"js"];
//    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//   NSString *fail= [_webview stringByEvaluatingJavaScriptFromString:jsCode];
//    if (fail==nil) {
//        NSLog(@"fail");
//    }
//    NSString *startSearch = [NSString stringWithFormat:@"MyApp_HighlightAllOccurencesOfString('%@');",str];
//    fail=[_webview stringByEvaluatingJavaScriptFromString:startSearch];
//    if (fail==nil) {
//        NSLog(@"fail");
//    }
//    //    NSLog(@"%@", [self stringByEvaluatingJavaScriptFromString:@"console"]);
//    NSLog(@"occurences %@",[_webview stringByEvaluatingJavaScriptFromString:@"MyApp_SearchResultCount;"]);
//    return [[_webview stringByEvaluatingJavaScriptFromString:@"MyApp_SearchResultCount;"] intValue];
//}
///*
// remove highlighted occurances if any
// */
//- (void)removeAllHighlights {
//    [_hide setEnabled:NO];
//    [_webview stringByEvaluatingJavaScriptFromString:@"MyApp_RemoveAllHighlights()"];
//}
#pragma mark XMLHandler Delegate Methods

- (void)foundRootPath:(NSString*)rootPath{
	
	//Found the path of *.opf file
	
	//get the full path of opf file
	//NSString *strOpfFilePath=[NSString stringWithFormat:@"%@/UnzippedEpub/%@",[self applicationDocumentsDirectory],rootPath];
    NSInteger iden=[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"];

    NSString *strOpfFilePath=[NSString stringWithFormat:@"%@/%d/%@",[self applicationDocumentsDirectory],iden,rootPath];
	NSFileManager *filemanager=[[NSFileManager alloc] init];
	
	self._rootPath=[strOpfFilePath stringByReplacingOccurrencesOfString:[strOpfFilePath lastPathComponent] withString:@""];
	
	if ([filemanager fileExistsAtPath:strOpfFilePath]) {
		
		//Now start parse this file
        _anotherHandlerOPF=[[XMLHandler alloc] init];
        _anotherHandlerOPF.delegate=self;
		[_anotherHandlerOPF parseXMLFileAt:strOpfFilePath];
	}
	else {
		
		UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error"
													  message:@"OPF File not found"
													 delegate:self
											cancelButtonTitle:@"OK"
											otherButtonTitles:nil];
		[alert show];
		//[alert release];
		alert=nil;
	}
	//[filemanager release];
	filemanager=nil;
	
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
   
    return  UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}
-(BOOL)shouldAutorotate{
    return YES;
}
- (void)finishedParsing:(EpubContent*)ePubContents{

	_pagesPath=[NSString stringWithFormat:@"%@/%@",self._rootPath,[ePubContents._manifest valueForKey:[ePubContents._spine objectAtIndex:0]]];
	self._ePubContent=ePubContents;
	_pageNumber=0;
	[self loadPage];
    [self addThumbnails];
 
}

-(void)leftOrRightGesture:(UISwipeGestureRecognizer *)gesture{
    _topToolbar.hidden=YES;
    
    if (gesture.direction==UISwipeGestureRecognizerDirectionRight) {
		NSLog(@"Right swipe");
        
		if (_pageNumber>0) {
			
			_pageNumber--;
			[self loadPage];
		}else{
            [self onBack:nil];
        }
	}
	else {
		NSLog(@"Left swipe");
		if ([self._ePubContent._spine count]-1>_pageNumber) {
			
			_pageNumber++;
			[self loadPage];
		}
	}

}
#pragma mark Button Actions

- (IBAction)onPreviousOrNext:(id)sender{
	
	
	UIBarButtonItem *btnClicked=(UIBarButtonItem*)sender;
	if (btnClicked.tag==0) {
		
		if (_pageNumber>0) {
			
			_pageNumber--;
			[self loadPage];
		}
	}
	else {
		
		if ([self._ePubContent._spine count]-1>_pageNumber) {
			
			_pageNumber++;
			[self loadPage];
		}
	}
}

- (IBAction)onBack:(id)sender{
   // [self.tabBarController.tabBar setHidden:NO];
    [self.navigationController.navigationBar setHidden:NO];
    self.navigationController.navigationBarHidden=NO;
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];
                           [_webview loadRequest:request];
[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	[self.navigationController popViewControllerAnimated:YES];
    NSLog(@"NSString %@",_strFileName);
    NSString *temp=[_strFileName stringByDeletingPathExtension];
    [[NSFileManager defaultManager]removeItemAtPath:temp error:nil];
    if (_pop) {
        [_pop dismissPopoverAnimated:YES];
    }
    [self stopRecording:nil];
    
//    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
//    delegate.PortraitOrientation=YES;
//    delegate.LandscapeOrientation=YES;
}

- (IBAction)showPopView:(id)sender {
   // NSString *deivceType=[UIDevice currentDevice].model;
    UINavigationController *nav;
    NotesHighlightViewController *notes=[[NotesHighlightViewController alloc]initWithStyle:UITableViewStyleGrouped With:[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"] withPageNo:_pageNumber];
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        [self.navigationController pushViewController:notes animated:YES];
       // [notes release];
        
        
    }else{
        nav=[[UINavigationController alloc]initWithRootViewController:notes];
       // [notes release];

       _pop=[[UIPopoverController alloc]initWithContentViewController:nav];
    [_pop presentPopoverFromBarButtonItem:_showPop permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        //[nav release];
    }
    
}

- (IBAction)playOrPauseAudio:(id)sender {

    // is not playing
    if (!_isPlaying) {
        
      
        [_webview stringByEvaluatingJavaScriptFromString:@"$('#jquery_jplayer').jPlayer('play')"];
        UIImage *image=[UIImage imageNamed:@"pause-control.png"];
          [_playPauseControl setImage:image forState:UIControlStateNormal];
        [self ribbonButtonClick:nil];
        
    }else{
        
        [_webview stringByEvaluatingJavaScriptFromString:@"$('#jquery_jplayer').jPlayer('pause')"];
        UIImage *image=[UIImage imageNamed:@"play-control.png"];
        [_playPauseControl setImage:image forState:UIControlStateNormal];

    }
    _isPlaying=!_isPlaying;
    
}
-(void)playingEnded{
    _isPlaying=NO;
    UIImage *image=[UIImage imageNamed:@"play-control.png"];
    [_playPauseControl setImage:image forState:UIControlStateNormal];
    NSLog(@"PLAYING ENDED");
}

- (IBAction)recordAudio:(id)sender {


  
    if(!_record){
        [UIView animateWithDuration:1.0 animations:^{
              CGRect frame;
            frame=  _recordBackgroundview.frame;
            frame.origin.x=frame.origin.x-frame.size.width;
            _recordBackgroundview.frame=frame;
        }];
        [self ribbonButtonClick:nil];
        
    }else{
        [UIView animateWithDuration:1.0 animations:^{
            CGRect frame;
            frame=  _recordBackgroundview.frame;
            frame.origin.x=frame.origin.x+frame.size.width;
            _recordBackgroundview.frame=frame;
        }];
    }
    _record=!_record;

}
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
   
   // [_anAudioRecorder release];
 
   // _anAudioRecorder=nil;
  [_recordAudioButton setEnabled:YES];

}
-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    NSLog(@"Error %@",error);
 //   [_anAudioRecorder release];
 //   _anAudioPlayer=nil;
    
}
/*Function Name : loadPage
 *Return Type   : void 
 *Parameters    : nil
 *Purpose       : To load actual pages to webview
 */

- (void)loadPage{
	
	_pagesPath=[NSString stringWithFormat:@"%@/%@",self._rootPath,[self._ePubContent._manifest valueForKey:[self._ePubContent._spine objectAtIndex:_pageNumber]]];
	[_webview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:_pagesPath]]];
    [self addThumbnails];
	//set page number
	//_pageNumberLbl.text=[NSString stringWithFormat:@"%d",_pageNumber+1];
}

#pragma mark Memory handlers

- (void)didReceiveMemoryWarning {
	
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
  //  [_videoCamera stopCameraCapture];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    // Set up an observer for proximity changes
 
    [self setShowRecordButton:nil];
    [self setNextButton:nil];
    [self setGameButton:nil];
    
    [self setRecordAudioButton:nil];
    [self setRecordBackgroundview:nil];
    [self setPlayPauseControl:nil];
    [self setToggleToolbar:nil];
    [self setImageToptoolbar:nil];
   

    [self setShowPop:nil];
    [self setScrollViewForThumnails:nil];
    
    [self setShareButton:nil];
    [self setDoneButton:nil];
    [self setTopToolbar:nil];

    [self setView:nil];
  
    _webview = nil;

}


/*- (void)dealloc {
if( [UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront ]){
        [_videoCamera release];
        [_filter release];
    }
    _gameLink=nil;
	//_arrayForItems=nil;
	[_webview release];
	_webview=nil;
	_imageLocation=nil;
    _url=nil;
	[_ePubContent release];
	_ePubContent=nil;
	
	_pagesPath=nil;
	_rootPath=nil;
	
	[_strFileName release];
	_strFileName=nil;
	
	//[_backGroundImage release];
//	_backGroundImage=nil;
	
    [_webview release];
   // [_view release];
//    [_Done release];
//    [_search release];
//    [_hide release];
//   
//    [_topToolbar release];
    [_topToolbar release];
    [_doneButton release];
    [_shareButton release];
   
    [_scrollViewForThumnails release];
    [_showPop release];
    [_imageToptoolbar release];
    [_toggleToolbar release];
    [_playPauseControl release];
    [_recordBackgroundview release];
    [_recordAudioButton release];
  
    [_gameButton release];
    [_nextButton release];
    [_showRecordButton release];
    [super dealloc];
}*/

- (IBAction)hideSearch:(id)sender {
 
}
- (IBAction)shareTheBook:(id)sender {
    NSString *ver= [UIDevice currentDevice].systemVersion;
    if([ver floatValue]>5.1){
    NSString *textToShare=[_url stringByAppendingString:@" great bk from MangoReader"];
    
   
    UIImage *image=[UIImage imageWithContentsOfFile:_imageLocation];
    NSArray *activityItems=@[textToShare,image];
    
    UIActivityViewController *activity=[[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    activity.excludedActivityTypes=@[UIActivityTypeCopyToPasteboard,UIActivityTypePostToWeibo,UIActivityTypeAssignToContact,UIActivityTypePrint,UIActivityTypeSaveToCameraRoll];
            if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
            [self presentModalViewController:activity animated:YES];
          //  [activity release];
            return;
        }
    UIPopoverController *pop=[[UIPopoverController alloc]initWithContentViewController:activity];
    
  //  [activity release];
        [pop presentPopoverFromBarButtonItem:_shareButton permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
        // you dont release this
        return;
    }
    MFMailComposeViewController *mail;
    mail=[[MFMailComposeViewController alloc]init];
    [mail setSubject:@"Found this awesome interactive book on MangoReader"];
    mail.modalPresentationStyle=UIModalTransitionStyleCoverVertical;

    [mail setMailComposeDelegate:self];
    NSString *body=[NSString stringWithFormat:@"Hi,\n%@",[_url stringByAppendingString:@"great bk from MangoReader"]];
    body =[body stringByAppendingString:@"\nI found this cool book on mangoreader - we bring books to life.The book is interactive with the characters moving on touch and movement, which makes it fun and engaging.The audio and text highlight syncing will make it easier for kids to learn and understand pronunciation.Not only this, I can play cool games in the book, draw and make puzzles and share my scores.\nDownload the MangoReader app from the appstore and try these awesome books."];
    [mail setMessageBody:body isHTML:NO];
    [self presentModalViewController:mail animated:YES];
  //  [mail release];

    
}

- (IBAction)ribbonButtonClick:(id)sender {
    NSLog(@"ribbonButton Click is called");
    if (_anAudioRecorder) {// nil assumption based on recording.
        
        NSLog(@"Recording is on");
        return;
    }
 if(_record&&sender){
     NSLog(@"recordAudio called");
            [self recordAudio:nil];
        }
      NSString *model=[UIDevice currentDevice].model;
    if (_hide&&sender) {// if hidden
          NSLog(@"hide is true");

        [UIView animateWithDuration:1.0 animations:^{
          //_imageToptoolbar
            CGRect frame=_imageToptoolbar.frame;
            frame.origin.y=0;
            _imageToptoolbar.frame=frame;
            
            frame=_toggleToolbar.frame;
            if ([model hasPrefix:@"iPad"]) {
                 frame.origin.y=_imageToptoolbar.frame.size.height-4;
            }else{
                frame.origin.y=_imageToptoolbar.frame.size.height-1;
            }
           
            _toggleToolbar.frame=frame;
            frame=_scrollViewForThumnails.frame;
            frame.origin.y=frame.origin.y-_scrollViewForThumnails.frame.size.height;
            _scrollViewForThumnails.frame=frame;
          
            _hide=!_hide;// reason in if is due to scheduling, which is a must
        }];
        
        NSLog(@"ribbonButton click scheduled");// only time scheduling is when the topbar is shown.
            [self performSelector:@selector(ribbonButtonClick:) withObject:nil afterDelay:20];
    
    }

    else if(!_hide){// simple reason to have else if instead of else is that call to this function is at times schedules with perform selector
        NSLog(@"hide is not true");
      
        [UIView animateWithDuration:1.0 animations:^{
            //_imageToptoolbar
            CGRect frame=_imageToptoolbar.frame;
              frame.origin.y=-_imageToptoolbar.frame.size.height;
            if ([model hasPrefix:@"iPad"]) {
                frame.origin.y=frame.origin.y+3;
            }
          
            _imageToptoolbar.frame=frame;
            
            
            frame=_toggleToolbar.frame;
            frame.origin.y=-1;
            _toggleToolbar.frame=frame;
            
            
            
            frame=_scrollViewForThumnails.frame;
            frame.origin.y=frame.origin.y+_scrollViewForThumnails.frame.size.height;
            _scrollViewForThumnails.frame=frame;
            _hide=!_hide;// reason in if is due to scheduling, which is a must
        }];
      
    }
   
    

}
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [controller dismissModalViewControllerAnimated:YES];
}
#pragma mark GameViewController
- (IBAction)openGame:(id)sender {
    if (_isPlaying) {
        
    
    [_webview stringByEvaluatingJavaScriptFromString:@"$('#jquery_jplayer').jPlayer('pause')"];
    UIImage *image=[UIImage imageNamed:@"play-control.png"];
    [_playPauseControl setImage:image forState:UIControlStateNormal];
        _isPlaying=NO;
    }
    _gameLink=[_gameLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
   NSURL *url= [NSURL URLWithString:_gameLink];
    WebViewController *web;
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
      web=  [[WebViewController alloc]initWithNibName:@"WebViewController" bundle:nil URL:url];
    }else{
      web  =[[WebViewController alloc]initWithNibName:@"WebViewControllerIphone" bundle:nil URL:url];}
    [self presentModalViewController:web animated:YES];
   // [web release];
    
}
//-(NSUInteger)supportedInterfaceOrientations{
//       NSLog(@"EpubSupported Supported");
//    return UIInterfaceOrientationMaskLandscape;
//}

#pragma mark recording
- (IBAction)startRecording:(id)sender {
  //  [_webview stringByEvaluatingJavaScriptFromString:@"$('#jquery_jplayer').jPlayer('stop')"];
    if (!_anAudioRecorder) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        NSDictionary *recordSettings = [NSDictionary
                                        dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kAudioFormatAppleIMA4],
                                        AVFormatIDKey,
                                        [NSNumber numberWithInt: 1],
                                        AVNumberOfChannelsKey,
                                        [NSNumber numberWithFloat:44100.0],
                                        AVSampleRateKey,
                                        nil];
        
        // Get temp path name
        
        NSString *path=[[NSUserDefaults standardUserDefaults] objectForKey:@"recordingDirectory"];
        NSInteger iden=[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"];
        NSString *appenLoc=[[NSString alloc] initWithFormat:@"%d",iden];
        path=[path stringByAppendingPathComponent:appenLoc];
    //    [appenLoc release];
        NSError *error;
        if (![[NSFileManager defaultManager]fileExistsAtPath:path]) {
             [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
            if (error) {
                NSLog(@"error %@",error);
            }
        }
       appenLoc=[[NSString alloc]initWithFormat:@"%d.ima4",_pageNumber ];
        
        NSString *loc=[path stringByAppendingPathComponent:appenLoc];
       
     //   [appenLoc release];
        if ([[NSFileManager defaultManager] fileExistsAtPath:loc]) {
            [[NSFileManager defaultManager]removeItemAtPath:loc error:nil];
        }
        NSURL *audioFileURL = [NSURL fileURLWithPath:loc];
        _anAudioRecorder= [[AVAudioRecorder alloc] initWithURL:audioFileURL
                                                      settings:recordSettings
                                                         error:&error];
        if (error) {
            NSLog(@"error %@",error);
        }

        [_anAudioRecorder setDelegate:self];
        [_anAudioRecorder recordForDuration:10];
        
        if ([_anAudioRecorder isRecording]) {
//            [[_recordAudioButton layer] setBorderWidth:3.0f];
//            float red=166/255;
//            float green=131/255;
//            UIColor *color=[UIColor colorWithRed:red green:green blue:0 alpha:1.0];
//            
//            [[_recordAudioButton layer]setBorderColor:color.CGColor];
            [_recordAudioButton setEnabled:NO];
        }
        
    }else{
        
    }
    
}

- (IBAction)stopRecording:(id)sender {
    if (_anAudioRecorder) {
        if ([_anAudioRecorder isRecording]) {
            [_anAudioRecorder stop];
           // [_anAudioRecorder release];
           // _anAudioRecorder=nil;
             // [[_recordAudioButton layer] setBorderWidth:0];
            [_recordAudioButton setEnabled:YES];
        }
    }
    if (_anAudioPlayer) {
        if ([_anAudioPlayer isPlaying]) {
            [_anAudioPlayer stop];
           // [_anAudioPlayer release];
          //  _anAudioPlayer=nil;
        }
    }
}

- (IBAction)playRecorded:(id)sender {
    NSString *path=[[NSUserDefaults standardUserDefaults] objectForKey:@"recordingDirectory"];
    NSInteger iden=[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"];
    //ima4
    NSString *appenLoc=[[NSString alloc]initWithFormat:@"%d/%d.ima4",iden,_pageNumber ];
 NSString *loc=[path stringByAppendingPathComponent:appenLoc];
    if ([[NSFileManager defaultManager]fileExistsAtPath:loc]) {
        if (!_anAudioPlayer) {
            UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
            AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                                     sizeof (audioRouteOverride),&audioRouteOverride);
            _anAudioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:loc] error:nil];
            [_anAudioPlayer setDelegate:self];
            [_anAudioPlayer setVolume:1.0];
            [_anAudioPlayer play];
        }
    }
}
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
  //  [_anAudioPlayer release];
  //  _anAudioPlayer=nil;
  //  [self recordAudio:nil];
    
}
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    NSLog(@"Error %@",error);
   // [_anAudioRecorder release];
   // _anAudioPlayer=nil;
}
-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if(motion==UIEventSubtypeMotionShake){
        [_webview stringByEvaluatingJavaScriptFromString:@"shakeActions()"];
        
        NSLog(@"motion shake");
    }
}
-(void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    
}
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
 
    
}
@end
