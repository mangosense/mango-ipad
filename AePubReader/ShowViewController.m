//
//  ShowViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 30/12/12.
//
//

#import "ShowViewController.h"
#import "DetailsViewController.h"
@interface ShowViewController ()

@end

@implementation ShowViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil with:(NSInteger )value
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _identity=value;
        NSString *record=[[NSUserDefaults standardUserDefaults] objectForKey:@"recordingDirectory"];
        NSString *iden=[NSString stringWithFormat:@"%d",_identity ];
        record=[record stringByAppendingPathComponent:iden];
        
       NSArray *array= [[NSFileManager defaultManager] contentsOfDirectoryAtPath:record error:nil];
        if (array.count!=0) {
            
        
            _array=[[NSMutableArray alloc]initWithArray:array];
        }
    }
    return self;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  _array.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
    NSString *ver= [UIDevice currentDevice].systemVersion;
    if ([ver floatValue]>=6.0) {
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    else{
        cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        [cell autorelease];
    }
    cell.textLabel.text=[_array objectAtIndex:indexPath.row];
    cell.textLabel.textAlignment=NSTextAlignmentCenter;
//    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
//    UIImage *image=[UIImage imageNamed:@"play-control.png"];
//    [button setImage:image forState:UIControlStateNormal];
//    button.tag=indexPath.row;
//    button.frame=CGRectMake(20.0, 5.0, 66, 66);
//    [button addTarget:self action:@selector(PlayOrPause:) forControlEvents:UIControlEventTouchUpInside];
//    button.titleLabel.text=@"p";
//    [cell addSubview:button];
//    [button release];
    return cell;
}
-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *record=[[NSUserDefaults standardUserDefaults] objectForKey:@"recordingDirectory"];
    NSString *iden=[NSString stringWithFormat:@"%d",_identity ];
    record=[record stringByAppendingPathComponent:iden];
    record=[record stringByAppendingPathComponent:[_array objectAtIndex:indexPath.row]];
    DetailsViewController *details=[[DetailsViewController alloc]initWithNibName:@"DetailsViewController" bundle:nil title:[_array objectAtIndex:indexPath.row] value:record];
    [self.navigationController pushViewController:details animated:YES];
    [details release];
}

-(void)PlayOrPause:(id)sender{
    UIButton *button=(UIButton *)sender;
//    if (_button.retainCount==2) {
//        [_button release];
//    }

    if ([button.titleLabel.text isEqualToString:@"p"]) {
        button.titleLabel.text=@"s";
        UIImage *image=[UIImage imageNamed:@"stop-recording-control.png"];
        [button setImage:image forState:UIControlStateNormal];
        NSString *record=[[NSUserDefaults standardUserDefaults] objectForKey:@"recordingDirectory"];
        record=[record stringByAppendingFormat:@"/%d",_identity ];
        NSString *iden=[NSString stringWithFormat:@"%d.ima4",button.tag ];
        record=[record stringByAppendingPathComponent:iden];
        if (_player) {
            
            [_player stop];
            _player =nil;
            if (_button) {
                UIImage *image=[UIImage imageNamed:@"play-control.png"];
                [_button setImage:image forState:UIControlStateNormal];
                _button=button;
                [_button retain];
            }
        }
        _player=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:record] error:nil];
        [_player setDelegate:self];
        [_player play];
        
    }else{
        UIImage *image=[UIImage imageNamed:@"play-control.png"];
        [button setImage:image forState:UIControlStateNormal];
        [_player stop];
        _player=nil;
      button.titleLabel.text=@"p";
    }
}
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (flag) {
          UIImage *image=[UIImage imageNamed:@"play-control.png"];
        [_button setImage:image forState:UIControlStateNormal];
        [_player release];
        [_button release];
        _player=nil;
    }
    
}
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    NSLog(@"%@",error);
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (!_array) {
        [_pop dismissPopoverAnimated:YES];
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.contentSizeForViewInPopover=CGSizeMake(150.0, 400.0);
    // Do any additional setup after loading the view from its nib.
    [_tableView setDelegate:self];
  
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle ==UITableViewCellEditingStyleDelete) {
        NSString *record=[[NSUserDefaults standardUserDefaults] objectForKey:@"recordingDirectory"];
        NSString *iden=[NSString stringWithFormat:@"%d",_identity ];
        record=[record stringByAppendingPathComponent:iden];
        record =[record stringByAppendingPathComponent:[_array objectAtIndex:indexPath.row]];
        [[NSFileManager defaultManager] removeItemAtPath:record error:nil];
        [_array removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
      [_array release];
    [_tableView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

@end
