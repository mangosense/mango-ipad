//
//  WebPageViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 03/01/13.
//
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "CustomWebView.h"
#import "SimpleView.h"
#import "Chapter.h"
#import "SearchResultsViewController.h"
#import "NotesHighlightViewController.h"
#import "TextViewViewController.h"
#import "TableOfContentsHandler.h"
#import "TableOfContentsViewController.h"
@interface WebPageViewController : UIViewController<UIWebViewDelegate,UISearchBarDelegate,UIGestureRecognizerDelegate,TextDelegate,ActionOnDeleteDelegate,TableOfContentDelegate>
@property (retain, nonatomic) IBOutlet UIButton *tocButton;
@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property(retain,nonatomic)NSURL *url;
@property(retain,nonatomic)NSString *val;
@property(retain,nonatomic)NSString *query;
@property (retain, nonatomic) IBOutlet UIView *leftSideView;
-(IBAction)notes:(id)sender;
- (IBAction)onBack:(id)sender;
@property(retain,nonatomic)Chapter *chapter;
@property (retain, nonatomic) IBOutlet UIButton *showNotesOrHighlight;
@property (retain, nonatomic) IBOutlet UIButton *highlightAsNotes;
@property (retain, nonatomic) IBOutlet SimpleView *simpleView;
@property (retain, nonatomic) IBOutlet UIButton *hideOrShow;
@property (retain, nonatomic) IBOutlet UIView *topView;
@property(retain,nonatomic) NSString *HighLight;
- (IBAction)removeAllHighlight:(id)sender;
@property(nonatomic,assign)BOOL hide;
- (IBAction)selection:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(Chapter *)chapter;
@property(retain,nonatomic)    UIPopoverController* searchResultsPopover;
- (IBAction)showList:(id)sender;
@property(retain,nonatomic) SearchResultsViewController *searchViewController;
@property (retain, nonatomic) IBOutlet UIButton *highlight;
@property (retain, nonatomic) IBOutlet UIButton *hideTouchUpInsider;
- (IBAction)highlightfromButton:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *notesButton;
@property(assign,nonatomic)BOOL tap;
@property(assign,nonatomic)CGRect frame;
@property(nonatomic,retain) NSString *selectedStringNote;
@property(nonatomic,retain)NSString *startContainerNote;
@property(nonatomic,retain)NSString *endContainerNote;
@property(nonatomic,retain)NSString *surroundingTextNote;
@property(nonatomic,retain) NSString *currentstartOffsetNote;
@property(nonatomic,assign)NSInteger totalCount;
- (IBAction)tableOfContents:(id)sender;
@property(nonatomic,retain)UIAlertView *alertView;
@property(assign,nonatomic)double left;
@property(assign,nonatomic)double top;
@property(retain,nonatomic) UIPopoverController *pop;
@property(strong,nonatomic)UIPopoverController *showNotes;
@property(strong,nonatomic) UIPopoverController *tableOfContentsPop;
@property(strong,nonatomic)UIPopoverController *listNotesHighlight;
@end
