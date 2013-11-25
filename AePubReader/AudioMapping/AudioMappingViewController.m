//
//  AnotherViewController.m
//  Hi
//
//  Created by Nikhil Dhavale on 16/10/13.
//  Copyright (c) 2013 Nikhil Dhavale. All rights reserved.
//

#import "AudioMappingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "BaseViewSample.h"
#import "Constants.h"
#import "MovableTextView.h"

@interface AudioMappingViewController ()

@property (nonatomic, assign) CGFloat xDiffToCenter;
@property (nonatomic, assign) CGFloat yDiffToCenter;

@end

@implementation AudioMappingViewController

@synthesize audioUrl;
@synthesize textForMapping;
@synthesize xDiffToCenter, yDiffToCenter;
@synthesize audioSpeedSlider;

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
    _listOfViews=[[NSMutableArray alloc]init];
    [_scrollView setBackgroundColor:COLOR_ORANGE];
    NSLog(@"%@", NSStringFromCGRect(_scrollView.frame));
    [audioSpeedSlider setMaximumValue:1.0f];
    [audioSpeedSlider setMinimumValue:0.5f];
    [audioSpeedSlider setValue:1.0f];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    if (_player) {
        [_player stop];
        
    }

}

- (void)setAudioUrl:(NSURL *)audioUrlForMapping {
    audioUrl = audioUrlForMapping;
    _player=[[AVAudioPlayer alloc]initWithContentsOfURL:audioUrl error:nil];
    [self sampleAudio];
}

- (void)setTextForMapping:(NSString *)textForMappingAudio {
    textForMapping = textForMappingAudio;
    _customView.text=[textForMapping componentsSeparatedByString:@" "];
    
    _cues= [[NSMutableArray alloc]initWithArray:[NSArray arrayWithObjects:@3650,@3900,@4000,@4500,@4800,@5300,@5400,@6000, nil]];
    _totalWordCount=_cues.count;
    
    if ([UIDevice currentDevice].systemVersion.integerValue<6) {
        _customView.space=[@" " sizeWithFont:_customView.textFont];
    }else{
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:_customView.textFont, NSFontAttributeName, nil];
        _customView.space=   [[[NSAttributedString alloc] initWithString:@" " attributes:attributes] size];
    }
    
    _index=0;
    _customView.backgroundColor = [UIColor clearColor];
}

-(void)completeTable{
    _index=0;
    _customView.backgroundColor=[UIColor greenColor];
    int x = 0;
    [self.scrollView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];

    for (int i=0; i<_cues.count; i++) {
        CGSize size;
        if ([UIDevice currentDevice].systemVersion.integerValue<6) {
            size=[_customView.text[i] sizeWithFont:[UIFont systemFontOfSize:17]];
        }else{
            NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:17], NSFontAttributeName, nil];
            size=   [[[NSAttributedString alloc] initWithString:_customView.text[i] attributes:attributes] size];
        }
        NSLog(@"%@ %f",_customView.text[i],size.width);
        size.width=MAX(50, size.width);
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(x, 0, size.width, size.height)];
        label.text=_customView.text[i];
        label.textAlignment=NSTextAlignmentCenter;
        [_scrollView addSubview:label];
        CGRect frame=label.frame;
        frame.origin.y=65;
        UITextField *textView=[[UITextField alloc]initWithFrame:frame];
        textView.text=[[NSString alloc]initWithFormat:@"%@",_cues[i]];
        textView.delegate=self;
        textView.textAlignment=NSTextAlignmentCenter;
        textView.tag=i;
        [_scrollView addSubview:textView];
        x+=size.width+_customView.space.width;
    }
}
-(void)sampleAudio{
    float duration=_player.duration;
    float numberOfSamples=duration/0.1f;
    int x=0;
    int prevWidth=0;
    float initialValue=0.1f;
    CGSize size;
    size.height=120;
    int index=0;
    [_listOfViews removeAllObjects];
    [[_scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _scrollView.backgroundColor=[UIColor whiteColor];
    for (int i=0;i<numberOfSamples;i++) {
        BaseViewSample *baseView=[[BaseViewSample alloc]initWithFrame:CGRectMake(x, 0, 50, 120)];
        [_listOfViews addObject:baseView];
        baseView.layer.borderColor=[UIColor blackColor].CGColor;
        baseView.layer.borderWidth=1.0f;
        baseView.containsValue=NO;
        [_scrollView addSubview:baseView];
        prevWidth=baseView.frame.size.width;
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, 10, 50, 30)];
        label.text=[[NSString alloc]initWithFormat: @"%0.1f",initialValue];
        [label setTextAlignment:NSTextAlignmentCenter];
        initialValue=label.text.floatValue;
        label.backgroundColor=[UIColor clearColor];
        [baseView addSubview:label];
        baseView.backgroundColor=[UIColor clearColor];
        baseView.tag=i;
        
        NSNumber *number;
        if (index<_cues.count) {
         number=_cues[index];
        }
        
        float sec=number.floatValue;
        sec=sec/1000;
        if (sec<=initialValue&&_customView.text.count>index&&_cues.count>index) {
                NSString *str=_customView.text[index];
            float val=initialValue;
            val=ceilf(initialValue*1000);
            NSInteger intval=val;
            number=[NSNumber numberWithInteger:intval];
            _cues[index]=number;

            CGSize size;
            if ([UIDevice currentDevice].systemVersion.integerValue<6) {
                size=[str sizeWithFont:[UIFont systemFontOfSize:17]];
            }else{
                NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:17], NSFontAttributeName, nil];
                size=   [[[NSAttributedString alloc] initWithString:str attributes:attributes] size];
            }
            CGRect frame=baseView.frame;

            CGFloat wd=MAX(frame.size.width, size.width);
                CustomLabel *labl=[[CustomLabel alloc]initWithFrame:CGRectMake(5, 40,wd ,50)];
            labl.delegate=self;
            labl.backgroundColor=[UIColor clearColor];
            labl.font=[UIFont systemFontOfSize:15];
            labl.cues=_cues;
            labl.index=index;
            frame.size.width=wd;
            prevWidth=wd;
            baseView.frame=frame;
                labl.textAlignment=NSTextAlignmentLeft;
                labl.text=_customView.text[index];
            labl.userInteractionEnabled=YES;
            labl.tag=i;
            labl.index=index;
            [baseView addSubview:labl];
            baseView.containsValue=YES;
            labl.arrayOfViews=_listOfViews;
            labl.scrollView=_scrollView;
            labl.xmin=x;
            labl.xmax=x+prevWidth;
            index++;
        }

        baseView.value=initialValue;
        initialValue+=0.1f;
        x+=prevWidth;
        
    }// end for

    x+=40;
    _scrollView.total=x;
    _scrollView.contentSize=CGSizeMake(x, 50);
    NSLog(@"%@",_cues);
}
- (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? paths[0] : nil;
        return basePath;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextClick:(id)sender {
    if (_customView.text.count>_index) {
        NSString *string=[_customView.text objectAtIndex:_index];
            NSLog(@"custom view.text");
        CGSize size;
        
        if ([UIDevice currentDevice].systemVersion.integerValue<6) {
            size=[string sizeWithFont:_customView.textFont];
        } else {
            NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:_customView.textFont, NSFontAttributeName, nil];
            size=   [[[NSAttributedString alloc] initWithString:string attributes:attributes] size];
        }
        
        if (_index>0) {
            _customView.x+=_customView.width+_customView.space.width;

        }
        
        if ((_customView.x+size.width)>_customView.frame.size.width) {
            _customView.y+=size.height;
            _customView.x=0;
        }
        
        _customView.height=size.height;
        _customView.width=size.width;
        [_customView setNeedsDisplay];
        _index++;
    }
    
}

