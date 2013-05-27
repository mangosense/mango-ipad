//
//  LandscapeTextBookViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 26/05/13.
//
//

#import <UIKit/UIKit.h>
#import "XMLHandler.h"
#import "EpubContentR.h"
#import "Chapter.h"
#import "SearchResult.h"
#import "SearchResultsViewController.h"
#import "TableOfContentsViewController.h"
@interface LandscapeTextBookViewController : UIViewController<UIPageViewControllerDataSource,UIPageViewControllerDelegate,XMLHandlerDelegate,SearchResultsDelegate,TableViewOfTOCdelegate,UIGestureRecognizerDelegate>
@property(retain,nonatomic)UIPageViewController *controller;
@property(retain,nonatomic)NSString *strFileName;
@property(retain,nonatomic)XMLHandler *xmlhandler;
@property(retain,nonatomic)XMLHandler *xmlhandlerOPF;
@property(retain,nonatomic) NSString *rootPath;
@property(retain,nonatomic)NSString *pagesPath;
@property(retain,nonatomic)EpubContent *ePubContent;
@property(assign,nonatomic) NSInteger pageNumber;
@property(retain,nonatomic)NSMutableArray *array;
@property(assign,nonatomic)UIPopoverController *pop;
@property(assign,nonatomic)BOOL hide;
@property(retain,nonatomic)UIButton *pullPush;
@property(assign,nonatomic)BOOL searching;
@property(strong,nonatomic)NSString *titleOfBook;
@property(assign,nonatomic)NSInteger identity;
- (NSString *)loadPage;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil WithString:(NSString *)link;
@end
