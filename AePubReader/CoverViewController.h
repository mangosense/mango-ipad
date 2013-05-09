//
//  CoverViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 08/05/13.
//
//

#import <UIKit/UIKit.h>
#import "EpubReaderViewController.h"
@interface CoverViewController : UIViewController<MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)readByMyself:(id)sender;
- (IBAction)readToMe:(id)sender;
- (IBAction)goToLibrary:(id)sender;
- (IBAction)recordMyVoice:(id)sender;
- (IBAction)shareTheBook:(id)sender;
@property(strong,nonatomic)NSString *imageLocation;
- (IBAction)description:(id)sender;
- (IBAction)readInMyVoice:(id)sender;
@property(weak,nonatomic)EpubReaderViewController *epubViewController;
@property(strong,nonatomic) UIPopoverController *popViewController;
@end
