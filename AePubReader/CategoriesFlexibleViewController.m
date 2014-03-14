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
#import "BooksCollectionViewController.h"

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
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (_pageNumber == 0 && !appDelegate.arePurchasesDownloading) {
        [self getAllPurchasedBooks];
        [self getAllFreeBooks];
        appDelegate.arePurchasesDownloading = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {

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
    
    BooksCollectionViewController *booksCollectionViewController = [[BooksCollectionViewController alloc] initWithNibName:@"BooksCollectionViewController" bundle:nil];
    booksCollectionViewController.toEdit = NO;
    booksCollectionViewController.categorySelected = categorySelected;
    [self.navigationController pushViewController:booksCollectionViewController animated:YES];
    
    /// -----
    /*BooksFromCategoryViewController *booksCategoryViewController=[[BooksFromCategoryViewController alloc]initWithNibName:@"BooksFromCategoryViewController" bundle:nil withInitialIndex:0];
    booksCategoryViewController.toEdit=NO;
    booksCategoryViewController.categorySelected = categorySelected;
    [self.navigationController pushViewController:booksCategoryViewController animated:YES];*/
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

#pragma mark - Get Books Count

- (NSDictionary *)bookCountForCategory {
    NSMutableDictionary *bookCountDict = [NSMutableDictionary dictionary];
    
    for (NSDictionary *categoryDict in _categoriesArray) {
        [bookCountDict setObject:[NSNumber numberWithInt:0] forKey:[categoryDict objectForKey:NAME]];
    }
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *allBooks = [appDelegate.dataModel getAllUserBooks];
    
    int allBooksCount = 0;
    for (Book *book in allBooks) {
        if ([appDelegate.ejdbController getBookForBookId:book.id]) {
            NSString *jsonLocation=book.localPathFile;
            NSFileManager *fm = [NSFileManager defaultManager];
            NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
            NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
            NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
            jsonLocation = [jsonLocation stringByAppendingPathComponent:[onlyJson firstObject]];
            
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonLocation] options:NSJSONReadingAllowFragments error:nil];
            
            NSLog(@"Categories - %@", [[jsonDict objectForKey:@"info"] objectForKey:@"categories"]);
            for (NSString *category in [[jsonDict objectForKey:@"info"] objectForKey:@"categories"]) {
                int bookCount = [[bookCountDict objectForKey:category] intValue];
                bookCount += 1;
                [bookCountDict setObject:[NSNumber numberWithInt:bookCount] forKey:category];
            }
            allBooksCount += 1;
        }
    }
    
    [bookCountDict setObject:[NSNumber numberWithInt:allBooksCount] forKey:ALL_BOOKS_CATEGORY];
    
    return bookCountDict;
}

#pragma mark - Setup UI

