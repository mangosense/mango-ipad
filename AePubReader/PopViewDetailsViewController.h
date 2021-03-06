//
//  PopViewDetailsViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 15/10/12.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "DownloadViewControlleriPad.h"
#import "Book.h"
#import "LibraryViewController.h"
@interface PopViewDetailsViewController : UIViewController<MFMailComposeViewControllerDelegate>

@property(retain,nonatomic)NSString *imageLocation;
@property(retain,nonatomic)Book *bookTapped;
@property(assign,nonatomic)DownloadViewControlleriPad *store;
@property (retain, nonatomic) IBOutlet UILabel *titleBook;
@property (retain, nonatomic) IBOutlet UIWebView *detailsWebView;

@property(assign,nonatomic) NSInteger bookId;
@property (retain, nonatomic) IBOutlet UILabel *fileSize;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property(assign,nonatomic)float size;
@property(assign,nonatomic)NSInteger iden;
@property(strong,nonatomic)UIPopoverController *popDetails;
@property(strong,nonatomic) LibraryViewController *controller;
- (IBAction)downloadBook:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil imageLocation:(NSString *)locationImage indentity:(NSInteger)iden;
@property (weak, nonatomic) IBOutlet UILabel *freeSpace;
//@property(assign,nonatomic) NSInteger bookId;
@end
