

#import <UIKit/UIKit.h>
#import "ZipArchive.h" 
#import "XMLHandler.h"
#import "EpubContentR.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
@interface EpubReaderViewController : UIViewController<XMLHandlerDelegate,UISearchBarDelegate,UIWebViewDelegate,UIGestureRecognizerDelegate,MFMailComposeViewControllerDelegate> {

	
	
    IBOutlet UIWebView *_webview;
	
	XMLHandler *_xmlHandler;
	EpubContent *_ePubContent;
	NSString *_pagesPath;
	NSString *_rootPath;
	NSString *_strFileName;

    
	int _pageNumber;
   
}
- (IBAction)shareTheBook:(id)sender;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property(retain,nonatomic)NSString *imageLocation;
@property(retain,nonatomic)NSString *url;
- (IBAction)hideSearch:(id)sender;
- (IBAction)onBack:(id)sender;
@property(retain,nonatomic)UIAlertView *alertView;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (retain, nonatomic) IBOutlet UIToolbar *topToolbar;

@property (nonatomic, retain)EpubContent *_ePubContent;
@property (nonatomic, retain)NSString *_rootPath;
@property (nonatomic, retain)NSString *_strFileName;
@property(nonatomic,retain)UITextField *textField;
@property(nonatomic,retain)UINavigationBar *nav;
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

