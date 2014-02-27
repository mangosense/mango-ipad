//
//  CategoriesFlexibleViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 20/11/13.
//
//

#import "CategoriesFlexibleViewController.h"
#import "BooksFromCategoryViewController.h"
#import "AePubReaderAppDelegate.h"
#import "SettingOptionViewController.h"
#import "MyStoriesBooksViewController.h"
#import "Constants.h"
#import "MBProgressHUD.h"

#define NUMBER_OF_CATEGORIES_PER_PAGE 6

@interface CategoriesFlexibleViewController ()

@end

@implementation CategoriesFlexibleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil pageNumber:(int)pageNumber {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _pageNumber = pageNumber;
    }
    return self;
}

- (IBAction)previousController:(id)sender {
       [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (!_categoriesArray) {
        [self getAllCategories];
    } else {
        [self setupUI];
    }
    
    if (_pageNumber == 0) {
        [self getAllPurchasedBooks];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openBooks:(id)sender {
    /*MyStoriesBooksViewController *myStoriesBooksViewController = [[MyStoriesBooksViewController alloc] initWithNibName:@"MyStoriesBooksViewController" bundle:nil];
    myStoriesBooksViewController.toEdit = NO;
    
    [self.navigationController pushViewController:myStoriesBooksViewController animated:YES];*/
    
    /// -----
    
    UIButton *button = (UIButton *)sender;
    NSDictionary *categorySelected = [_categoriesArray objectAtIndex:button.tag];
    
    BooksFromCategoryViewController *booksCategoryViewController=[[BooksFromCategoryViewController alloc]initWithNibName:@"BooksFromCategoryViewController" bundle:nil withInitialIndex:0];
    booksCategoryViewController.toEdit=NO;
    booksCategoryViewController.categorySelected = categorySelected;
    [self.navigationController pushViewController:booksCategoryViewController animated:YES];
}

- (IBAction)homeButton:(id)sender {
   
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *controller=(UIViewController *)delegate.controller;
    [self.navigationController popToViewController:controller animated:YES];
}

- (IBAction)settingsButton:(id)sender {
    UIButton *button=(UIButton *) sender;
    SettingOptionViewController *settingsViewController=[[SettingOptionViewController alloc]initWithStyle:UITableViewCellStyleDefault];
    settingsViewController.dismissDelegate=self;
    settingsViewController.controller=self.navigationController;
    _popOverController=[[UIPopoverController alloc]initWithContentViewController:settingsViewController];
    [_popOverController presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)nextButtonTapped:(id)sender {
    if ((_pageNumber+ 1)*NUMBER_OF_CATEGORIES_PER_PAGE < [_categoriesArray count]) {
        CategoriesFlexibleViewController *categoryFlexible=[[CategoriesFlexibleViewController alloc]initWithNibName:@"CategoriesFlexibleViewController" bundle:nil];
        categoryFlexible.pageNumber = _pageNumber + 1;
        categoryFlexible.categoriesArray = _categoriesArray;
        
        [self.navigationController pushViewController:categoryFlexible animated:YES];
    }
}

-(void)dismissPopOver{
    [_popOverController dismissPopoverAnimated:YES];

}

#pragma mark - Setup UI

- (void)setupUI {
    NSMutableArray *currentPageCategoriesArray = [[NSMutableArray alloc] init];
    
    NSArray *buttonsArray = [NSArray arrayWithObjects:_categoryButtonOne, _categoryButtonTwo, _categoryButtonThree, _categoryButtonFour, _categoryButtonFive, _categoryButtonSix, nil];
    for (int i = NUMBER_OF_CATEGORIES_PER_PAGE*_pageNumber; i < NUMBER_OF_CATEGORIES_PER_PAGE*(_pageNumber + 1); i++) {
        [currentPageCategoriesArray addObject:[_categoriesArray objectAtIndex:i]];
        UIButton *button = [buttonsArray objectAtIndex:i%NUMBER_OF_CATEGORIES_PER_PAGE];
        NSString *imageName;
        if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Bedtime Stories"]) {
            imageName = @"bedtimestories.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Traditional Tales"]) {
            imageName = @"traditional.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Poems and Songs"]) {
            imageName = @"poems and rhymes.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Holidays and Celebrations"]) {
            imageName = @"celebrations.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Morals and Values"]) {
            imageName = @"values.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Classic Stories"]) {
            imageName = @"classics.png";
        } else {
            imageName = @"icon_my existing books.png";
        }
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    
    _categoryLabelOne.text = [[currentPageCategoriesArray objectAtIndex:0] objectForKey:NAME];
    _categoryLabelTwo.text = [[currentPageCategoriesArray objectAtIndex:1] objectForKey:NAME];
    _categoryLabelThree.text = [[currentPageCategoriesArray objectAtIndex:2] objectForKey:NAME];
    _categoryLabelFour.text = [[currentPageCategoriesArray objectAtIndex:3] objectForKey:NAME];
    _categoryLabelFive.text = [[currentPageCategoriesArray objectAtIndex:4] objectForKey:NAME];
    _categoryLabelSix.text = [[currentPageCategoriesArray objectAtIndex:5] objectForKey:NAME];

    _categoryButtonOne.tag = _pageNumber*NUMBER_OF_CATEGORIES_PER_PAGE + 0;
    _categoryButtonTwo.tag = _pageNumber*NUMBER_OF_CATEGORIES_PER_PAGE + 1;
    _categoryButtonThree.tag = _pageNumber*NUMBER_OF_CATEGORIES_PER_PAGE + 2;
    _categoryButtonFour.tag = _pageNumber*NUMBER_OF_CATEGORIES_PER_PAGE + 3;
    _categoryButtonFive.tag = _pageNumber*NUMBER_OF_CATEGORIES_PER_PAGE + 4;
    _categoryButtonSix.tag = _pageNumber*NUMBER_OF_CATEGORIES_PER_PAGE + 5;

}

#pragma mark - Post API

- (void)getBookAtPath:(NSURL *)filePath {
    
    [filePath setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:nil];
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate unzipExistingJsonBooks];
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)reloadViewsWithArray:(NSArray *)dataArray ForType:(NSString *)type {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if ([type isEqualToString:CATEGORIES]) {
        NSMutableArray *categoriesWithMyBooksCategoryArray = [NSMutableArray arrayWithArray:dataArray];
        [categoriesWithMyBooksCategoryArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"My Books", NAME, nil]];
        _categoriesArray = [NSArray arrayWithArray:categoriesWithMyBooksCategoryArray];
        
        [self setupUI];
    } else if ([type isEqualToString:PURCHASED_STORIES]) {
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        
        for (NSDictionary *dataDict in dataArray) {
            NSString *bookId = [dataDict objectForKey:@"id"];
            Book *bk=[delegate.dataModel getBookOfId:bookId];
            if (!bk) {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                
                MangoApiController *apiController = [MangoApiController sharedApiController];
                [apiController downloadBookWithId:bookId withDelegate:self];
            }
        }
    }
}

#pragma mark - Get Categories

- (void)getAllCategories {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
    [apiController getListOf:CATEGORIES ForParameters:nil withDelegate:self];
}

#pragma mark - Get Purchased Books

- (void)getAllPurchasedBooks {
    MangoApiController *apiController = [MangoApiController sharedApiController];
    
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
