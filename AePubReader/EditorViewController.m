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

#define ENGLISH_TAG 9
#define TAMIL_TAG 10
#define MALAY_TAG 12
#define CHINESE_TAG 11

@interface EditorViewController ()

@property (nonatomic, strong) NSMutableArray *arrayOfPages;
@property (nonatomic, strong) UIButton *showScrollViewButton;
@property (nonatomic, strong) UIButton *showPaintPalletButton;
@property (nonatomic, strong) AwesomeMenu *paintMenu;
@property (nonatomic, strong) UIButton *eraserButton;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *recordAudioButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) AudioRecordingViewController *audioRecViewController;
@property (nonatomic, strong) UIPopoverController *photoPopoverController;
@property (nonatomic, strong) NSString *angryBirdsTamilJsonString;
@property (nonatomic, strong) NSString *angryBirdsEnglishJsonString;
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
@synthesize angryBirdsTamilJsonString;
@synthesize angryBirdsEnglishJsonString;
@synthesize tagForLanguage;
@synthesize englishLanguageButton;
@synthesize tamilLanguageButton;
@synthesize paintMenu;

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
    self.tabBarController.tabBar.translucent = NO;

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
         pageScrollView.frame = CGRectMake(0, 0, 150, self.view.frame.size.height);
         [showScrollViewButton setFrame:CGRectMake(pageScrollView.frame.origin.x + pageScrollView.frame.size.width, 0, 44, 44)];
     }];
    showScrollViewButton.tag = 1;
}

