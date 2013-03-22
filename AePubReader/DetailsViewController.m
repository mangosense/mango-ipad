//
//  DetailsViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 31/12/12.
//
//

#import "DetailsViewController.h"

@interface DetailsViewController ()

@end

@implementation DetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString *)stringValue value:(NSString *)val
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _titleLabel=[[NSString alloc]initWithString:stringValue];
        _loc=[[NSString alloc]initWithString:val];
        _isPlaying=NO;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _fileName.text =_titleLabel;
   self.contentSizeForViewInPopover= CGSizeMake(150.0, 400.0);

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*- (void)dealloc {
    [_fileName release];
    [_titleLabel release];
    [_loc release];
    _player=nil;
    [_playPause release];
    [super dealloc];
}*/
- (void)viewDidUnload {
    [self setFileName:nil];
    [self setPlayPause:nil];
    [super viewDidUnload];
}
- (IBAction)playOrPause:(id)sender {
    if (!_isPlaying) {
        
        UIImage *image=[UIImage imageNamed:@"stop-recording-control.png"];
          [_playPause setImage:image forState:UIControlStateNormal];
    
        NSURL *url=[NSURL URLWithString:_loc];
        _player=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
        [_player setDelegate:self];
        [_player play];
    }else{
        UIImage *image=[UIImage imageNamed:@"play-control.png"];
        [_playPause setImage:image forState:UIControlStateNormal];
        [_player stop];
       // [_player release];
       // _player=nil;
        
    }
_isPlaying=!_isPlaying;
}
-(void)viewDidDisappear:(BOOL)animated{
    [_player stop];
    //_player=nil;
  //  [_player release];
}
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    _isPlaying=NO;
    //[_player release];
   // _player=nil;
}
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    _isPlaying=NO;
    //[_player release];
   // _player=nil;
}
@end
