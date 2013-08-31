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
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>

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
#define TAMIL_TAG 10
#define MALAY_TAG 12
#define CHINESE_TAG 11

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
         accordion.frame = CGRectMake(0, 0, 200, self.view.frame.size.height);
         [showScrollViewButton setFrame:CGRectMake(accordion.frame.origin.x + accordion.frame.size.width, 0, 44, 44)];
     }];
    showScrollViewButton.tag = 1;
}

- (void)hidePageScrollView {
    [UIView
     animateWithDuration:0.2
     animations:^{
         accordion.frame = CGRectMake(-200, 0, 200, self.view.frame.size.height);
         [showScrollViewButton setFrame:CGRectMake(accordion.frame.origin.x + accordion.frame.size.width, 0, 44, 44)];
     }];
    showScrollViewButton.tag = 0;
}

- (void)createTextBoxAtPoint:(CGPoint)textCenterPoint {
    
}

#pragma mark - PageBackgroundImageView Delegate Method

- (void)replaceImageAtIndex:(NSInteger)index withImage:(UIImage *)image {
    [backgroundImagesArray replaceObjectAtIndex:index withObject:image];
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
    [recordAudioButton setFrame:CGRectMake(paintPalletView.frame.origin.x - 44, 60, 44, 44)];
    [[recordAudioButton layer] removeAllAnimations];
}

- (void)animateRecordButton {
    [UIView animateWithDuration:0.7 delay:0.0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse animations:^{
        recordAudioButton.frame = CGRectMake(recordAudioButton.frame.origin.x - 3, recordAudioButton.frame.origin.y - 3, recordAudioButton.frame.size.width + 6, recordAudioButton.frame.size.height + 6);
    } completion:NULL];
}

// Commented Audio recording. The feature has been abstracted to AudioRecordingViewController.
/*
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

}

- (void)stopPlaying
{
    NSLog(@"stopPlaying");
    [audioPlayer stop];
    NSLog(@"stopped");
    [playButton setImage:[UIImage imageNamed:@"play-control.png"] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playRecording) forControlEvents:UIControlEventTouchUpInside];
}
/////------------------------/////


- (void)stopRecording:(id)sender {
    UIButton *stopButton = (UIButton *)sender;
    [stopButton removeFromSuperview];
    [self stopAnimatingRecordButton];
    [self stopRecording];
    
    if (!playButton) {
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
    }
    [playButton addTarget:self action:@selector(playRecording) forControlEvents:UIControlEventTouchUpInside];
    if (![[self.view subviews] containsObject:playButton]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *recDir = [paths objectAtIndex:0];
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sampleRecord_%d.caf", recDir, backgroundImageView.indexOfThisImage]];
        NSString *path = [url path];
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
        if (data) {
            [self.view addSubview:playButton];
            [self.view bringSubviewToFront:playButton];
            [self.view bringSubviewToFront:paintPalletView];
        }
    }
}

- (void)recordAudio {
    [self stopPlaying];
    
    [recordAudioButton setImage:[UIImage imageNamed:@"start-recording-control.png"] forState:UIControlStateNormal];
    [self animateRecordButton];
    
    UIButton *stopRecordingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [stopRecordingButton setFrame:CGRectMake(recordAudioButton.frame.origin.x - 44 - 15, 60, 44, 44)];
    [stopRecordingButton setImage:[UIImage imageNamed:@"stop-recording-control.png"] forState:UIControlStateNormal];
    [stopRecordingButton setUserInteractionEnabled:YES];
    [[stopRecordingButton layer] setMasksToBounds:NO];
    [[stopRecordingButton layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[stopRecordingButton layer] setShadowOffset:CGSizeMake(-3, -3)];
    [[stopRecordingButton layer] setShadowOpacity:0.3f];
    [[stopRecordingButton layer] setShadowRadius:5];
    [[stopRecordingButton layer] setShouldRasterize:YES];
    [stopRecordingButton addTarget:self action:@selector(stopRecording:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopRecordingButton];
    [self.view bringSubviewToFront:stopRecordingButton];
    
    if (playButton) {
        [playButton removeFromSuperview];
    }
    
    [self startRecording];

}
*/

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
    
    //Create new page thumbnail in scroll view
    CGFloat minContentHeight = MAX(pageScrollView.frame.size.height, [arrayOfPages count]*150);
    pageScrollView.contentSize = CGSizeMake(pageScrollView.frame.size.width, minContentHeight);

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
            
            [pageScrollView addSubview:pageButton];
            
            CGFloat minContentHeight = MAX(pageScrollView.frame.size.height, ([arrayOfPages count]+1)*150);
            pageScrollView.contentSize = CGSizeMake(pageScrollView.frame.size.width, minContentHeight);
            // Add New Page Button
            if (addNewPageButton) {
                [addNewPageButton removeFromSuperview];
            }
            [self creatAddNewPageButton];
            //Display newly created page
            [self createPageWithPageNumber:[arrayOfPages count]-1];
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
                [photoPopoverController presentPopoverFromRect:CGRectMake(0, 0, 44, 44) inView:cameraButton permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
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
                [backgroundImageView drawSticker:viewImage inRect:[stickerView convertRect:subview.frame toView:self.view] WithTranslation:translatePoint AndRotation:-rotateAngle];
            }
            [stickerView removeFromSuperview];
            break;
        }
    }
    
}

