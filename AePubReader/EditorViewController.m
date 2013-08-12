//
//  EditorViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 08/08/13.
//
//

#import "EditorViewController.h"
#import "AudioRecordingViewController.h"
#import <QuartzCore/QuartzCore.h>

#define MAIN_TEXTVIEW_TAG 100

#define RED_BUTTON_TAG 1
#define YELLOW_BUTTON_TAG 2
#define GREEN_BUTTON_TAG 3
#define BLUE_BUTTON_TAG 4
#define PEA_GREEN_BUTTON_TAG 5
#define PURPLE_BUTTON_TAG 6
#define ORANGE_BUTTON_TAG 7

@interface EditorViewController ()

@property (nonatomic, strong) NSArray *arrayOfPages;
@property (nonatomic, strong) UIButton *showScrollViewButton;
@property (nonatomic, strong) UIButton *showPaintPalletButton;
@property (nonatomic, strong) UIButton *recordAudioButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) AudioRecordingViewController *audioRecViewController;
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
@synthesize recordAudioButton;
@synthesize audioPlayer;
@synthesize audioRecorder;
@synthesize playButton;
@synthesize audioRecViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.title=@"Editor";
        self.tabBarItem.image=[UIImage imageNamed:@"library.png"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.    
    
    [self createInitialUI];
    [self getBookJson];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
 
#pragma mark - Prepare UI

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
    
    showPaintPalletButton = [UIButton buttonWithType:UIButtonTypeCustom];
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
    [self.view bringSubviewToFront:showPaintPalletButton];
    
    /*recordAudioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [recordAudioButton setFrame:CGRectMake(paintPalletView.frame.origin.x - 44, 60, 44, 44)];
    [recordAudioButton setImage:[UIImage imageNamed:@"record-control.png"] forState:UIControlStateNormal];
    [recordAudioButton setUserInteractionEnabled:YES];
    [[recordAudioButton layer] setMasksToBounds:NO];
    [[recordAudioButton layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[recordAudioButton layer] setShadowOffset:CGSizeMake(-3, -3)];
    [[recordAudioButton layer] setShadowOpacity:0.3f];
    [[recordAudioButton layer] setShadowRadius:5];
    [[recordAudioButton layer] setShouldRasterize:YES];
    [recordAudioButton addTarget:self action:@selector(recordAudio) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordAudioButton];
    [self.view bringSubviewToFront:recordAudioButton];*/
    
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
    if ([backgroundImagesArray objectAtIndex:pageNumber]) {
        backgroundImageView.incrementalImage = [backgroundImagesArray objectAtIndex:pageNumber];
        [backgroundImageView setNeedsDisplay];
        //[backgroundImageView setImage:[backgroundImagesArray objectAtIndex:pageNumber]];
        backgroundImageView.indexOfThisImage = pageNumber;
    }
    if ([textOnPage length] > 0) {
        mainTextView.text = textOnPage;
        CGSize textSize = [mainTextView.text sizeWithFont:[UIFont boldSystemFontOfSize:24] constrainedToSize:CGSizeMake(700, 500) lineBreakMode:NSLineBreakByWordWrapping];
        [mainTextView setFrame:CGRectMake(mainTextView.frame.origin.x, mainTextView.frame.origin.y, textSize.width, textSize.height + 20)];
    } else {
        mainTextView.text = @"";
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
    [self.view bringSubviewToFront:pageScrollView];
    [self.view bringSubviewToFront:paintPalletView];
    
    if (!audioRecViewController) {
        audioRecViewController = [[AudioRecordingViewController alloc] initWithNibName:@"AudioRecordingViewController" bundle:nil];
        [audioRecViewController.view setFrame:CGRectMake(self.view.frame.size.width - 205, self.view.frame.size.height - 205, 200, 200)];
        [self.view addSubview:audioRecViewController.view];
    }
    audioRecViewController.audioUrl = url;
    [audioRecViewController stopPlaying];
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
            if ([[layerDict objectForKey:@"type"] isEqualToString:@"image"]) {
                
                if (!backgroundImagesArray) {
                    backgroundImagesArray = [[NSMutableArray alloc] init];
                }
                [backgroundImagesArray addObject:[UIImage imageNamed:[layerDict objectForKey:@"url"]]];
                
                UIButton *pageButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [pageButton setImage:[UIImage imageNamed:[layerDict objectForKey:@"url"]] forState:UIControlStateNormal];
                [pageButton addTarget:self action:@selector(createPageForSender:) forControlEvents:UIControlEventTouchUpInside];
                CGFloat yOffsetForButton = [arrayOfPages indexOfObject:dictionaryForPage]*150;
                [pageButton setFrame:CGRectMake(10, 15 + yOffsetForButton, 120, 120)];
                pageButton.tag = [arrayOfPages indexOfObject:dictionaryForPage];
                
                [[pageButton layer] setMasksToBounds:NO];
                [[pageButton layer] setShadowColor:[[UIColor blackColor] CGColor]];
                [[pageButton layer] setShadowOffset:CGSizeMake(10, 10)];
                [[pageButton layer] setShadowOpacity:0.3f];
                [[pageButton layer] setShadowRadius:2];
                [[pageButton layer] setShouldRasterize:YES];
                
                [pageScrollView addSubview:pageButton];
                
            }
        }
    }
}

