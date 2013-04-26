//
//  ViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 03/01/13.
//
//

#import "ViewController.h"
#import "EpubContentR.h"
#import "XMLHandler.h"
#import "ZipArchive.h"
#import <QuartzCore/QuartzCore.h>
#import "AePubReaderAppDelegate.h"
#import "Flurry.h"
@interface ViewController ()

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil WithString:(NSString *)link
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _strFileName=[[NSString alloc]initWithString:link];
      //  [self unzipAndSaveFile];
        NSLog(@" in view controller %@",_strFileName);
      
//        _array=[[NSMutableArray alloc]init];
//        for (NSString *key in _ePubContent._spine) {
//            NSString *temp=  [NSString stringWithFormat:@"%@/%@",_rootPath,[_ePubContent._manifest valueForKey:key]];
//            [_array addObject:temp];
//        }

        
    }
    return self;
}
- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
    
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
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
		
	//	[filemanager release];
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
		//[alert release];
		//alert=nil;
		
	}
//	[filemanager release];
	filemanager=nil;
	return @"";
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    if ([UIDevice currentDevice].orientation==UIDeviceOrientationPortraitUpsideDown) {
        return UIInterfaceOrientationPortraitUpsideDown;
        
    }
    return UIInterfaceOrientationPortrait;
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
		//[filemanager release];
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
		//	[alert release];
			alert=nil;
		}
		[za UnzipCloseFile];
	}
	//[za release];
}
- (NSUInteger)indexOfViewController:(WebPageViewController *)viewController
{
    // Return the index of the given data view controller.
    // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
    
   
    return [_array indexOfObject:viewController.chapter];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  //  [self unzipAndSaveFile:_strFileName];
    _xmlhandler=[[XMLHandler alloc] init];
	_xmlhandler.delegate=self;
	[_xmlhandler parseXMLFileAt:[self getRootFilePath]];
    
  
   [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self.navigationController.navigationBar setHidden:YES];
    [self.tabBarController.tabBar setHidden:YES];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        UIViewController *c=[[UIViewController alloc]init];
        [self presentModalViewController:c animated:NO];
        [self dismissViewControllerAnimated:NO completion:nil];
       // [c release];
    }
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        [Flurry logEvent:[ NSString stringWithFormat:@"ipad Text Book of id %d and title %@ opened ",_identity,_titleOfBook ] ];

    }else{
        [Flurry logEvent:[ NSString stringWithFormat:@"iphone or ipod  touch Text Book of id %d and title %@ opened",_identity,_titleOfBook ] ];
    }
    // do not add views here
   
    //add them in finished parsing
       // [[UIDevice currentDevice]setOrientation:UIDeviceOrientationPortrait];
}

