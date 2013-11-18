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

@interface AudioMappingViewController : UIViewController<UITextFieldDelegate,AVAudioPlayerDelegate,CustomLabelDelegate> {
    NSURL *audioUrl;
    NSString *textForMapping;
}

- (IBAction)nextClick:(id)sender;
- (IBAction)previous:(id)sender;
- (IBAction)playOriginal:(id)sender;
- (IBAction)map:(id)sender;
- (IBAction)record:(id)sender;
- (IBAction)playMapped:(id)sender;
- (IBAction)playRecored:(id)sender;

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

@end
