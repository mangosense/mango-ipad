

#import <UIKit/UIKit.h>
#import "ZipArchive.h" 
#import "XMLHandler.h"
#import "EpubContentR.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CircularProgressView.h"
#import "Flurry.h"
#import "PuttyView.h"
//#import "GPUImageVideoCamera.h"
//#import "GPUImageLuminosity.h"
@interface EpubReaderViewController : UIViewController<XMLHandlerDelegate,UISearchBarDelegate,UIWebViewDelegate,UIGestureRecognizerDelegate,MFMailComposeViewControllerDelegate,UIScrollViewDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate> {

  
	
	
    IBOutlet UIWebView *_webview;
	
	
	EpubContent *_ePubContent;
	NSString *_pagesPath;
	NSString *_rootPath;
	NSString *_strFileName;

    
	
   
}
@property(assign,nonatomic)int pageNumber;
@property (weak, nonatomic) IBOutlet UIButton *stopRecordingOrRecordedAudio;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property(strong,nonatomic) XMLHandler *xmlHandler;
@property(strong,nonatomic)XMLHandler *anotherHandlerOPF;
-(void)playingEnded;
//- (IBAction)startRecording:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *circularProgressView;
@property (weak, nonatomic) IBOutlet PuttyView *recordControlView;
@property(retain,nonatomic)AVAudioRecorder *anAudioRecorder;
@property(strong,nonatomic)AVAudioPlayer *anAudioPlayer;
@property(strong,nonatomic)AVAudioPlayer *playerDefault;
@property (retain, nonatomic) IBOutlet UIButton *playPauseControl;
@property(nonatomic,assign)BOOL isPlaying;
@property(assign,nonatomic)float val;
//@property(retain,nonatomic)NSArray *arrayForItems;
//@property (retain, nonatomic) IBOutlet UIView *recordBackgroundview;
- (IBAction)openGame:(id)sender;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollViewForThumnails;
- (IBAction)shareTheBook:(id)sender;
- (IBAction)ribbonButtonClick:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *toggleToolbar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property(retain,nonatomic)NSString *imageLocation;
@property (weak, nonatomic) IBOutlet UIButton *playRecordedButton;
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
@property(assign,nonatomic)BOOL pageLoaded;
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

- (IBAction)playOrPauseRecorded:(id)sender;
@property(strong,nonatomic)NSString *audioPath;
@property(assign,nonatomic)BOOL isOld;
-(void)leftOrRightGesture:(UISwipeGestureRecognizer *)gesture;
- (void)unzipAndSaveFile;
- (NSString *)applicationDocumentsDirectory; 
- (void)loadPage;
- (NSString*)getRootFilePath;
- (IBAction)backButtonOrNextButton:(id)sender;
- (void)setTitlename:(NSString*)titleText;
//- (void)setBackButton;
- (IBAction)onPreviousOrNext:(id)sender;
- (IBAction)stopRecordingOrRecordedAudioPlayed:(id)sender;
@property(strong,nonatomic)CircularProgressView *progressView;
- (IBAction)playOrPauseRecording:(id)sender;
@property(strong,nonatomic)NSTimer *timerProgress;
@property(strong,nonatomic)NSString *titleOfBook;
@property(assign,nonatomic)BOOL recordPaused;
@property(assign,nonatomic)BOOL playingPaused;
@property(assign,nonatomic)BOOL callOnBack;
@property(assign,nonatomic)BOOL startedReading;
@property(assign,nonatomic)BOOL viewAppeared;
@property(assign,nonatomic)NSTimeInterval startTime;
@property(retain,nonatomic)NSString *jsCode;
@property(assign,nonatomic)NSTimeInterval pageCountTime;
//@property (nonatomic, retain) SZActionBar *actionBar;
//@property (nonatomic, retain) id<SZEntity> entity;
@end

