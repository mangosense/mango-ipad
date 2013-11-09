//
//  EditorViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 08/08/13.
//
//

#import "EditorViewController.h"
#import "AudioRecordingViewController.h"
#import "AwesomeMenu.h"
#import "AwesomeMenuItem.h"
#import "AccordionView.h"
#import "DrawingToolsView.h"
#import "PublishViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Google_TTS_BySham.h"
#import "StoryJsonProcessor.h"
#import "Constants.h"

#define MAIN_TEXTVIEW_TAG 100

#define RED_BUTTON_TAG 1
#define YELLOW_BUTTON_TAG 2
#define GREEN_BUTTON_TAG 3
#define BLUE_BUTTON_TAG 4
#define PEA_GREEN_BUTTON_TAG 5
#define PURPLE_BUTTON_TAG 6
#define ORANGE_BUTTON_TAG 7
#define ERASER_BUTTON_TAG 8

#define BRUSH_MENU_TAG 1
#define COLOR_MENU_TAG 2

#define ENGLISH_TAG 9
#define ANGRYBIRDS_ENGLISH_TAG 17
#define TAMIL_TAG 10
#define MALAY_TAG 12
#define CHINESE_TAG 11
#define GERMAN_TAG 13
#define SPANISH_TAG 14

@interface EditorViewController ()

@property (nonatomic, strong) NSMutableArray *arrayOfPages;
@property (nonatomic, strong) UIButton *showScrollViewButton;
@property (nonatomic, strong) UIButton *showPaintPalletButton;
@property (nonatomic, strong) AwesomeMenu *paintMenu;
@property (nonatomic, strong) AwesomeMenu *brushMenu;
@property (nonatomic, strong) UIButton *eraserButton;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *recordAudioButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *assetsButton;
@property (nonatomic, strong) UIButton *brushButton;
@property (nonatomic, strong) AudioRecordingViewController *audioRecViewController;
@property (nonatomic, strong) UIPopoverController *photoPopoverController;
@property (nonatomic, strong) UIPopoverController *assetPopoverController;
@property (nonatomic, strong) NSString *angryBirdsTamilJsonString;
@property (nonatomic, strong) NSString *angryBirdsEnglishJsonString;
@property (nonatomic, strong) UIButton *addNewPageButton;
@property (nonatomic, strong) UIView *stickerView;
@property (nonatomic, assign) CGFloat rotateAngle;
@property (nonatomic, assign) CGPoint translatePoint;
@property (nonatomic, strong) AccordionView *accordion;
@property (nonatomic, strong) DrawingToolsView *toolsView;
@property (nonatomic, strong) UIView *drawerView;
@property (nonatomic, strong) UIView *staticToolsView;
@property (nonatomic, strong) UIButton *nextPageButton;
@property (nonatomic, strong) UIButton *previousPageButton;
@property (nonatomic, assign) int currentPage;
@property (nonatomic, strong) NSArray *arrayOfImageNames;
@property (nonatomic, strong) Google_TTS_BySham *google_tts_bysham;

@property (nonatomic, strong) NSString *frankfurtEnglishJson;
@property (nonatomic, strong) NSString *frankfurtSpanishJson;
@property (nonatomic, strong) NSString *frankfurtGermanJson;

@property (nonatomic, strong) UIButton *mangoButton;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UIButton *imageButton;
@property (nonatomic, strong) UIButton *textButton;
@property (nonatomic, strong) UIButton *audioButton;
@property (nonatomic, strong) UIButton *gamesButton;
@property (nonatomic, strong) UIButton *collaborationButton;
@property (nonatomic, strong) UIButton *playPreviewButton;
@property (nonatomic, strong) UIButton *pagesButton;

@property (nonatomic, strong) UIImageView *pagesListBackgroundView;
@property (nonatomic, strong) iCarousel *pagesListCarousel;

- (void)getBookJson;

@end

@implementation EditorViewController

@synthesize backgroundImageView;
@synthesize mainTextView;
@synthesize arrayOfPages;
@synthesize pageScrollView;
@synthesize paintPalletView;
@synthesize backgroundImagesArray;
@synthesize showScrollViewButton;
@synthesize showPaintPalletButton;
@synthesize eraserButton;
@synthesize cameraButton;
@synthesize recordAudioButton;
@synthesize audioPlayer;
@synthesize audioRecorder;
@synthesize playButton;
@synthesize audioRecViewController;
@synthesize photoPopoverController;
@synthesize assetPopoverController;
@synthesize angryBirdsTamilJsonString;
@synthesize angryBirdsEnglishJsonString;
@synthesize tagForLanguage;
@synthesize englishLanguageButton;
@synthesize tamilLanguageButton;
@synthesize paintMenu;
@synthesize brushMenu;
@synthesize assetsButton;
@synthesize brushButton;
@synthesize addNewPageButton;
@synthesize stickerView;
@synthesize rotateAngle;
@synthesize translatePoint;
@synthesize accordion;
@synthesize toolsView;
@synthesize drawerView;
@synthesize staticToolsView;
@synthesize nextPageButton;
@synthesize previousPageButton;
@synthesize currentPage;
@synthesize arrayOfImageNames;

@synthesize frankfurtEnglishJson;
@synthesize frankfurtGermanJson;
@synthesize frankfurtSpanishJson;

@synthesize mangoButton;
@synthesize menuButton;
@synthesize imageButton;
@synthesize textButton;
@synthesize audioButton;
@synthesize gamesButton;
@synthesize collaborationButton;
@synthesize playPreviewButton;
@synthesize pagesButton;

