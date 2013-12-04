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
#import "BooksFromCategoryViewController.h"
#import "MangoStoreViewController.h"

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
    BooksFromCategoryViewController *booksCategoryViewController=[[BooksFromCategoryViewController alloc]initWithNibName:@"BooksFromCategoryViewController" bundle:nil withInitialIndex:0];
    booksCategoryViewController.toEdit=YES;
    [self.navigationController pushViewController:booksCategoryViewController animated:YES];
    
//    _storiesViewController = [[StoriesViewController alloc] initWithNibName:@"StoriesViewController" bundle:nil];
//    [self.navigationController pushViewController:_storiesViewController animated:YES];
}

- (IBAction)openFreeStories:(id)sender {
    [self store:nil];
}

- (IBAction)store:(id)sender {
    //NewStoreCoverViewController *controller=[[NewStoreCoverViewController alloc]initWithNibName:@"NewStoreCoverViewController" bundle:nil shouldShowLibraryButton:NO];
    //[self.navigationController pushViewController:controller animated:YES];
    
    MangoStoreViewController *storeViewController = [[MangoStoreViewController alloc] initWithNibName:@"MangoStoreViewController" bundle:nil];
    [self.navigationController pushViewController:storeViewController animated:YES];
}

- (IBAction)myStories:(id)sender {
    CategoriesViewController *categoryViewController=[[CategoriesViewController alloc]initWithNibName:@"CategoriesViewController" bundle:nil];
    [self.navigationController pushViewController:categoryViewController animated:YES];
}
@end