- (IBAction)previous:(id)sender {
    if ([_player isPlaying]) {
        [_player pause];
    }
    else{
        [_player play];
    }
}

- (void)playAudioForReaderWithData:(NSData *)audioData AndDelegate:(id <AVAudioPlayerDelegate>)delegate {
    [self reset];
    [self nextClick:nil];
    
    _index--;
    
    _player=[[AVAudioPlayer alloc] initWithData:audioData error:nil];
    _player.delegate=delegate;
    [_player play];
    
    _timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(update) userInfo:nil repeats:YES];
    
    [self sampleAudio];
    
    CGRect frame=CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    _scrollView.progress=0;
    [_scrollView setNeedsDisplay];
    [ _scrollView scrollRectToVisible:frame animated:NO];
}

- (IBAction)playOriginal:(id)sender {
    [self reset];
    [self nextClick:nil];
    _index--;
    _player=[[AVAudioPlayer alloc]initWithContentsOfURL:audioUrl error:nil];
    _player.delegate=self;
    [_player play];
    _timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(update) userInfo:nil repeats:YES];
    [self sampleAudio];
    CGRect frame=CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    _scrollView.progress=0;
    [_scrollView setNeedsDisplay];
    [ _scrollView scrollRectToVisible:frame animated:NO];
}
-(void)update{
    
    if (_index<_cues.count) {
        NSNumber *number= _cues[_index];
        if ((_player.currentTime*1000)>=number.floatValue) {
            [self nextClick:nil];
        }
    }
    NSLog(@"update in timer");
    [self showProgress];
}
-(void)showProgress{
    float progress=_player.currentTime*_scrollView.total;
    progress/=_player.duration;
    float factor=_scrollView.progress/_scrollView.frame.size.width;
    factor=ceilf(factor);
    if (factor>=2) {
        factor-=1;
    }else{
        factor=0;
    }
    factor*=_scrollView.frame.size.width;
    CGRect frame=CGRectMake(factor, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    [ _scrollView scrollRectToVisible:frame animated:NO];
    if (progress>_scrollView.progress) {
        _scrollView.progress=progress;
        [_scrollView setNeedsDisplay];
        
    }
}

- (IBAction)map:(id)sender {
    if (_customView.text.count>=_anotherCues.count) {
        NSNumber *number=[NSNumber numberWithInteger:_player.currentTime*1000];
        [_anotherCues addObject:number];
        UITextView *textView=[_array objectAtIndex:_anotherCues.count-1];
        textView.text=[[NSString alloc]initWithFormat:@"%@",number ];
        NSLog(@"%d",_index);
        _cues=nil;
        _cues=_anotherCues;
        [self sampleAudio];
    }
}

- (IBAction)record:(id)sender {
    UIButton *button=(UIButton *)sender;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    if (_recorder) {
        if ([_recorder isRecording]) {
            [button setTitle:@"record" forState:UIControlStateNormal];
            [_recorder stop];
        }else{
            _recorder=nil;
        }
    } else {
        NSDictionary *recordSettings = @{AVFormatIDKey: @(kAudioFormatAppleIMA4),
                                         AVNumberOfChannelsKey: @1,
                                         AVSampleRateKey: @44100.0f};
        NSString *string=[self applicationDocumentsDirectory];
        string=[string stringByAppendingPathComponent:@"temp.iam4"];
        NSURL *audioFileURL = [NSURL fileURLWithPath:string];
        if ([[NSFileManager defaultManager] fileExistsAtPath:string]) {
            [[NSFileManager defaultManager] removeItemAtPath:string error:nil];
        }
        _recorder=[[AVAudioRecorder alloc]initWithURL:audioFileURL settings:recordSettings error:nil];
        
        [button setTitle:@"stop" forState:UIControlStateNormal];
        [_recorder record];
    }
}

- (IBAction)playMapped:(id)sender {
    [self reset];
    NSString *string=[self applicationDocumentsDirectory];
    string=[string stringByAppendingPathComponent:@"temp.iam4"];
    _player=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:string] error:nil];
    _player.delegate=self;
    [_player play];
    [_timer invalidate];
    _timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateRecorded) userInfo:nil repeats:YES];
    _cues=_anotherCues;
    
    [self sampleAudio];
}
-(void)updateRecorded{
    if (_index<_anotherCues.count) {
        NSNumber *number= _anotherCues[_index];
        if ((_player.currentTime*1000)>=number.floatValue) {
            [self nextClick:nil];
        }
    }
    [self showProgress];
    
}

