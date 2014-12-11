//
//  StatsViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 28/05/13.
//
//

#import "StatsViewController.h"

@interface StatsViewController ()

@end

@implementation StatsViewController

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
   NSInteger bookCount= [[NSUserDefaults standardUserDefaults]integerForKey:@"tbookCount"];
   NSInteger pageCounter= [[NSUserDefaults standardUserDefaults]integerForKey:@"tpageCount"];
  double timer=  [[NSUserDefaults standardUserDefaults]doubleForKey:@"timerCompleted"];
    _TimeRead.text=[NSString stringWithFormat:@"%.2f seconds",timer];
    _bookCount.text=[NSString stringWithFormat:@"%d books read",bookCount];
    _pageCount.text=[NSString stringWithFormat:@"%d pages turned",pageCounter];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTimeRead:nil];
    [self setPageCount:nil];
    [self setBookCount:nil];
    [super viewDidUnload];
}
- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
