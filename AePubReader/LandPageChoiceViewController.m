//
//  LandPageChoiceViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 19/11/13.
//
//

#import "LandPageChoiceViewController.h"
#import "NewStoreCoverViewController.h"
@interface LandPageChoiceViewController ()

@end

@implementation LandPageChoiceViewController

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

- (IBAction)creatAStory:(id)sender {
}

- (IBAction)openFreeStories:(id)sender {
}

- (IBAction)store:(id)sender {
    NewStoreCoverViewController *controller=[[NewStoreCoverViewController alloc]initWithNibName:@"NewStoreCoverViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
    
    
    
}

- (IBAction)myStories:(id)sender {
}
@end
