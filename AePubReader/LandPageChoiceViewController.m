//
//  LandPageChoiceViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 19/11/13.
//
//

#import "LandPageChoiceViewController.h"
#import "NewStoreCoverViewController.h"
#import "CustomNavViewController.h"
#import "CategoriesViewController.h"
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
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.controller=self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)creatAStory:(id)sender {
    _storiesViewController = [[StoriesViewController alloc] initWithNibName:@"StoriesViewController" bundle:nil];
    [self.navigationController pushViewController:_storiesViewController animated:YES];
}

- (IBAction)openFreeStories:(id)sender {
 
}

- (IBAction)store:(id)sender {
    NewStoreCoverViewController *controller=[[NewStoreCoverViewController alloc]initWithNibName:@"NewStoreCoverViewController" bundle:nil shouldShowLibraryButton:NO];
    [self.navigationController pushViewController:controller animated:YES];
    
    
    
}

- (IBAction)myStories:(id)sender {
    CategoriesViewController *categoryViewController=[[CategoriesViewController alloc]initWithNibName:@"CategoriesViewController" bundle:nil];
    [self.navigationController pushViewController:categoryViewController animated:YES];
}
@end
