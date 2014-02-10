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
#import "StoreCollectionFlowLayout.h"
#import "StoreCollectionHeaderView.h"
#import "CargoBay.h"

#define STORE_BOOK_CELL_ID @"StoreBookCell"
#define HEADER_ID @"headerId"

@interface MangoStoreCollectionViewController () {

    NSArray *collectionHeaderViewTitleArray;
}

@property (nonatomic, strong) UICollectionView *booksCollectionView;
@property (nonatomic, strong) NSMutableArray *liveStoriesArray;
@property (nonatomic, strong) UILabel *kTitle;
@property (nonatomic, strong) NSMutableDictionary *localImagesDictionary;

@end

@implementation MangoStoreCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//  [self.collectionView registerClass:[StoreBookCell class] forCellWithReuseIdentifier:STORE_BOOK_CELL_ID];
    _localImagesDictionary = [[NSMutableDictionary alloc] init];

    NSLog(@"%@", self.selectedItemDetail);
    self.kTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    self.kTitle.textAlignment = NSTextAlignmentCenter;
    self.kTitle.font = [UIFont boldSystemFontOfSize:18.0];
    self.kTitle.backgroundColor = COLOR_BROWN;
    self.kTitle.layer.cornerRadius = 10.0;
    self.kTitle.numberOfLines = 1;
    self.kTitle.textColor = [UIColor whiteColor];
    self.kTitle.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    self.kTitle.text = self.selectedItemTitle;
    [self.kTitle sizeToFit];    
    
    [self.kTitle setFrame:CGRectMake(self.kTitle.frame.origin.x, self.kTitle.frame.origin.y, self.kTitle.frame.size.width + 32, self.kTitle.frame.size.height)];
    
    CGRect frame = self.kTitle.frame;
    frame.origin.x = (CGRectGetWidth(self.view.frame) - CGRectGetWidth(frame))/2;
    frame.origin.y = 24;
    frame.size.height = 44;
    
    self.kTitle.frame = frame;
    [self.view addSubview:self.kTitle];
    
    [self setUpInitialUI];
    [self getFilteredStories];
}


- (void)setUpInitialUI {
    CGRect viewFrame = self.view.bounds;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    _booksCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(CGRectGetMinX(viewFrame), 80, CGRectGetWidth(viewFrame), CGRectGetHeight(viewFrame)-80) collectionViewLayout:layout];
    _booksCollectionView.dataSource = self;
    _booksCollectionView.delegate =self;
    _booksCollectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [_booksCollectionView registerClass:[StoreBookCell class] forCellWithReuseIdentifier:STORE_BOOK_CELL_ID];
    [_booksCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"defaultHeader"];
    [_booksCollectionView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_booksCollectionView];
}

