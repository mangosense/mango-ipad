//
//  LibraryViewController.h
//  AePubReader
//
//  Created by Nikhil Dhavale on 24/09/12.
//
//

#import <UIKit/UIKit.h>
#import "StoreViewController.h"
#import <Foundation/Foundation.h>
#import <CoreFoundation/CFURL.h>
#import "EpubReaderViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "RootViewController.h"
#import "PSTCollectionDataSource.h"
@interface LibraryViewController : UIViewController<StoreControllerDelegate,UIAlertViewDelegate,MFMailComposeViewControllerDelegate,XMLHandlerDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property(nonatomic,retain)NSArray *epubFiles;
@property(assign,nonatomic)NSInteger ymax;
@property(retain,nonatomic)UIAlertView *alertView;
@property(assign,nonatomic)BOOL showDeleteButton;
@property(assign,nonatomic)NSInteger index;
@property(assign,nonatomic)BOOL downloadFailed;
@property(assign,nonatomic) BOOL recordButton;
@property(assign,nonatomic)BOOL deleteButton;
@property(retain,nonatomic)UIMenuController *menu;
@property(retain,nonatomic)UIButton *buttonTapped;
@property(assign,nonatomic)BOOL allowOptions;
@property(assign,nonatomic)BOOL recordButtonShow;
@property(retain,nonatomic)NSArray *array;
@property(retain,nonatomic)XMLHandler *xmlhandler;
@property(retain,nonatomic) NSString *rootPath;
@property(assign,nonatomic)UIInterfaceOrientation interfaceOrientation;
@property(strong,nonatomic)UIPopoverController *popOverShare;
@property(strong,nonatomic)UIPopoverController *popRecording;
@property(strong,nonatomic)UICollectionView *collectionView;
@property(assign,nonatomic) NSUInteger emptyCellIndex;
@property(strong,nonatomic)PSTCollectionDataSource *dataSource;
@property(strong,nonatomic) PSUICollectionView *pstcollectionView;
@property(assign,nonatomic)BOOL correctNavigation;
@property(assign,nonatomic) BOOL nav;
-(void)shareButtonClicked:(id)sender;
- (void)showBookButton:(UIButton *)sender;
-(void)AddShareButton:(id)sender;
@end
