
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
#import "HKCircularProgressLayer.h"
#import "HKCircularProgressView.h"
#import "MyStoriesBooksViewController.h"

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
@property (nonatomic, strong) HKCircularProgressView *progressView;
@property (nonatomic, strong) NSString *selectedBookId;

@end

@implementation MangoStoreViewController

@synthesize filterPopoverController;
@synthesize liveStoriesFiltered;

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
    //bookDetailsViewController.priceLabel.text.font = [UIFont fontWithName:@"the_hungry_ghost" size:16.0];
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
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setObject:[NSNumber numberWithInt:6] forKey:LIMIT];
   // [paramDict setObject:IOS forKey:PLATFORM];

    if ([type isEqualToString:AGE_GROUPS]) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        self.ageGroupsFoundInResponse = dataArray;
        
        MangoApiController *apiController = [MangoApiController sharedApiController];
        
        //Get Stories For Age Groups
        for (NSDictionary *ageGroupDict in self.ageGroupsFoundInResponse) {
            NSString *ageGroup = [ageGroupDict objectForKey:NAME];
            [apiController getListOf:[STORY_FILTER_AGE_GROUP stringByAppendingString:ageGroup] ForParameters:paramDict withDelegate:self];
        }
        
        //Get Featured Stories
        if (!_featuredStoriesArray) {
            [apiController getListOf:FEATURED_STORIES ForParameters:paramDict withDelegate:self];
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
    } else {
        NSArray *methodNameComponents = [type componentsSeparatedByString:@"/"];
        NSString *filterString = [methodNameComponents lastObject];
        
        if (!liveStoriesFiltered) {
            liveStoriesFiltered = [[NSMutableDictionary alloc] init];
        }
        [liveStoriesFiltered removeAllObjects];
        [liveStoriesFiltered setObject:dataArray forKey:filterString];
    }
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    [_booksCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    [_storiesCarousel performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

- (void)getBookAtPath:(NSURL *)filePath {
    
    /*AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate unzipExistingJsonBooks];*/
    
    /*MyStoriesBooksViewController *myStoriesBooksViewController = [[MyStoriesBooksViewController alloc] initWithNibName:@"MyStoriesBooksViewController" bundle:nil];
    myStoriesBooksViewController.toEdit = NO;
    
    [self.navigationController pushViewController:myStoriesBooksViewController animated:YES];*/
    
    /// -----
    
    BooksFromCategoryViewController *booksCategoryViewController=[[BooksFromCategoryViewController alloc]initWithNibName:@"BooksFromCategoryViewController" bundle:nil withInitialIndex:0];
    booksCategoryViewController.toEdit = NO;
    [self.navigationController pushViewController:booksCategoryViewController animated:YES];
}

- (void)updateProgress:(NSNumber *)progress {
    if (!_progressView) {
        _progressView = [[HKCircularProgressView alloc] initWithFrame:CGRectMake(self.view.center.x - 50, self.view.center.y - 50, 100, 100)];
        _progressView.max = 100.0f;
        _progressView.step = 0.0f;
        [self.view addSubview:_progressView];
    }
    _progressView.current = [progress floatValue];
}

#pragma mark - Purchased Manager Call Back

- (void)itemReadyToUse:(NSString *)productId {
    MangoApiController *apiController = [MangoApiController sharedApiController];
    [apiController downloadBookWithId:productId withDelegate:self];
    
    _selectedBookId = productId;
}

#pragma mark - Get Books

- (void)getFilteredStories:(NSString *)filterName {
    filterName = [filterName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
    
    NSString *url;
    
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setObject:[NSNumber numberWithInt:100] forKey:LIMIT];
    
    switch (_tableType) {
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
            
        default:
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [_booksCollectionView reloadData];
            return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [apiController getListOf:url ForParameters:paramDict withDelegate:self];
}

- (void)getAllAgeGroups {
    MangoApiController *apiController = [MangoApiController sharedApiController];
    [apiController getListOf:AGE_GROUPS ForParameters:nil withDelegate:self];
}

- (void)setupInitialUI {
    _tableType = TABLE_TYPE_MAIN_STORE;
    [self getAllAgeGroups];
    
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
    
    _tableType = itemType;
    
    [self getFilteredStories:detailTitle];
}

- (void)seeAllTapped:(NSInteger)section {
    MangoStoreCollectionViewController *selectedCategoryViewController = [[MangoStoreCollectionViewController alloc] initWithNibName:@"MangoStoreCollectionViewController" bundle:nil];
    
    selectedCategoryViewController.selectedItemTitle = [self.ageGroupsFoundInResponse[section-1] objectForKey:NAME];
    selectedCategoryViewController.tableType = TABLE_TYPE_AGE_GROUPS;
    NSString *ageGroup = [[self.ageGroupsFoundInResponse objectAtIndex:section-1] objectForKey:NAME];
    selectedCategoryViewController.liveStoriesQueried = [liveStoriesFiltered objectForKey:ageGroup];
    [self.navigationController pushViewController:selectedCategoryViewController animated:YES];
}

#pragma mark - iCarousel Delegates

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    if (_featuredStoriesArray) {
        return [_featuredStoriesArray count];
    }
    return 5;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    iCarouselImageView *storyImageView = (iCarouselImageView *)[view viewWithTag:iCarousel_VIEW_TAG];
    
    if (!storyImageView) {
        storyImageView = [[iCarouselImageView alloc] initWithFrame:CGRectMake(0, 0, 400, 240)];
        storyImageView.delegate = self;
    }
    [storyImageView setContentMode:UIViewContentModeScaleAspectFill];
    [storyImageView setClipsToBounds:YES];

    if (_featuredStoriesArray) {
        NSString *coverImageUrl = [[ASSET_BASE_URL stringByAppendingString:[_featuredStoriesArray[index] objectForKey:@"cover"]] stringByReplacingOccurrencesOfString:@"cover_" withString:@"banner_"];
        if (self.featuredStoriesFetched) {
            if ([_localImagesDictionary objectForKey:coverImageUrl]) {
                storyImageView.image = [_localImagesDictionary objectForKey:coverImageUrl];
            } else {
                [storyImageView getImageForUrl:coverImageUrl];
            }
        }
    } else {
        storyImageView.image = [UIImage imageNamed:@"page.png"];
    }
    
    return storyImageView;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    if (_featuredStoriesArray) {
        NSDictionary *bookDict = [_featuredStoriesArray objectAtIndex:index];
        
        BookDetailsViewController *bookDetailsViewController = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController" bundle:nil];
        bookDetailsViewController.delegate = self;
        
        [bookDetailsViewController setModalPresentationStyle:UIModalPresentationPageSheet];
        [self presentViewController:bookDetailsViewController animated:YES completion:^(void) {
            bookDetailsViewController.bookTitleLabel.text = [bookDict objectForKey:@"title"];
            bookDetailsViewController.ageLabel.text = [NSString stringWithFormat:@"Age Groups: %@", [[[bookDict objectForKey:@"info"] objectForKey:@"age_groups"] componentsJoinedByString:@", "]];
            bookDetailsViewController.readingLevelLabel.text = [NSString stringWithFormat:@"Reading Levels: %@", [[[bookDict objectForKey:@"info"] objectForKey:@"learning_levels"] componentsJoinedByString:@", "]];
            bookDetailsViewController.numberOfPagesLabel.text = [NSString stringWithFormat:@"No. of pages: %d", [[bookDict objectForKey:@"page_count"] intValue]];
            if([[bookDict objectForKey:@"price"] floatValue] == 0.00){
                bookDetailsViewController.priceLabel.text = [NSString stringWithFormat:@"FREE"];
                [bookDetailsViewController.buyButton setImage:[UIImage imageNamed:@"Read-now.png"] forState:UIControlStateNormal];
            }
            else{
            bookDetailsViewController.priceLabel.text = [NSString stringWithFormat:@"$ %.2f", [[bookDict objectForKey:@"price"] floatValue]];
                [bookDetailsViewController.buyButton setImage:[UIImage imageNamed:@"buynow.png"] forState:UIControlStateNormal];
            }
            bookDetailsViewController.categoriesLabel.text = [[[bookDict objectForKey:@"info"] objectForKey:@"categories"] componentsJoinedByString:@", "];
            bookDetailsViewController.descriptionLabel.text = [bookDict objectForKey:@"synopsis"];
            
            bookDetailsViewController.selectedProductId = [bookDict objectForKey:@"id"];
            bookDetailsViewController.imageUrlString = [ASSET_BASE_URL stringByAppendingString:[bookDict objectForKey:@"cover"]];
        }];
        bookDetailsViewController.view.superview.frame = CGRectMake(([UIScreen mainScreen].applicationFrame.size.width/2)-400, ([UIScreen mainScreen].applicationFrame.size.height/2)-270, 800, 540);
    }
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
            return value * 1.5f;
        }
        
        case iCarouselOptionFadeMax: {
            if (carousel.type == iCarouselTypeCustom) {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value*0.5f;
        }
            
        case iCarouselOptionVisibleItems: {
            return 5;
        }
            
        default: {
            return value;
        }
    }
}

#pragma mark - Book View Delegate

- (void)openBookViewWithCategory:(NSDictionary *)categoryDict {
    BooksFromCategoryViewController *booksCategoryViewController=[[BooksFromCategoryViewController alloc]initWithNibName:@"BooksFromCategoryViewController" bundle:nil withInitialIndex:0];
    booksCategoryViewController.toEdit = NO;
    booksCategoryViewController.categorySelected = categoryDict;
    [self.navigationController pushViewController:booksCategoryViewController animated:YES];
}

#pragma mark - Local Image Saving Delegate

- (void)iCarouselSaveImage:(UIImage *)image ForUrl:(NSString *)imageUrl {
    [_localImagesDictionary setObject:image forKey:imageUrl];
}

- (void)saveImage:(UIImage *)image ForUrl:(NSString *)imageUrl {
    [_localImagesDictionary setObject:image forKey:imageUrl];
    //[_booksCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    switch (_tableType) {
        case TABLE_TYPE_MAIN_STORE: {
            if(section == 0) {
                return 1;
            } else {
                NSString *ageGroup = [[self.ageGroupsFoundInResponse objectAtIndex:section-1] objectForKey:NAME];
                if ([liveStoriesFiltered objectForKey:ageGroup]) {
                    return MIN(6, [[liveStoriesFiltered objectForKey:ageGroup] count]);
                }
                return 6;
            }
        }
            break;
            
        default: {
            return [[liveStoriesFiltered objectForKey:[[liveStoriesFiltered allKeys] firstObject]] count];
        }
            break;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    switch (_tableType) {
        case TABLE_TYPE_MAIN_STORE: {
            return self.ageGroupsFoundInResponse.count + 1;          // +1 for iCarousel at Section - 0.
        }
            break;
            
        default: {
            return 1;
        }
            break;
    }
    return 0;          // +1 for iCarousel at Section - 0.
}

- (void)setupCollectionViewCell:(StoreBookCell *)cell WithDict:(NSDictionary *)bookDict {
    cell.bookPriceLabel.text = [NSString stringWithFormat:@"%.2f", [[bookDict objectForKey:@"price"] floatValue]];
    
    cell.bookTitleLabel.text = [bookDict objectForKey:@"title"];
    [cell.bookTitleLabel setFrame:CGRectMake(2, cell.bookTitleLabel.frame.origin.y, cell.bookTitleLabel.frame.size.width, [cell.bookTitleLabel.text sizeWithFont:cell.bookTitleLabel.font constrainedToSize:CGSizeMake(cell.bookTitleLabel.frame.size.width, 50)].height)];
    [cell setNeedsLayout];
    
    cell.imageUrlString = [[bookDict objectForKey:@"cover"] stringByReplacingOccurrencesOfString:@"cover_" withString:@"thumb_"];
    if ([_localImagesDictionary objectForKey:[ASSET_BASE_URL stringByAppendingString:cell.imageUrlString]]) {
        cell.bookImageView.image = [_localImagesDictionary objectForKey:[ASSET_BASE_URL stringByAppendingString:cell.imageUrlString]];
    } else {
        [cell getImageForUrl:[ASSET_BASE_URL stringByAppendingString:cell.imageUrlString]];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (_tableType) {
        case TABLE_TYPE_MAIN_STORE: {
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
                cell.delegate = self;
                
                if(liveStoriesFiltered) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    NSString *ageGroup = [[self.ageGroupsFoundInResponse objectAtIndex:indexPath.section-1] objectForKey:NAME];
                    NSDictionary *bookDict= [[liveStoriesFiltered objectForKey:ageGroup] objectAtIndex:indexPath.row];
                    
                    if (bookDict) {
                        [self setupCollectionViewCell:cell WithDict:bookDict];
                    }
                }
                
                return cell;
            }
        }
            break;
            
        default: {
            StoreBookCell *cell = [cv dequeueReusableCellWithReuseIdentifier:STORE_BOOK_CELL_ID forIndexPath:indexPath];
            cell.delegate = self;
            
            if(liveStoriesFiltered) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSDictionary *bookDict= [[liveStoriesFiltered objectForKey:[[liveStoriesFiltered allKeys] firstObject]] objectAtIndex:indexPath.row];
                
                if (bookDict) {
                    [self setupCollectionViewCell:cell WithDict:bookDict];
                }
            }
            
            return cell;
        }
            break;
    }
    return nil;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    switch (_tableType) {
        case TABLE_TYPE_MAIN_STORE: {
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
            break;
            
        default:
            break;
    }
    return nil;
}

