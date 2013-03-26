

#import <UIKit/UIKit.h>
#import "ZipArchive.h" 
#import "XMLHandler.h"
#import "EpubContentR.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
//#import "GPUImageVideoCamera.h"
//#import "GPUImageLuminosity.h"
@interface EpubReaderViewController : UIViewController<XMLHandlerDelegate,UISearchBarDelegate,UIWebViewDelegate,UIGestureRecognizerDelegate,MFMailComposeViewControllerDelegate,UIScrollViewDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate> {

  
	
	
    IBOutlet UIWebView *_webview;
	
	
	EpubContent *_ePubContent;
	NSString *_pagesPath;
	NSString *_rootPath;
	NSString *_strFileName;

    
	int _pageNumber;
   
}
@property(strong,nonatomic) XMLHandler *xmlHandler;
@property(strong,nonatomic)XMLHandler *anotherHandlerOPF;
@property (retain, nonatomic) IBOutlet UIButton *recordAudioButton;
-(void)playingEnded;
- (IBAction)startRecording:(id)sender;
- (IBAction)stopRecording:(id)sender;
- (IBAction)playRecorded:(id)sender;
@property(assign,nonatomic)BOOL shouldAutoPlay;
@property(retain,nonatomic)AVAudioRecorder *anAudioRecorder;
@property(retain,nonatomic)AVAudioPlayer *anAudioPlayer;
@property(strong,nonatomic)AVAudioPlayer *playerDefault;
@property (retain, nonatomic) IBOutlet UIButton *playPauseControl;
@property(nonatomic,assign)BOOL isPlaying;
@property(assign,nonatomic)float val;
//@property(retain,nonatomic)NSArray *arrayForItems;
@property (retain, nonatomic) IBOutlet UIView *recordBackgroundview;
- (IBAction)openGame:(id)sender;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollViewForThumnails;
- (IBAction)shareTheBook:(id)sender;
- (IBAction)ribbonButtonClick:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *toggleToolbar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property(retain,nonatomic)NSString *imageLocation;
@property (retain, nonatomic) IBOutlet UIButton *nextButton;
@property(retain,nonatomic)NSString *url;
@property(retain,nonatomic)NSArray *thumbnails;
- (IBAction)hideSearch:(id)sender;
- (IBAction)onBack:(id)sender;
- (IBAction)showPopView:(id)sender;
- (IBAction)playOrPauseAudio:(id)sender;
- (IBAction)recordAudio:(id)sender;
@property (retain, nonatomic) IBOutlet UIView *imageToptoolbar;
@property(retain,nonatomic)UIAlertView *alertView;
@property (retain, nonatomic) IBOutlet UIButton *showRecordButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property(assign,nonatomic)BOOL hide;
@property(assign,nonatomic)BOOL record;
@property(assign,nonatomic)BOOL wasFirstInPortrait;
@property(assign,nonatomic)BOOL DayOrNight;
@property (retain, nonatomic) IBOutlet UIButton *gameButton;
@property(retain,nonatomic)NSString *gameLink;
@property(assign,nonatomic)BOOL page;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *showPop;
@property (retain, nonatomic) IBOutlet UIToolbar *topToolbar;
@property(retain,nonatomic)UIPopoverController *pop;
@property (nonatomic, retain)EpubContent *_ePubContent;
@property (nonatomic, retain)NSString *_rootPath;
@property (nonatomic, retain)NSString *_strFileName;
@property(nonatomic,retain)UITextField *textField;
@property(nonatomic,retain)UINavigationBar *nav;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property(strong,nonatomic)NSTimer *timer;
@property(strong,nonatomic)NSString *audioPath;
-(void)leftOrRightGesture:(UISwipeGestureRecognizer *)gesture;
- (void)unzipAndSaveFile;
- (NSString *)applicationDocumentsDirectory; 
- (void)loadPage;
- (NSString*)getRootFilePath;
- (IBAction)backButtonOrNextButton:(id)sender;
- (void)setTitlename:(NSString*)titleText;
//- (void)setBackButton;
- (IBAction)onPreviousOrNext:(id)sender;
//@property (nonatomic, retain) SZActionBar *actionBar;
//@property (nonatomic, retain) id<SZEntity> entity;
@end

