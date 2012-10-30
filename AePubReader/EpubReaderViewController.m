
#import "EpubReaderViewController.h"


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
- (void)viewDidLoad {
	
    [super viewDidLoad];
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
  //  top.direction=UISwipeGestureRecognizerDirectionDown;
    top.numberOfTapsRequired=2;
    top.numberOfTouchesRequired=1;
    
    [top setDelegate:self];
    [_webview.scrollView addGestureRecognizer:top];
    
    [top release];
    [right release];
    [left release];
 //   [_Done setTintColor:[UIColor grayColor]];
    [_shareButton setTintColor:[UIColor lightGrayColor]];
    [self.navigationController.navigationBar addSubview:_textField];
//    [_hide setTintColor:[UIColor grayColor]];
//    [_hide setEnabled:NO];
    [_textField release];
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
    NSLog(@"superview ht %f",self.view.frame.size.height);
    _webview.scrollView.bounces=NO;
    _webview.scrollView.alwaysBounceHorizontal=NO;
    _webview.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"wood_pattern.png"]];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [_doneButton setTintColor:[UIColor lightGrayColor]];
  //  _webview.autoresizingMask=UIViewAutoresizingFlexibleHeight;
    //_webview.contentMode=UIViewContentModeScaleToFill;
//    NSString *ver= [UIDevice currentDevice].systemVersion;
//    if ([ver floatValue]<5.1) {
//        [_shareButton setEnabled:NO];
//        
//    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]||
        [gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]
        ) {
        return YES;
    }
return NO;
}
-(void)DoubleTap:(UIGestureRecognizer *)top{
    _topToolbar.hidden=!_topToolbar.hidden;
    //_actionBar.hidden=!_actionBar.hidden;
    NSLog(@"Tap gesture");
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
//    if (_alertView) {
//        [_alertView dismissWithClickedButtonIndex:0 animated:YES];
//        _alertView=nil;
//
    NSLog(@"%@",error);
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    NSString *jsCode=@"$('.jp-play').click()";
    [_webview stringByEvaluatingJavaScriptFromString:jsCode];
    
//    jsCode = @"<script type=\"text/javascript\"> document.ontouchmove = function(e){ e.preventDefault(); } </script>";
//    [_webview stringByEvaluatingJavaScriptFromString:jsCode];
//    jsCode=@"var imported = document.createElement('script'); imported.src = 'jquery.js';document.getElementsByTagName('head')[0].appendChild(imported);$('a').each(function(i,link){if($(link).attr('onclick')!=''){alert('hi); $(link).attr('href','javascript:void(0)');}});";
    jsCode=@"var hLink=document.getElementsByTagName('a');for (i=0;i<hLink.length;i++) {if (hLink[i].getAttribute('href')=='#') {hLink[i].setAttribute('href','javascript:void(0)');}}";
     [_webview stringByEvaluatingJavaScriptFromString:jsCode];
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
 
    
}
/*Function Name : setTitlename
 *Return Type   : void
 *Parameters    : NSString- Text to set as title
 *Purpose       : To set the title for the view
 */

- (void)setTitlename:(NSString*)titleText{
	
	// this will appear as the title in the navigation bar
	CGRect frame = CGRectMake(0, 0, 200, 44);
	UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
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
		[filemanager release];
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
			[alert release];
			alert=nil;
		}
		[za UnzipCloseFile];
	}					
	[za release];
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
		
		[filemanager release];
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
		[alert release];
		alert=nil;
		
	}
	[filemanager release];
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
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            [self.navigationController popViewControllerAnimated:YES];
            NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];
            [_webview loadRequest:request];
            NSString *temp=[_strFileName stringByDeletingPathExtension];
            [[NSFileManager defaultManager]removeItemAtPath:temp error:nil];
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
		[_xmlHandler parseXMLFileAt:strOpfFilePath];
	}
	else {
		
		UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error"
													  message:@"OPF File not found"
													 delegate:self
											cancelButtonTitle:@"OK"
											otherButtonTitles:nil];
		[alert show];
		[alert release];
		alert=nil;
	}
	[filemanager release];
	filemanager=nil;
	
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (void)finishedParsing:(EpubContent*)ePubContents{

	_pagesPath=[NSString stringWithFormat:@"%@/%@",self._rootPath,[ePubContents._manifest valueForKey:[ePubContents._spine objectAtIndex:0]]];
	self._ePubContent=ePubContents;
	_pageNumber=0;
	[self loadPage];
}
-(void)leftOrRightGesture:(UISwipeGestureRecognizer *)gesture{
    _topToolbar.hidden=YES;
    
    if (gesture.direction==UISwipeGestureRecognizerDirectionRight) {
		NSLog(@"Right swipe");
        
		if (_pageNumber>0) {
			
			_pageNumber--;
			[self loadPage];
		}else{
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            	[self.navigationController popViewControllerAnimated:YES];
            NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];
            [_webview loadRequest:request];
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
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];
                           [_webview loadRequest:request];
[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	[self.navigationController popViewControllerAnimated:YES];
    NSLog(@"NSString %@",_strFileName);
    NSString *temp=[_strFileName stringByDeletingPathExtension];
    [[NSFileManager defaultManager]removeItemAtPath:temp error:nil];
}

/*Function Name : loadPage
 *Return Type   : void 
 *Parameters    : nil
 *Purpose       : To load actual pages to webview
 */

- (void)loadPage{
	
	_pagesPath=[NSString stringWithFormat:@"%@/%@",self._rootPath,[self._ePubContent._manifest valueForKey:[self._ePubContent._spine objectAtIndex:_pageNumber]]];
	[_webview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:_pagesPath]]];
	//set page number
	//_pageNumberLbl.text=[NSString stringWithFormat:@"%d",_pageNumber+1];
}

#pragma mark Memory handlers

- (void)didReceiveMemoryWarning {
	
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setShareButton:nil];
    [self setDoneButton:nil];
    [self setTopToolbar:nil];
//    [self setTopToolbar:nil];
//   
//    _topToolbar = nil;
//    [self setHide:nil];
//    [self setSearch:nil];
//    [self setDone:nil];
    [self setView:nil];
    [_webview release];
    _webview = nil;

}


- (void)dealloc {
	
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
    [super dealloc];
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
    UIPopoverController *pop=[[UIPopoverController alloc]initWithContentViewController:activity];
    
    [activity release];
        [pop presentPopoverFromBarButtonItem:_shareButton permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
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
    [mail release];

    
}
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [controller dismissModalViewControllerAnimated:YES];
}
@end