- (void)addImageForButton:(UIButton *)button {
    if ([[self.view subviews] containsObject:stickerView]) {
        [self addAssetToView];
    }
    
    [assetPopoverController dismissPopoverAnimated:YES];
    NSArray *arrayOfImageNames = [NSArray arrayWithObjects:@"1-leaf.png", @"2-Grass.png", @"3-leaves.png", @"10-leaves.png", @"11-leaves.png", @"A.png", @"B.png", @"bamboo-01.png", @"bamboo-02.png", @"bambu-01.png", @"bambu-02.png", @"bambu.png", @"Branch_01.png", @"C.png", @"coconut tree.png", @"grass1.png", @"hills-01.png", @"hills-02.png", @"hills-03.png", @"leaf-02", @"mushroom_01.png", @"mushroom_02.png", @"mushroom_03.png", @"mushroom_04.png", @"rock_01.png", @"rock_02.png", @"rock_03.png", @"rock_04.png", @"rock_05.png", @"rock_06.png", @"rock_07.png", @"rock_08.png", @"rock_09.png", @"rock-10.png", @"rock_11.png", @"rock_12.png", @"tree2.png", nil];
    
    stickerView = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x - 90, self.view.center.y - 90, 140, 180)];
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
    
    [self.view addSubview:stickerView];
    
    rotateAngle = 0;
    translatePoint = stickerView.center;
}

- (void)showAssets {
    NSLog(@"Show Assets");
    UIScrollView *assetsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 250, 500)];
    assetsScrollView.backgroundColor = [UIColor whiteColor];
    [assetsScrollView setUserInteractionEnabled:YES];
    CGFloat minContentHeight = MAX(assetsScrollView.frame.size.height, 37*150);
    assetsScrollView.contentSize = CGSizeMake(assetsScrollView.frame.size.width, minContentHeight);
    UIViewController *scrollViewController = [[UIViewController alloc] init];
    [scrollViewController.view setFrame:CGRectMake(0, 0, 250, 500)];
    [scrollViewController.view addSubview:assetsScrollView];
    
    NSArray *arrayOfImageNames = [NSArray arrayWithObjects:@"1-leaf.png", @"2-Grass.png", @"3-leaves.png", @"10-leaves.png", @"11-leaves.png", @"A.png", @"B.png", @"bamboo-01.png", @"bamboo-02.png", @"bambu-01.png", @"bambu-02.png", @"bambu.png", @"Branch_01.png", @"C.png", @"coconut tree.png", @"grass1.png", @"hills-01.png", @"hills-02.png", @"hills-03.png", @"leaf-02", @"mushroom_01.png", @"mushroom_02.png", @"mushroom_03.png", @"mushroom_04.png", @"rock_01.png", @"rock_02.png", @"rock_03.png", @"rock_04.png", @"rock_05.png", @"rock_06.png", @"rock_07.png", @"rock_08.png", @"rock_09.png", @"rock-10.png", @"rock_11.png", @"rock_12.png", @"tree2.png", nil];
    for (NSString *imageName in arrayOfImageNames) {
        UIImage *image = [UIImage imageNamed:imageName];
        UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [imageButton setImage:image forState:UIControlStateNormal];
        [imageButton setFrame:CGRectMake(65, [arrayOfImageNames indexOfObject:imageName]*150 + 15, 120, 120)];
        imageButton.tag = [arrayOfImageNames indexOfObject:imageName];
        [imageButton addTarget:self action:@selector(addImageForButton:) forControlEvents:UIControlEventTouchUpInside];
        [assetsScrollView addSubview:imageButton];
    }
    
    assetPopoverController = [[UIPopoverController alloc] initWithContentViewController:scrollViewController];
    [assetPopoverController setPopoverContentSize:CGSizeMake(250, 500)];
    assetPopoverController.delegate = self;
    [assetPopoverController presentPopoverFromRect:assetsButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}

#pragma mark - Prepare UI

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
    [self.view addSubview:brushMenu];
    
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

