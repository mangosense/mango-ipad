//
//  CategoriesViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 19/11/13.
//
//

#import "CategoriesViewController.h"

@interface CategoriesViewController ()

@end

@implementation CategoriesViewController

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

- (IBAction)backToLandingPage:(id)sender {
    [self.navigationController popToViewController:_controller animated:YES];
}
@end