#pragma mark - Parsing Book Json

- (void)getBookJson {
    // Temporarily adding hardcoded string
    NSString *bookJsonString = @"[{\"id\":\"Cover\",\"name\":\"Cover\",\"layers\":[{\"type\":\"image\",\"url\":\"a9457d95f7.jpg\",\"alignment\":\"left\",\"order\":0,\"name\":\"\"}],\"order\":0,\"pageNo\":1,\"original_id\":1317},{\"id\":1,\"name\":1,\"layers\":[{\"type\":\"image\",\"url\":\"71b1a3e2b0.jpg\",\"alignment\":\"middle\",\"order\":0,\"name\":\"\"},{\"type\":\"audio\",\"url\":\"51d029a922.mp3\",\"wordTimes\":[1.70530104637146,2.2062370777130127,2.7171740531921387,3.218951940536499,3.7340469360351562,3.9840149879455566,4.5863800048828125,4.836188793182373,5.338126182556152,6.100030899047852,6.598808765411377,7.39418888092041,7.644157886505127,8.151094436645508,8.402063369750977,8.901841163635254,9.151650428771973,9.402618408203125,9.907554626464844,10.159363746643066,10.661300659179688,11.420206069946289,11.671014785766602,11.924983024597168,12.440077781677246,12.690047264099121,13.459952354431152,13.709919929504395,13.991363525390625,14.994919776916504,15.502857208251953,15.752823829650879,16.002792358398438,17.00634765625,17.287792205810547,17.796728134155273,18.563793182373047,19.06357192993164,19.5633487701416,20.063125610351562,21.814586639404297,22.319364547729492,22.570331573486328,22.821300506591797,23.57304573059082,23.822856903076172,24.072824478149414,24.574602127075195,24.82457160949707,25.07453727722168,25.5753173828125,26.325063705444336,26.826841354370117,27.077808380126953,27.328777313232422,27.831554412841797,28.081523895263672,28.331331253051758,28.837268829345703,29.089237213134766,29.598173141479492,30.09895133972168],\"wordMap\":[{\"word\":\"Neelu\",\"step\":17,\"wordIdx\":1},{\"word\":\"the\",\"step\":22,\"wordIdx\":2},{\"word\":\"butterfly\",\"step\":27,\"wordIdx\":3},{\"word\":\"was\",\"step\":32,\"wordIdx\":4},{\"word\":\"scolding\",\"step\":37,\"wordIdx\":5},{\"word\":\"her\",\"step\":40,\"wordIdx\":6},{\"word\":\"son\",\"step\":46,\"wordIdx\":7},{\"word\":\"Katty,\",\"step\":48,\"wordIdx\":8},{\"word\":\"the\",\"step\":53,\"wordIdx\":9},{\"word\":\"caterpillar,\",\"step\":61,\"wordIdx\":10},{\"word\":\"Why\",\"step\":66,\"wordIdx\":11},{\"word\":\"did\",\"step\":74,\"wordIdx\":12},{\"word\":\"you\",\"step\":76,\"wordIdx\":13},{\"word\":\"eat\",\"step\":82,\"wordIdx\":14},{\"word\":\"all\",\"step\":84,\"wordIdx\":15},{\"word\":\"the\",\"step\":89,\"wordIdx\":16},{\"word\":\"leaves\",\"step\":92,\"wordIdx\":17},{\"word\":\"of\",\"step\":94,\"wordIdx\":18},{\"word\":\"the\",\"step\":99,\"wordIdx\":19},{\"word\":\"plants?\",\"step\":102,\"wordIdx\":20},{\"word\":\"Why\",\"step\":107,\"wordIdx\":21},{\"word\":\"do\",\"step\":114,\"wordIdx\":22},{\"word\":\"you\",\"step\":117,\"wordIdx\":23},{\"word\":\"overeat?\",\"step\":119,\"wordIdx\":24},{\"word\":\"The\",\"step\":124,\"wordIdx\":25},{\"word\":\"gardener\",\"step\":127,\"wordIdx\":26},{\"word\":\"is\",\"step\":135,\"wordIdx\":27},{\"word\":\"angry.\",\"step\":137,\"wordIdx\":28},{\"word\":\"He\",\"step\":140,\"wordIdx\":29},{\"word\":\"is\",\"step\":150,\"wordIdx\":30},{\"word\":\"looking\",\"step\":155,\"wordIdx\":31},{\"word\":\"for\",\"step\":158,\"wordIdx\":32},{\"word\":\"you.\",\"step\":160,\"wordIdx\":33},{\"word\":\"Why?\",\"step\":170,\"wordIdx\":34},{\"word\":\"don't\",\"step\":173,\"wordIdx\":35},{\"word\":\"yath'ever\",\"step\":178,\"wordIdx\":36},{\"word\":\"use\",\"step\":186,\"wordIdx\":37},{\"word\":\"your\",\"step\":191,\"wordIdx\":38},{\"word\":\"brain?\",\"step\":196,\"wordIdx\":39},{\"word\":\"What\",\"step\":201,\"wordIdx\":40},{\"word\":\"can\",\"step\":218,\"wordIdx\":41},{\"word\":\"I\",\"step\":223,\"wordIdx\":42},{\"word\":\"do\",\"step\":226,\"wordIdx\":43},{\"word\":\"mother?\",\"step\":228,\"wordIdx\":44},{\"word\":\"My\",\"step\":236,\"wordIdx\":45},{\"word\":\"brain\",\"step\":238,\"wordIdx\":46},{\"word\":\"is\",\"step\":241,\"wordIdx\":47},{\"word\":\"in\",\"step\":246,\"wordIdx\":48},{\"word\":\"my\",\"step\":248,\"wordIdx\":49},{\"word\":\"tummy,\",\"step\":251,\"wordIdx\":50},{\"word\":\"so\",\"step\":256,\"wordIdx\":51},{\"word\":\"I\",\"step\":263,\"wordIdx\":52},{\"word\":\"do\",\"step\":268,\"wordIdx\":53},{\"word\":\"what\",\"step\":271,\"wordIdx\":54},{\"word\":\"my\",\"step\":273,\"wordIdx\":55},{\"word\":\"tummy\",\"step\":278,\"wordIdx\":56},{\"word\":\"tells\",\"step\":281,\"wordIdx\":57},{\"word\":\"me\",\"step\":283,\"wordIdx\":58},{\"word\":\"to\",\"step\":288,\"wordIdx\":59},{\"word\":\"do,\",\"step\":291,\"wordIdx\":60},{\"word\":\"replied\",\"step\":296,\"wordIdx\":61},{\"word\":\"Katty.\",\"step\":301,\"wordIdx\":62}],\"order\":0,\"name\":\"\"},{\"type\":\"color\",\"color\":\"rgb(255,204,102)\",\"order\":0,\"name\":\"\"}],\"order\":0,\"pageNo\":1,\"original_id\":1329}]";
    NSData *jsonData = [bookJsonString dataUsingEncoding:NSUTF8StringEncoding];
    arrayOfPages = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"number of pages: %d", [arrayOfPages count]);
    
    [self createScrollView];
    [self createPageWithPageNumber:0];

}

@end