- (void)setupButton:(UIButton *)button withImage:(UIImage *)buttonImage belowButton:(UIView *)upperButton {
    CGFloat originY = 0;
    if (upperButton) {
        originY = upperButton.frame.origin.y + 60;
    }
    [button setFrame:CGRectMake(paintPalletView.frame.origin.x - 44, originY, 44, 44)];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [[button layer] setCornerRadius:button.frame.size.height/20];
    [button setUserInteractionEnabled:YES];
    [[button layer] setMasksToBounds:NO];
    [[button layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[button layer] setShadowOffset:CGSizeMake(-3, -3)];
    [[button layer] setShadowOpacity:0.3f];
    [[button layer] setShadowRadius:5];
    [[button layer] setShouldRasterize:YES];
    [self.view addSubview:button];
    [self.view bringSubviewToFront:button];
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

- (void)createToolView {
    // Show Scroll View Button
    [self createScrollViewButton];
    
    // Camera Button
    cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:cameraButton withImage:[UIImage imageNamed:@"camera_gray_round.png"] belowButton:nil];
    [cameraButton addTarget:self action:@selector(cameraButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    // Record Audio Button
    recordAudioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:recordAudioButton withImage:[UIImage imageNamed:@"record-control.png"] belowButton:cameraButton];
    [recordAudioButton addTarget:self action:@selector(showAudioControl) forControlEvents:UIControlEventTouchUpInside];
    
    // Eraser Button
    eraserButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:eraserButton withImage:[UIImage imageNamed:@"eraser.png"] belowButton:recordAudioButton];
    eraserButton.tag = ERASER_BUTTON_TAG;
    [eraserButton addTarget:self action:@selector(paintButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // Assets Button
    assetsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setupButton:assetsButton withImage:[UIImage imageNamed:@"insert_image.png"] belowButton:brushMenu];
    [assetsButton setFrame:CGRectMake(assetsButton.frame.origin.x, brushMenu.startPoint.y + 60, assetsButton.frame.size.width, assetsButton.frame.size.height)];
    [assetsButton addTarget:self action:@selector(showAssets) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view bringSubviewToFront:pageScrollView];

    
    accordion = [[AccordionView alloc] initWithFrame:CGRectMake(-200, 0, 200, [[UIScreen mainScreen] bounds].size.height)];
    
    [self.view addSubview:accordion];
    self.view.backgroundColor = [UIColor colorWithRed:0.925 green:0.941 blue:0.945 alpha:1.000];
    
    // Only height is taken into account, so other parameters are just dummy
    UIButton *header1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
    [header1 setTitle:@"Pages" forState:UIControlStateNormal];
    header1.backgroundColor = [UIColor blackColor];
    // Pages List View
    pageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 200, self.view.frame.size.height - 90)];
    [self setupScrollView:pageScrollView withImage:[UIImage imageNamed:@"topdot.png"]];
    [[pageScrollView layer] setShadowOffset:CGSizeMake(3, 3)];
    [accordion addHeader:header1 withView:pageScrollView];
    
    UIButton *header2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
    [header2 setTitle:@"Drawing Tools" forState:UIControlStateNormal];
    header2.backgroundColor = [UIColor blackColor];
    // Paint Pallet Round Menu
    paintMenu = [self createPaintPalletView];
    // Brush Menu
    brushMenu = [self createBrushMenu];
    UIView *paintBrushMenu = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, self.view.frame.size.height - 90)];
    [paintBrushMenu setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"topdot.png"]]];
    [paintBrushMenu addSubview:paintMenu];
    [paintBrushMenu addSubview:brushMenu];
    [accordion addHeader:header2 withView:paintBrushMenu];
    
    UIButton *header3 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
    [header3 setTitle:@"Assets" forState:UIControlStateNormal];
    header3.backgroundColor = [UIColor blackColor];
    UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.view.frame.size.height - 90)];
    view3.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"topdot.png"]];
    [accordion addHeader:header3 withView:view3];
    
    [accordion setNeedsLayout];
    // Set this if you want to allow multiple selection
    [accordion setAllowsMultipleSelection:NO];
}

- (void)createInitialUI {
    UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo1.png"]];
    self.navigationItem.titleView=imageView;
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];

    backgroundImageView = [[SmoothDrawingView alloc] initWithFrame:self.view.frame];
    backgroundImageView.delegate = self;
    // Temporarily adding fixed image
    [self.view addSubview:backgroundImageView];
    
    // Text View
    mainTextView = [[MovableTextView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x + 20, self.view.frame.origin.y + 20, self.view.frame.size.width/3, self.view.frame.size.height/4)];
    mainTextView.tag = MAIN_TEXTVIEW_TAG;
    mainTextView.textColor = [UIColor blackColor];
    mainTextView.font = [UIFont boldSystemFontOfSize:24];
    [self.view addSubview:mainTextView];
        
    [self createToolView];
}

