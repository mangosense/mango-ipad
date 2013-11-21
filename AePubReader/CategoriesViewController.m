//
//  CategoriesViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 19/11/13.
//
//

#import "CategoriesViewController.h"
#import "SettingOptionViewController.h"
#import "CategoriesFlexibleViewController.h"
#import "AePubReaderAppDelegate.h"
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
AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
 UIViewController *controller=(UIViewController *)   delegate.controller;
    [self.navigationController popToViewController:controller animated:YES];
}

- (IBAction)settingsOption:(id)sender {
    UIButton *button=(UIButton *) sender;
    SettingOptionViewController *settingsViewController=[[SettingOptionViewController alloc]initWithStyle:UITableViewCellStyleDefault];
    settingsViewController.dismissDelegate=self;
    settingsViewController.controller=self.navigationController;
    _popOverController=[[UIPopoverController alloc]initWithContentViewController:settingsViewController];
    [_popOverController presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}
-(void)dismissPopOver{
    [_popOverController dismissPopoverAnimated:YES];
}
- (IBAction)openBooks:(id)sender {
    UIButton *button=(UIButton *)sender;
    switch (button.tag) {
        case 0:

        break;
        
        default:
        break;
    }
}
    
- (IBAction)nextButton:(id)sender {
    CategoriesFlexibleViewController *categoryFlexible=[[CategoriesFlexibleViewController alloc]initWithNibName:@"CategoriesFlexibleViewController" bundle:nil];
    [self.navigationController pushViewController:categoryFlexible animated:YES];
}
@end