@synthesize pagesListBackgroundView;
@synthesize pagesListCarousel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.title=@"Stories";
        self.tabBarItem.image=[UIImage imageNamed:@"library.png"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.    
    
    [self.view setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
    
    self.navigationController.navigationBar.translucent = NO;
//    self.tabBarController.tabBar.translucent = NO;

    /*[[tamilLanguageButton layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[tamilLanguageButton layer] setShadowOffset:CGSizeMake(5, 5)];
    [[tamilLanguageButton layer] setShadowOpacity:0.7f];
    [[tamilLanguageButton layer] setShadowRadius:5];
    [[tamilLanguageButton layer] setShouldRasterize:YES];
    
    [[englishLanguageButton layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[englishLanguageButton layer] setShadowOffset:CGSizeMake(5, 5)];
    [[englishLanguageButton layer] setShadowOpacity:0.7f];
    [[englishLanguageButton layer] setShadowRadius:5];
    [[englishLanguageButton layer] setShouldRasterize:YES];*/
    
    UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo1.png"]];
    self.navigationItem.titleView=imageView;
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];

    [self chooseLanguage:tagForLanguage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Choose Language

- (IBAction)languageButtonTapped:(id)sender {
    UIButton *languageButton = (UIButton *)sender;
    [self chooseLanguage:languageButton.tag];
}

- (void)chooseLanguage:(NSInteger)tagForChosenLanguage {
//    tagForLanguage = tagForChosenLanguage;
    [self createInitialUI];
    [self getBookJson];
}

#pragma mark - Show/Hide Panels

- (void)showOrHidePaintPalletView {
    if (showPaintPalletButton.tag == 1) {
        [self hidePaintPalletView];
    } else {
        [self showPaintPalletView];
    }
}

- (void)showOrHideScrollView {
    if (showScrollViewButton.tag == 1) {
        [self hidePageScrollView];
    } else {
        [self showPageScrollView];
    }
}

#pragma mark - Gesture Handlers

- (void)showPaintPalletView {
    [self.view bringSubviewToFront:paintPalletView];
    [UIView
     animateWithDuration:0.2
     animations:^{
         paintPalletView.frame = CGRectMake(self.view.frame.size.width - 90, 0, 90, self.view.frame.size.height);
         [showPaintPalletButton setFrame:CGRectMake(paintPalletView.frame.origin.x - 44, 0, 44, 44)];
     }];
    showPaintPalletButton.tag = 1;
}

- (void)hidePaintPalletView {
    [self.view bringSubviewToFront:paintPalletView];
    [UIView
     animateWithDuration:0.2
     animations:^{
         paintPalletView.frame = CGRectMake(self.view.frame.size.width, 0, 90, self.view.frame.size.height);
         [showPaintPalletButton setFrame:CGRectMake(paintPalletView.frame.origin.x - 44, 0, 44, 44)];
     }];
    showPaintPalletButton.tag = 0;
}

- (void)showPageScrollView {
    [UIView
     animateWithDuration:0.2
     animations:^{
         drawerView.frame = CGRectMake(0, 0, 200, self.view.frame.size.height);
         [showScrollViewButton setFrame:CGRectMake(drawerView.frame.origin.x + drawerView.frame.size.width, 0, 44, 44)];
         [previousPageButton setFrame:CGRectMake(showScrollViewButton.frame.origin.x, previousPageButton.frame.origin.y, 44, 44)];
         [backgroundImageView setFrame:CGRectMake(drawerView.frame.origin.x + drawerView.frame.size.width + 20, self.view.frame.size.height/2 - 265, self.view.frame.size.width - 200 - 40, 531)];
         for (UIView *subView in [backgroundImageView subviews]) {
             if ([subView isKindOfClass:[UIWebView class]]) {
                 [subView setFrame:CGRectMake(0, 0, self.view.frame.size.width - 200 - 40, 531)];
                 break;
             }
         }
         [[backgroundImageView layer] setMasksToBounds:NO];
         [[backgroundImageView layer] setShadowColor:[[UIColor blackColor] CGColor]];
         [[backgroundImageView layer] setShadowOffset:CGSizeMake(3, 3)];
         [[backgroundImageView layer] setShadowOpacity:0.3f];
         [[backgroundImageView layer] setShadowRadius:5];
         [[backgroundImageView layer] setShouldRasterize:YES];
     }];
    [backgroundImageView refreshTempImage];
    showScrollViewButton.tag = 1;
}

- (void)hidePageScrollView {
    [UIView
     animateWithDuration:0.2
     animations:^{
         drawerView.frame = CGRectMake(-200, 0, 200, self.view.frame.size.height);
         [showScrollViewButton setFrame:CGRectMake(drawerView.frame.origin.x + drawerView.frame.size.width, 0, 44, 44)];
         [previousPageButton setFrame:CGRectMake(showScrollViewButton.frame.origin.x, previousPageButton.frame.origin.y, 44, 44)];
         [backgroundImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
         for (UIView *subView in [backgroundImageView subviews]) {
             if ([subView isKindOfClass:[UIWebView class]]) {
                 [subView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
                 break;
             }
         }
     }];
    [backgroundImageView refreshTempImage];
    showScrollViewButton.tag = 0;
}

- (void)createTextBoxAtPoint:(CGPoint)textCenterPoint {
    
}

#pragma mark - PageBackgroundImageView Delegate Method

- (void)replaceImageAtIndex:(NSInteger)index withImage:(UIImage *)image {
    [backgroundImagesArray replaceObjectAtIndex:index withObject:image];
}

#pragma mark - Drawing Delegate

- (void)widthOfBrush:(CGFloat)brushWidth {
    backgroundImageView.selectedBrush = brushWidth;
}

- (void)widthOfEraser:(CGFloat)eraserWidth {
    backgroundImageView.selectedEraserWidth = eraserWidth;
}

- (void)selectedColor:(int)color {
    backgroundImageView.selectedColor = color;
}

#pragma mark - Paint Button Methods

- (IBAction)paintButtonPressed:(id)sender {
    UIButton *paintButton = (UIButton *)sender;
    backgroundImageView.selectedColor = paintButton.tag;
}

- (IBAction)paintBrushButtonPressed:(id)sender {
    UIButton *brushSizeButton = (UIButton *)sender;
    backgroundImageView.selectedBrush = brushSizeButton.tag;
}

#pragma mark - Button Animation

- (void)stopAnimatingRecordButton {
    [recordAudioButton setImage:[UIImage imageNamed:@"record-control.png"] forState:UIControlStateNormal];
    [recordAudioButton setFrame:CGRectMake(28, 30, 44, 44)];
    [[recordAudioButton layer] removeAllAnimations];
}

- (void)animateRecordButton {
    [UIView animateWithDuration:0.7 delay:0.0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse animations:^{
        recordAudioButton.frame = CGRectMake(recordAudioButton.frame.origin.x - 3, recordAudioButton.frame.origin.y - 3, recordAudioButton.frame.size.width + 6, recordAudioButton.frame.size.height + 6);
    } completion:NULL];
}

#pragma mark - Audio Recording

- (void)startRecording
{
    NSLog(@"startRecording");
    
    // Init audio with record capability
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] initWithCapacity:10];
    if(recordEncoding == ENC_PCM)
    {
        [recordSettings setObject:[NSNumber numberWithInt: kAudioFormatLinearPCM] forKey: AVFormatIDKey];
        [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    }
    else
    {
        NSNumber *formatObject;
        
        switch (recordEncoding) {
            case (ENC_AAC):
                formatObject = [NSNumber numberWithInt: kAudioFormatMPEG4AAC];
                break;
            case (ENC_ALAC):
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleLossless];
                break;
            case (ENC_IMA4):
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
                break;
            case (ENC_ILBC):
                formatObject = [NSNumber numberWithInt: kAudioFormatiLBC];
                break;
            case (ENC_ULAW):
                formatObject = [NSNumber numberWithInt: kAudioFormatULaw];
                break;
            default:
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
        }
        
        [recordSettings setObject:formatObject forKey: AVFormatIDKey];
        [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        [recordSettings setObject:[NSNumber numberWithInt:12800] forKey:AVEncoderBitRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSettings setObject:[NSNumber numberWithInt: AVAudioQualityHigh] forKey: AVEncoderAudioQualityKey];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *recDir = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sampleRecord_%d.caf", recDir, backgroundImageView.indexOfThisImage]];
    
    NSError *error = nil;
    audioRecorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&error];
    
    if ([audioRecorder prepareToRecord] == YES){
        [audioRecorder record];
    }else {
        int errorCode = CFSwapInt32HostToBig ([error code]);
        NSLog(@"Error: %@ [%4.4s])" , [error localizedDescription], (char*)&errorCode);
        
    }
    NSLog(@"recording");
}

- (void)stopRecording
{
    NSLog(@"stopRecording");
    [audioRecorder stop];
    NSLog(@"stopped");
}

- (void)playRecording
{
    NSLog(@"playRecording");
    // Init audio with playback capability
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *recDir = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sampleRecord_%d.caf", recDir, backgroundImageView.indexOfThisImage]];
    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    audioPlayer.numberOfLoops = 0;
    [audioPlayer play];
    NSLog(@"playing");
    
    [playButton setImage:[UIImage imageNamed:@"stop-recording-control.png"] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(stopPlaying) forControlEvents:UIControlEventTouchUpInside];
    [recordAudioButton setEnabled:NO];
}

- (void)stopPlaying
{
    NSLog(@"stopPlaying");
    [audioPlayer stop];
    NSLog(@"stopped");
    [playButton setImage:[UIImage imageNamed:@"play-control.png"] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playRecording) forControlEvents:UIControlEventTouchUpInside];
    [recordAudioButton setEnabled:YES];
}
/////------------------------/////


- (void)stopRecording:(id)sender {

    UIButton *stopButton = (UIButton *)sender;
    [stopButton removeFromSuperview];
    [self stopAnimatingRecordButton];
    [self stopRecording];
    
    [playButton setEnabled:YES];
    [playButton addTarget:self action:@selector(playRecording) forControlEvents:UIControlEventTouchUpInside];
}

- (void)recordAudio {
    [self stopPlaying];
    
    [recordAudioButton setImage:[UIImage imageNamed:@"start-recording-control.png"] forState:UIControlStateNormal];
    //[self animateRecordButton];
    
    UIButton *stopRecordingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [stopRecordingButton setFrame:CGRectMake(recordAudioButton.frame.origin.x, recordAudioButton.frame.origin.y, 44, 44)];
    [stopRecordingButton setImage:[UIImage imageNamed:@"stop-recording-control.png"] forState:UIControlStateNormal];
    [stopRecordingButton setUserInteractionEnabled:YES];
    [[stopRecordingButton layer] setMasksToBounds:NO];
    [[stopRecordingButton layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[stopRecordingButton layer] setShadowOffset:CGSizeMake(-3, -3)];
    [[stopRecordingButton layer] setShadowOpacity:0.3f];
    [[stopRecordingButton layer] setShadowRadius:5];
    [[stopRecordingButton layer] setShouldRasterize:YES];
    [stopRecordingButton addTarget:self action:@selector(stopRecording:) forControlEvents:UIControlEventTouchUpInside];
    [staticToolsView addSubview:stopRecordingButton];
    [staticToolsView bringSubviewToFront:stopRecordingButton];
    
    [playButton setEnabled:NO];
    
    [self startRecording];

}


#pragma mark - New Page

- (void)addNewPageWithImageUrl:(NSURL *)imageUrl {
    NSMutableDictionary *newPageDictionary = [[NSMutableDictionary alloc] init];
    [newPageDictionary setObject:[NSNumber numberWithInt:[arrayOfPages count]] forKey:@"id"];
    [newPageDictionary setObject:[NSNumber numberWithInt:[arrayOfPages count]] forKey:@"name"];
    
    NSMutableArray *layersArray = [[NSMutableArray alloc] init];
    NSDictionary *imageDictionary = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"capturedImage", imageUrl, nil] forKeys:[NSArray arrayWithObjects:@"type", @"url", nil]];
    [layersArray addObject:imageDictionary];
    [newPageDictionary setObject:layersArray forKey:@"layers"];
    
    [arrayOfPages addObject:newPageDictionary];
    NSLog(@"arrayOfPages = %@", arrayOfPages);
    
    if (!backgroundImagesArray) {
        backgroundImagesArray = [[NSMutableArray alloc] init];
    }
    NSURL *asseturl = imageUrl;
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:asseturl resultBlock:^(ALAsset *myasset) {
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        if (iref) {
            UIImage *image = [UIImage imageWithCGImage:iref];
            [backgroundImagesArray addObject:image];
            
            UIButton *pageButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [pageButton setImage:image forState:UIControlStateNormal];
            [pageButton addTarget:self action:@selector(createPageForSender:) forControlEvents:UIControlEventTouchUpInside];
            CGFloat yOffsetForButton = [arrayOfPages indexOfObject:newPageDictionary]*150;
            [pageButton setFrame:CGRectMake(15, 15 + yOffsetForButton, 160, 120)];
            pageButton.tag = [backgroundImagesArray indexOfObject:image];
            
            [[pageButton layer] setMasksToBounds:NO];
            [[pageButton layer] setShadowColor:[[UIColor blackColor] CGColor]];
            [[pageButton layer] setShadowOffset:CGSizeMake(10, 10)];
            [[pageButton layer] setShadowOpacity:0.3f];
            [[pageButton layer] setShadowRadius:2];
            [[pageButton layer] setShouldRasterize:YES];
            
            [pagesListCarousel reloadData];
            [self carousel:pagesListCarousel didSelectItemAtIndex:[arrayOfPages count]-1];
        }
    } failureBlock:^(NSError *myerror) {
        NSLog(@"Booya, cant get image - %@",[myerror localizedDescription]);
    }];    
}

#pragma mark - UIImagePickerController Delegate Method

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (photoPopoverController) {
        if ([photoPopoverController isPopoverVisible]) {
            [photoPopoverController dismissPopoverAnimated:true];
        }
    }
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Dismissed");
    }];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    // Request to save the image to camera roll
    [library writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
        if (error) {
            NSLog(@"error");
        } else {
            NSLog(@"url %@", assetURL);
            [self addNewPageWithImageUrl:assetURL];
        }  
    }];
    [self hidePageScrollView];
}

#pragma mark - UIActionSheet Delegate Method

