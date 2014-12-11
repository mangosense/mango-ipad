//
//  DetailsViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 31/12/12.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface DetailsViewController : UIViewController<AVAudioPlayerDelegate>
@property (retain, nonatomic) IBOutlet UILabel *fileName;
@property(retain,nonatomic)NSString *loc;
@property(retain,nonatomic)NSString *titleLabel;
@property(assign,nonatomic)BOOL isPlaying;
@property(retain,nonatomic) AVAudioPlayer *player;
- (IBAction)playOrPause:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *playPause;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString *)stringValue value:(NSString *)val;
@end
