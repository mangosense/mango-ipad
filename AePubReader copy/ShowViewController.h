//
//  ShowViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 30/12/12.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface ShowViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate>
@property (retain, nonatomic) IBOutlet UITableView *tableView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil with:(NSInteger )value;
@property(retain,nonatomic)NSMutableArray *array;
@property(nonatomic,assign)UIPopoverController *pop;
@property(nonatomic,retain)AVAudioPlayer *player;
@property(nonatomic,retain)UIButton *button;
@property(nonatomic,assign)NSInteger identity;
@end