-(void)goToPrev:(id)sender{
  NSInteger index=  [self presentationIndexForPageViewController:self.controller];
 
    NSLog(@"%d",index);
}
-(void)getToNext:(id)sender{
    NSInteger index=  [self presentationIndexForPageViewController:self.controller];
    NSLog(@"%d",index);
}
-(void)finishedParsing:(EpubContent *)ePubContents{
    self.ePubContent=ePubContents;
            _array=[[NSMutableArray alloc]init];
    
    for (int i=0;i<_ePubContent._spine.count;i++) {
        NSString *key=[_ePubContent._spine objectAtIndex:i];
                NSString *temp=  [NSString stringWithFormat:@"%@/%@",_rootPath,[_ePubContent._manifest valueForKey:key]];
        Chapter *chap=[[Chapter alloc]initWithPath:temp chapterIndex:i andWith:i];
                [_array addObject:chap];
   //     [chap release];
            }
    self.controller=[[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.controller.delegate=self;
    self.controller.dataSource=self;
    [self addChildViewController:self.controller];
//    CGRect pageViewRect = self.view.bounds;
//    pageViewRect.origin.x+=20;
//    pageViewRect.size.width-=20;
//    self.controller.view.frame = pageViewRect;
    CGRect frame=self.view.frame;
   // frame.origin.x+=20;
    self.controller.view.frame=frame;
    [self.view addSubview:self.controller.view];
    
 
    [self.controller didMoveToParentViewController:self];
 //   [self.controller release];
//    for (UIGestureRecognizer *gest in self.controller.gestureRecognizers) {
//        gest.delegate=self;
//      
//    }
    WebPageViewController *page;
        Chapter *chap=[_array objectAtIndex:0];
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==UIUserInterfaceIdiomPhone) {
     
       
            page=[[WebPageViewController alloc]initWithNibName:@"WebPageViewIphone" bundle:nil url:chap];
        

        
        
        
    }else{
        page=[[WebPageViewController alloc]initWithNibName:@"WebPageViewController" bundle:nil url:chap];
    }
     page.totalCount=_ePubContent._spine.count;
    NSArray *arrayControllers=@[page];
    [self.controller setViewControllers:arrayControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
 //   [page autorelease];
   

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self.navigationController.navigationBar setHidden:YES];
    [self.tabBarController.tabBar setHidden:YES];

}
//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
//    CGPoint point = [touch locationInView:self.view];
//
//    
//    NSInteger index=[self indexOfViewController:(WebPageViewController *)[self.controller.viewControllers lastObject]];
//    if (index==0) {
//        
//     
//    }
//    
//    else if(index ==_array.count-1)
//    {
//        
//  
//    }
//
//    
//        
//        if(point.x > 50) return YES;
//        
// 
//    
//    return NO;
//
//}
//-(void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:YES];
//
//    
//}
-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{

   
}
-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers{
    
   //  NSLog(@"next%d",pendingViewControllers.count);

}
-(void)setSearch:(BOOL)searching{
    _searching=searching;
}
-(BOOL)getSearch{
    return _searching;
}
-(void)LibraryPressed:(id)sender{

    [self.navigationController popViewControllerAnimated:YES];
}
- (void)unzipAndSaveFile:(NSString *)epubLoc{
//	[epubLoc retain];
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
			//[alert release];
			alert=nil;
		}
		[za UnzipCloseFile];
	}
   // [epubLoc release];
	//[za release];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
   
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.navigationController.navigationBar setHidden:NO];
    [self.tabBarController.tabBar setHidden:NO];
    [Flurry logEvent:[ NSString stringWithFormat:@"Text Book of id %d and title %@ closed at pagenumber %d",_identity,_titleOfBook,_pageNumber ] ];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)loadSpine:(int)chapterIndex atPageIndex:(int)pageIndex highlightSearchResult:(SearchResult *)hit{
    Chapter *chapter=[_array objectAtIndex:chapterIndex];
    WebPageViewController *page;
    if (_pop) {
        [_pop dismissPopoverAnimated:YES];
       
    }
       if ([[UIDevice currentDevice] userInterfaceIdiom] ==UIUserInterfaceIdiomPhone) {
    
        page=[[WebPageViewController alloc]initWithNibName:@"WebPageViewIphone" bundle:nil url:chapter];
      
        
    }else{
        page=[[WebPageViewController alloc]initWithNibName:@"WebPageViewController" bundle:nil url: chapter];
    }
    if (hit) {
           page.query=hit.originatingQuery; 
    }
 page.totalCount=_ePubContent._spine.count;
    NSArray *array=[NSArray arrayWithObject:page];
  //  [page release];
    WebPageViewController *current=[_controller.viewControllers lastObject];
    [current.searchResultsPopover dismissPopoverAnimated:YES];
    if (current.chapter.chapterIndex>chapterIndex) {
          [_controller setViewControllers:array direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    }else if(current.chapter.chapterIndex<chapterIndex){
        [_controller setViewControllers:array direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }else{
         [_controller setViewControllers:array direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    }

    
}
#pragma mark - UIPageViewController Data Source
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    
    NSUInteger index = [self indexOfViewController:(WebPageViewController*)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    
  
    WebPageViewController *page;
    Chapter *chap=[_array objectAtIndex:index];


    if ([[UIDevice currentDevice] userInterfaceIdiom] ==UIUserInterfaceIdiomPhone) {

            page=[[WebPageViewController alloc]initWithNibName:@"WebPageViewIphone" bundle:nil url:chap];
       
       
    }else{
        page=[[WebPageViewController alloc]initWithNibName:@"WebPageViewController" bundle:nil url: chap];
    }
    page.totalCount=_ePubContent._spine.count;
   // [page autorelease];
    return page;

}
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    // Return the data view controller for the given index.
    NSInteger index= [self indexOfViewController:(WebPageViewController*)viewController];
    
     index++;
   
    if (self.array.count==index) {
        return nil;
    }
   
    WebPageViewController *page;
    Chapter *chap=[_array objectAtIndex:index];

    if ([[UIDevice currentDevice] userInterfaceIdiom] ==UIUserInterfaceIdiomPhone) {

            page=[[WebPageViewController alloc]initWithNibName:@"WebPageViewIphone" bundle:nil url:chap];
        

      
    }else{
        page=[[WebPageViewController alloc]initWithNibName:@"WebPageViewController" bundle:nil url: chap];
    }
 page.totalCount=_ePubContent._spine.count;
    //[page autorelease];
    return page;
}
#pragma mark - UIPageViewController delegate methods
- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    //   if (UIInterfaceOrientationIsPortrait(orientation) || ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)) {
    // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
    /*
     [self._ePubContent._spine count]-1
     */
   // if (UIInterfaceOrientationIsPortrait(orientation)) {
        UIViewController *currentViewController = self.controller.viewControllers[0];
        NSArray *viewControllers = @[currentViewController];
        [self.controller setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
        
        self.controller.doubleSided = NO;
        return UIPageViewControllerSpineLocationMin;
//    }
//
//        NSArray *viewControllers = nil;
//    UIViewController *currentViewController = self.controller.viewControllers[0];
//        NSUInteger indexOfCurrentViewController = [self indexOfViewController:(WebPageViewController *)currentViewController];
//       if (indexOfCurrentViewController == 0 || indexOfCurrentViewController % 2 == 0) {
//            UIViewController *nextViewController = [self pageViewController:self.controller viewControllerAfterViewController:currentViewController];
//            viewControllers = @[currentViewController, nextViewController];
//        } else {
//            UIViewController *previousViewController = [self pageViewController:self.controller viewControllerAfterViewController:currentViewController];
//        viewControllers = @[previousViewController, currentViewController];
//        }
//        [self.controller setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
//     self.controller.doubleSided = YES;
//    //
//        return UIPageViewControllerSpineLocationMid;
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
            NSString  *actual=[self.ePubContent._manifest valueForKey:[self.ePubContent._spine objectAtIndex:index]];
            actual =[actual stringByDeletingPathExtension];
            NSString *val=[actual stringByAppendingString:@".png"];
            NSLog(@"spine at %d %@ %@",index,val,[self.ePubContent._spine objectAtIndex:index]);
            [arrayMutable addObject:val];
            //[val release];
        }
        array=[NSArray arrayWithArray:arrayMutable];
     //   [arrayMutable release];
        //  array=  [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        CGSize size=  _scrollViewForThumnails.contentSize;
        CGFloat width=array.count *200;
     
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
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
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
            NSLog(@"location %@",imageLoc);
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
         //   [image release];
            x+=increment;
            
        }
        
        
    }
    
    
}
- (NSString *)loadPage{
	
	_pagesPath=[NSString stringWithFormat:@"%@/%@",self.rootPath,[self.ePubContent._manifest valueForKey:[self.ePubContent._spine objectAtIndex:_pageNumber]]];
	
    [self addThumbnails];
    return _pagesPath;
    
	//set page number
	//_pageNumberLbl.text=[NSString stringWithFormat:@"%d",_pageNumber+1];
}
    //    }

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
        _xmlhandlerOPF=[[XMLHandler alloc] init];
        _xmlhandlerOPF.delegate=self;
		[_xmlhandlerOPF parseXMLFileAt:strOpfFilePath];
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
-(void)loadPage:(NSString *)lastPath{
    NSString *path=[self.rootPath stringByAppendingFormat:@"/%@",lastPath];
    
    for (Chapter *chap in _array) {
        NSLog(@"spinePath %@",chap.spinePath);
        if ([chap.spinePath isEqualToString:path]) {
            [self loadSpine:chap.chapterIndex atPageIndex:chap.chapterIndex highlightSearchResult:nil];
            break;
        }
    }
}
/*-(void)dealloc{
    _ePubContent=nil;
    _xmlhandler=nil;
    _pagesPath=nil;
    _pullPush=nil;
    [_strFileName release];
    [super dealloc];
}*/
@end
