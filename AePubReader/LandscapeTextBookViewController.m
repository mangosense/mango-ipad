//
//  LandscapeTextBookViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 26/05/13.
//
//

#import "LandscapeTextBookViewController.h"
#import "Flurry.h"
#import "LandscapePageViewController.h"
@interface LandscapeTextBookViewController ()

@end

@implementation LandscapeTextBookViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil WithString:(NSString *)link{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _strFileName=[[NSString alloc]initWithString:link];

    }
    return self;
}
- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskLandscape;
    
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    
    return  UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
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
    if ([UIDevice currentDevice].orientation==UIDeviceOrientationLandscapeLeft) {
        return UIInterfaceOrientationLandscapeLeft;
        
    }
    return UIInterfaceOrientationLandscapeRight;
}
- (NSUInteger)indexOfViewController:(LandscapePageViewController *)viewController
{
    // Return the index of the given data view controller.
    // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
    
    
    return [_array indexOfObject:viewController.chapter];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
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
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    [dictionary setValue:[NSNumber numberWithInteger:_identity] forKey:@"identity"];
    [dictionary setValue:_titleOfBook forKey:@"book title"];
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        [Flurry logEvent:@"ipad Text Book Landscape of opened " withParameters:dictionary ];
        
    }else{
        [Flurry logEvent:@"iphone or ipod  touch  Landscape Text Book opened" withParameters:dictionary ];
    }

    // Do any additional setup after loading the view from its nib.
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
    [UIDevice currentDevice];
    if ([UIDevice currentDevice].systemVersion.integerValue<6) {
          self.controller=[[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    }else{
          self.controller=[[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    }
  
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
    
    /// Here code Changes
    LandscapePageViewController *page;
    Chapter *chap=[_array objectAtIndex:0];
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==UIUserInterfaceIdiomPhone) {
        
        
        page=[[LandscapePageViewController alloc]initWithNibName:@"LandscapePageiPhone" bundle:nil url:chap];
        
        
        
        
        
    }else{
        page=[[LandscapePageViewController alloc]initWithNibName:@"LandscapePageViewController" bundle:nil url:chap];
    }
    page.totalCount=_ePubContent._spine.count;
    NSArray *arrayControllers=@[page];
    [self.controller setViewControllers:arrayControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    //   [page autorelease];
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self.navigationController.navigationBar setHidden:YES];
    [self.tabBarController.tabBar setHidden:YES];
    
}
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
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.navigationController.navigationBar setHidden:NO];
    [self.tabBarController.tabBar setHidden:NO];
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    [dictionary setValue:[NSNumber numberWithInteger:_identity] forKey:@"identity"];
    [dictionary setValue:_titleOfBook forKey:@"title"];
    [dictionary setValue:[NSNumber numberWithInteger:_pageNumber] forKey:@"pageNumber"];
    [Flurry logEvent:@"Text Book of closed" withParameters:dictionary ];
    
}
-(void)loadSpine:(int)chapterIndex atPageIndex:(int)pageIndex highlightSearchResult:(SearchResult *)hit{
    Chapter *chapter=[_array objectAtIndex:chapterIndex];
    LandscapePageViewController *page;

    if (_pop) {
        [_pop dismissPopoverAnimated:YES];
        
    }
    /// code changes here
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==UIUserInterfaceIdiomPhone) {
        
        page=[[LandscapePageViewController alloc]initWithNibName:@"LandscapePageiPhone" bundle:nil url:chapter];
        
        
    }else{
        page=[[LandscapePageViewController alloc]initWithNibName:@"LandscapePageViewController" bundle:nil url:chapter];
    }
    if (hit) {
        page.query=hit.originatingQuery;
    }
    page.totalCount=_ePubContent._spine.count;
    NSArray *array=[NSArray arrayWithObject:page];
    //  [page release];
    LandscapePageViewController *current=[_controller.viewControllers lastObject];
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
    
    NSUInteger index = [self indexOfViewController:(LandscapePageViewController*)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    
    
    LandscapePageViewController *page;
    Chapter *chap=[_array objectAtIndex:index];
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==UIUserInterfaceIdiomPhone) {
        
        page=[[LandscapePageViewController alloc]initWithNibName:@"LandscapePageiPhone" bundle:nil url:chap];
        
        
    }else{
        page=[[LandscapePageViewController alloc]initWithNibName:@"LandscapePageViewController" bundle:nil url:chap];
    }
    page.totalCount=_ePubContent._spine.count;
    page.titleOfBook=_titleOfBook;
    page.bookId=_identity;
    // [page autorelease];
    return page;
    
}
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    // Return the data view controller for the given index.
    NSInteger index= [self indexOfViewController:(LandscapePageViewController*)viewController];
    
    index++;
    
    if (self.array.count==index) {
        return nil;
    }
    
    LandscapePageViewController *page;
    Chapter *chap=[_array objectAtIndex:index];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==UIUserInterfaceIdiomPhone) {
        
        page=[[LandscapePageViewController alloc]initWithNibName:@"LandscapePageiPhone" bundle:nil url:chap];
        
        
    }else{
        page=[[LandscapePageViewController alloc]initWithNibName:@"LandscapePageViewController" bundle:nil url:chap];
    }

    page.titleOfBook=_titleOfBook;
    page.bookId=_identity;
    page.totalCount=_ePubContent._spine.count;
    //[page autorelease];
    return page;
}
#pragma mark - UIPageViewController delegate methods
- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{

    UIViewController *currentViewController = self.controller.viewControllers[0];
    NSArray *viewControllers = @[currentViewController];
    [self.controller setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
    
    self.controller.doubleSided = NO;
    return UIPageViewControllerSpineLocationMin;

}
- (NSString *)loadPage{
	
	_pagesPath=[NSString stringWithFormat:@"%@/%@",self.rootPath,[self.ePubContent._manifest valueForKey:[self.ePubContent._spine objectAtIndex:_pageNumber]]];
	
    //[self addThumbnails];
    return _pagesPath;
    
	//set page number
	//_pageNumberLbl.text=[NSString stringWithFormat:@"%d",_pageNumber+1];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