- (IBAction)playRecored:(id)sender {
    [self reset];
    _player=[[AVAudioPlayer alloc]initWithContentsOfURL:audioUrl error:nil];
    _player.delegate=self;
    
    [_player setEnableRate:YES];
    _player.rate = audioSpeedSlider.value;
    [_player play];
    [self sampleAudio];

    if (_anotherCues) {
        [_anotherCues removeAllObjects];
    }else{
        _anotherCues=[[NSMutableArray alloc]init];
        
    }
    CGRect frame=CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    _scrollView.progress=0;
    [_scrollView setNeedsDisplay];
    [ _scrollView scrollRectToVisible:frame animated:NO];
    [_timer invalidate];
    _timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(showProgress) userInfo:nil repeats:YES];
}

-(void)reset{
    _index=0;
    _customView.x=0;
    _customView.y=0;
    _customView.width=0;
    _customView.height=0;
    [_customView setNeedsDisplay];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSLog(@"%@%@",textField.text,string);
    NSString *str=[NSString stringWithFormat:@"%@%@",textField.text,string];
    
    _cues[textField.tag]=[NSNumber numberWithInteger:str.integerValue];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [_timer invalidate];
    _scrollView.progress=0;
    [_scrollView setNeedsDisplay];
    _player = nil;
}

#pragma mark - Exit

- (IBAction)exitButtonTapped:(id)sender {
    for (UIView *subview in [self.view.superview subviews]) {
        if ([subview isKindOfClass:[MovableTextView class]]) {
            [subview setHidden:NO];
        }
    }
    
    [_customView removeFromSuperview];
    [self.view removeFromSuperview];
}

#pragma mark - Audio Speed

- (IBAction)audioSpeedSliderValueChanged:(id)sender {
    [_player setRate:audioSpeedSlider.value];
}

#pragma mark - Touch Methods

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.view.superview];
    xDiffToCenter = location.x - self.view.center.x;
    yDiffToCenter = location.y - self.view.center.y;
    
    self.view.alpha = 0.7f;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.view.superview];
    
    self.view.center = CGPointMake(MAX(5 + self.view.frame.size.width/2, MIN(location.x - xDiffToCenter, self.view.superview.frame.size.width - self.view.frame.size.width/2 - 5)), MAX(5 + self.view.frame.size.height/2, MIN(location.y - yDiffToCenter, self.view.superview.frame.size.height - self.view.frame.size.height/2 - 5/* - 150*/)));
    self.view.alpha = 0.7f;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.view.superview];
    
    self.view.alpha = 1.0f;
    
    self.view.center = CGPointMake(MAX(5 + self.view.frame.size.width/2, MIN(location.x - xDiffToCenter, self.view.superview.frame.size.width - self.view.frame.size.width/2 - 5)), MAX(5 + self.view.frame.size.height/2, MIN(location.y - yDiffToCenter, self.view.superview.frame.size.height - self.view.frame.size.height/2 - 5/* - 150*/)));
    [self resignFirstResponder];
}

@end
