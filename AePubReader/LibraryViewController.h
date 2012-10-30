//
//  LibraryViewController.h
//  AePubReader
//
//  Created by Nikhil Dhavale on 24/09/12.
//
//

#import <UIKit/UIKit.h>
#import "StoreViewController.h"


#import "EpubReaderViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
@interface LibraryViewController : UIViewController<StoreControllerDelegate,UIAlertViewDelegate,MFMailComposeViewControllerDelegate>
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
-(void)shareButtonClicked:(id)sender;
- (void)showBookButton:(UIButton *)sender;
-(void)AddShareButton:(id)sender;
@end
