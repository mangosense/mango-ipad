//
//  MangoDashbProfileViewController.m
//  MangoReader
//
//  Created by Harish on 4/27/14.
//
//

#import "MangoDashbProfileViewController.h"

@interface MangoDashbProfileViewController ()

@end

@implementation MangoDashbProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Second Tab";
        self.tabBarItem.image = [UIImage imageNamed:@"Logout.png"];
       // [[[self tabBarController] tabBar] setSelectionIndicatorImage:[UIImage imageNamed:@"facebook_login.png"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (IBAction)logoutUser:(id)sender{
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
