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
#import "MyStoriesBooksViewController.h"
#import "CategoriesFlexibleViewController.h"

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
    /*MyStoriesBooksViewController *myStoriesBooksViewController = [[MyStoriesBooksViewController alloc] initWithNibName:@"MyStoriesBooksViewController" bundle:nil];
    myStoriesBooksViewController.toEdit = YES;
    
    [self.navigationController pushViewController:myStoriesBooksViewController animated:YES];*/

    /// -----
    BooksFromCategoryViewController *booksCategoryViewController=[[BooksFromCategoryViewController alloc]initWithNibName:@"BooksFromCategoryViewController" bundle:nil withInitialIndex:0];
    booksCategoryViewController.toEdit=YES;
    [self.navigationController pushViewController:booksCategoryViewController animated:YES];
    
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
    CategoriesFlexibleViewController *categoryFlexible=[[CategoriesFlexibleViewController alloc]initWithNibName:@"CategoriesFlexibleViewController" bundle:nil];
    categoryFlexible.pageNumber = 0;
    [self.navigationController pushViewController:categoryFlexible animated:YES];
}
@end
