
//
//  MangoStoreViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 03/12/13.
//
//

#import "MangoStoreViewController.h"
#import "Constants.h"
#import "StoreCollectionFlowLayout.h"
#import "StoreCollectionHeaderView.h"
#import "AePubReaderAppDelegate.h"
#import "MBProgressHUD.h"
#import "BooksFromCategoryViewController.h"
#import "MangoStoreCollectionViewController.h"
#import "iCarouselImageView.h"
#import "CargoBay.h"

@interface MangoStoreViewController () <collectionSeeAllDelegate> {
}

@property (nonatomic, strong) UIPopoverController *filterPopoverController;
@property (nonatomic, strong) UICollectionView *booksCollectionView;
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) NSMutableArray *liveStoriesArray;
@property (nonatomic, strong) NSMutableDictionary *liveStoriesFiltered;
@property (nonatomic, strong) NSMutableDictionary *localImagesDictionary;
@property (nonatomic, strong) NSMutableArray *featuredStoriesArray;
@property (nonatomic, strong) NSArray *ageGroupsFoundInResponse;
@property (nonatomic, assign) BOOL liveStoriesFetched;
@property (nonatomic, assign) BOOL featuredStoriesFetched;
@property (nonatomic, strong) NSMutableArray *purchasedBooks;
@property (nonatomic, strong) NSString *currentProductPrice;
@property (nonatomic, assign) int liveStoriesForAgeCounter;

@end

@implementation MangoStoreViewController

@synthesize filterPopoverController;
@synthesize liveStoriesFiltered;
@synthesize liveStoriesForAgeCounter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    //Register observer
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:[CargoBay sharedManager]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _localImagesDictionary = [[NSMutableDictionary alloc] init];
    [self setupInitialUI];
    
    //Register observer
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[CargoBay sharedManager]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.searchTextField = textField;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:textField.text forKey:@"id"];
    
    [self itemType:TABLE_TYPE_SEARCH tappedWithDetail:dict];
    self.searchTextField = nil;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    /*    MangoApiController *apiController = [MangoApiController sharedApiController];
     //    apiController.delegate = self;
     [apiController getListOf:LIVE_STORIES_SEARCH ForParameters:[NSDictionary dictionaryWithObject:textField.text forKey:@"q"] withDelegate:self];
     */
}

#pragma mark - Action Methods

