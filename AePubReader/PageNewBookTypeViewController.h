//
//  PageNewBookTypeViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 21/11/13.
//
//

#import <UIKit/UIKit.h>
#import "AePubReaderAppDelegate.h"
#import "DataModelControl.h"
#import "MangoEditorViewController.h"
#import "AudioMappingViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MangoEditorViewController.h"
#import "DismissPopOver.h"
#import "MangoBook.h"
#import "LastPageViewController.h"

@interface PageNewBookTypeViewController : UIViewController<DismissPopOver,AVAudioPlayerDelegate, UIWebViewDelegate, UIScrollViewDelegate, MangoPostApiProtocol>{
    
    NSString *userEmail;
    NSString *userDeviceID;
    NSString *ID;
    NSString *viewName;
    Class popoverClass;
    BOOL refreshCover;
    NSString *storyAsAppFilePath;
    int validUserSubscription;
}
- (IBAction)ShowOptions:(id)sender;
- (IBAction)BackButton:(id)sender;
- (IBAction)closeButton:(id)sender;
- (IBAction)shareButton:(id)sender;
- (IBAction)editButton:(id)sender;
- (IBAction)changeLanguage:(id)sender;
@property(assign,nonatomic) NSInteger option;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil WithOption:(NSInteger )option BookId:(NSString *)bookId;
@property(assign,nonatomic) NSString *bookId;
@property (weak, nonatomic) IBOutlet UIView *viewBase;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UIButton *showOptionButton;
- (IBAction)previousButton:(id)sender;
- (IBAction)nextButton:(id)sender;
- (IBAction)playOrPauseButton:(id)sender;
- (IBAction)openGameCentre:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *playOrPauseButton;
@property(strong,nonatomic) Book *book;
@property(assign,nonatomic) NSInteger pageNumber;
@property(retain,nonatomic)UIView *pageView;
@property(retain,nonatomic) NSString *jsonContent;
@property(assign,nonatomic) NSInteger pageNo;
@property(retain,nonatomic) UIPopoverController *pop;
@property(retain,nonatomic) AudioMappingViewController *audioMappingViewController;
-(void)loadPageWithOption:(NSInteger)option;
@property(retain,nonatomic) UIPopoverController *popOverShare;
@property(retain,nonatomic) UIPopoverController *menuPopoverController;
@property(strong, nonatomic) NSMutableArray *avilableLanguages;

@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UIButton *menuButton;
@property (nonatomic, strong) IBOutlet UIButton *previousPageButton;
@property (nonatomic, strong) IBOutlet UIButton *nextPageButton;
@property (nonatomic, strong) IBOutlet UIButton *languageAvailButton;
@property (nonatomic, strong) IBOutlet UIButton *editButton;
@property(nonatomic, strong) IBOutlet UIButton *shareButton;

@property (nonatomic, strong) NSDate *timeCalculate;
@property (nonatomic, strong) NSString *bookGradeLevel;
@property (nonatomic, strong) NSString *bookImageURL;
@property (nonatomic, strong) NSString *loginUserEmail;
@property (nonatomic, strong) NSString *loginUserName;
@property (nonatomic, retain) WEPopoverController *popoverControlleriPhone;

@property (nonatomic, retain) IBOutlet UIView* settingsProbView;
@property (nonatomic, retain) IBOutlet UIView* settingsProbSupportView;
@property (nonatomic, retain) IBOutlet UITextField *textQuesSolution;

- (IBAction)displyParentalControl:(id)sender;
- (IBAction)allowParentToShareOrNot:(id)sender;
- (IBAction)closeParentalControl:(id)sender;


@end