- (void)createPageWithPageNumber:(NSInteger)pageNumber {
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
                
                [backgroundImageView removeFromSuperview];
                UIWebView *widgetWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
                
                if (tagForLanguage == ENGLISH_TAG) {
                    NSLog(@"%@", [NSString stringWithFormat:@"/%d/%@", [[layerDict objectForKey:@"wid"] intValue], [layerDict objectForKey:@"slug"]]);
                    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:[NSString stringWithFormat:@"/%d/%@", [[layerDict objectForKey:@"wid"] intValue], [layerDict objectForKey:@"slug"]]]];
                    [widgetWebView loadRequest:[NSURLRequest requestWithURL:url]];
                } else if (tagForLanguage == TAMIL_TAG) {
                    NSLog(@"%@", [NSString stringWithFormat:@"/widgets/%d/%@", [[layerDict objectForKey:@"wid"] intValue], [layerDict objectForKey:@"slug"]]);
                    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:[NSString stringWithFormat:@"/widgets/%d/%@", [[layerDict objectForKey:@"wid"] intValue], [layerDict objectForKey:@"slug"]]]];
                    [widgetWebView loadRequest:[NSURLRequest requestWithURL:url]];
                }
                
                [self.view addSubview:widgetWebView];
                
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
            if (![self.view.subviews containsObject:backgroundImageView]) {
                // Temporarily adding fixed image
                [self.view addSubview:backgroundImageView];
            }
            
            if ([backgroundImagesArray objectAtIndex:pageNumber]) {
                backgroundImageView.incrementalImage = [backgroundImagesArray objectAtIndex:pageNumber];
                backgroundImageView.tempImage = [backgroundImagesArray objectAtIndex:pageNumber];
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
        
        UIButton *pageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [pageButton setImage:[UIImage imageNamed:[imageDict objectForKey:@"url"]] forState:UIControlStateNormal];
        [pageButton addTarget:self action:@selector(createPageForSender:) forControlEvents:UIControlEventTouchUpInside];
        CGFloat yOffsetForButton = [arrayOfPages indexOfObject:newPageDict]*150;
        [pageButton setFrame:CGRectMake(15, 15 + yOffsetForButton, 160, 120)];
        pageButton.tag = [backgroundImagesArray count] - 1;
        [[pageButton layer] setMasksToBounds:NO];
        [[pageButton layer] setShadowColor:[[UIColor blackColor] CGColor]];
        [[pageButton layer] setShadowOffset:CGSizeMake(10, 10)];
        [[pageButton layer] setShadowOpacity:0.3f];
        [[pageButton layer] setShadowRadius:2];
        [[pageButton layer] setShouldRasterize:YES];
        [pageScrollView addSubview:pageButton];
        
        CGFloat minContentHeight = MAX(pageScrollView.frame.size.height, ([arrayOfPages count]+1)*150);
        pageScrollView.contentSize = CGSizeMake(pageScrollView.frame.size.width, minContentHeight);
        // Add New Page Button
        if (addNewPageButton) {
            [addNewPageButton removeFromSuperview];
        }
        [self creatAddNewPageButton];
        [self createPageWithPageNumber:pageNumber];
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
    [self hidePageScrollView];
    [self hidePaintPalletView];
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

- (void)createScrollView {
    CGFloat minContentHeight = MAX(pageScrollView.frame.size.height, ([arrayOfPages count]+1)*150);
    pageScrollView.contentSize = CGSizeMake(pageScrollView.frame.size.width, minContentHeight);
    for (NSDictionary *dictionaryForPage in arrayOfPages) {
        for (NSDictionary *layerDict in [dictionaryForPage objectForKey:@"layers"]) {
            if ([[layerDict objectForKey:@"type"] isEqualToString:@"capturedImage"]) {
                if (!backgroundImagesArray) {
                    backgroundImagesArray = [[NSMutableArray alloc] init];
                }
                
                NSURL *asseturl = [layerDict objectForKey:@"url"];
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
                         CGFloat yOffsetForButton = [arrayOfPages indexOfObject:dictionaryForPage]*150;
                         [pageButton setFrame:CGRectMake(15, 15 + yOffsetForButton, 160, 120)];
                         pageButton.tag = [backgroundImagesArray indexOfObject:image];
                         
                         [[pageButton layer] setMasksToBounds:NO];
                         [[pageButton layer] setShadowColor:[[UIColor blackColor] CGColor]];
                         [[pageButton layer] setShadowOffset:CGSizeMake(10, 10)];
                         [[pageButton layer] setShadowOpacity:0.3f];
                         [[pageButton layer] setShadowRadius:2];
                         [[pageButton layer] setShouldRasterize:YES];
                         
                         [pageScrollView addSubview:pageButton];
                     }
                 } failureBlock:^(NSError *myerror) {
                     NSLog(@"Booya, cant get image - %@",[myerror localizedDescription]);
                 }];

            } else if ([[layerDict objectForKey:@"type"] isEqualToString:@"image"]) {
                
                if (!backgroundImagesArray) {
                    backgroundImagesArray = [[NSMutableArray alloc] init];
                }
                [backgroundImagesArray addObject:[UIImage imageNamed:[layerDict objectForKey:@"url"]]];
                
                UIButton *pageButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [pageButton setImage:[UIImage imageNamed:[layerDict objectForKey:@"url"]] forState:UIControlStateNormal];
                [pageButton addTarget:self action:@selector(createPageForSender:) forControlEvents:UIControlEventTouchUpInside];
                CGFloat yOffsetForButton = [arrayOfPages indexOfObject:dictionaryForPage]*150;
                [pageButton setFrame:CGRectMake(15, 15 + yOffsetForButton, 160, 120)];
                pageButton.tag = [backgroundImagesArray indexOfObject:[UIImage imageNamed:[layerDict objectForKey:@"url"]]];
                
                [[pageButton layer] setMasksToBounds:NO];
                [[pageButton layer] setShadowColor:[[UIColor blackColor] CGColor]];
                [[pageButton layer] setShadowOffset:CGSizeMake(10, 10)];
                [[pageButton layer] setShadowOpacity:0.3f];
                [[pageButton layer] setShadowRadius:2];
                [[pageButton layer] setShouldRasterize:YES];
                
                [pageScrollView addSubview:pageButton];
                
            } else if ([[layerDict objectForKey:@"type"] isEqualToString:@"widget"]) {
                if (!backgroundImagesArray) {
                    backgroundImagesArray = [[NSMutableArray alloc] init];
                }
                [backgroundImagesArray addObject:[[UIImage alloc] init]];
                
                UIButton *pageButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [pageButton addTarget:self action:@selector(createPageForSender:) forControlEvents:UIControlEventTouchUpInside];
                CGFloat yOffsetForButton = [arrayOfPages indexOfObject:dictionaryForPage]*150;
                [pageButton setFrame:CGRectMake(15, 15 + yOffsetForButton, 160, 120)];
                pageButton.tag = [backgroundImagesArray count]-1;
                
                [[pageButton layer] setMasksToBounds:NO];
                [[pageButton layer] setShadowColor:[[UIColor blackColor] CGColor]];
                [[pageButton layer] setShadowOffset:CGSizeMake(10, 10)];
                [[pageButton layer] setShadowOpacity:0.3f];
                [[pageButton layer] setShadowRadius:2];
                [[pageButton layer] setShouldRasterize:YES];
                
                if ([[layerDict objectForKey:@"wid"] intValue] == 4 || [[layerDict objectForKey:@"wid"] intValue] == 7) {
                    [pageButton setImage:[UIImage imageNamed:@"page1.jpg"] forState:UIControlStateNormal];
                } else if ([[layerDict objectForKey:@"wid"] intValue] == 5 || [[layerDict objectForKey:@"wid"] intValue] == 8) {
                    [pageButton setImage:[UIImage imageNamed:@"3.jpg"] forState:UIControlStateNormal];
                } else if ([[layerDict objectForKey:@"wid"] intValue] == 6 || [[layerDict objectForKey:@"wid"] intValue] == 9) {
                    [pageButton setImage:[UIImage imageNamed:@"q1.jpg"] forState:UIControlStateNormal];
                }
                
                [pageScrollView addSubview:pageButton];

            }
        }
    }
    
    // Add New Page Button
    [self creatAddNewPageButton];
}