- (IBAction)goBackToStoryPage:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)filterSelected:(id)sender {
    [self.searchTextField resignFirstResponder];
    self.searchTextField = nil;
    
    ItemsListViewController *textTemplatesListViewController = [[ItemsListViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [textTemplatesListViewController.view setFrame:CGRectMake(0, 0, 250, 250)];
    textTemplatesListViewController.delegate = self;
    
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case CATEGORY_TAG: {
            textTemplatesListViewController.tableType = TABLE_TYPE_CATEGORIES;
        }
            break;
            
        case AGE_TAG: {
            textTemplatesListViewController.tableType = TABLE_TYPE_AGE_GROUPS;
        }
            break;
            
        case LANGUAGE_TAG: {
            textTemplatesListViewController.tableType = TABLE_TYPE_LANGUAGE;
        }
            break;
            
        case GRADE_TAG: {
            textTemplatesListViewController.tableType = TABLE_TYPE_GRADE;
        }
            break;
            
        default:
            break;
    }
    
    self.filterPopoverController = [[UIPopoverController alloc] initWithContentViewController:textTemplatesListViewController];
    [self.filterPopoverController setPopoverContentSize:CGSizeMake(250, 250)];
    self.filterPopoverController.delegate = self;
    [self.filterPopoverController.contentViewController.view setBackgroundColor:COLOR_LIGHT_GREY];
    [self.filterPopoverController presentPopoverFromRect:button.frame inView:self.view.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

#pragma mark - Post API Delegate

- (void)reloadViewsWithArray:(NSArray *)dataArray ForType:(NSString *)type {
    if ([type isEqualToString:AGE_GROUPS]) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        self.ageGroupsFoundInResponse = dataArray;
        
        MangoApiController *apiController = [MangoApiController sharedApiController];
        
        liveStoriesForAgeCounter = 0;
        //Get Stories For Age Groups
        for (NSDictionary *ageGroupDict in self.ageGroupsFoundInResponse) {
            NSString *ageGroup = [ageGroupDict objectForKey:NAME];
            [apiController getListOf:[STORY_FILTER_AGE_GROUP stringByAppendingString:ageGroup] ForParameters:nil withDelegate:self];
        }
        
        //Get Featured Stories
        if (!_featuredStoriesArray) {
            [apiController getListOf:FEATURED_STORIES ForParameters:nil withDelegate:self];
        }
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    } else if ([type isEqualToString:FEATURED_STORIES]) {
        if (!_featuredStoriesArray) {
            _featuredStoriesArray = [[NSMutableArray alloc] init];
        }
        [_featuredStoriesArray addObjectsFromArray:dataArray];
        _featuredStoriesFetched = YES;
    } else if ([type rangeOfString:STORY_FILTER_AGE_GROUP].location != NSNotFound) {
        NSArray *methodNameComponents = [type componentsSeparatedByString:@"/"];
        NSString *ageGroup = [methodNameComponents lastObject];
        
        if (!liveStoriesFiltered) {
            liveStoriesFiltered = [[NSMutableDictionary alloc] init];
        }
        [liveStoriesFiltered setObject:dataArray forKey:ageGroup];
        
        liveStoriesForAgeCounter += 1;
    }
    
    if (liveStoriesForAgeCounter == [self.ageGroupsFoundInResponse count] && _featuredStoriesFetched) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        [_booksCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        [_storiesCarousel performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }
}

- (void)getBookAtPath:(NSURL *)filePath {
    [filePath setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:nil];
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate unzipExistingJsonBooks];
    
    BooksFromCategoryViewController *booksCategoryViewController=[[BooksFromCategoryViewController alloc]initWithNibName:@"BooksFromCategoryViewController" bundle:nil withInitialIndex:0];
    booksCategoryViewController.toEdit=NO;
    [self.navigationController pushViewController:booksCategoryViewController animated:YES];
}

#pragma mark - Purchased Manager Call Back

- (void)itemReadyToUse:(NSString *) productId {
    MangoApiController *apiController = [MangoApiController sharedApiController];
    [apiController downloadBookWithId:productId withDelegate:self];
}

#pragma mark - Filters

- (void)filterResponse {
    NSMutableDictionary *filteredStoriesDict = [[NSMutableDictionary alloc] init];

    for (NSDictionary *story in self.liveStoriesArray) {
        NSArray *ageGroups = [[story objectForKey:@"info"] objectForKey:@"age_groups"];
        
        for (NSString *ageGroupOfStory in ageGroups) {
            for (NSDictionary *ageGroupDict in self.ageGroupsFoundInResponse) {
                NSString *ageGroup = [ageGroupDict objectForKey:NAME];
                if ([ageGroup isEqualToString:ageGroupOfStory]) {
                    if ([[filteredStoriesDict allKeys] containsObject:ageGroup]) {
                        [[filteredStoriesDict objectForKey:ageGroup] addObject:story];
                    } else {
                        NSMutableArray *storiesArray = [[NSMutableArray alloc] initWithObjects:story, nil];
                        [filteredStoriesDict setObject:storiesArray forKey:ageGroup];
                    }
                    break;
                }
            }
        }

    }
    
    NSLog(@"%@", filteredStoriesDict);
    liveStoriesFiltered = filteredStoriesDict;
    [_booksCollectionView reloadData];
}

#pragma mark - Get Purchased Books

- (void)getLiveStories {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
    [apiController getListOf:LIVE_STORIES ForParameters:nil withDelegate:self];
}

- (void)getAllAgeGroups {
    MangoApiController *apiController = [MangoApiController sharedApiController];
    [apiController getListOf:AGE_GROUPS ForParameters:nil withDelegate:self];
}

- (void)setupInitialUI {
    [self getAllAgeGroups];
    //[self getLiveStories];
    
    CGRect viewFrame = self.view.bounds;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    _booksCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(CGRectGetMinX(viewFrame), 80, CGRectGetWidth(viewFrame), CGRectGetHeight(viewFrame)-80) collectionViewLayout:layout];
    _booksCollectionView.dataSource = self;
    _booksCollectionView.delegate =self;
    [_booksCollectionView registerClass:[StoreBookCarouselCell class] forCellWithReuseIdentifier:STORE_BOOK_CAROUSEL_CELL_ID];
    [_booksCollectionView registerClass:[StoreBookCell class] forCellWithReuseIdentifier:STORE_BOOK_CELL_ID];
    [_booksCollectionView registerClass:[StoreCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HEADER_ID];
    [_booksCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Section0"];
    [_booksCollectionView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_booksCollectionView];
}

#pragma mark - Items Delegate

- (void)itemType:(int)itemType tappedWithDetail:(NSDictionary *)detailDict {
    [self.filterPopoverController dismissPopoverAnimated:YES];
    NSString *detailId = [detailDict objectForKey:@"id"];
    NSString *detailTitle = [detailDict objectForKey:@"title"];
    
    if(!detailTitle) {
        detailTitle = detailId;     // id is same as title.... detailTitle will be nil.
    }
    
    MangoStoreCollectionViewController *selectedCategoryViewController = [[MangoStoreCollectionViewController alloc] initWithNibName:@"MangoStoreCollectionViewController" bundle:nil];
    selectedCategoryViewController.tableType = itemType;
    selectedCategoryViewController.selectedItemDetail = detailId;       // Used for API call
    selectedCategoryViewController.selectedItemTitle = detailTitle;     // Used for setting View's Title  :: Both vary e.g. as in case of category above will be an Alphanumeric value (id)
    [self.navigationController pushViewController:selectedCategoryViewController animated:YES];
}

- (void)seeAllTapped:(NSInteger)section {
    MangoStoreCollectionViewController *selectedCategoryViewController = [[MangoStoreCollectionViewController alloc] initWithNibName:@"MangoStoreCollectionViewController" bundle:nil];
    selectedCategoryViewController.selectedItemTitle = [[self.ageGroupsFoundInResponse[section-1] objectForKey:NAME] stringByAppendingString:@" Years"];
    NSString *ageGroup = [[self.ageGroupsFoundInResponse objectAtIndex:section-1] objectForKey:NAME];
    selectedCategoryViewController.liveStoriesQueried = [liveStoriesFiltered objectForKey:ageGroup];
    [self.navigationController pushViewController:selectedCategoryViewController animated:YES];
}

#pragma mark - iCarousel Delegates

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [_featuredStoriesArray count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    //TODO: Need to set images to carousel
    iCarouselImageView *storyImageView = (iCarouselImageView *)[view viewWithTag:iCarousel_VIEW_TAG];
    
    if (!storyImageView) {
        storyImageView = [[iCarouselImageView alloc] initWithFrame:CGRectMake(0, 0, 400, 240)];
        storyImageView.delegate = self;
        [storyImageView setImage:[UIImage imageNamed:@"backimageiphonen.png"]];
    }
    
    if (self.featuredStoriesFetched) {
        if ([_localImagesDictionary objectForKey:[ASSET_BASE_URL stringByAppendingString:[self.featuredStoriesArray[index] objectForKey:@"cover"]]]) {
            storyImageView.image = [_localImagesDictionary objectForKey:[ASSET_BASE_URL stringByAppendingString:[self.featuredStoriesArray[index] objectForKey:@"cover"]]];
        } else {
            [storyImageView getImageForUrl:[ASSET_BASE_URL stringByAppendingString:[self.featuredStoriesArray[index] objectForKey:@"cover"]]];
        }
    }
    
    return storyImageView;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    //customize carousel display
    switch (option) {
        case iCarouselOptionWrap: {
            //normally you would hard-code this to YES or NO
            return YES;
        }
            
        case iCarouselOptionSpacing: {
            //add a bit of spacing between the item views
            return value * 1.05f;
        }
            
        case iCarouselOptionFadeMax: {
            if (carousel.type == iCarouselTypeCustom) {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value;
        }
            
        default: {
            return value;
        }
    }
}

#pragma mark - Local Image Saving Delegate

- (void)iCarouselSaveImage:(UIImage *)image ForUrl:(NSString *)imageUrl {
    [_localImagesDictionary setObject:image forKey:imageUrl];
}

- (void)saveImage:(UIImage *)image ForUrl:(NSString *)imageUrl {
    [_localImagesDictionary setObject:image forKey:imageUrl];
    [_booksCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    if(section == 0) {
        return 1;
    } else {
        NSString *ageGroup = [[self.ageGroupsFoundInResponse objectAtIndex:section-1] objectForKey:NAME];
        return MIN(6, [[liveStoriesFiltered objectForKey:ageGroup] count]);
    }
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return self.ageGroupsFoundInResponse.count + 1;          // +1 for iCarousel at Section - 0.
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        StoreBookCarouselCell *cell = [cv dequeueReusableCellWithReuseIdentifier:STORE_BOOK_CAROUSEL_CELL_ID forIndexPath:indexPath];
        
        if (!_storiesCarousel) {
            _storiesCarousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, 984, 240)];
            _storiesCarousel.delegate = self;
            _storiesCarousel.dataSource = self;
            _storiesCarousel.type = iCarouselTypeCoverFlow;
            [cell.contentView addSubview:_storiesCarousel];
        }
        
        [_storiesCarousel reloadData];
        return cell;
    } else {
        StoreBookCell *cell = [cv dequeueReusableCellWithReuseIdentifier:STORE_BOOK_CELL_ID forIndexPath:indexPath];
        
        //        cell.bookAgeGroupLabel.text = [NSString stringWithFormat:@"For Age %d-%d Yrs", 2*(indexPath.section - 1), 2*(indexPath.section - 1) + 2];
        cell.delegate = self;
        
        NSDictionary *bookDict;
        
        if(liveStoriesFiltered) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSString *ageGroup = [[self.ageGroupsFoundInResponse objectAtIndex:indexPath.section-1] objectForKey:NAME];
            bookDict= [[liveStoriesFiltered objectForKey:ageGroup] objectAtIndex:indexPath.row];
        }
        //        else
        //            bookDict = [_liveStoriesArray objectAtIndex:indexPath.row];
        
        cell.bookPriceLabel.text = [bookDict objectForKey:@"price"];
        
        cell.bookTitleLabel.text = [bookDict objectForKey:@"title"];
        [cell.bookTitleLabel setFrame:CGRectMake(2, cell.bookTitleLabel.frame.origin.y, cell.bookTitleLabel.frame.size.width, [cell.bookTitleLabel.text sizeWithFont:cell.bookTitleLabel.font constrainedToSize:CGSizeMake(cell.bookTitleLabel.frame.size.width, 50)].height)];
        [cell setNeedsLayout];
        
        cell.imageUrlString = [bookDict objectForKey:@"cover"];
        if ([_localImagesDictionary objectForKey:[ASSET_BASE_URL stringByAppendingString:[bookDict objectForKey:@"cover"]]]) {
            cell.bookImageView.image = [_localImagesDictionary objectForKey:[ASSET_BASE_URL stringByAppendingString:[bookDict objectForKey:@"cover"]]];
        } else {
            [cell getImageForUrl:[ASSET_BASE_URL stringByAppendingString:[bookDict objectForKey:@"cover"]]];
        }
        
        return cell;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section != 0) {
        StoreCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HEADER_ID forIndexPath:indexPath];
        headerView.titleLabel.textColor = COLOR_DARK_RED;
        headerView.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        headerView.titleLabel.text = [[self.ageGroupsFoundInResponse[indexPath.section-1] objectForKey:NAME] stringByAppendingString:@" Years"];
        headerView.section = indexPath.section;
        headerView.delegate = self;
        
        if(liveStoriesFiltered) {
            headerView.seeAllButton.hidden = NO;
        }
        
        return headerView;
    } else {
        UICollectionReusableView *headerViewForCarousel = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Section0" forIndexPath:indexPath];
        return headerViewForCarousel;
    }
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *bookDict = [_liveStoriesArray objectAtIndex:indexPath.row];
    //TODO: Need to change key name.
    NSString *productId = [bookDict objectForKey:@"id"];
    if (productId != nil && productId.length > 0) {
        
        //        //Check product is already purchased or not?
        //        if ([self isProductPurchased:productId]) {
        //            [self itemReadyToUse:productId];//Download Product from server.
        //        }
        //        else {
        //            ///Purchasing Products
        //            //TODO: Need to change key name.
        //            NSString * skIdentifier = [bookDict objectForKey:@"purchasedProduct_Identifier"];
        
        //        [[PurchaseManager sharedManager] itemProceedToPurchase:productId storeIdentifier:skIdentifier withDelegate:self];
        
        //        }
        
        [[PurchaseManager sharedManager] itemProceedToPurchase:productId storeIdentifier:@"752" withDelegate:self];
    }
    else {
        NSLog(@"Product dose not have relative Id");
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if(section == 0) {
        return UIEdgeInsetsMake(10, 0, 10, 0);
    } else {
        return UIEdgeInsetsMake(20, 20, 0, 0);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return CGSizeMake(collectionView.frame.size.width, 0);
    } else {
        return CGSizeMake(collectionView.frame.size.width, 40);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(984, 240);
    }
    
    return CGSizeMake(150, 240);
}

#pragma mark - Private Methods

- (void)getImageForUrl:(NSString *)urlString {
    MangoApiController *apiController = [MangoApiController sharedApiController];
    [apiController getImageAtUrl:urlString withDelegate:self];
}

# pragma mark - Retrieving/Saving data from/to disk

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.searchTextField ) {
        [self.searchTextField resignFirstResponder];
        self.searchTextField = nil;
    }
}

@end