- (void)setupUI {
    NSDictionary *bookCountDict = [self bookCountForCategory];
    NSLog(@"%@", bookCountDict);

    NSMutableArray *currentPageCategoriesArray = [[NSMutableArray alloc] init];
    
    NSArray *buttonsArray = [NSArray arrayWithObjects:_categoryButtonOne, _categoryButtonTwo, _categoryButtonThree, _categoryButtonFour, _categoryButtonFive, _categoryButtonSix, nil];
    for (int i = NUMBER_OF_CATEGORIES_PER_PAGE*_pageNumber; i < MIN(NUMBER_OF_CATEGORIES_PER_PAGE*(_pageNumber + 1), [_categoriesArray count]); i++) {
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
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Animals and Nature"]) {
            imageName = @"animals-and-nature.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"My Books"]) {
            imageName = @"my-books.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"School Time"]) {
            imageName = @"school-time.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Family and Friends"]) {
            imageName = @"family-and-friends.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Action and Adventure"]) {
            imageName = @"Action and Adventure.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Comics and Graphic Novels"]) {
            imageName = @"Comics and Graphic Novels.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Financial Literacy"]) {
            imageName = @"Financial Literacy.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"General and Miscellaneous"]) {
            imageName = @"General and Miscellaneous.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Humour"]) {
            imageName = @"Humour.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Mystery and Suspense"]) {
            imageName = @"Mystery and Suspense.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Picture Books"]) {
            imageName = @"Picture Books.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Science and Nature"]) {
            imageName = @"Science and Nature.png";
        } else {
            imageName = @"icon_my existing books.png";
        }
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        
        if ([[bookCountDict objectForKey:[[_categoriesArray objectAtIndex:i] objectForKey:@"name"]] intValue] > 0) {
            UILabel *bookcountLabel = [[UILabel alloc] initWithFrame:CGRectMake(button.frame.origin.x + button.frame.size.width - 30, button.frame.origin.y - 14, 44, 44)];
            [bookcountLabel setBackgroundColor:COLOR_LIGHT_GREY];
            [bookcountLabel setAlpha:0.8f];
            [bookcountLabel setFont:[UIFont boldSystemFontOfSize:32.0f]];
            [bookcountLabel setTextColor:[UIColor blackColor]];
            [bookcountLabel setTextAlignment:NSTextAlignmentCenter];
            [[bookcountLabel layer] setCornerRadius:22.0f];
            [bookcountLabel setClipsToBounds:YES];
            [bookcountLabel setText:[NSString stringWithFormat:@"%d", [[bookCountDict objectForKey:[[_categoriesArray objectAtIndex:i] objectForKey:@"name"]] intValue]]];
            [self.view addSubview:bookcountLabel];
        }
    }
    
    for (int i = 0; i < [currentPageCategoriesArray count]; i++) {
        switch (i) {
            case 0:
                _categoryLabelOne.text = [[currentPageCategoriesArray objectAtIndex:i] objectForKey:NAME];
                _categoryButtonOne.tag = _pageNumber*NUMBER_OF_CATEGORIES_PER_PAGE + i;
                break;
                
            case 1:
                _categoryLabelTwo.text = [[currentPageCategoriesArray objectAtIndex:i] objectForKey:NAME];
                _categoryButtonTwo.tag = _pageNumber*NUMBER_OF_CATEGORIES_PER_PAGE + i;
                break;
                
            case 2:
                _categoryLabelThree.text = [[currentPageCategoriesArray objectAtIndex:i] objectForKey:NAME];
                _categoryButtonThree.tag = _pageNumber*NUMBER_OF_CATEGORIES_PER_PAGE + i;
                break;
                
            case 3:
                _categoryLabelFour.text = [[currentPageCategoriesArray objectAtIndex:i] objectForKey:NAME];
                _categoryButtonFour.tag = _pageNumber*NUMBER_OF_CATEGORIES_PER_PAGE + i;
                break;
                
            case 4:
                _categoryLabelFive.text = [[currentPageCategoriesArray objectAtIndex:i] objectForKey:NAME];
                _categoryButtonFive.tag = _pageNumber*NUMBER_OF_CATEGORIES_PER_PAGE + i;
                break;
                
            case 5:
                _categoryLabelSix.text = [[currentPageCategoriesArray objectAtIndex:i] objectForKey:NAME];
                _categoryButtonSix.tag = _pageNumber*NUMBER_OF_CATEGORIES_PER_PAGE + i;
                break;
                
            default:
                break;
        }
    }
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
        [categoriesWithMyBooksCategoryArray insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"All Books", NAME, nil] atIndex:0];
        _categoriesArray = [NSArray arrayWithArray:categoriesWithMyBooksCategoryArray];
        
        [self setupUI];
    } else if ([type isEqualToString:PURCHASED_STORIES] || [type isEqualToString:FREE_STORIES]) {
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        
        int numberOfBooksForDownload = 0;
        for (NSDictionary *dataDict in dataArray) {
            NSString *bookId = [dataDict objectForKey:@"id"];
            Book *bk=[delegate.dataModel getBookOfEJDBId:bookId];
            if (!bk) {
                MangoApiController *apiController = [MangoApiController sharedApiController];
                [apiController downloadBookWithId:bookId withDelegate:self ForTransaction:nil];
                numberOfBooksForDownload += 1;
            }
        }
        
        if (numberOfBooksForDownload > 0) {
            UIAlertView *booksDownloadAlertView = [[UIAlertView alloc] initWithTitle:@"Downloading Books" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            if ([type isEqualToString:PURCHASED_STORIES]) {
                [booksDownloadAlertView setMessage:@"Your purchased books are being downloaded in the background."];
            } else {
                [booksDownloadAlertView setMessage:@"You have 5 free books from MangoReader! They will be downloaded in the background, while you continue exploring the app."];
            }
            [booksDownloadAlertView show];
        }
    }
}

#pragma mark - Get Categories

- (void)getAllCategories {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
    [apiController getListOf:CATEGORIES ForParameters:nil withDelegate:self];
}

#pragma mark - Get Books

-(void)getAllFreeBooks {
    MangoApiController *apiController = [MangoApiController sharedApiController];
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.loggedInUserInfo) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [apiController getListOf:FREE_STORIES ForParameters:nil withDelegate:self];
    }
}

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