#define CAMERA_INDEX 1
#define LIBRARY_INDEX 0

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case CAMERA_INDEX: {
            if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
            {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.allowsEditing = YES;
                [self presentViewController:imagePicker animated:YES completion:^{
                    NSLog(@"Completed");
                }];
            }
        }
            break;
            
        case LIBRARY_INDEX: {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.allowsEditing = YES;
                
                photoPopoverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
                photoPopoverController.delegate = self;
                [photoPopoverController presentPopoverFromRect:CGRectMake(0, 0, 44, 44) inView:cameraButton permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Camera Methods

- (void)cameraButtonTapped {
    UIActionSheet *photoActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Library", @"Camera", nil];
    [photoActionSheet showFromRect:CGRectMake(0, 0, 44, 44) inView:cameraButton animated:YES];
}

#pragma mark - Awesome Menu Delegate

- (void)awesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx {
    switch (menu.tag) {
        case BRUSH_MENU_TAG:
            backgroundImageView.selectedBrush = idx + 1;
            break;
            
        case COLOR_MENU_TAG:
            backgroundImageView.selectedColor = idx + 1;
            break;
            
        default:
            break;
    }
}

#pragma mark - Gesture Handlers for Assets

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void) addGestureRecognizersforView:(UIView *)someView {
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    panRecognizer.delegate = self;
    [someView addGestureRecognizer:panRecognizer];
    
    UIRotationGestureRecognizer *rotateRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
    rotateRecognizer.delegate = self;
    someView.multipleTouchEnabled = YES;
    [someView addGestureRecognizer:rotateRecognizer];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    pinchRecognizer.delegate = self;
    [someView addGestureRecognizer:pinchRecognizer];
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    longPressRecognizer.delegate = self;
    longPressRecognizer.minimumPressDuration = 2.0;
    [someView addGestureRecognizer:longPressRecognizer];
}

- (void) move:(UIPanGestureRecognizer *)recognizer{
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x+translation.x, recognizer.view.center.y+translation.y);
    translatePoint = recognizer.view.center;
    NSLog(@"Rotate Angle = %f \n Translate Point = (%f, %f)", rotateAngle, translatePoint.x, translatePoint.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (void) rotate:(UIRotationGestureRecognizer *)recognizer{
    NSLog(@"Rotate");
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    rotateAngle = atan2f(recognizer.view.transform.b, recognizer.view.transform.a);;
    NSLog(@"Rotate Angle = %f \n Translate Point = (%f, %f)", rotateAngle, translatePoint.x, translatePoint.y);
    recognizer.rotation = 0;
}

- (void) pinch:(UIPinchGestureRecognizer *)recognizer{
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
    if (recognizer.view.frame.size.width < 120) {
        [recognizer.view removeFromSuperview];
    }
}

- (void) longPressed:(UILongPressGestureRecognizer *)recognizer{
    NSLog(@"Long Pressed");
}

#pragma mark - Show Assets

- (void)addAssetToView {
    UIImage *viewImage = nil;
    for (UIView *subview in [stickerView subviews]) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            UIImageView *subviewImageView = (UIImageView *)subview;
            viewImage = subviewImageView.image;
            if (viewImage) {
                NSLog(@"Rotate Angle = %f \n Translate Point = (%f, %f)", rotateAngle, translatePoint.x, translatePoint.y);
                [backgroundImageView drawSticker:viewImage inRect:[stickerView convertRect:subview.frame toView:backgroundImageView] WithTranslation:translatePoint AndRotation:-rotateAngle];
            }
            [stickerView removeFromSuperview];
            break;
        }
    }
    
}

- (void)addImageForButton:(UIButton *)button {
    if ([[backgroundImageView subviews] containsObject:stickerView]) {
        [self addAssetToView];
    }
    [assetPopoverController dismissPopoverAnimated:YES];
    
    stickerView = [[UIView alloc] initWithFrame:CGRectMake(backgroundImageView.center.x - 90, backgroundImageView.center.y - 90, 140, 180)];
    [stickerView setUserInteractionEnabled:YES];
    [stickerView setMultipleTouchEnabled:YES];
    [self addGestureRecognizersforView:stickerView];

    UIImageView *assetImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 120, 120)];
    assetImageView.image = [UIImage imageNamed:[arrayOfImageNames objectAtIndex:button.tag]];
    [stickerView addSubview:assetImageView];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setImage:[UIImage imageNamed:@"Checkmark.png"] forState:UIControlStateNormal];
    [doneButton setFrame:CGRectMake(50, 130, 44, 44)];
    [doneButton addTarget:self action:@selector(addAssetToView) forControlEvents:UIControlEventTouchUpInside];
    [stickerView addSubview:doneButton];
    
    [backgroundImageView addSubview:stickerView];
    
    rotateAngle = 0;
    translatePoint = stickerView.center;
}

- (void)assetTypeSelected:(id)sender {
    for (UIView *subview in [assetPopoverController.contentViewController.view subviews]) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            [subview removeFromSuperview];
            break;
        }
    }
    UIScrollView *assetsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, 250, 500)];
    assetsScrollView.backgroundColor = [UIColor whiteColor];
    [assetsScrollView setUserInteractionEnabled:YES];
    
    UISegmentedControl *control = (UISegmentedControl *)sender;
    int selectedIndex = control.selectedSegmentIndex;
    switch (selectedIndex) {
        case 0: {
            arrayOfImageNames = [NSArray arrayWithObjects:@"1-leaf.png", @"2-Grass.png", @"3-leaves.png", @"10-leaves.png", @"11-leaves.png", @"A.png", @"B.png", @"bamboo-01.png", @"bamboo-02.png", @"bambu-01.png", @"bambu-02.png", @"bambu.png", @"Branch_01.png", @"C.png", @"coconut tree.png", @"grass1.png", @"hills-01.png", @"hills-02.png", @"hills-03.png", @"leaf-02", @"mushroom_01.png", @"mushroom_02.png", @"mushroom_03.png", @"mushroom_04.png", @"rock_01.png", @"rock_02.png", @"rock_03.png", @"rock_04.png", @"rock_05.png", @"rock_06.png", @"rock_07.png", @"rock_08.png", @"rock_09.png", @"rock-10.png", @"rock_11.png", @"rock_12.png", @"tree2.png", nil];
        }
            break;
            
        case 1: {
            arrayOfImageNames = [NSArray arrayWithObjects:@"rock_09.png", @"rock-10.png", @"rock_11.png", @"rock_12.png", @"tree2.png", nil];
        }
            break;
            
        default:
            break;
    }
    
    for (NSString *imageName in arrayOfImageNames) {
        UIImage *image = [UIImage imageNamed:imageName];
        UIButton *assetImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [assetImageButton setImage:image forState:UIControlStateNormal];
        [assetImageButton setFrame:CGRectMake(65, [arrayOfImageNames indexOfObject:imageName]*150 + 15, 120, 120)];
        assetImageButton.tag = [arrayOfImageNames indexOfObject:imageName];
        [assetImageButton addTarget:self action:@selector(addImageForButton:) forControlEvents:UIControlEventTouchUpInside];
        [assetsScrollView addSubview:assetImageButton];
    }
    CGFloat minContentHeight = MAX(assetsScrollView.frame.size.height, [arrayOfImageNames count]*150 + 50);
    assetsScrollView.contentSize = CGSizeMake(assetsScrollView.frame.size.width, minContentHeight);
    
    [assetPopoverController.contentViewController.view addSubview:assetsScrollView];
}