#pragma mark - UICollectionView Delegate

- (void)showBookDetailsForBook:(NSDictionary *)bookDict {
    BookDetailsViewController *bookDetailsViewController = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController" bundle:nil];
    bookDetailsViewController.delegate = self;
    
    [bookDetailsViewController setModalPresentationStyle:UIModalPresentationPageSheet];
    [self presentViewController:bookDetailsViewController animated:YES completion:^(void) {
        bookDetailsViewController.bookTitleLabel.text = [bookDict objectForKey:@"title"];
        bookDetailsViewController.ageLabel.text = @"";
        bookDetailsViewController.readingLevelLabel.text = [NSString stringWithFormat:@"Reading Levels: %@", [[[bookDict objectForKey:@"info"] objectForKey:@"learning_levels"] componentsJoinedByString:@", "]];
        bookDetailsViewController.numberOfPagesLabel.text = [NSString stringWithFormat:@"No. of pages: %d", [[bookDict objectForKey:@"page_count"] intValue]];
        bookDetailsViewController.priceLabel.text = [NSString stringWithFormat:@"Rs. %.2f", [[bookDict objectForKey:@"price"] floatValue]];
        bookDetailsViewController.categoriesLabel.text = [[[bookDict objectForKey:@"info"] objectForKey:@"categories"] componentsJoinedByString:@", "];
        bookDetailsViewController.descriptionLabel.text = [bookDict objectForKey:@"synopsis"];
        
        bookDetailsViewController.selectedProductId = [bookDict objectForKey:@"id"];
        bookDetailsViewController.imageUrlString = [ASSET_BASE_URL stringByAppendingString:[bookDict objectForKey:@"cover"]];
    }];
    bookDetailsViewController.view.superview.frame = CGRectMake(([UIScreen mainScreen].applicationFrame.size.width/2)-400, ([UIScreen mainScreen].applicationFrame.size.height/2)-270, 800, 540);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    switch (_tableType) {
        case TABLE_TYPE_MAIN_STORE: {
            if (indexPath.section == 0) {
                
            } else {
                
                NSString *ageGroup = [[self.ageGroupsFoundInResponse objectAtIndex:indexPath.section - 1] objectForKey:NAME];
                NSDictionary *bookDict = [[liveStoriesFiltered objectForKey:ageGroup] objectAtIndex:indexPath.row];
                
                if (bookDict) {
                    [self showBookDetailsForBook:bookDict];
                }
            }
        }
            break;
            
        default: {
            NSDictionary *bookDict = [[liveStoriesFiltered objectForKey:[[liveStoriesFiltered allKeys] firstObject]] objectAtIndex:indexPath.row];
            
            if (bookDict) {
                [self showBookDetailsForBook:bookDict];
            }
        }
            break;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    switch (_tableType) {
        case TABLE_TYPE_MAIN_STORE: {
            if(section == 0) {
                return UIEdgeInsetsMake(10, 0, 10, 0);
            }
        }
            break;
            
        default:
            break;
    }
    return UIEdgeInsetsMake(20, 20, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return CGSizeMake(collectionView.frame.size.width, 0);
    } else {
        return CGSizeMake(collectionView.frame.size.width, 40);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (_tableType) {
        case TABLE_TYPE_MAIN_STORE: {
            if (indexPath.section == 0) {
                return CGSizeMake(984, 240);
            }
        }
            break;
            
        default:
            break;
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
