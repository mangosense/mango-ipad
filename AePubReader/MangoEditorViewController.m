//
//  MangoEditorViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 14/11/13.
//
//

#import "MangoEditorViewController.h"
#import "Constants.h"
#import "MovableTextView.h"
#import <AVFoundation/AVFoundation.h>

#define ENGLISH_TAG 9
#define ANGRYBIRDS_ENGLISH_TAG 17
#define TAMIL_TAG 10
#define MALAY_TAG 12
#define CHINESE_TAG 11
#define GERMAN_TAG 13
#define SPANISH_TAG 14

@interface MangoEditorViewController ()

@property (nonatomic, strong) NSString *bookJsonString;
@property (nonatomic, strong) NSMutableArray *pagesArray;
@property (nonatomic, assign) int currentPageNumber;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation MangoEditorViewController

@synthesize pageImageView;
@synthesize mangoButton;
@synthesize menuButton;
@synthesize imageButton;
@synthesize textButton;
@synthesize audioButton;
@synthesize gamesButton;
@synthesize collaborationButton;
@synthesize playStoryButton;
@synthesize pagesCarousel;
@synthesize chosenBookTag;
@synthesize bookJsonString;
@synthesize pagesArray;
@synthesize currentPageNumber;
@synthesize audioRecorder;
@synthesize audioPlayer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self getBookJson];
    [pagesCarousel setClipsToBounds:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Methods

- (IBAction)mangoButtonTapped:(id)sender {
    
}

- (IBAction)menuButtonTapped:(id)sender {
    
}

- (IBAction)imageButtonTapped:(id)sender {
    
}

- (IBAction)textButtonTapped:(id)sender {
    
}

- (IBAction)audioButtonTapped:(id)sender {
    
}

- (IBAction)gamesButtonTapped:(id)sender {
    
}

- (IBAction)collaborationButtonTapped:(id)sender {
    
}

- (IBAction)playStoryButtonTapped:(id)sender {
    
}

#pragma mark - iCarousel Datasource And Delegate Methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [pagesArray count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    UIButton *pageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [pageButton setFrame:CGRectMake(0, 0, 130, 90)];
    [pageButton setImage:[UIImage imageNamed:@"pagesbutton.png"] forState:UIControlStateNormal];

    NSDictionary *pageDict = [pagesArray objectAtIndex:index];
    NSArray *layersArray = [[pageDict objectForKey:@"json"] objectForKey:LAYERS];
    for (NSDictionary *layerDict in layersArray) {
        if ([[layerDict objectForKey:TYPE] isEqualToString:IMAGE]) {
            [pageButton setImage:[UIImage imageNamed:[layerDict objectForKey:ASSET_URL]] forState:UIControlStateNormal];
            break;
        }
    }
    
    return pageButton;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    [self renderPage:index];
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

#pragma mark - DoodleDelegate Method

- (void)replaceImageAtIndex:(NSInteger)index withImage:(UIImage *)image {
    
}

#pragma mark - Render JSON (Temporary - For Demo Story)

- (void)renderPage:(int)pageNumber {
    currentPageNumber = pageNumber;
    
    for (UIView *subview in [pageImageView subviews]) {
        [subview removeFromSuperview];
    }
    pageImageView.incrementalImage = nil;
    
    NSDictionary *pageDict = [pagesArray objectAtIndex:pageNumber];
    NSArray *layersArray = [[pageDict objectForKey:@"json"] objectForKey:LAYERS];
    NSURL *audioUrl;
    NSString *textOnPage;
    CGRect textFrame;
    
    for (NSDictionary *layerDict in layersArray) {
        if ([[layerDict objectForKey:TYPE] isEqualToString:IMAGE]) {
            pageImageView.incrementalImage = [UIImage imageNamed:[layerDict objectForKey:ASSET_URL]];
        } else if ([[layerDict objectForKey:TYPE] isEqualToString:AUDIO]) {
            audioUrl = [NSURL URLWithString:[layerDict objectForKey:AUDIO]];
        } else if ([[layerDict objectForKey:TYPE] isEqualToString:TEXT]) {
            textOnPage = [layerDict objectForKey:TEXT];
            textFrame = CGRectMake([[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_POSITION_X] floatValue], [[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_POSITION_Y] floatValue], [[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_SIZE_WIDTH] floatValue], [[[layerDict objectForKey:TEXT_FRAME] objectForKey:TEXT_SIZE_HEIGHT] floatValue]);
            
            MovableTextView *pageTextView = [[MovableTextView alloc] initWithFrame:textFrame];
            pageTextView.font = [UIFont boldSystemFontOfSize:24];
            pageTextView.text = textOnPage;
            [pageImageView addSubview:pageTextView];
        }
    }
}

#pragma mark - Book JSON Methods

- (void)getBookJson {
    bookJsonString = @"{\"id\":829,\"title\":\"rahul\",\"language\":\"English\",\"pages\":[{\"id\":584,\"json\":{\"id\":\"Cover\",\"name\":\"Cover\",\"layers\":[{\"type\":\"image\",\"name\":\"image\",\"url\":\"91f501c53a.jpg\",\"alignment\":\"left\",\"order\":0,\"style\":{}}],\"order\":0,\"pageNo\":1,\"original_id\":584}},{\"id\":585,\"json\":{\"id\":1,\"name\":1,\"type\":\"page\",\"layers\":[{\"type\":\"text\",\"name\":\"text-1\",\"alignment\":\"left\",\"order\":0,\"style\":{\"top\":253,\"left\":401,\"width\":431,\"height\":173},\"text\":\"testing the tex box for json attributes\",\"words\":[{\"index\":0,\"text\":\"testing\"},{\"index\":1,\"text\":\"the\"},{\"index\":2,\"text\":\"tex\"},{\"index\":3,\"text\":\"box\"},{\"index\":4,\"text\":\"for\"},{\"index\":5,\"text\":\"json\"},{\"index\":6,\"text\":\"attributes\"}]},{\"type\":\"image\",\"name\":\"image\",\"url\":\"91f501c53a.jpg\",\"alignment\":\"middle\",\"order\":0,\"style\":{}}],\"order\":0,\"pageNo\":1,\"original_id\":585}},{\"id\":586,\"json\":{\"id\":3,\"name\":3,\"type\":\"page\",\"layers\":[{\"type\":\"text\",\"name\":\"text\",\"alignment\":\"left\",\"order\":0,\"style\":{}},{\"type\":\"image\",\"name\":\"image\",\"url\":\"91f501c53a.jpg\",\"alignment\":\"left\",\"order\":0,\"style\":{}}],\"order\":0,\"pageNo\":1,\"original_id\":586}},{\"id\":587,\"json\":{\"id\":2,\"name\":2,\"type\":\"page\",\"layers\":[{\"type\":\"text\",\"name\":\"text\",\"alignment\":\"left\",\"order\":0,\"style\":{}},{\"type\":\"image\",\"name\":\"image\",\"url\":\"91f501c53a.jpg\",\"alignment\":\"left\",\"order\":0,\"style\":{}}],\"order\":0,\"pageNo\":1,\"original_id\":587}},{\"id\":588,\"json\":{\"id\":4,\"name\":4,\"type\":\"page\",\"layers\":[{\"type\":\"text\",\"name\":\"text\",\"alignment\":\"left\",\"order\":0,\"style\":{}}],\"order\":0,\"pageNo\":1}},{\"id\":589,\"json\":{\"id\":4,\"name\":4,\"type\":\"page\",\"layers\":[{\"type\":\"text\",\"name\":\"text-1\",\"alignment\":\"left\",\"order\":0,\"style\":{\"top\":156,\"left\":112},\"text\":\"Mysql create user and grant privileges.\",\"words\":[{\"index\":0,\"text\":\"Mysql\"},{\"index\":1,\"text\":\"create\"},{\"index\":2,\"text\":\"user\"},{\"index\":3,\"text\":\"and\"},{\"index\":4,\"text\":\"grant\"},{\"index\":5,\"text\":\"privileges.\"}]},{\"type\":\"image\",\"name\":\"image\",\"url\":\"91f501c53a.jpg\",\"alignment\":\"left\",\"order\":0,\"style\":{}}],\"order\":0,\"pageNo\":1,\"original_id\":589}}]}";
    
    NSData *jsonData = [bookJsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    NSLog(@"%@", jsonDict);
    
    pagesArray = [jsonDict objectForKey:PAGES];
    [pagesCarousel reloadData];
    [self renderPage:1];
}

#pragma mark - Audio Recording

- (void)startRecordingAudio {
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
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sampleRecord_%d.caf", recDir, currentPageNumber]];
    
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

- (void)stopRecordingAudio
{
    NSLog(@"stopRecording");
    [audioRecorder stop];
    NSLog(@"stopped");
    [self saveAudio];
}

- (void)saveAudio {
    NSMutableDictionary *audioDict = [[NSMutableDictionary alloc] init];
    [audioDict setObject:AUDIO forKey:TYPE];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *recDir = [paths objectAtIndex:0];
    [audioDict setObject:[NSString stringWithFormat:@"%@/sampleRecord_%d.caf", recDir, currentPageNumber] forKey:ASSET_URL];
    
    NSData *jsonData = [bookJsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    [[[[[jsonDict objectForKey:PAGES] objectAtIndex:currentPageNumber] objectForKey:@"json"] objectForKey:LAYERS] addObject:jsonDict];
    
    NSData *newJsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONReadingAllowFragments error:nil];
    bookJsonString = [[NSString alloc] initWithData:newJsonData encoding:NSUTF8StringEncoding];
}

#pragma mark - Audio Playing

- (void)startPlayingAudio {
    NSLog(@"playRecording");
    // Init audio with playback capability
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *recDir = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sampleRecord_%d.caf", recDir, currentPageNumber]];
    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    audioPlayer.numberOfLoops = 0;
    [audioPlayer play];
}

- (void)stopPlayingAudio {
    NSLog(@"stopPlaying");
    [audioPlayer stop];
    NSLog(@"stopped");
}

@end
