//
//  MangoStoreCollectionViewController.m
//  MangoReader
//
//  Created by Avinash Nehra on 1/13/14.
//
//

#import "MangoStoreCollectionViewController.h"
#import "MBProgressHUD.h"
#import "Constants.h"

#define STORE_BOOK_CELL_ID @"StoreBookCell"

@interface MangoStoreCollectionViewController () {

    NSMutableDictionary *bookDict;
}

@end

@implementation MangoStoreCollectionViewController

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
	// Do any additional setup after loading the view.
//     [self.collectionView registerClass:[StoreBookCell class] forCellWithReuseIdentifier:STORE_BOOK_CELL_ID];
    NSLog(@"%@", self.categoryID);
    [self getCategoryBooks];
}

- (void)getCategoryBooks {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
    apiController.delegate = self;
    NSString *url = [STORY_FILTER_CATEGORY stringByAppendingString:[self.categoryID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [apiController getListOf:url ForParameters:nil];
}

- (void)reloadViewsWithArray:(NSArray *)dataArray ForType:(NSString *)type {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"Data Array: %@", dataArray);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)bacKButtonTapped:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

@end