- (void)showAssets {
    NSLog(@"Show Assets");
    
    UIScrollView *assetsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, 250, 500)];
    assetsScrollView.backgroundColor = [UIColor whiteColor];
    [assetsScrollView setUserInteractionEnabled:YES];
    CGFloat minContentHeight = MAX(assetsScrollView.frame.size.height, 37*150);
    assetsScrollView.contentSize = CGSizeMake(assetsScrollView.frame.size.width, minContentHeight);
    
    UISegmentedControl *assetTypeSegmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"All", @"Story", nil]];
    [assetTypeSegmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [assetTypeSegmentedControl setSelectedSegmentIndex:0];
    [assetTypeSegmentedControl addTarget:self action:@selector(assetTypeSelected:) forControlEvents:UIControlEventValueChanged];
    [assetTypeSegmentedControl setFrame:CGRectMake(0, 0, 250, 44)];

    UIViewController *scrollViewController = [[UIViewController alloc] init];
    [scrollViewController.view setFrame:CGRectMake(0, 0, 250, 500)];
    [scrollViewController.view addSubview:assetsScrollView];
    [scrollViewController.view addSubview:assetTypeSegmentedControl];
        
    arrayOfImageNames = [NSArray arrayWithObjects:@"1-leaf.png", @"2-Grass.png", @"3-leaves.png", @"10-leaves.png", @"11-leaves.png", @"A.png", @"B.png", @"bamboo-01.png", @"bamboo-02.png", @"bambu-01.png", @"bambu-02.png", @"bambu.png", @"Branch_01.png", @"C.png", @"coconut tree.png", @"grass1.png", @"hills-01.png", @"hills-02.png", @"hills-03.png", @"leaf-02", @"mushroom_01.png", @"mushroom_02.png", @"mushroom_03.png", @"mushroom_04.png", @"rock_01.png", @"rock_02.png", @"rock_03.png", @"rock_04.png", @"rock_05.png", @"rock_06.png", @"rock_07.png", @"rock_08.png", @"rock_09.png", @"rock-10.png", @"rock_11.png", @"rock_12.png", @"tree2.png", nil];
    for (NSString *imageName in arrayOfImageNames) {
        UIImage *image = [UIImage imageNamed:imageName];
        UIButton *assetImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [assetImageButton setImage:image forState:UIControlStateNormal];
        [assetImageButton setFrame:CGRectMake(65, [arrayOfImageNames indexOfObject:imageName]*150 + 15, 120, 120)];
        assetImageButton.tag = [arrayOfImageNames indexOfObject:imageName];
        [assetImageButton addTarget:self action:@selector(addImageForButton:) forControlEvents:UIControlEventTouchUpInside];
        [assetsScrollView addSubview:assetImageButton];
    }
    
    assetPopoverController = [[UIPopoverController alloc] initWithContentViewController:scrollViewController];
    [assetPopoverController setPopoverContentSize:CGSizeMake(250, 500)];
    assetPopoverController.delegate = self;
    [assetPopoverController presentPopoverFromRect:CGRectMake(0, 100 + 2*200/3 + 150 + 10, 200, 45) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

#pragma mark - Previous Next Page Methods

- (void)showNextPage {
    [self createPageWithPageNumber:currentPage+1];
}

- (void)showPreviousPage {
    if (currentPage > 0) {
        [self createPageWithPageNumber:currentPage-1];
    }
}

#pragma mark - Share Story

- (void)showPublishDetailsView {
    PublishViewController *publishDetailsViewController = [[PublishViewController alloc] initWithNibName:@"PublishViewController" bundle:nil];
    
    UINavigationController *publishNavigationController = [[UINavigationController alloc] initWithRootViewController:publishDetailsViewController];
    publishNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    publishNavigationController.navigationBar.tintColor = [UIColor blackColor];
    [publishNavigationController setTitle:@"Enter Book Details"];
    
    UIBarButtonItem *cancelItem=[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:nil];
    cancelItem.tintColor=[UIColor blackColor];
    UIBarButtonItem *publishItem=[[UIBarButtonItem alloc]initWithTitle:@"Publish" style:UIBarButtonItemStyleBordered target:self action:nil];
    publishItem.tintColor=[UIColor blackColor];
    
    publishNavigationController.navigationItem.leftBarButtonItem = cancelItem;
    publishNavigationController.navigationItem.rightBarButtonItem = publishItem;
    
    [self presentViewController:publishNavigationController animated:YES completion:^{
        
    }];
}

#pragma mark - Menu Actions

- (void)menuButtonTapped {
    /*UIPopoverController *menuPopoverController = [[UIPopoverController alloc] initWithContentViewController:nil];
    [menuPopoverController presentPopoverFromRect:menuButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];*/
}

- (void)imageButtonTapped {
    
}

- (void)audioButtonTapped {
    
}

- (void)textButtonTapped {
    
}

- (void)gamesButtonTapped {
    
}

- (void)collaborationButtonTapped {
    
}

- (void)playPreviewButtonTapped {
    
}

#define PAGES_SELECTED_TAG 1
#define PAGES_UNSELECTED_TAG 0
- (void)pagesButtonTapped {
    if (pagesButton.tag == PAGES_SELECTED_TAG) {
        [pagesListBackgroundView removeFromSuperview];
        [self setupButton:pagesButton withImage:[UIImage imageNamed:@"pagesbutton.png"] belowButton:playPreviewButton withShadow:NO andSelector:@selector(pagesButtonTapped)];
        [pagesListCarousel removeFromSuperview];
        pagesButton.tag = PAGES_UNSELECTED_TAG;
    } else {
        pagesListBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(pagesButton.frame.origin.x + 5, pagesButton.frame.origin.y + 6, self.view.frame.size.width - 25, 108)];
        [pagesListBackgroundView setImage:[[UIImage imageNamed:@"pagesbg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(75, 200, 15, 200) resizingMode:UIImageResizingModeStretch]];
        [self.view addSubview:pagesListBackgroundView];
        
        [self createPagesListCarouselView];
        
        [self setupButton:pagesButton withImage:[UIImage imageNamed:@"pagesbutton_selected.png"] belowButton:playPreviewButton withShadow:NO andSelector:@selector(pagesButtonTapped)];
        [self.view bringSubviewToFront:pagesButton];
        pagesButton.tag = PAGES_SELECTED_TAG;
    }
}

#pragma mark - Populate backgroundImagesArray

- (void)populateBackgroundImagesArray {
    if (!backgroundImagesArray) {
        backgroundImagesArray = [[NSMutableArray alloc] init];
    }

    for (NSDictionary *dictionaryForPage in arrayOfPages) {
        for (NSDictionary *layerDict in [dictionaryForPage objectForKey:LAYERS]) {
            if ([[layerDict objectForKey:TYPE] isEqualToString:CAPTURED_IMAGE]) {
                NSURL *asseturl = [layerDict objectForKey:@"url"];
                ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
                [assetslibrary assetForURL:asseturl resultBlock:^(ALAsset *myasset) {
                    ALAssetRepresentation *rep = [myasset defaultRepresentation];
                    CGImageRef iref = [rep fullResolutionImage];
                    if (iref) {
                        UIImage *image = [UIImage imageWithCGImage:iref];
                        [backgroundImagesArray addObject:image];
                    }
                } failureBlock:^(NSError *myerror) {
                    NSLog(@"Booya, cant get image - %@",[myerror localizedDescription]);
                }];
                
            } else if ([[layerDict objectForKey:@"type"] isEqualToString:@"image"]) {
                [backgroundImagesArray addObject:[UIImage imageNamed:[layerDict objectForKey:@"url"]]];
            } else if ([[layerDict objectForKey:@"type"] isEqualToString:@"widget"]) {
                [backgroundImagesArray addObject:[[UIImage alloc] init]];
            }
        }
    }
}

#pragma mark - iCarousel Delegate/Datasource

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [arrayOfPages count] + 1;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    
    UIButton *pageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [pageButton setFrame:CGRectMake(0, 0, 130, 90)];

    if (index < [arrayOfPages count]) {
        NSDictionary *dictionaryForPage = [arrayOfPages objectAtIndex:index];

        for (NSDictionary *layerDict in [dictionaryForPage objectForKey:LAYERS]) {
            if ([[layerDict objectForKey:TYPE] isEqualToString:CAPTURED_IMAGE]) {
                NSURL *asseturl = [layerDict objectForKey:@"url"];
                ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
                [assetslibrary assetForURL:asseturl resultBlock:^(ALAsset *myasset) {
                    ALAssetRepresentation *rep = [myasset defaultRepresentation];
                    CGImageRef iref = [rep fullResolutionImage];
                    if (iref) {
                        UIImage *image = [UIImage imageWithCGImage:iref];
                        [pageButton setImage:image forState:UIControlStateNormal];
                        pageButton.tag = [backgroundImagesArray indexOfObject:image];
                    }
                } failureBlock:^(NSError *myerror) {
                    NSLog(@"Booya, cant get image - %@",[myerror localizedDescription]);
                }];
            } else if ([[layerDict objectForKey:@"type"] isEqualToString:@"image"]) {
                [pageButton setImage:[UIImage imageNamed:[layerDict objectForKey:@"url"]] forState:UIControlStateNormal];
                pageButton.tag = [backgroundImagesArray indexOfObject:[UIImage imageNamed:[layerDict objectForKey:@"url"]]];
            } else if ([[layerDict objectForKey:@"type"] isEqualToString:@"widget"]) {
                pageButton.tag = [backgroundImagesArray count]-1;
                
                if ([[layerDict objectForKey:@"wid"] intValue] == 4 || [[layerDict objectForKey:@"wid"] intValue] == 7) {
                    [pageButton setImage:[UIImage imageNamed:@"page1.jpg"] forState:UIControlStateNormal];
                } else if ([[layerDict objectForKey:@"wid"] intValue] == 5 || [[layerDict objectForKey:@"wid"] intValue] == 8) {
                    [pageButton setImage:[UIImage imageNamed:@"3.jpg"] forState:UIControlStateNormal];
                } else if ([[layerDict objectForKey:@"wid"] intValue] == 6 || [[layerDict objectForKey:@"wid"] intValue] == 9) {
                    [pageButton setImage:[UIImage imageNamed:@"q1.jpg"] forState:UIControlStateNormal];
                }
            }
        }
    } else {
        [pageButton setImage:[UIImage imageNamed:@"addnewpage.png"] forState:UIControlStateNormal];
        pageButton.tag = [arrayOfPages count];
    }
    
    [pageButton addTarget:self action:@selector(createPageForSender:) forControlEvents:UIControlEventTouchUpInside];
    return pageButton;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    [self createPageWithPageNumber:index];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return NO;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 1.05f;
        }
        case iCarouselOptionFadeMax:
        {
            if (carousel.type == iCarouselTypeCustom)
            {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value;
        }
        default:
        {
            return value;
        }
    }
}

#pragma mark - Prepare UI

- (void)createPagesListCarouselView {
    pagesListCarousel = [[iCarousel alloc] initWithFrame:CGRectMake(pagesButton.frame.origin.x + 65, pagesButton.frame.origin.y + 6, self.view.frame.size.width - 110, 108)];
    [pagesListCarousel setClipsToBounds:YES];
    pagesListCarousel.type = iCarouselTypeLinear;
    [pagesListCarousel setBackgroundColor:[UIColor clearColor]];
    pagesListCarousel.delegate = self;
    pagesListCarousel.dataSource = self;
    
    [self.view addSubview:pagesListCarousel];
}

- (void)showAudioControl {
    if (audioRecViewController.view.isHidden == YES) {
        [audioRecViewController.view setHidden:NO];
        [UIView animateWithDuration:0.5 animations:^{
            audioRecViewController.view.alpha = 1.0f;
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            audioRecViewController.view.alpha = 0.0f;
        } completion:^(BOOL finished){
            [audioRecViewController.view setHidden:YES];
        }];
    }
}

- (NSMutableArray *)arrayOfMenuItemsForColors:(NSArray *)colorsArray {
    NSMutableArray *arrayOfMenuItems = [[NSMutableArray alloc] init];
    for (NSString *colorString in colorsArray) {
        AwesomeMenuItem *starMenuItem = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:colorString]
                                                               highlightedImage:[UIImage imageNamed:colorString]
                                                                   ContentImage:[UIImage imageNamed:colorString]
                                                        highlightedContentImage:nil];
        [arrayOfMenuItems addObject:starMenuItem];
    }
    
    return arrayOfMenuItems;
}

- (AwesomeMenu *)createBrushMenu {
    //Brush Buttons Menu
    NSArray *menuItemsArray = (NSArray *)[self arrayOfMenuItemsForColors:[NSArray arrayWithObjects:@"brush-small.png", @"brush-medium.png", @"brush-large.png", nil]];
    
    // the start item, similar to "add" button of Path
    AwesomeMenuItem *startItem = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"brush-small.png"]
                                                       highlightedImage:[UIImage imageNamed:@"brush-small.png"]
                                                           ContentImage:[UIImage imageNamed:@"brush-small.png"]
                                                highlightedContentImage:[UIImage imageNamed:@"brush-small.png"]];
    // setup the menu and options
    brushMenu = [[AwesomeMenu alloc] initWithFrame:CGRectMake(0, 200, 200, 200) startItem:startItem optionMenus:menuItemsArray];
    brushMenu.tag = BRUSH_MENU_TAG;
    brushMenu.delegate = self;
    
    brushMenu.startPoint = CGPointMake(100, 200);
    brushMenu.rotateAngle = 0;
    brushMenu.menuWholeAngle = 2*M_PI;
    brushMenu.timeOffset = 0.036f;
    brushMenu.farRadius = 70.0f;
    brushMenu.nearRadius = 60.0f;
    brushMenu.endRadius = 70.0f;
    
    return brushMenu;
}