- (void)getFilteredStories {
    MangoApiController *apiController = [MangoApiController sharedApiController];
//    apiController.delegate = self;
    
    NSString *url;
    
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setObject:[NSNumber numberWithInt:30] forKey:LIMIT];
    NSString *filterName = [self.selectedItemTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    switch (self.tableType) {
        case TABLE_TYPE_CATEGORIES: {
            url = [STORY_FILTER_CATEGORY stringByAppendingString:filterName];
        }
            break;
            
        case TABLE_TYPE_AGE_GROUPS: {
            url = [STORY_FILTER_AGE_GROUP stringByAppendingString:filterName];
        }
            break;
            
        case TABLE_TYPE_LANGUAGE: {
            url = [STORY_FILTER_LANGUAGES stringByAppendingString:filterName];
        }
            break;
            
        case TABLE_TYPE_GRADE: {
            url = [STORY_FILTER_GRADE stringByAppendingString:filterName];
        }
            break;
            
        case TABLE_TYPE_SEARCH: {
            url = LIVE_STORIES_SEARCH;
            [paramDict setObject:filterName forKey:@"q"];
        }
            break;
            
        default: self.liveStoriesArray = [[NSMutableArray alloc] init];
            [self.liveStoriesArray addObjectsFromArray:self.liveStoriesQueried];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.booksCollectionView reloadData];
            return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [apiController getListOf:url ForParameters:paramDict withDelegate:self];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods

- (IBAction)bacKButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - CollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.liveStoriesArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {    
    StoreBookCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:STORE_BOOK_CELL_ID forIndexPath:indexPath];
    
//    cell.bookAgeGroupLabel.text = [NSString stringWithFormat:@"For Age %d-%d Yrs", 2*(indexPath.section - 1), 2*(indexPath.section - 1) + 2];
    cell.delegate = self;
    
    NSDictionary *bookDict;
    
    if(_liveStoriesArray.count > indexPath.row) {
        bookDict = [_liveStoriesArray objectAtIndex:indexPath.row];
        
        cell.bookPriceLabel.text = [NSString stringWithFormat:@"%d", [[bookDict objectForKey:@"price"] intValue]];//@"Rs. 99";
        cell.bookTitleLabel.text = [bookDict objectForKey:@"title"];
        [cell.bookTitleLabel setFrame:CGRectMake(2, cell.bookTitleLabel.frame.origin.y, cell.bookTitleLabel.frame.size.width, [cell.bookTitleLabel.text sizeWithFont:cell.bookTitleLabel.font constrainedToSize:CGSizeMake(cell.bookTitleLabel.frame.size.width, 50)].height)];
        [cell setNeedsLayout];
        
        cell.imageUrlString = [bookDict objectForKey:@"cover"];
        
        if (self.liveStoriesArray) {
            if ([_localImagesDictionary objectForKey:[ASSET_BASE_URL stringByAppendingString:[bookDict objectForKey:@"cover"]]]) {
                cell.bookImageView.image = [_localImagesDictionary objectForKey:[ASSET_BASE_URL stringByAppendingString:[bookDict objectForKey:@"cover"]]];
            } else {
                [cell getImageForUrl:[ASSET_BASE_URL stringByAppendingString:[bookDict objectForKey:@"cover"]]];
            }
        }
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"defaultHeader" forIndexPath:indexPath];
    return headerView;    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *bookDict = [_liveStoriesArray objectAtIndex:indexPath.row];

    NSString *productId = [bookDict objectForKey:@"id"];
    if (productId != nil && productId.length > 0) {
        [[PurchaseManager sharedManager] itemProceedToPurchase:productId storeIdentifier:productId withDelegate:self];
    }
    else {
        NSLog(@"Product dose not have relative Id");
    }
}

#pragma mark - Local Image Saving Delegate

- (void)saveImage:(UIImage *)image ForUrl:(NSString *)imageUrl {
    [_localImagesDictionary setObject:image forKey:imageUrl];
    [_booksCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(20, 20, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.frame.size.width, 20);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(150, 270);
}

#pragma mark - Post API Delegate

- (void)reloadViewsWithArray:(NSArray *)dataArray ForType:(NSString *)type {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (!self.liveStoriesArray) {
        _liveStoriesArray = [[NSMutableArray alloc] init];
    }
    [self.liveStoriesArray addObjectsFromArray:dataArray];
    
    [self.booksCollectionView reloadData];
}

# pragma mark - Private Methods

- (NSArray *)getStoriesForAgeGroup:(NSInteger)section {
    NSArray *stories = nil;
    
//    if (!self.liveStoriesArray) {
//        return stories;
//    }
//    
//    switch (section) {
//        case 1: stories = [self.liveStoriesFiltered objectForKey:@"0-2"];
//            break;
//        case 2: stories = [self.liveStoriesFiltered objectForKey:@"3-5"];
//            break;
//        case 3: stories = [self.liveStoriesFiltered objectForKey:@"6-8"];
//            break;
//        case 4: stories = [self.liveStoriesFiltered objectForKey:@"11-13"];
//            break;
//        case 5: stories = [self.liveStoriesFiltered objectForKey:@"13+"];
//            break;
//        default:
//            break;
//    }
    
    return stories;
}

@end