- (void)hidePageScrollView {
    [UIView
     animateWithDuration:0.2
     animations:^{
         pageScrollView.frame = CGRectMake(-150, 0, 150, self.view.frame.size.height);
         [showScrollViewButton setFrame:CGRectMake(pageScrollView.frame.origin.x + pageScrollView.frame.size.width, 0, 44, 44)];
     }];
    showScrollViewButton.tag = 0;
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
    UIButton *brushButton = (UIButton *)sender;
    backgroundImageView.selectedBrush = brushButton.tag;
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
            [pageButton setFrame:CGRectMake(10, 15 + yOffsetForButton, 120, 120)];
            pageButton.tag = [backgroundImagesArray indexOfObject:image];
            
            [[pageButton layer] setMasksToBounds:NO];
            [[pageButton layer] setShadowColor:[[UIColor blackColor] CGColor]];
            [[pageButton layer] setShadowOffset:CGSizeMake(10, 10)];
            [[pageButton layer] setShadowOpacity:0.3f];
            [[pageButton layer] setShadowRadius:2];
            [[pageButton layer] setShouldRasterize:YES];
            
            [pageScrollView addSubview:pageButton];
            
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

#pragma mark - Paint Menu Delegate

- (void)awesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx {
    backgroundImageView.selectedColor = idx + 1;
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

- (void)createInitialUI {
    backgroundImageView = [[SmoothDrawingView alloc] initWithFrame:self.view.frame];
    backgroundImageView.delegate = self;
    // Temporarily adding fixed image
    [self.view addSubview:backgroundImageView];
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showPageScrollView)];
    swipeUp.numberOfTouchesRequired = 2;
    swipeUp.direction = UISwipeGestureRecognizerDirectionRight;
    swipeUp.delaysTouchesBegan = YES;
    [backgroundImageView addGestureRecognizer:swipeUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hidePageScrollView)];
    swipeDown.numberOfTouchesRequired = 2;
    swipeDown.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeDown.delaysTouchesBegan = YES;
    [backgroundImageView addGestureRecognizer:swipeDown];
    
    mainTextView = [[MovableTextView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x + 20, self.view.frame.origin.y + 20, self.view.frame.size.width/3, self.view.frame.size.height/4)];
    mainTextView.tag = MAIN_TEXTVIEW_TAG;
    mainTextView.textColor = [UIColor blackColor];
    mainTextView.font = [UIFont boldSystemFontOfSize:24];
    [self.view addSubview:mainTextView];
    
    UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo1.png"]];
    self.navigationItem.titleView=imageView;
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
        
    [pageScrollView setFrame:CGRectMake(-150, 0, 150, self.view.frame.size.height)];
    UIImage *image=[UIImage imageNamed:@"topdot.png"];
    pageScrollView.backgroundColor= [UIColor colorWithPatternImage:image];
    [[pageScrollView layer] setMasksToBounds:NO];
    [[pageScrollView layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[pageScrollView layer] setShadowOffset:CGSizeMake(3, 3)];
    [[pageScrollView layer] setShadowOpacity:0.3f];
    [[pageScrollView layer] setShadowRadius:5];
    [[pageScrollView layer] setShouldRasterize:YES];
    
    [[paintPalletView layer] setMasksToBounds:NO];
    [[paintPalletView layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[paintPalletView layer] setShadowOffset:CGSizeMake(-3, -3)];
    [[paintPalletView layer] setShadowOpacity:0.3f];
    [[paintPalletView layer] setShadowRadius:5];
    [[paintPalletView layer] setShouldRasterize:YES];
    [paintPalletView setBackgroundColor:[UIColor colorWithPatternImage:image]];
    [self.view bringSubviewToFront:paintPalletView];
    
    showScrollViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [showScrollViewButton setFrame:CGRectMake(pageScrollView.frame.origin.x + pageScrollView.frame.size.width, 0, 44, 44)];
    [showScrollViewButton setImage:[UIImage imageNamed:@"mango-icon.png"] forState:UIControlStateNormal];
    //    [showScrollViewButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"topdot.png"]]];
    [[showScrollViewButton layer] setCornerRadius:showScrollViewButton.frame.size.height/20];
    [showScrollViewButton setUserInteractionEnabled:YES];
    [[showScrollViewButton layer] setMasksToBounds:NO];
    [[showScrollViewButton layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[showScrollViewButton layer] setShadowOffset:CGSizeMake(3, 3)];
    [[showScrollViewButton layer] setShadowOpacity:0.3f];
    [[showScrollViewButton layer] setShadowRadius:5];
    [[showScrollViewButton layer] setShouldRasterize:YES];
    showScrollViewButton.tag = pageScrollView.frame.origin.x>0 ? 1:0;
    [showScrollViewButton addTarget:self action:@selector(showOrHideScrollView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showScrollViewButton];
    [self.view bringSubviewToFront:showScrollViewButton];
    
    /*showPaintPalletButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [showPaintPalletButton setFrame:CGRectMake(paintPalletView.frame.origin.x - 44, 0, 44, 44)];
    [showPaintPalletButton setImage:[UIImage imageNamed:@"brush-small.png"] forState:UIControlStateNormal];
    //    [showPaintPalletButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"topdot.png"]]];
    [[showPaintPalletButton layer] setCornerRadius:showPaintPalletButton.frame.size.height/20];
    [showPaintPalletButton setUserInteractionEnabled:YES];
    [[showPaintPalletButton layer] setMasksToBounds:NO];
    [[showPaintPalletButton layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[showPaintPalletButton layer] setShadowOffset:CGSizeMake(-3, -3)];
    [[showPaintPalletButton layer] setShadowOpacity:0.3f];
    [[showPaintPalletButton layer] setShadowRadius:5];
    [[showPaintPalletButton layer] setShouldRasterize:YES];
    showPaintPalletButton.tag = paintPalletView.frame.origin.x<self.view.frame.size.width ? 1:0;
    [showPaintPalletButton addTarget:self action:@selector(showOrHidePaintPalletView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showPaintPalletButton];
    [self.view bringSubviewToFront:showPaintPalletButton];*/
    
    cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraButton setFrame:CGRectMake(paintPalletView.frame.origin.x - 44, 0, 44, 44)];
    [cameraButton setImage:[UIImage imageNamed:@"camera_gray_round.png"] forState:UIControlStateNormal];
    [[cameraButton layer] setCornerRadius:cameraButton.frame.size.height/20];
    [cameraButton setUserInteractionEnabled:YES];
    [[cameraButton layer] setMasksToBounds:NO];
    [[cameraButton layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[cameraButton layer] setShadowOffset:CGSizeMake(-3, -3)];
    [[cameraButton layer] setShadowOpacity:0.3f];
    [[cameraButton layer] setShadowRadius:5];
    [[cameraButton layer] setShouldRasterize:YES];
    [cameraButton addTarget:self action:@selector(cameraButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraButton];
    [self.view bringSubviewToFront:cameraButton];
    
    recordAudioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [recordAudioButton setFrame:CGRectMake(paintPalletView.frame.origin.x - 44, cameraButton.frame.origin.y + 60, 44, 44)];
    [recordAudioButton setImage:[UIImage imageNamed:@"record-control.png"] forState:UIControlStateNormal];
    [recordAudioButton setUserInteractionEnabled:YES];
    [[recordAudioButton layer] setMasksToBounds:NO];
    [[recordAudioButton layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[recordAudioButton layer] setShadowOffset:CGSizeMake(-3, -3)];
    [[recordAudioButton layer] setShadowOpacity:0.3f];
    [[recordAudioButton layer] setShadowRadius:5];
    [[recordAudioButton layer] setShouldRasterize:YES];
    [recordAudioButton addTarget:self action:@selector(showAudioControl) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordAudioButton];
    [self.view bringSubviewToFront:recordAudioButton];
    
    eraserButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [eraserButton setFrame:CGRectMake(paintPalletView.frame.origin.x - 44, recordAudioButton.frame.origin.y + 60, 44, 44)];
    eraserButton.tag = ERASER_BUTTON_TAG;
    [eraserButton setImage:[UIImage imageNamed:@"eraser.png"] forState:UIControlStateNormal];
    [[eraserButton layer] setCornerRadius:eraserButton.frame.size.height/20];
    [eraserButton setUserInteractionEnabled:YES];
    [[eraserButton layer] setMasksToBounds:NO];
    [[eraserButton layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[eraserButton layer] setShadowOffset:CGSizeMake(-3, -3)];
    [[eraserButton layer] setShadowOpacity:0.3f];
    [[eraserButton layer] setShadowRadius:5];
    [[eraserButton layer] setShouldRasterize:YES];
    [eraserButton addTarget:self action:@selector(paintButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:eraserButton];
    [self.view bringSubviewToFront:eraserButton];
    
    //Paint Buttons Menu
    AwesomeMenuItem *starMenuItem1 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"red-splash.png"]
                                                           highlightedImage:[UIImage imageNamed:@"red-splash.png"]
                                                               ContentImage:[UIImage imageNamed:@"red-splash.png"]
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem2 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"yellow-splash.png"]
                                                           highlightedImage:[UIImage imageNamed:@"yellow-splash.png"]
                                                               ContentImage:[UIImage imageNamed:@"yellow-splash.png"]
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem3 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"green-splash.png"]
                                                           highlightedImage:[UIImage imageNamed:@"green-splash.png"]
                                                               ContentImage:[UIImage imageNamed:@"green-splash.png"]
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem4 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"skyblue-splash.png"]
                                                           highlightedImage:[UIImage imageNamed:@"skyblue-splash.png"]
                                                               ContentImage:[UIImage imageNamed:@"skyblue-splash.png"]
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem5 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"peasgreen-splash.png"]
                                                           highlightedImage:[UIImage imageNamed:@"peasgreen-splash.png"]
                                                               ContentImage:[UIImage imageNamed:@"peasgreen-splash.png"]
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem6 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"purple-splash.png"]
                                                           highlightedImage:[UIImage imageNamed:@"purple-splash.png"]
                                                               ContentImage:[UIImage imageNamed:@"purple-splash.png"]
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem7 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"orange-splash.png"]
                                                           highlightedImage:[UIImage imageNamed:@"orange-splash.png"]
                                                               ContentImage:[UIImage imageNamed:@"orange-splash.png"]
                                                    highlightedContentImage:nil];
    
    // the start item, similar to "add" button of Path
    AwesomeMenuItem *startItem = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"red-splash.png"]
                                                       highlightedImage:[UIImage imageNamed:@"red-splash.png"]
                                                           ContentImage:[UIImage imageNamed:@"red-splash.png"]
                                                highlightedContentImage:[UIImage imageNamed:@"red-splash.png"]];
    // setup the menu and options
    paintMenu = [[AwesomeMenu alloc] initWithFrame:self.view.bounds startItem:startItem optionMenus:[NSArray arrayWithObjects:starMenuItem1, starMenuItem2, starMenuItem3, starMenuItem4, starMenuItem5, starMenuItem6, starMenuItem7, nil]];
    paintMenu.delegate = self;
    [self.view addSubview:paintMenu];
    
    paintMenu.startPoint = CGPointMake(paintPalletView.frame.origin.x - 22, eraserButton.frame.origin.y + 60 + 22);
    paintMenu.rotateAngle = -M_PI/4 + 0.35;
    paintMenu.menuWholeAngle = -M_PI/2 - 0.7;
    paintMenu.timeOffset = 0.036f;
    paintMenu.farRadius = 150.0f;
    paintMenu.nearRadius = 120.0f;
    paintMenu.endRadius = 150.0f;
    
    [self.view bringSubviewToFront:pageScrollView];
}

- (void)createPageWithPageNumber:(NSInteger)pageNumber {
    NSMutableString *textOnPage = [[NSMutableString alloc] initWithString:@""];
    
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
            
            /*NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"widgets/4/"]];
            [webview loadRequest:[NSURLRequest requestWithURL:url]];*/
            
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

- (void)createScrollView {
    CGFloat minContentHeight = MAX(pageScrollView.frame.size.height, [arrayOfPages count]*150);
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
                         [pageButton setFrame:CGRectMake(10, 15 + yOffsetForButton, 120, 120)];
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
                [pageButton setFrame:CGRectMake(10, 15 + yOffsetForButton, 120, 120)];
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
                [pageButton setFrame:CGRectMake(10, 15 + yOffsetForButton, 120, 120)];
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