- (AwesomeMenu *)createPaintPalletView {
    //Paint Buttons Menu
    NSArray *menuItemsArray = (NSArray *)[self arrayOfMenuItemsForColors:[NSArray arrayWithObjects:@"red-splash.png", @"yellow-splash.png", @"green-splash.png", @"skyblue-splash.png", @"peasgreen-splash.png", @"purple-splash.png", @"orange-splash.png", nil]];
        
    // the start item, similar to "add" button of Path
    AwesomeMenuItem *startItem = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"red-splash.png"]
                                                       highlightedImage:[UIImage imageNamed:@"red-splash.png"]
                                                           ContentImage:[UIImage imageNamed:@"red-splash.png"]
                                                highlightedContentImage:[UIImage imageNamed:@"red-splash.png"]];
    // setup the menu and options
    paintMenu = [[AwesomeMenu alloc] initWithFrame:CGRectMake(0, 0, 200, 200) startItem:startItem optionMenus:menuItemsArray];
    paintMenu.tag = COLOR_MENU_TAG;
    paintMenu.delegate = self;
    
    paintMenu.startPoint = CGPointMake(100, 100);
    paintMenu.rotateAngle = 0;
    paintMenu.menuWholeAngle = 2*M_PI;
    paintMenu.timeOffset = 0.036f;
    paintMenu.farRadius = 70.0f;
    paintMenu.nearRadius = 60.0f;
    paintMenu.endRadius = 70.0f;
    
    return paintMenu;
}

- (void)setupButton:(UIButton *)button withImage:(UIImage *)buttonImage belowButton:(UIView *)upperButton withShadow:(BOOL)shadowEnabled andSelector:(SEL)selector {
    CGFloat originY = 0;
    if (upperButton) {
        originY = upperButton.frame.origin.y + upperButton.frame.size.height;
    }
    [button setFrame:CGRectMake(upperButton.frame.origin.x, originY, upperButton.frame.size.width, upperButton.frame.size.height)];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [[button layer] setCornerRadius:button.frame.size.height/20];
    [button setUserInteractionEnabled:YES];
    [[button layer] setMasksToBounds:NO];
    if (shadowEnabled) {
        [[button layer] setShadowColor:[[UIColor blackColor] CGColor]];
        [[button layer] setShadowOffset:CGSizeMake(3, 3)];
        [[button layer] setShadowOpacity:0.3f];
        [[button layer] setShadowRadius:5];
        [[button layer] setShouldRasterize:YES];
    }
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupScrollView:(UIView *)theView withImage:(UIImage *)image {
    [[theView layer] setMasksToBounds:NO];
    [[theView layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[theView layer] setShadowOpacity:0.3f];
    [[theView layer] setShadowRadius:5];
    [[theView layer] setShouldRasterize:YES];
    [theView setBackgroundColor:[UIColor colorWithPatternImage:image]];
}

- (void)createScrollViewButton {
    showScrollViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [showScrollViewButton setFrame:CGRectMake(accordion.frame.origin.x + accordion.frame.size.width, 0, 44, 44)];
    [showScrollViewButton setImage:[UIImage imageNamed:@"mango-icon.png"] forState:UIControlStateNormal];
    [[showScrollViewButton layer] setCornerRadius:showScrollViewButton.frame.size.height/20];
    [showScrollViewButton setUserInteractionEnabled:YES];
    [[showScrollViewButton layer] setMasksToBounds:NO];
    [[showScrollViewButton layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[showScrollViewButton layer] setShadowOffset:CGSizeMake(3, 3)];
    [[showScrollViewButton layer] setShadowOpacity:0.3f];
    [[showScrollViewButton layer] setShadowRadius:5];
    [[showScrollViewButton layer] setShouldRasterize:YES];
    showScrollViewButton.tag = accordion.frame.origin.x>0 ? 1:0;
    [showScrollViewButton addTarget:self action:@selector(showOrHideScrollView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showScrollViewButton];
    [self.view bringSubviewToFront:showScrollViewButton];
}

- (void)createStaticToolsView {
    UIButton *header = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, staticToolsView.frame.size.width, 10)];
    [header setTitle:@"" forState:UIControlStateNormal];
    header.backgroundColor = [UIColor blackColor];
    [staticToolsView addSubview:header];
    
    // Record Audio Button
    recordAudioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:recordAudioButton withImage:[UIImage imageNamed:@"record-control.png"] belowButton:header withShadow:YES andSelector:@selector(recordAudio)];
    [staticToolsView addSubview:recordAudioButton];
    
    playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:playButton withImage:[UIImage imageNamed:@"play-control.png"] belowButton:header withShadow:YES andSelector:@selector(playRecording)];
    [playButton setFrame:CGRectMake(128, playButton.frame.origin.y, 44, 44)];
    [staticToolsView addSubview:playButton];
    
    // Camera Button
    cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:cameraButton withImage:[UIImage imageNamed:@"camera_gray_round.png"] belowButton:playButton withShadow:YES andSelector:@selector(cameraButtonTapped)];
    [cameraButton setFrame:CGRectMake(128, 104, 44, 44)];
    [staticToolsView addSubview:cameraButton];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:shareButton withImage:[UIImage imageNamed:@"sharebutton.png"] belowButton:recordAudioButton withShadow:YES andSelector:nil];
    [shareButton setFrame:CGRectMake(28, 104, 44, 44)];
    //[shareButton addTarget:self action:@selector(showPublishDetailsView) forControlEvents:UIControlEventTouchUpInside];
    [staticToolsView addSubview:shareButton];
}

- (void)createPreviousAndNextButtons {
    nextPageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextPageButton setFrame:CGRectMake(self.view.frame.origin.x + self.view.frame.size.width - 50, backgroundImageView.frame.origin.y + backgroundImageView.frame.size.height - 50, 44, 44)];
    [nextPageButton setImage:[UIImage imageNamed:@"next-button.png"] forState:UIControlStateNormal];
    [nextPageButton addTarget:self action:@selector(showNextPage) forControlEvents:UIControlEventTouchUpInside];
    
    previousPageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [previousPageButton setFrame:CGRectMake(0, backgroundImageView.frame.origin.y + backgroundImageView.frame.size.height - 50, 44, 44)];
    [previousPageButton setImage:[UIImage imageNamed:@"previous-button.png"] forState:UIControlStateNormal];
    [previousPageButton addTarget:self action:@selector(showPreviousPage) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:nextPageButton];
    [self.view addSubview:previousPageButton];
    [self.view bringSubviewToFront:nextPageButton];
    [self.view bringSubviewToFront:previousPageButton];
}

// Removing for new UI
/*
- (void)createToolView {
    // Show Scroll View Button
    [self createScrollViewButton];
        
    drawerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, self.view.frame.size.height)];
    [drawerView setBackgroundColor:COLOR_GREY];
    
    accordion = [[AccordionView alloc] initWithFrame:CGRectMake(0, 0, 200, drawerView.frame.size.height - 180)];
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    // Only height is taken into account, so other parameters are just dummy
    UIButton *header1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 45)];
    [header1 setTitle:@"Pages" forState:UIControlStateNormal];
    [[header1 layer] setBorderWidth:1.0f];
    [[header1 layer] setBorderColor:[[UIColor colorWithPatternImage:[UIImage imageNamed:@"topdot.png"]] CGColor]];
    header1.backgroundColor = [UIColor blackColor];
    // Pages List View
    pageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 200, self.view.frame.size.height - 90 - 180)];
    [self setupScrollView:pageScrollView withImage:[UIImage imageNamed:@"topdot.png"]];
    [[pageScrollView layer] setShadowOffset:CGSizeMake(3, 3)];
    [accordion addHeader:header1 withView:pageScrollView];
    
    UIButton *header2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 45)];
    [header2 setTitle:@"Drawing Tools" forState:UIControlStateNormal];
    [[header2 layer] setBorderWidth:1.0f];
    [[header2 layer] setBorderColor:[[UIColor colorWithPatternImage:[UIImage imageNamed:@"topdot.png"]] CGColor]];
    header2.backgroundColor = [UIColor blackColor];
    toolsView = [[DrawingToolsView alloc] initWithFrame:CGRectMake(0, 0, 200, self.view.frame.size.height - 90 - 180)];
    toolsView.delegate = self;
    [accordion addHeader:header2 withView:toolsView];
    [self selectedColor:RED_BUTTON_TAG];
    [self widthOfBrush:5.0f];
    [self widthOfEraser:20.0f];
    [accordion setNeedsLayout];
    // Set this if you want to allow multiple selection
    [accordion setAllowsMultipleSelection:NO];
    [accordion setSelectedIndex:1];
    [drawerView addSubview:accordion];
    
    staticToolsView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 180, 200, 180)];
    [staticToolsView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"topdot.png"]]];
    [self createStaticToolsView];
    [drawerView addSubview:staticToolsView];
    
    [self.view addSubview:drawerView];
    
    [self createPreviousAndNextButtons];
}
*/
 
- (void)wordTapped:(UITapGestureRecognizer *)recognizer {
    NSLog(@"Clicked");
    
    CGPoint pos = [recognizer locationInView:mainTextView];
    
    NSLog(@"Tap Gesture Coordinates: %.2f %.2f", pos.x, pos.y);
    
    //get location in text from textposition at point
    UITextPosition *tapPos = [mainTextView closestPositionToPoint:pos];
    
    //fetch the word at this position (or nil, if not available)
    UITextRange * wr = [mainTextView.tokenizer rangeEnclosingPosition:tapPos withGranularity:UITextGranularityWord inDirection:UITextLayoutDirectionRight];
    
    NSLog(@"WORD: %@", [mainTextView textInRange:wr]);
    
    self.google_tts_bysham = [[Google_TTS_BySham alloc] init];
    [self.google_tts_bysham speak:[mainTextView textInRange:wr]];
    
}

