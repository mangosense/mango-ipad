//
//  AudioRecordingViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 12/08/13.
//
//

#import "AudioRecordingViewController.h"

@interface AudioRecordingViewController ()

@property (nonatomic, assign) BOOL isPaused;

@end

enum
{
    ENC_AAC = 1,
    ENC_ALAC = 2,
    ENC_IMA4 = 3,
    ENC_ILBC = 4,
    ENC_ULAW = 5,
    ENC_PCM = 6,
} encodingTypes;

@implementation AudioRecordingViewController

@synthesize audioUrl;
@synthesize isPaused;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Audio Recording Methods

- (void)enablePlayAndStopButtons {
    NSString *path = [audioUrl path];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
    if (!data) {
        [self.playButton setEnabled:NO];
        [self.stopButton setEnabled:NO];
    } else {
        [self.playButton setEnabled:YES];
        [self.stopButton setEnabled:YES];
    }
}

- (void)recordAudio {
    [self.recordButton setImage:[UIImage imageNamed:@"recordbuttonpressed.png"] forState:UIControlStateNormal];

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
    
    NSURL *url = audioUrl;
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

- (IBAction)startRecording
{
    if (audioRecorder) {
        if ([audioRecorder isRecording]) {
            [self stopRecording];
        } else {
            [self recordAudio];
        }
    } else {
        [self recordAudio];
    }
}

- (void)stopRecording
{
    [self.recordButton setImage:[UIImage imageNamed:@"recordbutton.png"] forState:UIControlStateNormal];
    NSLog(@"stopRecording");
    [audioRecorder stop];
    NSLog(@"stopped");
    [self enablePlayAndStopButtons];
}

- (void)playAudio {
    [self.playButton setImage:[UIImage imageNamed:@"playbuttonpressed.png"] forState:UIControlStateNormal];

    NSLog(@"playRecording");
    // Init audio with playback capability
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSURL *url = audioUrl;
    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    audioPlayer.numberOfLoops = 0;
    [audioPlayer play];
    NSLog(@"playing");
    isPaused = NO;

}

- (IBAction)playRecording
{
    if (audioPlayer) {
        if ([audioPlayer isPlaying]) {
            [audioPlayer pause];
            isPaused = YES;
            [self.playButton setImage:[UIImage imageNamed:@"playbutton.png"] forState:UIControlStateNormal];
        } else {
            if (isPaused) {
                [audioPlayer play];
            } else {
                [self playAudio];
            }
        }
    } else {
        [self playAudio];
    }
}

- (IBAction)stopPlaying
{
    isPaused = NO;
    [self.playButton setImage:[UIImage imageNamed:@"playbutton.png"] forState:UIControlStateNormal];
    NSLog(@"stopPlaying");
    [audioPlayer stop];
    NSLog(@"stopped");
}

@end
