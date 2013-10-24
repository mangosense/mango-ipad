//
//  AudioRecordingViewController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 12/08/13.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioRecordingViewController : UIViewController {
    AVAudioPlayer *audioPlayer;
    AVAudioRecorder *audioRecorder;
    
    int recordEncoding;
    
    NSURL *audioUrl;
}

@property (nonatomic, strong) NSURL *audioUrl;

@property (nonatomic, strong) IBOutlet UIButton *recordButton;
@property (nonatomic, strong) IBOutlet UIButton *stopButton;
@property (nonatomic, strong) IBOutlet UIButton *playButton;

- (IBAction)startRecording;
- (IBAction)playRecording;
- (IBAction)stopPlaying;

@end