- (void)createMenus {
    [self.view setBackgroundColor:COLOR_GREY];
    
    mangoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [mangoButton setImage:[UIImage imageNamed:@"mangoicon.png"] forState:UIControlStateNormal];
    [mangoButton setFrame:CGRectMake(10, backgroundImageView.frame.origin.y - 10, 60, 70)];
    [self.view addSubview:mangoButton];
    
    menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:menuButton withImage:[UIImage imageNamed:@"menubutton.png"] belowButton:mangoButton withShadow:NO andSelector:@selector(menuButtonTapped)];
    [self.view addSubview:menuButton];
    
    imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [imageButton setImage:[UIImage imageNamed:@"imagebutton.png"] forState:UIControlStateNormal];
    [imageButton setFrame:CGRectMake(10, menuButton.frame.origin.y + menuButton.frame.size.height + 20, 60, 60)];
    [imageButton addTarget:self action:@selector(imageButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imageButton];
    
    textButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:textButton withImage:[UIImage imageNamed:@"textbutton.png"] belowButton:imageButton withShadow:NO andSelector:@selector(textButtonTapped)];
    [self.view addSubview:textButton];

    audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:audioButton withImage:[UIImage imageNamed:@"audiobutton.png"] belowButton:textButton withShadow:NO andSelector:@selector(audioButtonTapped)];
    [self.view addSubview:audioButton];

    gamesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:gamesButton withImage:[UIImage imageNamed:@"gamebutton.png"] belowButton:audioButton withShadow:NO andSelector:@selector(gamesButtonTapped)];
    [self.view addSubview:gamesButton];

    collaborationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:collaborationButton withImage:[UIImage imageNamed:@"collaborationbutton.png"] belowButton:gamesButton withShadow:NO andSelector:@selector(collaborationButtonTapped)];
    [self.view addSubview:collaborationButton];
    
    playPreviewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playPreviewButton setFrame:CGRectMake(10, backgroundImageView.frame.origin.y + backgroundImageView.frame.size.height - 55, 60, 60)];
    [playPreviewButton setImage:[UIImage imageNamed:@"playbuttonnew.png"] forState:UIControlStateNormal];
    [playPreviewButton addTarget:self action:@selector(playPreviewButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playPreviewButton];
    
    pagesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:pagesButton withImage:[UIImage imageNamed:@"pagesbutton.png"] belowButton:playPreviewButton withShadow:NO andSelector:@selector(pagesButtonTapped)];
    [self.view addSubview:pagesButton];
}

- (void)createInitialUI {
    UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo1.png"]];
    self.navigationItem.titleView=imageView;
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];

    backgroundImageView = [[SmoothDrawingView alloc] initWithFrame:CGRectMake(80, 15, self.view.frame.size.width - 105, self.view.frame.size.height - 210)];
    backgroundImageView.delegate = self;
    // Temporarily adding fixed image
    [self.view addSubview:backgroundImageView];
    
    // Text View
    mainTextView = [[MovableTextView alloc] initWithFrame:CGRectMake(backgroundImageView.frame.origin.x + 20, backgroundImageView.frame.origin.y + 20, backgroundImageView.frame.size.width/3, backgroundImageView.frame.size.height/4)];
    mainTextView.tag = MAIN_TEXTVIEW_TAG;
    mainTextView.textColor = [UIColor blackColor];
    mainTextView.font = [UIFont boldSystemFontOfSize:24];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wordTapped:)];
    tapRecognizer.delegate = self;
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [mainTextView addGestureRecognizer:tapRecognizer];
    
    [backgroundImageView addSubview:mainTextView];
    
    // Removing for new UI
    //[self createToolView];
    
    // For new UI
    [self createMenus];
}

- (void)createPageWithPageNumber:(NSInteger)pageNumber {
    currentPage = pageNumber;
    
    NSMutableString *textOnPage = [[NSMutableString alloc] initWithString:@""];
    
    if (pageNumber < [arrayOfPages count]) {
        NSDictionary *dictionaryForPage = [arrayOfPages objectAtIndex:pageNumber];
        for (NSDictionary *layerDict in [dictionaryForPage objectForKey:@"layers"]) {
            if ([[layerDict objectForKey:@"type"] isEqualToString:@"audio"]) {
                NSArray *arrayOfWords = [layerDict objectForKey:@"wordMap"];
                for (NSDictionary *wordDict in arrayOfWords) {
                    [textOnPage appendFormat:@"%@ ", [wordDict objectForKey:@"word"]];
                }
            }
        }
        
        if ([[dictionaryForPage allKeys] containsObject:@"type"]) {
            if ([[dictionaryForPage objectForKey:@"type"] isEqualToString:@"widget"]) {
                NSDictionary *layerDict = [[dictionaryForPage objectForKey:@"layers"] objectAtIndex:0];
                
                for (UIView *subview in backgroundImageView.subviews) {
                    if ([subview isKindOfClass:[UIWebView class]]) {
                        [subview removeFromSuperview];
                        break;
                    }
                }
                
                UIWebView *widgetWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, backgroundImageView.frame.size.width, backgroundImageView.frame.size.height)];
                
                if (tagForLanguage == ENGLISH_TAG || tagForLanguage == GERMAN_TAG || tagForLanguage == SPANISH_TAG) {
                    NSLog(@"%@", [NSString stringWithFormat:@"/%d/%@", [[layerDict objectForKey:@"wid"] intValue], [layerDict objectForKey:@"slug"]]);
                    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:[NSString stringWithFormat:@"/%d/%@", [[layerDict objectForKey:@"wid"] intValue], [layerDict objectForKey:@"slug"]]]];
                    [widgetWebView loadRequest:[NSURLRequest requestWithURL:url]];
                } else if (tagForLanguage == TAMIL_TAG) {
                    NSLog(@"%@", [NSString stringWithFormat:@"/widgets/%d/%@", [[layerDict objectForKey:@"wid"] intValue], [layerDict objectForKey:@"slug"]]);
                    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:[NSString stringWithFormat:@"/widgets/%d/%@", [[layerDict objectForKey:@"wid"] intValue], [layerDict objectForKey:@"slug"]]]];
                    [widgetWebView loadRequest:[NSURLRequest requestWithURL:url]];
                }
                
                [backgroundImageView addSubview:widgetWebView];
                
                [mainTextView setFrame:CGRectMake(0, 0, 100, 100)];
                mainTextView.text = @"";
            }
        } else {
            for (UIView *subview in self.view.subviews) {
                if ([subview isKindOfClass:[UIWebView class]]) {
                    [subview removeFromSuperview];
                    break;
                }
            }
            if (!backgroundImageView) {
                backgroundImageView = [[SmoothDrawingView alloc] initWithFrame:self.view.frame];
                backgroundImageView.delegate = self;
            }
            for (UIView *subView in [backgroundImageView subviews]) {
                if ([subView isKindOfClass:[UIWebView class]]) {
                    [subView removeFromSuperview];
                    break;
                }
            }
            /*if (![self.view.subviews containsObject:backgroundImageView]) {
                // Temporarily adding fixed image
                [self.view addSubview:backgroundImageView];
            }*/
            
            if ([backgroundImagesArray objectAtIndex:pageNumber]) {
                backgroundImageView.incrementalImage = [backgroundImagesArray objectAtIndex:pageNumber];
                backgroundImageView.originalImage = [backgroundImagesArray objectAtIndex:pageNumber];
                [backgroundImageView setNeedsDisplay];
                //[backgroundImageView setImage:[backgroundImagesArray objectAtIndex:pageNumber]];
                backgroundImageView.indexOfThisImage = pageNumber;
            }
            if ([textOnPage length] > 0) {
                mainTextView.text = textOnPage;
                CGSize textSize = [mainTextView.text sizeWithFont:[UIFont boldSystemFontOfSize:24] constrainedToSize:CGSizeMake(700, 500) lineBreakMode:NSLineBreakByWordWrapping];
                [mainTextView setFrame:CGRectMake(mainTextView.frame.origin.x, mainTextView.frame.origin.y, textSize.width, textSize.height + 60)];
            } else {
                [mainTextView setFrame:CGRectMake(0, 0, 100, 100)];
                mainTextView.text = @"";
            }
        }
    }
    else {
        NSMutableDictionary *newPageDict = [[NSMutableDictionary alloc] init];
        [newPageDict setObject:[NSNumber numberWithInt:[arrayOfPages count]] forKey:@"id"];
        [newPageDict setObject:[NSNumber numberWithInt:[arrayOfPages count]] forKey:@"name"];
        NSMutableArray *layersArray = [[NSMutableArray alloc] init];
        NSMutableDictionary *imageDict = [[NSMutableDictionary alloc] init];
        [imageDict setObject:@"image" forKey:@"type"];
        [imageDict setObject:@"white_page.jpeg" forKey:@"url"];
        [layersArray addObject:imageDict];
        [newPageDict setObject:layersArray forKey:@"layers"];
        [arrayOfPages addObject:newPageDict];
        
        if (!backgroundImagesArray) {
            backgroundImagesArray = [[NSMutableArray alloc] init];
        }
        [backgroundImagesArray addObject:[UIImage imageNamed:[imageDict objectForKey:@"url"]]];
        [pagesListCarousel reloadData];
        [self carousel:pagesListCarousel didSelectItemAtIndex:[arrayOfPages count] - 1];
    }
    
    if ([[self.view subviews] containsObject:playButton]) {
        [playButton removeFromSuperview];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *recDir = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sampleRecord_%d.caf", recDir, backgroundImageView.indexOfThisImage]];
    //NSString *path = [url path];
    //NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
    /*if (data) {
        playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [playButton setFrame:CGRectMake(recordAudioButton.frame.origin.x, 120, 44, 44)];
        [playButton setImage:[UIImage imageNamed:@"play-control.png"] forState:UIControlStateNormal];
        [playButton setUserInteractionEnabled:YES];
        [[playButton layer] setMasksToBounds:NO];
        [[playButton layer] setShadowColor:[[UIColor blackColor] CGColor]];
        [[playButton layer] setShadowOffset:CGSizeMake(-3, -3)];
        [[playButton layer] setShadowOpacity:0.3f];
        [[playButton layer] setShadowRadius:5];
        [[playButton layer] setShouldRasterize:YES];
        [playButton addTarget:self action:@selector(playRecording) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:playButton];
        [self.view bringSubviewToFront:playButton];
    } else if ([[self.view subviews] containsObject:playButton]) {
        [playButton removeFromSuperview];
    }*/
    
    if (!audioRecViewController) {
        audioRecViewController = [[AudioRecordingViewController alloc] initWithNibName:@"AudioRecordingViewController" bundle:nil];
        [audioRecViewController.view setFrame:CGRectMake(self.view.frame.size.width - 205, self.view.frame.size.height - 205, 200, 200)];
        audioRecViewController.view.alpha = 0.0f;
        [audioRecViewController.view setHidden:YES];
        [self.view addSubview:audioRecViewController.view];
    }
    audioRecViewController.audioUrl = url;
    [audioRecViewController stopPlaying];
    
    [self.view bringSubviewToFront:mainTextView];
    [self.view bringSubviewToFront:showScrollViewButton];
    [self.view bringSubviewToFront:showPaintPalletButton];
    [self.view bringSubviewToFront:paintMenu];
    [self.view bringSubviewToFront:brushMenu];
    [self.view bringSubviewToFront:assetsButton];
    [self.view bringSubviewToFront:cameraButton];
    [self.view bringSubviewToFront:eraserButton];
    [self.view bringSubviewToFront:recordAudioButton];
    [self.view bringSubviewToFront:audioRecViewController.view];
    [self.view bringSubviewToFront:pageScrollView];
    [self.view bringSubviewToFront:paintPalletView];
}

