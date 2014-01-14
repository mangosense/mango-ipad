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

    NSMutableDictionary *bookDict;
}

@property (nonatomic, strong) UICollectionView *booksCollectionView;

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
//     [self.collectionView registerClass:[StoreBookCell class] forCellWithReuseIdentifier:STORE_BOOK_CELL_ID];
    NSLog(@"%@", self.categoryID);
    [self getCategoryBooks];
}



- (void)setUpInitialUI {

    CGRect viewFrame = self.view.bounds;
    
    StoreCollectionFlowLayout *layout = [[StoreCollectionFlowLayout alloc] init];
    _booksCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(CGRectGetMinX(viewFrame), 80, CGRectGetWidth(viewFrame), CGRectGetHeight(viewFrame)-80) collectionViewLayout:layout];
    _booksCollectionView.dataSource = self;
    _booksCollectionView.delegate =self;
    _booksCollectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [_booksCollectionView registerClass:[StoreBookCell class] forCellWithReuseIdentifier:STORE_BOOK_CELL_ID];
    [_booksCollectionView registerClass:[StoreCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HEADER_ID];
    [_booksCollectionView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_booksCollectionView];
}

- (void)getCategoryBooks {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
    apiController.delegate = self;
    NSString *url = [STORY_FILTER_CATEGORY stringByAppendingString:self.categoryID];
//    NSString *url = [STORY_FILTER_CATEGORY stringByAppendingString:[self.categoryID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [apiController getListOf:url ForParameters:nil];
}

- (void)reloadViewsWithArray:(NSArray *)dataArray ForType:(NSString *)type {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"Data Array: %@", dataArray);
    [self setUpInitialUI];
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
    
    return 5;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    
    return 6+1;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    StoreBookCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:STORE_BOOK_CELL_ID forIndexPath:indexPath];
    
    cell.bookAgeGroupLabel.text = [NSString stringWithFormat:@"For Age %d-%d Yrs", 2*(indexPath.section - 1), 2*(indexPath.section - 1) + 2];
    cell.delegate = self;
    
//    NSDictionary *bookDict = [_liveStoriesArray objectAtIndex:indexPath.row];
    
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
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    StoreCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HEADER_ID forIndexPath:indexPath];
    headerView.titleLabel.textColor = COLOR_DARK_RED;
    headerView.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    headerView.titleLabel.text = [NSString stringWithFormat:@"For Age %d-%d Years", 2*(indexPath.section), 2*(indexPath.section) + 2];
    
    return headerView;    
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(20, 20, 20, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    return CGSizeMake(collectionView.frame.size.width, 20);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(150, 270);
}

@end
