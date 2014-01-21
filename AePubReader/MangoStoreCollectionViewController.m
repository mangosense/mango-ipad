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

#define STORE_BOOK_CELL_ID @"StoreBookCell"
#define HEADER_ID @"headerId"

@interface MangoStoreCollectionViewController () {

    NSArray *collectionHeaderViewTitleArray;
}

@property (nonatomic, strong) UICollectionView *booksCollectionView;
@property (nonatomic, strong) NSMutableArray *liveStoriesArray;
@property (nonatomic, strong) UILabel *kTitle;

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
    [self.kTitle setFrame:CGRectMake(self.kTitle.frame.origin.x, self.kTitle.frame.origin.y, self.kTitle.frame.size.width + 16, self.kTitle.frame.size.height)];
    
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
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
//    apiController.delegate = self;
    
    NSString *url;
    NSDictionary *param = nil;
    
    switch (self.tableType) {
        case TABLE_TYPE_CATEGORIES: {
            url = [STORY_FILTER_CATEGORY stringByAppendingString:self.selectedItemDetail];
        }
            break;
            
        case TABLE_TYPE_AGE_GROUPS: {
            NSString *ageGroup = self.selectedItemDetail;
            NSRange range = [ageGroup rangeOfString:@" Years"];
            
            if (range.location != NSNotFound) {
                ageGroup = [ageGroup stringByReplacingCharactersInRange:range withString:@""];
            }
            url = [STORY_FILTER_AGE_GROUP stringByAppendingString:ageGroup];
        }
            break;
            
        case TABLE_TYPE_LANGUAGE: {
            url = [STORY_FILTER_LANGUAGES stringByAppendingFormat:@"%@/languages", self.selectedItemDetail];
        }
            break;
            
        case TABLE_TYPE_GRADE: {
        }
            break;
            
        case TABLE_TYPE_SEARCH: {
            url = LIVE_STORIES_SEARCH;
            param = [NSDictionary dictionaryWithObject:self.selectedItemDetail forKey:@"q"];
        }
            break;
            
        default:
            break;
    }
    
    [apiController getListOf:url ForParameters:param withDelegate:self];
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
    
//    bookDict = [self getStoriesForAgeGroup:indexPath.section][indexPath.row];
    
    cell.bookPriceLabel.text = [bookDict objectForKey:@"price"];//@"Rs. 99";
    
    cell.bookTitleLabel.text = [bookDict objectForKey:@"title"];
    [cell.bookTitleLabel setFrame:CGRectMake(2, cell.bookTitleLabel.frame.origin.y, cell.bookTitleLabel.frame.size.width, [cell.bookTitleLabel.text sizeWithFont:cell.bookTitleLabel.font constrainedToSize:CGSizeMake(cell.bookTitleLabel.frame.size.width, 50)].height)];
    [cell setNeedsLayout];
    
    cell.imageUrlString = [bookDict objectForKey:@"cover"];
//    if ([_localImagesDictionary objectForKey:[bookDict objectForKey:@"cover"]]) {
//        cell.bookImageView.image = [_localImagesDictionary objectForKey:[bookDict objectForKey:@"cover"]];
//    } else {
        [cell getImageForUrl:[bookDict objectForKey:@"cover"]];
//    }
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"defaultHeader" forIndexPath:indexPath];
    return headerView;    
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
    NSLog(@"Collection View Type: %@ /n Data Array: %@", type, dataArray);
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