#pragma mark - Parsing Book Json

- (void)getBookJson {
    // Temporarily adding hardcoded string
    angryBirdsTamilJsonString = @"[{\"id\":\"Cover\",\"name\":\"Cover\",\"layers\":[{\"type\":\"image\",\"url\":\"abad124338.jpg\",\"alignment\":\"left\",\"order\":0,\"name\":\"\"}],\"order\":0,\"pageNo\":1,\"original_id\":747,\"child\":\"jigsaw\"},{\"id\":1,\"name\":1,\"layers\":[{\"type\":\"image\",\"url\":\"21833583e6.jpg\",\"alignment\":\"middle\",\"order\":0,\"name\":\"\"},{\"type\":\"text\",\"alignment\":\"left\",\"order\":0,\"name\":\"\"},{\"type\":\"audio\",\"url\":\"671db6ad7f.mp3\",\"wordTimes\":[2.4927539825439453,3.2448489665985107,4.247387886047363,4.749120235443115,5.000740051269531],\"wordMap\":[{\"word\":\"சுந்தரம்\",\"step\":25,\"wordIdx\":1},{\"word\":\"தினமும்\",\"step\":32,\"wordIdx\":2},{\"word\":\"கணினி\",\"step\":42,\"wordIdx\":3},{\"word\":\"விளையாட்டு\",\"step\":47,\"wordIdx\":4},{\"word\":\"விளையாடுவான்.\",\"step\":50,\"wordIdx\":5}],\"order\":0,\"name\":\"\"}],\"order\":0,\"pageNo\":1,\"original_id\":748},{\"id\":2,\"name\":2,\"layers\":[{\"type\":\"image\",\"url\":\"50d0f84f99.jpg\",\"alignment\":\"middle\",\"order\":0,\"name\":\"\"},{\"type\":\"text\",\"alignment\":\"left\",\"order\":0,\"name\":\"\"},{\"type\":\"audio\",\"url\":\"d13bba5005.mp3\",\"wordTimes\":[1.2127419710159302,1.9000000000000001,2.725771903991699,3.4780259132385254,3.981329917907715,5.232964038848877,6.485886096954346,7,7.489037990570068,7.9,8.200000000000001,8.8,9.243943214416504],\"wordMap\":[{\"word\":\"ஒருநாள்\",\"step\":12,\"wordIdx\":1},{\"word\":\"அவன்\",\"step\":19,\"wordIdx\":2},{\"word\":\"வீட்டில்\",\"step\":27,\"wordIdx\":3},{\"word\":\"யாரும்\",\"step\":35,\"wordIdx\":4},{\"word\":\"இல்லை.\",\"step\":40,\"wordIdx\":5},{\"word\":\"அப்போது\",\"step\":52,\"wordIdx\":6},{\"word\":\"சுந்தரம்\",\"step\":65,\"wordIdx\":7},{\"word\":\" “கோபமான\",\"step\":70,\"wordIdx\":8},{\"word\":\"குருவி”\",\"step\":75,\"wordIdx\":9},{\"word\":\"என்ற\",\"step\":79,\"wordIdx\":10},{\"word\":\"விளையாட்டை\",\"step\":82,\"wordIdx\":11},{\"word\":\"விளையாடிக்\",\"step\":88,\"wordIdx\":12},{\"word\":\"கொண்டிருந்தான்.\",\"step\":92,\"wordIdx\":13}],\"order\":0,\"name\":\"\"}],\"order\":0,\"pageNo\":1,\"original_id\":749},{\"id\":3,\"name\":3,\"layers\":[{\"type\":\"image\",\"url\":\"a8fc0e26ef.jpg\",\"alignment\":\"middle\",\"order\":0,\"name\":\"\"},{\"type\":\"text\",\"alignment\":\"left\",\"order\":0,\"name\":\"\"},{\"type\":\"audio\",\"url\":\"bd026a2f3b.mp3\",\"wordTimes\":null,\"wordMap\":[{\"word\":\"அப்போது\",\"step\":12,\"wordIdx\":1},{\"word\":\"ஏதோ\",\"step\":19,\"wordIdx\":2},{\"word\":\"சத்தம்\",\"step\":27,\"wordIdx\":3},{\"word\":\"கேட்டது\",\"step\":35,\"wordIdx\":4},{\"word\":\"அவன்.\",\"step\":40,\"wordIdx\":5},{\"word\":\"திரும்பிப்\",\"step\":52,\"wordIdx\":6},{\"word\":\"பார்த்தான்.\",\"step\":65,\"wordIdx\":7}],\"order\":0,\"name\":\"\"}],\"order\":0,\"pageNo\":1,\"original_id\":750},{\"id\":4,\"name\":4,\"layers\":[{\"type\":\"image\",\"url\":\"685dcbd3db.jpg\",\"alignment\":\"middle\",\"order\":0,\"name\":\"\"},{\"type\":\"text\",\"alignment\":\"left\",\"order\":0,\"name\":\"\"},{\"type\":\"audio\",\"url\":\"515c992c1b.mp3\",\"wordTimes\":null,\"wordMap\":[{\"word\":\"அங்கே\",\"step\":12,\"wordIdx\":1},{\"word\":\"அவன்\",\"step\":19,\"wordIdx\":2},{\"word\":\"வீட்டுச்\",\"step\":27,\"wordIdx\":3},{\"word\":\"சன்னல்\",\"step\":35,\"wordIdx\":4},{\"word\":\"பக்கத்தில்\",\"step\":40,\"wordIdx\":5},{\"word\":\"நான்கு\",\"step\":52,\"wordIdx\":6},{\"word\":\"பறவைகள்\",\"step\":65,\"wordIdx\":7},{\"word\":\"உட்கார்ந்து\",\"step\":35,\"wordIdx\":8},{\"word\":\"இருந்தன.\",\"step\":40,\"wordIdx\":9},{\"word\":\"அவை\",\"step\":52,\"wordIdx\":10},{\"word\":\"அவனைக்\",\"step\":65,\"wordIdx\":11},		{\"word\":\"கோபமாகப்\",\"step\":52,\"wordIdx\":12},{\"word\":\"பார்த்தன.\",\"step\":65,\"wordIdx\":13}],\"order\":0,\"name\":\"\"}],\"order\":0,\"pageNo\":1,\"original_id\":752},{\"id\":5,\"name\":6,\"layers\":[{\"type\":\"widget\",\"wid\":\"5\",\"slug\":\"Where_is_sundaram\",\"order\":0,\"name\":\"\"}],\"order\":0,\"pageNo\":1,\"type\":\"widget\",\"original_id\":760},{\"id\":6,\"name\":5,\"layers\":[{\"type\":\"widget\",\"wid\":\"4\",\"slug\":\"where_is_bird\",\"order\":0,\"name\":\"\"}],\"order\":0,\"pageNo\":1,\"type\":\"widget\",\"original_id\":761},{\"id\":7,\"name\":7,\"layers\":[{\"type\":\"widget\",\"wid\":\"6\",\"slug\":\"widget3\",\"order\":0,\"name\":\"\"}],\"order\":0,\"pageNo\":1,\"type\":\"widget\",\"original_id\":762},{\"id\":\"jigsaw\",\"name\":\"jigsaw\",\"layers\":[{\"type\":\"image\",\"url\":\"a8fc0e26ef.jpg\",\"order\":0,\"name\":\"\"}],\"type\":\"game\",\"pageid\":\"Cover\",\"order\":0,\"pageNo\":1,\"original_id\":775}]";
    
    angryBirdsEnglishJsonString = @"[{\"id\": \"Cover\",\"name\": \"Cover\",\"layers\": [{\"type\": \"image\",\"url\": \"8517823664.jpg\",\"alignment\": \"left\",\"order\": 0,\"name\": \"\"}],\"order\": 0,\"pageNo\": 1,\"original_id\": 763},{\"id\": 1,\"name\": 1,\"layers\": [{\"type\": \"image\",\"url\": \"21833583e6.jpg\",\"alignment\": \"middle\",\"order\": 0,\"name\": \"\"},{\"type\": \"text\",\"text\": \"Sundaram utilizar para jugar juegos de computadora todo el día.\",\"alignment\": \"left\",\"order\": 0,\"name\": \"\",\"language\": \"es\"},{\"type\": \"audio\",\"url\": \"f9c3d294be.mp3\",\"wordTimes\": [0.6199439764022827,1.1206820011138916,1.4000000000000001,1.6,1.9000000000000001,2.2,2.7],\"wordMap\": [{\"word\": \"Sundaram\",\"step\": 6,\"wordIdx\": 1},{\"word\": \"used\",\"step\": 11,\"wordIdx\": 2},{\"word\": \"to\",\"step\": 14,\"wordIdx\": 3},{\"word\": \"play\",\"step\": 16,\"wordIdx\": 4},{\"word\": \"computer\",\"step\": 19,\"wordIdx\": 5},{\"word\": \"games\",\"step\": 22,\"wordIdx\": 6},{\"word\": \"everyday.\",\"step\": 27,\"wordIdx\": 7}],\"order\": 0,\"name\": \"\"},{\"type\": \"original_text\",\"text\": \"Sundaram used to play computer games all day.\",\"language\": \"en\",\"order\": 0,\"name\": \"\"}],\"order\": 0,\"pageNo\": 1,\"original_id\": 764},{\"id\": 2,\"name\": 2,\"layers\": [{\"type\": \"image\",\"url\": \"50d0f84f99.jpg\",\"alignment\": \"middle\",\"order\": 0,\"name\": \"\"},{\"type\": \"text\",\"alignment\": \"left\",\"order\": 0,\"name\": \"\"},{\"type\": \"audio\",\"url\": \"23a68f3938.mp3\",\"wordTimes\": [0.41754600405693054,0.6674889922142029,1.173475980758667,1.4266209602355957,1.679677963256836,1.9314359426498413,2.1820950508117676,2.4327518939971924,2.9337239265441895,3.18544602394104,3.9370460510253906,4.187881946563721,4.438592910766602,4.7,4.9],\"wordMap\": [{\"word\": \"One\",\"step\": 4,\"wordIdx\": 1},{\"word\": \"day\",\"step\": 7,\"wordIdx\": 2},{\"word\": \"he\",\"step\": 12,\"wordIdx\": 3},{\"word\": \"is\",\"step\": 14,\"wordIdx\": 4},{\"word\": \"playing\",\"step\": 17,\"wordIdx\": 5},{\"word\": \"a\",\"step\": 19,\"wordIdx\": 6},{\"word\": \"game\",\"step\": 22,\"wordIdx\": 7},{\"word\": \"called\",\"step\": 24,\"wordIdx\": 8},{\"word\": \"Angry\",\"step\": 29,\"wordIdx\": 9},{\"word\": \"birds\",\"step\": 32,\"wordIdx\": 10},{\"word\": \"when\",\"step\": 39,\"wordIdx\": 11},{\"word\": \"no\",\"step\": 42,\"wordIdx\": 12},{\"word\": \"one\",\"step\": 44,\"wordIdx\": 13},{\"word\": \"is\",\"step\": 47,\"wordIdx\": 14},{\"word\": \"around.\",\"step\": 49,\"wordIdx\": 15}],\"order\": 0,\"name\": \"\"}],\"order\": 0,\"pageNo\": 1,\"original_id\": 765},{\"id\": 3,\"name\": 3,\"layers\": [{\"type\": \"image\",\"url\": \"a8fc0e26ef.jpg\",\"alignment\": \"middle\",\"order\": 0,\"name\": \"\"},{\"type\": \"text\",\"alignment\": \"left\",\"order\": 0,\"name\": \"\"},{\"type\": \"audio\",\"url\": \"64d4de5ec4.mp3\",\"wordTimes\": [0.4,0.9,1,1.3,1.6,1.957522988319397,2.2085559368133545,2.2085559368133545,3.2106990814208984,3.4614439010620117,3.711867094039917,3.9624791145324707,4.213839054107666,4.4638590812683105,4.720414161682129,4.965227127075195],\"wordMap\": [{\"word\": \"And\",\"step\": 4,\"wordIdx\": 1},{\"word\": \"he\",\"step\": 9,\"wordIdx\": 2},{\"word\": \"heard\",\"step\": 10,\"wordIdx\": 3},{\"word\": \"some\",\"step\": 13,\"wordIdx\": 4},{\"word\": \"noise\",\"step\": 16,\"wordIdx\": 5},{\"word\": \"near\",\"step\": 20,\"wordIdx\": 6},{\"word\": \"the\",\"step\": 22,\"wordIdx\": 7},{\"word\": \"window,\",\"step\": 22,\"wordIdx\": 8},{\"word\": \"he\",\"step\": 32,\"wordIdx\": 9},{\"word\": \"turned\",\"step\": 35,\"wordIdx\": 10},{\"word\": \"from\",\"step\": 37,\"wordIdx\": 11},{\"word\": \"game\",\"step\": 40,\"wordIdx\": 12},{\"word\": \"and\",\"step\": 42,\"wordIdx\": 13},{\"word\": \"looked\",\"step\": 45,\"wordIdx\": 14},{\"word\": \"at\",\"step\": 47,\"wordIdx\": 15},{\"word\": \"it.\",\"step\": 50,\"wordIdx\": 16}],\"order\": 0,\"name\": \"\"}],\"order\": 0,\"pageNo\": 1,\"original_id\": 766},{\"id\": 4,\"name\": 4,\"layers\": [{\"type\": \"image\",\"url\": \"685dcbd3db.jpg\",\"alignment\": \"middle\",\"order\": 0,\"name\": \"\"},{\"type\": \"text\",\"alignment\": \"left\",\"order\": 0,\"name\": \"\"},{\"type\": \"audio\",\"url\": \"f3905b0506.mp3\",\"wordTimes\": [0.6486089825630188,0.8334199786186218,1.2000000000000002,1.6,1.9000000000000001,2.5,2.943850040435791,3.1125309467315674,3.3000000000000003,3.5,3.8000000000000003,4.170816898345947,5.1000000000000005,5.4,5.742791175842285,6.095162868499756,6.443782806396484,6.976383209228516],\"wordMap\": [{\"word\": \"Four\",\"step\": 6,\"wordIdx\": 1},{\"word\": \"birds\",\"step\": 8,\"wordIdx\": 2},{\"word\": \"were\",\"step\": 12,\"wordIdx\": 3},{\"word\": \"sitting\",\"step\": 16,\"wordIdx\": 4},{\"word\": \"there\",\"step\": 19,\"wordIdx\": 5},{\"word\": \"on\",\"step\": 25,\"wordIdx\": 6},{\"word\": \"the\",\"step\": 29,\"wordIdx\": 7},{\"word\": \"side\",\"step\": 31,\"wordIdx\": 8},{\"word\": \"of\",\"step\": 33,\"wordIdx\": 9},{\"word\": \"his\",\"step\": 35,\"wordIdx\": 10},{\"word\": \"house\",\"step\": 38,\"wordIdx\": 11},{\"word\": \"window,\",\"step\": 42,\"wordIdx\": 12},{\"word\": \"and\",\"step\": 51,\"wordIdx\": 13},{\"word\": \"staring\",\"step\": 54,\"wordIdx\": 14},{\"word\": \"at\",\"step\": 57,\"wordIdx\": 15},{\"word\": \"him\",\"step\": 61,\"wordIdx\": 16},{\"word\": \"very\",\"step\": 64,\"wordIdx\": 17},{\"word\": \"angrily.\",\"step\": 70,\"wordIdx\": 18}],\"order\": 0,\"name\": \"\"}],\"order\": 0,\"pageNo\": 1,\"original_id\": 768},{\"id\": 5,\"name\": 5,\"layers\": [{\"type\": \"widget\",\"wid\": \"7\",\"slug\": \"Where_is_sundaram\",\"order\": 0,\"name\": \"\"}],\"order\": 0,\"pageNo\": 1,\"type\": \"widget\"},{\"id\": 6,\"name\": 6,\"layers\": [{\"type\": \"widget\",\"wid\": \"8\",\"slug\": \"where_is_bird\",\"order\": 0,\"name\": \"\"}],\"order\": 0,\"pageNo\": 1,\"type\": \"widget\",\"original_id\": 773},{\"id\": 7,\"name\": 7,\"layers\": [{\"type\": \"widget\",\"wid\": \"9\",\"slug\": \"widget3\",\"order\": 0,\"name\": \"\"}],\"order\": 0,\"pageNo\": 1,\"type\": \"widget\"}]";
    
    NSString *jsonString;
    if (tagForLanguage == TAMIL_TAG) {
        jsonString = angryBirdsTamilJsonString;
    } else {
        jsonString = angryBirdsEnglishJsonString;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    arrayOfPages = [[NSMutableArray alloc] initWithArray:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    NSLog(@"number of pages: %d", [arrayOfPages count]);
    
    [self createScrollView];
    [self createPageWithPageNumber:0];

}

@end
