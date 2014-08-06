//
//  AnotherViewController.h
//  Hi
//
//  Created by Nikhil Dhavale on 16/10/13.
//  Copyright (c) 2013 Nikhil Dhavale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomMappingView.h"
#import "CustomScrollView.h"
#import <AVFoundation/AVFoundation.h>
#import "CustomLabel.h"
#import "MangoTextField.h"

@protocol AudioMappingDelegate;


@interface AudioMappingViewController : UIViewController<UITextFieldDelegate,AVAudioPlayerDelegate,CustomLabelDelegate> {
    NSURL *audioUrl;
    NSString *textForMapping;
    
    IBOutlet UISlider *audioSpeedSlider;
}

- (IBAction)nextClick:(id)sender;
- (IBAction)previous:(id)sender;
- (IBAction)playOriginal:(id)sender;
- (IBAction)map:(id)sender;
- (IBAction)record:(id)sender;
- (IBAction)playMapped:(id)sender;
- (IBAction)playRecored:(id)sender;
- (IBAction)audioSpeedSliderValueChanged:(id)sender;
- (IBAction)exitButtonTapped:(id)sender;
-(void)update;

- (void)playAudioForReaderWithData:(NSData *)audioData AndDelegate:(id <AVAudioPlayerDelegate>)delegate;

@property (nonatomic, strong) IBOutlet UISlider *audioSpeedSlider;
@property (nonatomic, strong) IBOutlet UIButton *hitAndRecordButton;

@property(assign,nonatomic) NSInteger index;
@property(retain,nonatomic) NSMutableArray *cues;
@property(retain,nonatomic) NSMutableArray *anotherCues;
@property (weak, nonatomic) IBOutlet CustomMappingView *customView;
@property(retain,nonatomic) AVAudioPlayer *player;
@property(retain,nonatomic) NSTimer *timer;
@property(retain,nonatomic) AVAudioRecorder *recorder;
@property (weak, nonatomic) IBOutlet CustomScrollView *scrollView;
@property(strong,nonatomic) NSMutableArray *array;
@property(strong,nonatomic) NSMutableArray *listOfViews;
@property(assign,nonatomic) NSInteger totalWordCount;
@property (nonatomic, strong) NSURL *audioUrl;
@property (nonatomic, strong) NSString *textForMapping;
@property (nonatomic, assign) id <AudioMappingDelegate> audioMappingDelegate;

@property (nonatomic, strong) MangoTextField *mangoTextField;
@property (nonatomic, assign) float audioMappingRate;

@end


@protocol AudioMappingDelegate <NSObject>

- (void)saveAudioMapping;
- (void)audioMappingViewControllerdidFinishPlaying:(AudioMappingViewController *) vc;

@end

