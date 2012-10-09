//
//  LibraryViewController.h
//  AePubReader
//
//  Created by Nikhil Dhavale on 24/09/12.
//
//

#import <UIKit/UIKit.h>
#import "StoreViewController.h"
#import "EPubViewController.h"
#import "EpubReaderViewController.h"
@interface LibraryViewController : UIViewController<StoreControllerDelegate,UIAlertViewDelegate>
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property(nonatomic,retain)NSArray *epubFiles;
@property(assign,nonatomic)NSInteger ymax;
@property(retain,nonatomic)UIAlertView *alertView;
@property(assign,nonatomic)BOOL showDeleteButton;
@property(assign,nonatomic)NSInteger index;
@property(assign,nonatomic)BOOL addControlEvents;
@property(assign,nonatomic)BOOL downloadFailed;
@property(retain,nonatomic)UIMenuController *menu;
@property(retain,nonatomic)UIButton *buttonTapped;
@property(assign,nonatomic)BOOL allowOptions;
- (void)showBookButton:(UIButton *)sender;
@end
