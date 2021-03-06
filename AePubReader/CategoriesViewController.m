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
#import "MyStoriesBooksViewController.h"

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
    /*MyStoriesBooksViewController *myStoriesBooksViewController = [[MyStoriesBooksViewController alloc] initWithNibName:@"MyStoriesBooksViewController" bundle:nil];
    myStoriesBooksViewController.toEdit = NO;
    
    [self.navigationController pushViewController:myStoriesBooksViewController animated:YES];*/
    
    /// -------
    BooksFromCategoryViewController *booksCategoryViewController=[[BooksFromCategoryViewController alloc]initWithNibName:@"BooksFromCategoryViewController" bundle:nil withInitialIndex:0];
    booksCategoryViewController.toEdit=NO;
    
    [self.navigationController pushViewController:booksCategoryViewController animated:YES];
}
    
- (IBAction)nextButton:(id)sender {
    CategoriesFlexibleViewController *categoryFlexible=[[CategoriesFlexibleViewController alloc]initWithNibName:@"CategoriesFlexibleViewController" bundle:nil];
    [self.navigationController pushViewController:categoryFlexible animated:YES];
}

#pragma mark - Post API Delegate

- (void)getBookAtPath:(NSURL *)filePath {

    [filePath setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:nil];
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate unzipExistingJsonBooks];
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
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
            //[apiController downloadBookWithId:bookId withDelegate:self];
        }
    }
    //[self openBooks:nil];
}

#pragma mark - Get Purchased Books

- (void)getAllPurchasedBooks {
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
//    apiController.delegate = self;
    
    NSMutableDictionary *paramsdict = [[NSMutableDictionary alloc] init];
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.loggedInUserInfo) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        [paramsdict setObject:appDelegate.loggedInUserInfo.authToken forKey:AUTH_TOKEN];
        [paramsdict setObject:appDelegate.loggedInUserInfo.email forKey:EMAIL];
        
        [apiController getListOf:PURCHASED_STORIES ForParameters:paramsdict withDelegate:self];
    }
    
}

@end
