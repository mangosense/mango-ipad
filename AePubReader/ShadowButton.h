//
//  ShadowButton.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 28/09/12.
//
//

#import <UIKit/UIKit.h>

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
@class DownloadViewControlleriPad,LibraryViewController;

@interface ShadowButton : UIButton<MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>
@property(nonatomic,retain)NSString *stringLink;
@property(nonatomic,assign)NSString *imageLocalLocation;
@property(nonatomic,assign)DownloadViewControlleriPad *storeViewController;
@property(nonatomic,assign)LibraryViewController *libraryViewController;
-(void)share:(id)sender;
-(void)DownloadBook:(id)storeBookButton;
-(void)ViewBook:(id)ViewBookButton;
@property(nonatomic,assign)BOOL downloading;
@end
