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
#import "BooksFromCategoryViewController.h"
#import "Constants.h"
#import "MBProgressHUD.h"

@interface CategoriesViewController ()

@property (nonatomic, strong) NSMutableArray *booksArray;

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
    [self getAllPurchasedBooks];
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
    BooksFromCategoryViewController *booksCategoryViewController=[[BooksFromCategoryViewController alloc]initWithNibName:@"BooksFromCategoryViewController" bundle:nil withInitialIndex:0];
    booksCategoryViewController.toEdit=NO;
    
    [self.navigationController pushViewController:booksCategoryViewController animated:YES];}
    
- (IBAction)nextButton:(id)sender {
    CategoriesFlexibleViewController *categoryFlexible=[[CategoriesFlexibleViewController alloc]initWithNibName:@"CategoriesFlexibleViewController" bundle:nil];
    [self.navigationController pushViewController:categoryFlexible animated:YES];
}

#pragma mark - Post API Delegate

- (void)getBookAtPath:(NSURL *)filePath {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    [filePath setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:nil];
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate unzipExistingJsonBooks];
}

- (void)reloadViewsWithArray:(NSArray *)dataArray ForType:(NSString *)type {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    _booksArray = [[NSMutableArray alloc] initWithArray:dataArray];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    
    for (NSDictionary *dataDict in dataArray) {
        NSString *bookId = [dataDict objectForKey:@"id"];
        Book *bk=[delegate.dataModel getBookOfId:bookId];
        if (!bk) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            MangoApiController *apiController = [MangoApiController sharedApiController];
            apiController.delegate = self;
            [apiController downloadBookWithId:bookId];
        }
    }
    //[self openBooks:nil];
}

#pragma mark - Get Purchased Books

- (void)getAllPurchasedBooks {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
//    apiController.delegate = self;
    
    NSMutableDictionary *paramsdict = [[NSMutableDictionary alloc] init];
    [paramsdict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:AUTH_TOKEN] forKey:AUTH_TOKEN];
    [paramsdict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:EMAIL] forKey:EMAIL];
    
    [apiController getListOf:PURCHASED_STORIES ForParameters:paramsdict withDelegate:self];
}

@end