- (void)createPageForSender:(UIButton *)sender {
    [self createPageWithPageNumber:sender.tag];
    //[self hidePageScrollView];
}

- (void)creatAddNewPageButton {
    addNewPageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addNewPageButton setImage:[UIImage imageNamed:@"new_page.png"] forState:UIControlStateNormal];
    [addNewPageButton addTarget:self action:@selector(createPageForSender:) forControlEvents:UIControlEventTouchUpInside];
    CGFloat yOffsetForButton = [arrayOfPages count]*150;
    [addNewPageButton setFrame:CGRectMake(15, 15 + yOffsetForButton, 160, 120)];
    addNewPageButton.tag = [arrayOfPages count];
    
    [[addNewPageButton layer] setMasksToBounds:NO];
    [[addNewPageButton layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[addNewPageButton layer] setShadowOffset:CGSizeMake(10, 10)];
    [[addNewPageButton layer] setShadowOpacity:0.3f];
    [[addNewPageButton layer] setShadowRadius:2];
    [[addNewPageButton layer] setShouldRasterize:YES];
    
    [pageScrollView addSubview:addNewPageButton];
}

#pragma mark - Parsing Book Json

- (void)processJson:(NSDictionary *)jsonDict {
    NSDictionary *pageViewDict = [StoryJsonProcessor pageViewForJsonString:jsonDict];
    NSLog(@"%@", pageViewDict);
}

