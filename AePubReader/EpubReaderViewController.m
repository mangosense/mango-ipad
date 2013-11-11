
#import "EpubReaderViewController.h"
#import "NotesHighlightViewController.h"
#import "AePubReaderAppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "WebViewController.h"
#import <AudioToolbox/AudioServices.h>
#import "UIWebView+SearchWebView.h"
#import "CoverViewController.h"
#import "PreKCategoriesViewController.h"

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
    if (button.tag==0&&UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        [self.navigationController popViewControllerAnimated:NO];
        _pageNumber=1;
        return;
    }
    _pageNumber=button.tag;
    [self loadPage];
    
    
}
-(void)addThumbnails{
  //  NSLog(@"file location %@",_rootPath);
 

    NSFileManager *defaultManager=[NSFileManager defaultManager];
      NSInteger index;

    NSString *thumbNailLocation=[_rootPath stringByAppendingPathComponent:@"thumbnails"];
    if ( [defaultManager fileExistsAtPath:thumbNailLocation]) {
       NSArray *array= [defaultManager contentsOfDirectoryAtPath:thumbNailLocation error:nil];
        NSMutableArray *arrayMutable=[[NSMutableArray alloc]initWithCapacity:array.count];
        
        for (index=0; index<_ePubContent._spine.count; index++) {
            NSString  *actual=[self._ePubContent._manifest valueForKey:(self._ePubContent._spine)[index]];
            actual =[actual stringByDeletingPathExtension];
            NSString *val=[actual stringByAppendingString:@".png"];
            [arrayMutable addObject:val];
        }
        array=[NSArray arrayWithArray:arrayMutable];

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
            NSString *imageLoc=array[index];
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
    _callOnBack=NO;
    UIImage *image=[UIImage imageNamed:@"top.png"];
    UIColor *color=[UIColor colorWithPatternImage:image];
    _imageToptoolbar.backgroundColor=color;
    image=[UIImage imageNamed:@"side.png"];
   color=[UIColor colorWithPatternImage:image];
  //  _recordBackgroundview.backgroundColor=color;
    _hide=YES;
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    [dictionary setValue:_titleOfBook forKey:@"book title"];
    [dictionary setValue:@([[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"]) forKey:@"bookid"];
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        NSString *string=@"ipad Story Book reading ";
        
        [Flurry logEvent:string withParameters:dictionary];
    }else{
        NSString *string=@"iphone or ipod touch Store Book reading";
        
        [Flurry logEvent:string withParameters:dictionary];
    }

    [_recordButton addTarget:self action:@selector(wasDragged:withEvent:)  forControlEvents:UIControlEventTouchDragInside];
    [_playRecordedButton addTarget:self action:@selector(wasDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [_stopRecordingOrRecordedAudio addTarget:self action:@selector(wasDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
	[_webview setBackgroundColor:[UIColor clearColor]];
	//First unzip the epub file to documents directory
	//[self unzipAndSaveFile];
	_xmlHandler=[[XMLHandler alloc] init];
	_xmlHandler.delegate=self;
  
        [_xmlHandler parseXMLFileAt:[self getRootFilePath]];
    
    [_leftButton setAlpha:0.25f];
    [_rightButton setAlpha:0.25f];
   
      [self removeZoom:_webview];
   /* UISwipeGestureRecognizer *left=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftOrRightGesture:)];
    left.direction=UISwipeGestureRecognizerDirectionRight;
    UISwipeGestureRecognizer *right=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftOrRightGesture:)];
    right.direction=UISwipeGestureRecognizerDirectionLeft;
    [_webview.scrollView addGestureRecognizer:left];
    [_webview.scrollView addGestureRecognizer:right];*/

    [_shareButton setTintColor:[UIColor lightGrayColor]];
    [self.navigationController.navigationBar addSubview:_textField];

    [self.navigationController.navigationBar setHidden:YES];
        [self.tabBarController.tabBar setHidden:YES];
    [_webview setDelegate:self];

    NSLog(@"height %f",_webview.frame.size.height);
    NSString *temp=[_strFileName stringByDeletingPathExtension];
    if([[NSFileManager defaultManager]fileExistsAtPath:temp]){
        [[NSURL URLWithString:temp] setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:nil];
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
    
    //_webview.scrollView.scrollEnabled=NO;
    
   // _webview.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"wood_pattern.png"]];
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
      // rect= _recordBackgroundview.frame;
        rect.origin.x=568.0;
       // _recordBackgroundview.frame=rect;
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
        UIViewController *c=[[UIViewController alloc]init];
 
        [self presentViewController:c animated:NO completion:^(void){
            [self dismissModalViewControllerAnimated:YES];
        }];
        
        _wasFirstInPortrait=YES;
 

    }else{
    
        NSLog(@"landscape");
    }
    _hide=YES;
    _record=NO;
    _topToolbar.hidden=YES;
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled==YES) {
        // Set up an observer for proximity changes
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)
                                                     name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    }

    [_playRecordedButton setEnabled:NO];

    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        _progressView=[[CircularProgressView alloc]initWithFrame:CGRectMake(27, 25, 178, 175)];

    }else{
        _progressView=[[CircularProgressView alloc]initWithFrame:CGRectMake(34, 33, 95,95)];
    }
    [_progressView setColourR:0.0 G:1.0 B:0.0 A:1.0];
    [_recordControlView addSubview:_progressView];
    [_recordControlView bringSubviewToFront:_recordButton];
    [_recordControlView bringSubviewToFront:_stopRecordingOrRecordedAudio];
    [_recordControlView bringSubviewToFront:_playRecordedButton];

    [_progressView setHidden:YES];
    _viewAppeared=NO;
    _startTime=[[NSDate date]timeIntervalSince1970];
    _startedReading=YES;
    _playingPaused=YES;
}
- (IBAction)wasDragged:(UIButton *)button withEvent:(UIEvent *)event{
    //get the touch
    UITouch *touch=[[event touchesForView:button] anyObject];
    //get delta
    CGPoint previousLocation=[touch previousLocationInView:button];
    CGPoint location=[touch locationInView:button];
    CGFloat delta_x=location.x-previousLocation.x;
    CGFloat delta_y=location.y-previousLocation.y;
    _recordControlView.center=CGPointMake(_recordControlView.center.x+delta_x,_recordControlView.center.y+delta_y);
}
-(void)showDay{
    _DayOrNight=YES;
     [_webview stringByEvaluatingJavaScriptFromString:@"showDay()"];
}
-(void)showNight{
    _DayOrNight=NO;
     [_webview stringByEvaluatingJavaScriptFromString:@"showNight()"];
}


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

-(BOOL)canBecomeFirstResponder{
    return YES;
}
-(void)notes:(id)sender{


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


    
}


-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{

    NSLog(@"%@",error);
}
-(void) scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x > 0)
        scrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y);
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
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
  
   // NSLog(@" %@",jsCode);
    if ([jsCode isEqualToString:@"true"]) {
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        if (delegate.options) {
            
            
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
-(void)addListener{
    NSString  *jsCode=[_webview stringByEvaluatingJavaScriptFromString:@"function tryout(){if(document.getElementById('jquery_jplayer')){return true}} tryout()"];
    
    NSLog(@" %@",jsCode);
    if ([jsCode isEqualToString:@"true"]) {
        jsCode=@" $('#jquery_jplayer').bind($.jPlayer.event.ended, function(event) {  window.location = \"playingCompleted:myObjectiveCFunction\";});";
        [_webview stringByEvaluatingJavaScriptFromString:jsCode];

        [_playPauseControl setEnabled:YES];

    }else{
        [_playPauseControl setEnabled:NO];

    }
}
-(void)AlternativetoPlayAudio{
    [self readyState];
      NSString *value=[_webview stringByEvaluatingJavaScriptFromString:@"$('#jquery_jplayer').data('handleAudio').getAudioPath()"];
    if (value.length==0) {
        [self readyState];
        _isOld=YES;
    }else{
        NSString  *jsCode=[_webview stringByEvaluatingJavaScriptFromString:@"function tryout(){if(document.getElementById('jquery_jplayer')){return true}} tryout()"];
        
        if ([jsCode isEqualToString:@"false"]) {
            [_playPauseControl setEnabled:NO];

        }else{
             [_playPauseControl setEnabled:YES];
        }
  
       
        _isOld=NO;
    }

    
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopRecordingOrRecordedAudioPlayed:nil];
    _pageLoaded=NO;
    NSString *jsCode;
    UIImage *image=[UIImage imageNamed:@"play-control.png"];
    [_playPauseControl setImage:image forState:UIControlStateNormal];
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {

        webView.scrollView.bounces=NO;
        jsCode=@"<meta name=\"viewport\" content=\"width=device-width\" />";
        [webView stringByEvaluatingJavaScriptFromString:jsCode];
        webView.scrollView.delegate=self;
     
    }
    [UIView animateWithDuration:2.0 animations:^(void) {
        
        [_leftButton setAlpha:1.0f];
        [_rightButton setAlpha:1.0f];
        [_toggleToolbar setAlpha:1.0f];
        
    }];
    [UIView animateWithDuration:1.0 animations:^(void) {
        
        [_leftButton setAlpha:0.25f];
        [_rightButton setAlpha:0.25f];
        [_toggleToolbar setAlpha:0.25f];
        
    }];
    if ([self._ePubContent._spine count]-1==_pageNumber) {
        _rightButton.hidden=YES;
    }else{
        _rightButton.hidden=NO;
    }
    
    _isPlaying=NO;

//
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        jsCode=[_webview stringByEvaluatingJavaScriptFromString:@"localStorage.autoPlay"];
   
        if ([jsCode isEqualToString:@"1"]) {
        delegate.options=1;
            [self performSelector:@selector(playOrPauseAudio:) withObject:nil afterDelay:0];

        }else if([jsCode isEqualToString:@"0"]){
            delegate.options=0;
        }
    }else
    {
 

        switch (delegate.options) {
            case 0: // read by myself

            break;
            case 1:// read to me
              
                    [self performSelector:@selector(playOrPauseAudio:) withObject:nil afterDelay:0];
                
            break;
            case 2: // record voice
            if ([_recordControlView isHidden]) {
                [self recordAudio:nil];

            }
            break;
            case 3: // play recorded voice
                if (![_recordControlView isHidden]) {
                    [self recordAudio:nil];
 
                }
                if (_pageNumber>0) {
                    [self performSelector:@selector(playInMyVoice) withObject:self afterDelay:2];

                }
                break;
            default:
            break;
            }
       
    [_webview stringByEvaluatingJavaScriptFromString:jsCode];
  
    [self performSelector:@selector(addListener) withObject:nil afterDelay:1.0];
    }
    NSLog(@"pageNumber %d",_pageNumber);
    CGSize size=webView.scrollView.contentSize;
    size.width=1024;
    [webView.scrollView setContentSize:size];
    NSString *page=[[webView.request.URL absoluteString] lastPathComponent];
   // NSLog(@"path %@",page);
    for (int i=0;i<_ePubContent._spine.count;i++) {
        NSString *temp=[_ePubContent._manifest valueForKey:(self._ePubContent._spine)[i]];
        if ([temp isEqualToString:page]) {
            if (i!=_pageNumber) {
                if (_pageNumber<i) {
                    _pageNumber=i;

                }
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
    
    if (_pageNumber==0) {
        _leftButton.hidden=YES;
        _rightButton.hidden=YES;
    }else{
        _leftButton.hidden=NO;
        _rightButton.hidden=NO;
    }
    NSString *path=[[NSUserDefaults standardUserDefaults] objectForKey:@"recordingDirectory"];
    NSInteger iden=[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"];
    NSString *appenLoc=[[NSString alloc] initWithFormat:@"%d",iden];
    path=[path stringByAppendingPathComponent:appenLoc];
    appenLoc=[[NSString alloc]initWithFormat:@"%d.ima4",_pageNumber ];

    path=[path stringByAppendingPathComponent:appenLoc];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [_playRecordedButton setEnabled:NO];
    }else{
        [_playRecordedButton setEnabled:YES];
    }
    _anAudioPlayer=nil;
    [_stopRecordingOrRecordedAudio setEnabled:NO];
}
-(void)playInMyVoice{
    UIImage *image=[UIImage imageNamed:@"pause-control.png"];
    [_playPauseControl setImage:image forState:UIControlStateNormal];
     AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];

    NSString *path=[[NSUserDefaults standardUserDefaults] objectForKey:@"recordingDirectory"];
    NSInteger iden=[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"];
    //ima4
    NSString *appenLoc=[[NSString alloc]initWithFormat:@"%d/%d.ima4",iden,_pageNumber ];
    NSString *loc=[path stringByAppendingPathComponent:appenLoc];
    NSLog(@"loc %@",loc);
    NSError *error;
    if([[NSFileManager defaultManager] fileExistsAtPath:loc]){
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                                 sizeof (audioRouteOverride),&audioRouteOverride);
        _anAudioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:loc] error:&error];
        [_anAudioPlayer setDelegate:self];
        [_anAudioPlayer setVolume:1.0];
        [_anAudioPlayer play];
        if (error) {
            NSLog(@"%@",[error debugDescription]);
        }
        NSLog(@"Page Number %d playing audio",_pageNumber);

    }
    
}
-(void)update{
    
    float totalDuration=[_playerDefault duration];
    float currentDuration=_playerDefault.currentTime;
    float percentage=currentDuration/totalDuration;
    percentage=percentage*100;
    _jsCode=[[NSString alloc]initWithFormat:@"$('#jquery_jplayer').data('handleAudio').setAudioCue(%f,%f)",percentage,currentDuration];
   // NSLog(@"%@",_jsCode);
    [self performSelectorOnMainThread:@selector(sendUrl) withObject:nil waitUntilDone:YES];
    /*"$('#jquery_jplayer').data('handleAudio').setAudioCue("
    + percentage + "," + currentDuration + ")";*/
}
-(void)sendUrl{
    [_webview stringByEvaluatingJavaScriptFromString:_jsCode];
}
-(void)webViewDidStartLoad:(UIWebView *)webView{
   

}
-(void)viewDidDisappear:(BOOL)animated{
   
    NSString *value=[_strFileName stringByDeletingPathExtension];
    [[NSUserDefaults standardUserDefaults]setValue:value forKey:@"locDirectory"];
    if ([_anAudioPlayer isPlaying]) {
        [_anAudioPlayer stop];
    }
    if ([_timerProgress isValid]) {
        [_timerProgress invalidate];
    }

    if (_isPlaying) {
        [self playOrPauseAudio:nil];
    }
_pageCountTime=[[NSDate date]timeIntervalSince1970]-_pageCountTime;
NSTimeInterval avgTime=[[NSUserDefaults standardUserDefaults] floatForKey:@"avgPageTimer"];
avgTime=avgTime+_pageCountTime;
avgTime=avgTime/2;
[[NSUserDefaults standardUserDefaults] setFloat:avgTime forKey:@"avgPageTimer"];


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

    NSString *string=@"started reading Book ";
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    [dictionary setValue:@([[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"]) forKey:@"identity"];
    [dictionary setValue:_titleOfBook forKey:@"book title"];
    [Flurry logEvent:string withParameters:dictionary];

//    if (!_isPlaying ) {
//        [self playOrPauseAudio:nil];
//
//    }
}
-(void)viewWillDisappear:(BOOL)animated{
    if (_playerDefault&&_playerDefault.isPlaying) {
        [self playOrPauseAudio:nil];

    }
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
       //[self becomeFirstResponder];
//[self loadPage];
   /* if (_pageNumber==0&&UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        //CoverViewController
        [self performSelector:@selector(delayedPush) withObject:nil afterDelay:5];
    }*/
    //[self performSelector:@selector(loadPage) withObject:nil afterDelay:6];
    _viewAppeared=YES;
}
-(void)delayedPush{
    CoverViewController *coverViewController=[[CoverViewController alloc]initWithNibName:@"CoverViewController" bundle:nil];
    coverViewController.imageLocation=_imageLocation;
    [self.navigationController pushViewController:coverViewController animated:NO];
    coverViewController.epubViewController=self;
    _pageNumber++;

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
    NSString *basePath = ([paths count] > 0) ? paths[0] : nil;
    return basePath;
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
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

    NSString *strFilePath=[NSString stringWithFormat:@"%@/%d/META-INF/container.xml",[self applicationDocumentsDirectory],iden];
	if ([filemanager fileExistsAtPath:strFilePath]) {
		
		//valid ePub
		NSLog(@"Parse now");
		
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
		alert=nil;
		
	}
	filemanager=nil;
	return @"";
}

- (IBAction)backButtonOrNextButton:(id)sender {
    UIButton *btnClicked=(UIButton*)sender;
    [btnClicked setAlpha:1.0f];
	if (btnClicked.tag==0) {
		
		if (_pageNumber>0) {
			
			_pageNumber--;
            if (_pageNumber==0&&UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
                [self.navigationController popViewControllerAnimated:NO];
                _pageNumber=1;

            }else{
                [self loadPage];

            }
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

#pragma mark XMLHandler Delegate Methods

- (void)foundRootPath:(NSString*)rootPath{
	
	//Found the path of *.opf file
   
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
		alert=nil;
        }
   
	
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
   
    return  UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}
-(BOOL)shouldAutorotate{
    return YES;
}
- (void)finishedParsing:(EpubContent*)ePubContents{

	_pagesPath=[NSString stringWithFormat:@"%@/%@",self._rootPath,[ePubContents._manifest valueForKey:(ePubContents._spine)[0]]];
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
#pragma newRecordControls
- (IBAction)stopRecordingOrRecordedAudioPlayed:(id)sender {
    if ([_anAudioRecorder isRecording]||_recordPaused) {
        [_anAudioRecorder stop];
        _anAudioRecorder=nil;
        _recordPaused =NO;
        [_playRecordedButton setEnabled:YES];
        [_stopRecordingOrRecordedAudio setEnabled:NO];
        UIImage *image=[UIImage imageNamed:@"recordbutton.png"];
        
        [_recordButton setImage:image forState:UIControlStateNormal];
    }
   
    if ([_anAudioPlayer isPlaying]||_playingPaused) {
        [_anAudioPlayer stop];
        _anAudioPlayer =nil;
        [_stopRecordingOrRecordedAudio setEnabled:NO];
        [_recordButton setEnabled:YES];
        _playingPaused=NO;
        UIImage *image=[UIImage imageNamed:@"playbutton.png"];
        [_playRecordedButton setImage:image forState:UIControlStateNormal];
    }
    [_progressView setHidden:YES];
}

- (IBAction)onBack:(id)sender{
    if(_playerDefault){
        _playerDefault=nil;
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

    self.navigationController.navigationBarHidden=NO;

    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];
                           [_webview loadRequest:request];


    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.tabBarController.tabBar setHidden:NO];

    NSLog(@"NSString %@",_strFileName);

    if (_pop) {
        [_pop dismissPopoverAnimated:YES];
    }
    [self stopRecordingOrRecordedAudioPlayed:nil];
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    [dictionary setValue:@([[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"]) forKey:@"identity"];
    [dictionary setValue:_titleOfBook forKey:@"book title"];
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        NSString *string=@"ipad Story Book closed ";
        [Flurry logEvent:string withParameters:dictionary];
    }else{
        NSString *string=@"iphone or ipod touch  Story Book closed ";
                [Flurry logEvent:string withParameters:dictionary];
    }
    [self.tabBarController.tabBar setHidden:NO];
  
    double last=    [[NSUserDefaults standardUserDefaults]doubleForKey:@"timerCompleted"];
       double endStartTimer=[[NSDate date]timeIntervalSince1970];
    endStartTimer=endStartTimer-_startTime;
    last=last+endStartTimer;
    [[NSUserDefaults standardUserDefaults] setFloat:last forKey:@"timerCompleted"];
    _pageCountTime=[[NSDate date]timeIntervalSince1970]-_pageCountTime;
    NSTimeInterval avgTime=[[NSUserDefaults standardUserDefaults] floatForKey:@"avgPageTimer"];
    avgTime=avgTime+_pageCountTime;
    avgTime=avgTime/2;
    [[NSUserDefaults standardUserDefaults] setFloat:avgTime forKey:@"avgPageTimer"];
}

- (IBAction)showPopView:(id)sender {
    UINavigationController *nav;
    NotesHighlightViewController *notes=[[NotesHighlightViewController alloc]initWithStyle:UITableViewStyleGrouped With:[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"] withPageNo:_pageNumber];
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        [self.navigationController pushViewController:notes animated:YES];
        
        
    }else{
        nav=[[UINavigationController alloc]initWithRootViewController:notes];

       _pop=[[UIPopoverController alloc]initWithContentViewController:nav];
    [_pop presentPopoverFromBarButtonItem:_showPop permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
}

- (IBAction)playOrPauseAudio:(id)sender {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    if (delegate.options==3) {
        if ([_anAudioPlayer isPlaying]) {
            [_anAudioPlayer pause];
            UIImage *image=[UIImage imageNamed:@"play-control.png"];
            [_playPauseControl setImage:image forState:UIControlStateNormal];

        }else{
            [_anAudioPlayer play];
            UIImage *image=[UIImage imageNamed:@"pause-control.png"];
            [_playPauseControl setImage:image forState:UIControlStateNormal];
        }
        
        
   
     }//recording case ends
    else{
        
        if (_timerProgress&&!_playerDefault) {
            [_timerProgress invalidate];
            _timerProgress=nil;
        }
        if (!_playerDefault) {
            
         
            NSString *audioPath=[_webview stringByEvaluatingJavaScriptFromString:@"$('#jquery_jplayer').data('handleAudio').getAudioPath()"];
            audioPath=[_rootPath stringByAppendingPathComponent:audioPath];
            NSLog(@"audioPath %@",audioPath);
            NSError *error;
            if ([audioPath hasSuffix:@"mp3"]) {
                audioPath=[audioPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                _playerDefault=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:audioPath] error:&error];
                if (error) {
                    NSLog(@"%@",error);

                }
                [_playerDefault setDelegate:self];
                [_playerDefault setVolume:1.0];
                [_playerDefault play];
                  _timerProgress=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(update) userInfo:nil repeats:YES];
                _playingPaused=NO;
                }
            UIImage *image=[UIImage imageNamed:@"pause-control.png"];
            [_playPauseControl setImage:image forState:UIControlStateNormal];
             [self ribbonButtonClick:nil];
        }else{
            if ([_playerDefault isPlaying]) {
                [_playerDefault pause];
                _playingPaused=YES;
                UIImage *image=[UIImage imageNamed:@"play-control.png"];
                [_playPauseControl setImage:image forState:UIControlStateNormal];
            }else{
                [_playerDefault play];
                _playingPaused=NO;
                UIImage *image=[UIImage imageNamed:@"pause-control.png"];
                [_playPauseControl setImage:image forState:UIControlStateNormal];
                 [self ribbonButtonClick:nil];
            }
        }
    /*    if (!_isPlaying) {
        
      
            [_webview stringByEvaluatingJavaScriptFromString:@"$('#jquery_jplayer').jPlayer('play')"];
            UIImage *image=[UIImage imageNamed:@"pause-control.png"];
              NSString *audioPath=[_webview stringByEvaluatingJavaScriptFromString:@"$('#jquery_jplayer').data('handleAudio').getAudioPath()"];
            NSLog(@"%@",audioPath);
            [_playPauseControl setImage:image forState:UIControlStateNormal];
            [self ribbonButtonClick:nil];
        
        }else{
        
            [_webview stringByEvaluatingJavaScriptFromString:@"$('#jquery_jplayer').jPlayer('pause')"];
            UIImage *image=[UIImage imageNamed:@"play-control.png"];
            [_playPauseControl setImage:image forState:UIControlStateNormal];

        }
        _isPlaying=!_isPlaying;*/
    }
    
}
-(void)playingEnded{
    _isPlaying=NO;
    UIImage *image=[UIImage imageNamed:@"play-control.png"];
    [_playPauseControl setImage:image forState:UIControlStateNormal];
    NSLog(@"PLAYING ENDED");
}

- (IBAction)recordAudio:(id)sender {

    if ([_recordControlView isHidden]) {
        [_recordControlView setHidden:NO];
        [_recordControlView setAlpha:0.0f];
        [UIView animateWithDuration:2.0 animations:^(void) {
            [_recordControlView setAlpha:1.0f];
            
        }];
        [self ribbonButtonClick:nil];
    }else{
     //   [_recordButton setAlpha:1.0f];
        [UIView animateWithDuration:1.0 animations:^(void){
        
            [_recordControlView setAlpha:0.0f];
        } completion:^(BOOL completed){
            [_recordControlView setHidden:YES];
        
        }];
        
    }
    if (_isPlaying) {
        [self playOrPauseAudio:nil];
    }

    _record=!_record;

}
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    [_timerProgress invalidate];
    _timerProgress=nil;

    if (_anAudioRecorder) {
        _anAudioRecorder =nil;
    }
    if (_anAudioPlayer) {
        _anAudioPlayer=nil;
    }
    [_stopRecordingOrRecordedAudio setEnabled:NO];

    UIImage *image=[UIImage imageNamed:@"recordbutton.png"];
    
    [_recordButton setImage:image forState:UIControlStateNormal];
    [_playRecordedButton setEnabled:YES];
    [_progressView setHidden:YES];


}
-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    NSLog(@"Error %@",error);

    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:[error debugDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    UIImage *image=[UIImage imageNamed:@"recordbutton.png"];
    [_stopRecordingOrRecordedAudio setEnabled:NO];

    [_recordButton setImage:image forState:UIControlStateNormal];
 
    [_playRecordedButton setEnabled:YES];
    [_progressView setHidden:YES];

}
/*Function Name : loadPage
 *Return Type   : void 
 *Parameters    : nil
 *Purpose       : To load actual pages to webview
 */

- (void)loadPage{
	
    if (_pageNumber==0&&UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
            _pageNumber++;
        
    }
        if (_playerDefault) {
            _playerDefault=nil;
        }
	_pagesPath=[NSString stringWithFormat:@"%@/%@",self._rootPath,[self._ePubContent._manifest valueForKey:(self._ePubContent._spine)[_pageNumber]]];
	[_webview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:_pagesPath]]];
        
    [self addThumbnails];
        if (_pageCountTime==0) {
            _pageCountTime=[[NSDate date]timeIntervalSince1970];
            
        }else{
           
            NSTimeInterval diff=[[NSDate date]timeIntervalSince1970]-_pageCountTime;
             _pageCountTime=[[NSDate date]timeIntervalSince1970];
            NSTimeInterval avgTime=[[NSUserDefaults standardUserDefaults] floatForKey:@"avgPageTimer"];
            avgTime=avgTime+diff;
            avgTime=avgTime/2;
            [[NSUserDefaults standardUserDefaults] setFloat:avgTime forKey:@"avgPageTimer"];
            
        }
    
   NSInteger pageCount= [[NSUserDefaults standardUserDefaults]integerForKey:@"tpageCount"];
    pageCount++;
    [[NSUserDefaults standardUserDefaults]setInteger:pageCount forKey:@"tpageCount"];
    if(self._ePubContent._spine.count-2<=_pageNumber&&_startedReading){
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        NSInteger bookCount=[[NSUserDefaults standardUserDefaults]integerForKey:@"tbookCount"];
        bookCount++;
        [[NSUserDefaults standardUserDefaults] setInteger:bookCount forKey:@"tbookCount"];
         NSInteger iden=[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"];
      
        Book *book=[delegate.dataModel getBookOfId:[NSString stringWithFormat:@"%d",iden ]];
         bookCount=book.bookCount.integerValue;
        bookCount++;
        book.bookCount=[NSNumber numberWithInteger:bookCount];
            [delegate.dataModel saveData:book];
            _startedReading=NO;
        
    }
	//set page number
	//_pageNumberLbl.text=[NSString stringWithFormat:@"%d",_pageNumber+1];
}

#pragma mark Memory handlers

- (void)didReceiveMemoryWarning {
	
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setCircularProgressView:nil];
    [self setStopRecordingOrRecordedAudio:nil];
    [self setPlayRecordedButton:nil];
    [self setRecordButton:nil];
    [self setRecordControlView:nil];
    [self setRecordButton:nil];
    [self setPlayRecordedButton:nil];
    [self setRightButton:nil];
    [self setLeftButton:nil];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    // Set up an observer for proximity changes
 
    [self setShowRecordButton:nil];
    [self setNextButton:nil];
    [self setGameButton:nil];
    
   // [self setRecordAudioButton:nil];
   // [self setRecordBackgroundview:nil];
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
    NSString *body=[NSString stringWithFormat:@"Hi,\n%@",[_url stringByAppendingString:@" great bk from MangoReader"]];
    body =[body stringByAppendingString:@"\nI found this cool book on mangoreader - we bring books to life.The book is interactive with the characters moving on touch and movement, which makes it fun and engaging.The audio and text highlight syncing will make it easier for kids to learn and understand pronunciation.Not only this, I can play cool games in the book, draw and make puzzles and share my scores.\nDownload the MangoReader app from the appstore and try these awesome books."];
    [mail setMessageBody:body isHTML:NO];
    [self presentModalViewController:mail animated:YES];
  //  [mail release];

    
}

- (IBAction)ribbonButtonClick:(id)sender {
    NSLog(@"ribbonButton Click is called");
    if ([_anAudioRecorder isRecording]) {// nil assumption based on recording.
        
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
            [self performSelector:@selector(ribbonButtonClick:) withObject:nil afterDelay:15];
        [_leftButton setAlpha:1.0f];
        [_rightButton setAlpha:1.0f];
        [_toggleToolbar setAlpha:1.0f];
    }

    else if(!_hide){// simple reason to have else if instead of else is that call to this function is at times schedules with perform selector
        [_leftButton setAlpha:0.25f];
        [_rightButton setAlpha:0.25f];
        [_toggleToolbar setAlpha:0.25f];
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
    if ([_playerDefault isPlaying]) {
        [_playerDefault pause];
        UIImage *image=[UIImage imageNamed:@"play-control.png"];
        [_playPauseControl setImage:image forState:UIControlStateNormal];
    }
    _gameLink=[_gameLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
   NSURL *url= [NSURL URLWithString:_gameLink];
    WebViewController *web;
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
      web=  [[WebViewController alloc]initWithNibName:@"WebViewController" bundle:nil URL:url];
    }else{
      web  =[[WebViewController alloc]initWithNibName:@"WebViewControllerIphone" bundle:nil URL:url];}
    [self presentModalViewController:web animated:YES];
    
}

#pragma mark recording
/*- (IBAction)startRecording:(id)sender {
    UIButton *recordButton=(UIButton *)sender;
  //  [_webview stringByEvaluatingJavaScriptFromString:@"$('#jquery_jplayer').jPlayer('stop')"];
 //   [_anAudioRecorder pause];
    [_progressView setHidden:NO];
    
    if (![_anAudioRecorder isRecording]) {
        if (_isPlaying) {
            [self playOrPauseAudio:nil];
        }
        if ([_anAudioPlayer isPlaying]) {
            [self playRecorded:nil];
        }
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
            [[NSFileManager defaultManager]removeItemAtPath:loc error:&error];
            if (error) {
                NSLog(@"error %@",error);
    
            }
        }
        NSURL *audioFileURL = [NSURL fileURLWithPath:loc];
        _anAudioRecorder= [[AVAudioRecorder alloc] initWithURL:audioFileURL
                                                      settings:recordSettings
                                                         error:&error];
        if (error) {
            NSLog(@"error %@",error);
        }

        [_anAudioRecorder setDelegate:self];
        [_anAudioRecorder recordForDuration:60];
        UIImage *image=[UIImage imageNamed:@"stop-recording-control.png"];
        [recordButton setImage:image forState:UIControlStateNormal];
        [_playRecordedButton setEnabled:NO];
        [_progressView setHidden:NO];
        _timerProgress=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    }else{
        [_anAudioRecorder stop];
        [_playRecordedButton setEnabled:YES];
        [_progressView setHidden:YES];
        UIImage *image=[UIImage imageNamed:@"start-recording-control.png"];
        [recordButton setImage:image forState:UIControlStateNormal];
        
    }
   
}*/
-(void)updateProgressOfRecorder{
    double progress=_anAudioRecorder.currentTime;
    progress=progress/60.0;
    [_progressView setProgress:progress];
    
   // CGFloat float=
    
}
-(void)updateProgressOfPlayer{
    double progress=_anAudioPlayer.currentTime;
    progress=progress/_anAudioPlayer.duration;
    [_progressView setProgress:progress];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    if (delegate.options==3) {
        [_anAudioPlayer stop];
        _pageNumber++;
        [self loadPage];
        return;
    }
       if (delegate.options==1) {// if read to me option
        if ([self._ePubContent._spine count]-1>_pageNumber) {
			
			_pageNumber++;
            
			[self loadPage];
		}

    }
    UIImage *image=[UIImage imageNamed:@"play-control.png"];
    [_playRecordedButton setImage:image forState:UIControlStateNormal];
    [_playPauseControl setImage:image forState:UIControlStateNormal];
    if (_playerDefault==player) {
        [_webview stringByEvaluatingJavaScriptFromString:@"$('#jquery_jplayer').data('handleAudio').resetCues()"];
        _anAudioPlayer=nil;
    }
    [_stopRecordingOrRecordedAudio setEnabled:NO];

    [_recordButton setEnabled:YES];
    //_playingPaused=NO;
    if (_playerDefault) {
        _playerDefault=nil;
        [_timerProgress invalidate];
        _timerProgress=nil;
    }

    if (_timerProgress) {
        [_timerProgress invalidate];
        _timerProgress=nil;
    }
   
    [_progressView setProgress:1.0f];
    [self performSelector:@selector(hideProgress) withObject:nil afterDelay:1.0];

}
-(void)hideProgress{
    [_progressView setHidden:YES];

}
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    NSLog(@"Error %@",error);
    [_progressView setHidden:YES];
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:[error debugDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    if (_anAudioPlayer) {
        _anAudioPlayer =nil;
        
    }
    UIImage *image=[UIImage imageNamed:@"playbutton.png"];
    [_playRecordedButton setImage:image forState:UIControlStateNormal];
    _playingPaused=NO;
    [_stopRecordingOrRecordedAudio setEnabled:NO];

    [_recordButton setEnabled:YES];
    if (_timerProgress ) {
        [_timerProgress invalidate];
        _timerProgress =nil;
    }
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
#pragma resume or pause the recording action
- (IBAction)playOrPauseRecording:(id)sender {
    UIButton *recordButton=(UIButton *)sender;
    [_stopRecordingOrRecordedAudio setEnabled:YES];
    [_progressView setHidden:NO];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    if (!_timerProgress) {
    _timerProgress=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressOfRecorder) userInfo:nil repeats:YES];
    }
    
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];

    if (!_anAudioRecorder) {
        [dictionary setValue:@([[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"]) forKey:@"identity"];
        [Flurry logEvent:@"recording" withParameters:dictionary];
        NSDictionary *recordSettings = @{AVFormatIDKey: @(kAudioFormatAppleIMA4),
                                        AVNumberOfChannelsKey: @1,
                                        AVSampleRateKey: @44100.0f};
        NSString *path=[[NSUserDefaults standardUserDefaults] objectForKey:@"recordingDirectory"];
        NSInteger iden=[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"];
        NSString *appenLoc=[[NSString alloc] initWithFormat:@"%d",iden];
        path=[path stringByAppendingPathComponent:appenLoc];
        NSError *error;
        if (![[NSFileManager defaultManager]fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
            if (error) {
                NSLog(@"error %@",error);
            }
        }
        appenLoc=[[NSString alloc]initWithFormat:@"%d.ima4",_pageNumber ];
        
        NSString *loc=[path stringByAppendingPathComponent:appenLoc];
        NSURL *audioFileURL = [NSURL fileURLWithPath:loc];

        _anAudioRecorder=[[AVAudioRecorder alloc]initWithURL:audioFileURL settings:recordSettings error:&error];
        if (error) {
            NSLog(@"error %@",error);
        }
        [_anAudioRecorder setDelegate:self];
        [_anAudioRecorder recordForDuration:60];
        _recordPaused=NO;
        UIImage *image=[UIImage imageNamed:@"recordbuttonpressed.png"];
        [recordButton setImage:image forState:UIControlStateNormal];
        [_playRecordedButton setEnabled:NO];
    }else{
        if (!_recordPaused) {// if it is not paused
            UIImage *image=[UIImage imageNamed:@"recordbutton.png"];
            [recordButton setImage:image forState:UIControlStateNormal];
            _recordPaused=YES;
            [_anAudioRecorder pause];
            
        }else{
            UIImage *image=[UIImage imageNamed:@"recordbuttonpressed.png"];
            [recordButton setImage:image forState:UIControlStateNormal];
            [_anAudioRecorder record];
            _recordPaused=NO;
            
        }
    }
    [_stopRecordingOrRecordedAudio setEnabled:YES];
   
}
#pragma play or pause the recorded audio
- (IBAction)playOrPauseRecorded:(id)sender {
    NSString *path=[[NSUserDefaults standardUserDefaults] objectForKey:@"recordingDirectory"];
    NSInteger iden=[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"];
    //ima4
    NSString *appenLoc=[[NSString alloc]initWithFormat:@"%d/%d.ima4",iden,_pageNumber ];
    NSString *loc=[path stringByAppendingPathComponent:appenLoc];
    NSLog(@"%@",loc);
    _timerProgress=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressOfPlayer) userInfo:nil repeats:YES];
    [_progressView setHidden:NO];
    if ([[NSFileManager defaultManager]fileExistsAtPath:loc]) {
        [_recordButton setEnabled:NO];
        [_stopRecordingOrRecordedAudio setEnabled:YES];
        if (!_anAudioPlayer) {
            UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
            AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                                     sizeof (audioRouteOverride),&audioRouteOverride);
            _anAudioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:loc] error:nil];
            [_anAudioPlayer setDelegate:self];
            [_anAudioPlayer setVolume:1.0];
            [_anAudioPlayer play];
            _playingPaused=NO;
            UIImage *image=[UIImage imageNamed:@"playbuttonpressed.png"];
            [_playRecordedButton setImage:image forState:UIControlStateNormal];
        }else{
            if (!_playingPaused) {
                [_anAudioPlayer pause];
                UIImage *image=[UIImage imageNamed:@"playbutton.png"];
                [_playRecordedButton setImage:image forState:UIControlStateNormal];
                _playingPaused=YES;
            }else{
                UIImage *image=[UIImage imageNamed:@"playbuttonpressed.png"];
                [_playRecordedButton setImage:image forState:UIControlStateNormal];
                [_anAudioPlayer play];
                _playingPaused=NO;
            }
        }
    }
    
}
@end