- (void)getBookJson {
    // Temporarily adding hardcoded string
    angryBirdsTamilJsonString = @"[{\"id\":\"Cover\",\"name\":\"Cover\",\"layers\":[{\"type\":\"image\",\"url\":\"abad124338.jpg\",\"alignment\":\"left\",\"order\":0,\"name\":\"\"}],\"order\":0,\"pageNo\":1,\"original_id\":747,\"child\":\"jigsaw\"},{\"id\":1,\"name\":1,\"layers\":[{\"type\":\"image\",\"url\":\"21833583e6.jpg\",\"alignment\":\"middle\",\"order\":0,\"name\":\"\"},{\"type\":\"text\",\"alignment\":\"left\",\"order\":0,\"name\":\"\"},{\"type\":\"audio\",\"url\":\"671db6ad7f.mp3\",\"wordTimes\":[2.4927539825439453,3.2448489665985107,4.247387886047363,4.749120235443115,5.000740051269531],\"wordMap\":[{\"word\":\"சுந்தரம்\",\"step\":25,\"wordIdx\":1},{\"word\":\"தினமும்\",\"step\":32,\"wordIdx\":2},{\"word\":\"கணினி\",\"step\":42,\"wordIdx\":3},{\"word\":\"விளையாட்டு\",\"step\":47,\"wordIdx\":4},{\"word\":\"விளையாடுவான்.\",\"step\":50,\"wordIdx\":5}],\"order\":0,\"name\":\"\"}],\"order\":0,\"pageNo\":1,\"original_id\":748},{\"id\":2,\"name\":2,\"layers\":[{\"type\":\"image\",\"url\":\"50d0f84f99.jpg\",\"alignment\":\"middle\",\"order\":0,\"name\":\"\"},{\"type\":\"text\",\"alignment\":\"left\",\"order\":0,\"name\":\"\"},{\"type\":\"audio\",\"url\":\"d13bba5005.mp3\",\"wordTimes\":[1.2127419710159302,1.9000000000000001,2.725771903991699,3.4780259132385254,3.981329917907715,5.232964038848877,6.485886096954346,7,7.489037990570068,7.9,8.200000000000001,8.8,9.243943214416504],\"wordMap\":[{\"word\":\"ஒருநாள்\",\"step\":12,\"wordIdx\":1},{\"word\":\"அவன்\",\"step\":19,\"wordIdx\":2},{\"word\":\"வீட்டில்\",\"step\":27,\"wordIdx\":3},{\"word\":\"யாரும்\",\"step\":35,\"wordIdx\":4},{\"word\":\"இல்லை.\",\"step\":40,\"wordIdx\":5},{\"word\":\"அப்போது\",\"step\":52,\"wordIdx\":6},{\"word\":\"சுந்தரம்\",\"step\":65,\"wordIdx\":7},{\"word\":\" “கோபமான\",\"step\":70,\"wordIdx\":8},{\"word\":\"குருவி”\",\"step\":75,\"wordIdx\":9},{\"word\":\"என்ற\",\"step\":79,\"wordIdx\":10},{\"word\":\"விளையாட்டை\",\"step\":82,\"wordIdx\":11},{\"word\":\"விளையாடிக்\",\"step\":88,\"wordIdx\":12},{\"word\":\"கொண்டிருந்தான்.\",\"step\":92,\"wordIdx\":13}],\"order\":0,\"name\":\"\"}],\"order\":0,\"pageNo\":1,\"original_id\":749},{\"id\":3,\"name\":3,\"layers\":[{\"type\":\"image\",\"url\":\"a8fc0e26ef.jpg\",\"alignment\":\"middle\",\"order\":0,\"name\":\"\"},{\"type\":\"text\",\"alignment\":\"left\",\"order\":0,\"name\":\"\"},{\"type\":\"audio\",\"url\":\"bd026a2f3b.mp3\",\"wordTimes\":null,\"wordMap\":[{\"word\":\"அப்போது\",\"step\":12,\"wordIdx\":1},{\"word\":\"ஏதோ\",\"step\":19,\"wordIdx\":2},{\"word\":\"சத்தம்\",\"step\":27,\"wordIdx\":3},{\"word\":\"கேட்டது\",\"step\":35,\"wordIdx\":4},{\"word\":\"அவன்.\",\"step\":40,\"wordIdx\":5},{\"word\":\"திரும்பிப்\",\"step\":52,\"wordIdx\":6},{\"word\":\"பார்த்தான்.\",\"step\":65,\"wordIdx\":7}],\"order\":0,\"name\":\"\"}],\"order\":0,\"pageNo\":1,\"original_id\":750},{\"id\":4,\"name\":4,\"layers\":[{\"type\":\"image\",\"url\":\"685dcbd3db.jpg\",\"alignment\":\"middle\",\"order\":0,\"name\":\"\"},{\"type\":\"text\",\"alignment\":\"left\",\"order\":0,\"name\":\"\"},{\"type\":\"audio\",\"url\":\"515c992c1b.mp3\",\"wordTimes\":null,\"wordMap\":[{\"word\":\"அங்கே\",\"step\":12,\"wordIdx\":1},{\"word\":\"அவன்\",\"step\":19,\"wordIdx\":2},{\"word\":\"வீட்டுச்\",\"step\":27,\"wordIdx\":3},{\"word\":\"சன்னல்\",\"step\":35,\"wordIdx\":4},{\"word\":\"பக்கத்தில்\",\"step\":40,\"wordIdx\":5},{\"word\":\"நான்கு\",\"step\":52,\"wordIdx\":6},{\"word\":\"பறவைகள்\",\"step\":65,\"wordIdx\":7},{\"word\":\"உட்கார்ந்து\",\"step\":35,\"wordIdx\":8},{\"word\":\"இருந்தன.\",\"step\":40,\"wordIdx\":9},{\"word\":\"அவை\",\"step\":52,\"wordIdx\":10},{\"word\":\"அவனைக்\",\"step\":65,\"wordIdx\":11},		{\"word\":\"கோபமாகப்\",\"step\":52,\"wordIdx\":12},{\"word\":\"பார்த்தன.\",\"step\":65,\"wordIdx\":13}],\"order\":0,\"name\":\"\"}],\"order\":0,\"pageNo\":1,\"original_id\":752},{\"id\":5,\"name\":6,\"layers\":[{\"type\":\"widget\",\"wid\":\"5\",\"slug\":\"Where_is_sundaram\",\"order\":0,\"name\":\"\"}],\"order\":0,\"pageNo\":1,\"type\":\"widget\",\"original_id\":760},{\"id\":6,\"name\":5,\"layers\":[{\"type\":\"widget\",\"wid\":\"4\",\"slug\":\"where_is_bird\",\"order\":0,\"name\":\"\"}],\"order\":0,\"pageNo\":1,\"type\":\"widget\",\"original_id\":761},{\"id\":7,\"name\":7,\"layers\":[{\"type\":\"widget\",\"wid\":\"6\",\"slug\":\"widget3\",\"order\":0,\"name\":\"\"}],\"order\":0,\"pageNo\":1,\"type\":\"widget\",\"original_id\":762},{\"id\":\"jigsaw\",\"name\":\"jigsaw\",\"layers\":[{\"type\":\"image\",\"url\":\"a8fc0e26ef.jpg\",\"order\":0,\"name\":\"\"}],\"type\":\"game\",\"pageid\":\"Cover\",\"order\":0,\"pageNo\":1,\"original_id\":775}]";
    
    angryBirdsEnglishJsonString = @"[{\"id\": \"Cover\",\"name\": \"Cover\",\"layers\": [{\"type\": \"image\",\"url\": \"8517823664.jpg\",\"alignment\": \"left\",\"order\": 0,\"name\": \"\"}],\"order\": 0,\"pageNo\": 1,\"original_id\": 763},{\"id\": 1,\"name\": 1,\"layers\": [{\"type\": \"image\",\"url\": \"21833583e6.jpg\",\"alignment\": \"middle\",\"order\": 0,\"name\": \"\"},{\"type\": \"text\",\"text\": \"Sundaram utilizar para jugar juegos de computadora todo el día.\",\"alignment\": \"left\",\"order\": 0,\"name\": \"\",\"language\": \"es\"},{\"type\": \"audio\",\"url\": \"f9c3d294be.mp3\",\"wordTimes\": [0.6199439764022827,1.1206820011138916,1.4000000000000001,1.6,1.9000000000000001,2.2,2.7],\"wordMap\": [{\"word\": \"Sundaram\",\"step\": 6,\"wordIdx\": 1},{\"word\": \"used\",\"step\": 11,\"wordIdx\": 2},{\"word\": \"to\",\"step\": 14,\"wordIdx\": 3},{\"word\": \"play\",\"step\": 16,\"wordIdx\": 4},{\"word\": \"computer\",\"step\": 19,\"wordIdx\": 5},{\"word\": \"games\",\"step\": 22,\"wordIdx\": 6},{\"word\": \"everyday.\",\"step\": 27,\"wordIdx\": 7}],\"order\": 0,\"name\": \"\"},{\"type\": \"original_text\",\"text\": \"Sundaram used to play computer games all day.\",\"language\": \"en\",\"order\": 0,\"name\": \"\"}],\"order\": 0,\"pageNo\": 1,\"original_id\": 764},{\"id\": 2,\"name\": 2,\"layers\": [{\"type\": \"image\",\"url\": \"50d0f84f99.jpg\",\"alignment\": \"middle\",\"order\": 0,\"name\": \"\"},{\"type\": \"text\",\"alignment\": \"left\",\"order\": 0,\"name\": \"\"},{\"type\": \"audio\",\"url\": \"23a68f3938.mp3\",\"wordTimes\": [0.41754600405693054,0.6674889922142029,1.173475980758667,1.4266209602355957,1.679677963256836,1.9314359426498413,2.1820950508117676,2.4327518939971924,2.9337239265441895,3.18544602394104,3.9370460510253906,4.187881946563721,4.438592910766602,4.7,4.9],\"wordMap\": [{\"word\": \"One\",\"step\": 4,\"wordIdx\": 1},{\"word\": \"day\",\"step\": 7,\"wordIdx\": 2},{\"word\": \"he\",\"step\": 12,\"wordIdx\": 3},{\"word\": \"is\",\"step\": 14,\"wordIdx\": 4},{\"word\": \"playing\",\"step\": 17,\"wordIdx\": 5},{\"word\": \"a\",\"step\": 19,\"wordIdx\": 6},{\"word\": \"game\",\"step\": 22,\"wordIdx\": 7},{\"word\": \"called\",\"step\": 24,\"wordIdx\": 8},{\"word\": \"Angry\",\"step\": 29,\"wordIdx\": 9},{\"word\": \"birds\",\"step\": 32,\"wordIdx\": 10},{\"word\": \"when\",\"step\": 39,\"wordIdx\": 11},{\"word\": \"no\",\"step\": 42,\"wordIdx\": 12},{\"word\": \"one\",\"step\": 44,\"wordIdx\": 13},{\"word\": \"is\",\"step\": 47,\"wordIdx\": 14},{\"word\": \"around.\",\"step\": 49,\"wordIdx\": 15}],\"order\": 0,\"name\": \"\"}],\"order\": 0,\"pageNo\": 1,\"original_id\": 765},{\"id\": 3,\"name\": 3,\"layers\": [{\"type\": \"image\",\"url\": \"a8fc0e26ef.jpg\",\"alignment\": \"middle\",\"order\": 0,\"name\": \"\"},{\"type\": \"text\",\"alignment\": \"left\",\"order\": 0,\"name\": \"\"},{\"type\": \"audio\",\"url\": \"64d4de5ec4.mp3\",\"wordTimes\": [0.4,0.9,1,1.3,1.6,1.957522988319397,2.2085559368133545,2.2085559368133545,3.2106990814208984,3.4614439010620117,3.711867094039917,3.9624791145324707,4.213839054107666,4.4638590812683105,4.720414161682129,4.965227127075195],\"wordMap\": [{\"word\": \"And\",\"step\": 4,\"wordIdx\": 1},{\"word\": \"he\",\"step\": 9,\"wordIdx\": 2},{\"word\": \"heard\",\"step\": 10,\"wordIdx\": 3},{\"word\": \"some\",\"step\": 13,\"wordIdx\": 4},{\"word\": \"noise\",\"step\": 16,\"wordIdx\": 5},{\"word\": \"near\",\"step\": 20,\"wordIdx\": 6},{\"word\": \"the\",\"step\": 22,\"wordIdx\": 7},{\"word\": \"window,\",\"step\": 22,\"wordIdx\": 8},{\"word\": \"he\",\"step\": 32,\"wordIdx\": 9},{\"word\": \"turned\",\"step\": 35,\"wordIdx\": 10},{\"word\": \"from\",\"step\": 37,\"wordIdx\": 11},{\"word\": \"game\",\"step\": 40,\"wordIdx\": 12},{\"word\": \"and\",\"step\": 42,\"wordIdx\": 13},{\"word\": \"looked\",\"step\": 45,\"wordIdx\": 14},{\"word\": \"at\",\"step\": 47,\"wordIdx\": 15},{\"word\": \"it.\",\"step\": 50,\"wordIdx\": 16}],\"order\": 0,\"name\": \"\"}],\"order\": 0,\"pageNo\": 1,\"original_id\": 766},{\"id\": 4,\"name\": 4,\"layers\": [{\"type\": \"image\",\"url\": \"685dcbd3db.jpg\",\"alignment\": \"middle\",\"order\": 0,\"name\": \"\"},{\"type\": \"text\",\"alignment\": \"left\",\"order\": 0,\"name\": \"\"},{\"type\": \"audio\",\"url\": \"f3905b0506.mp3\",\"wordTimes\": [0.6486089825630188,0.8334199786186218,1.2000000000000002,1.6,1.9000000000000001,2.5,2.943850040435791,3.1125309467315674,3.3000000000000003,3.5,3.8000000000000003,4.170816898345947,5.1000000000000005,5.4,5.742791175842285,6.095162868499756,6.443782806396484,6.976383209228516],\"wordMap\": [{\"word\": \"Four\",\"step\": 6,\"wordIdx\": 1},{\"word\": \"birds\",\"step\": 8,\"wordIdx\": 2},{\"word\": \"were\",\"step\": 12,\"wordIdx\": 3},{\"word\": \"sitting\",\"step\": 16,\"wordIdx\": 4},{\"word\": \"there\",\"step\": 19,\"wordIdx\": 5},{\"word\": \"on\",\"step\": 25,\"wordIdx\": 6},{\"word\": \"the\",\"step\": 29,\"wordIdx\": 7},{\"word\": \"side\",\"step\": 31,\"wordIdx\": 8},{\"word\": \"of\",\"step\": 33,\"wordIdx\": 9},{\"word\": \"his\",\"step\": 35,\"wordIdx\": 10},{\"word\": \"house\",\"step\": 38,\"wordIdx\": 11},{\"word\": \"window,\",\"step\": 42,\"wordIdx\": 12},{\"word\": \"and\",\"step\": 51,\"wordIdx\": 13},{\"word\": \"staring\",\"step\": 54,\"wordIdx\": 14},{\"word\": \"at\",\"step\": 57,\"wordIdx\": 15},{\"word\": \"him\",\"step\": 61,\"wordIdx\": 16},{\"word\": \"very\",\"step\": 64,\"wordIdx\": 17},{\"word\": \"angrily.\",\"step\": 70,\"wordIdx\": 18}],\"order\": 0,\"name\": \"\"}],\"order\": 0,\"pageNo\": 1,\"original_id\": 768},{\"id\": 5,\"name\": 5,\"layers\": [{\"type\": \"widget\",\"wid\": \"7\",\"slug\": \"Where_is_sundaram\",\"order\": 0,\"name\": \"\"}],\"order\": 0,\"pageNo\": 1,\"type\": \"widget\"},{\"id\": 6,\"name\": 6,\"layers\": [{\"type\": \"widget\",\"wid\": \"8\",\"slug\": \"where_is_bird\",\"order\": 0,\"name\": \"\"}],\"order\": 0,\"pageNo\": 1,\"type\": \"widget\",\"original_id\": 773},{\"id\": 7,\"name\": 7,\"layers\": [{\"type\": \"widget\",\"wid\": \"9\",\"slug\": \"widget3\",\"order\": 0,\"name\": \"\"}],\"order\": 0,\"pageNo\": 1,\"type\": \"widget\"}]";
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"english_live_json_1500" ofType:@"json"];
    frankfurtEnglishJson = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error: NULL];
    NSLog(@"%@", frankfurtEnglishJson);
    
    filePath = [[NSBundle mainBundle] pathForResource:@"german_live_json_1707" ofType:@"json"];
    frankfurtGermanJson = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error: NULL];
    NSLog(@"%@", frankfurtGermanJson);
    
    filePath = [[NSBundle mainBundle] pathForResource:@"spanish_live_json_1886" ofType:@"json"];
    frankfurtSpanishJson = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error: NULL];
    NSLog(@"%@", frankfurtSpanishJson);
    
    NSString *jsonString;
    
    switch (tagForLanguage) {
        case ENGLISH_TAG:
            jsonString = [frankfurtEnglishJson stringByReplacingOccurrencesOfString:@"res/" withString:@""];
            break;
            
        case GERMAN_TAG:
            jsonString = [frankfurtGermanJson stringByReplacingOccurrencesOfString:@"res/" withString:@""];
            break;
            
        case SPANISH_TAG:
            jsonString = [frankfurtSpanishJson stringByReplacingOccurrencesOfString:@"res/" withString:@""];
            break;
            
        case TAMIL_TAG:
            jsonString = angryBirdsTamilJsonString;
            break;
            
        case ANGRYBIRDS_ENGLISH_TAG: {
            jsonString = angryBirdsEnglishJsonString;
        }
            break;
            
        default:
            break;
    }
    
    /*if (tagForLanguage == TAMIL_TAG) {
        jsonString = angryBirdsTamilJsonString;
    } else {
        jsonString = angryBirdsEnglishJsonString;
    }*/
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    arrayOfPages = [[NSMutableArray alloc] initWithArray:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    NSLog(@"number of pages: %d", [arrayOfPages count]);
    [self processJson:[arrayOfPages objectAtIndex:1]];
    
    [self populateBackgroundImagesArray];
    [self createPageWithPageNumber:0];

}

@end
