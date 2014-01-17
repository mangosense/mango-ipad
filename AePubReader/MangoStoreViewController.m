
//
//  MangoStoreViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 03/12/13.
//
//

#import "MangoStoreViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "StoreCollectionFlowLayout.h"
#import "StoreCollectionHeaderView.h"
#import "AePubReaderAppDelegate.h"
#import "AFHTTPRequestOperationManager.h"
#import "MBProgressHUD.h"
#import "BooksFromCategoryViewController.h"
#import "MangoStoreCollectionViewController.h"

#define SEGMENT_WIDTH 600
#define SEGMENT_HEIGHT 60
#define FILTER_BUTTON_WIDTH 130
#define CATEGORY_TAG 1
#define AGE_TAG 2
#define LANGUAGE_TAG 3
#define GRADE_TAG 4

#define STORE_BOOK_CELL_ID @"StoreBookCell"
#define STORE_BOOK_CAROUSEL_CELL_ID @"StoreBookCarouselCell"

#define HEADER_ID @"headerId"

#import "CargoBay.h"

@interface MangoStoreViewController ()

@property (nonatomic, strong) UIPopoverController *filterPopoverController;
@property (nonatomic, strong) UICollectionView *booksCollectionView;
@property (nonatomic, strong) NSMutableArray *liveStoriesArray;
@property (nonatomic, strong) NSMutableDictionary *liveStoriesFiltered;
@property (nonatomic, strong) NSMutableDictionary *localImagesDictionary;
@property (nonatomic, strong) NSMutableArray *featuredStoriesArray;
@property (nonatomic, assign) BOOL liveStoriesFetched;
@property (nonatomic, assign) BOOL featuredStoriesFetched;

@property (nonatomic, strong) NSMutableArray *purchasedBooks;
@property (nonatomic, strong) NSString * currentProductPrice;

@end

@implementation MangoStoreViewController

@synthesize filterPopoverController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _localImagesDictionary = [[NSMutableDictionary alloc] init];
    [self setupInitialUI];
    
    //Register observer
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[CargoBay sharedManager]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSLog(@"STring:: %@", string);
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"Need to call api for Search text..");
    [self.view endEditing:YES];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    MangoApiController *apiController = [MangoApiController sharedApiController];
    apiController.delegate = self;
    [apiController getListOf:LIVE_STORIES_SEARCH ForParameters:[NSDictionary dictionaryWithObject:textField.text forKey:@"q"]];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
/*    MangoApiController *apiController = [MangoApiController sharedApiController];
    apiController.delegate = self;
    [apiController getListOf:LIVE_STORIES_SEARCH ForParameters:[NSDictionary dictionaryWithObject:textField.text forKey:@"q"]];
 */
}

#pragma mark - Action Methods

- (IBAction)goBackToStoryPage:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)filterSelected:(id)sender {
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
            textTemplatesListViewController.itemsListArray = [NSMutableArray arrayWithObjects:@"0-2 Years", @"2-4 Years", @"4-6 Years", @"6-8 Years", @"8-10 Years", @"10-12 Years", nil];
        }
            break;
            
        case LANGUAGE_TAG: {
            textTemplatesListViewController.tableType = TABLE_TYPE_LANGUAGE;
            textTemplatesListViewController.itemsListArray = [NSMutableArray arrayWithObjects:@"English", @"Spanish", @"French", @"German", @"Tamil", @"Hindi", nil];
        }
            break;
            
        case GRADE_TAG: {           // FIXME: Change Table Type
            textTemplatesListViewController.tableType = TABLE_TYPE_TEXT_TEMPLATES;
            textTemplatesListViewController.itemsListArray = [NSMutableArray arrayWithObjects:@"Pre K", @"Kindergarten", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", nil];
        }
            break;
            
        default:
            break;
    }
    
    filterPopoverController = [[UIPopoverController alloc] initWithContentViewController:textTemplatesListViewController];
    [filterPopoverController setPopoverContentSize:CGSizeMake(250, 250)];
    filterPopoverController.delegate = self;
    [filterPopoverController.contentViewController.view setBackgroundColor:COLOR_LIGHT_GREY];
    [filterPopoverController presentPopoverFromRect:button.frame inView:self.view.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

#pragma mark - Post API Delegate

- (void)reloadViewsWithArray:(NSArray *)dataArray ForType:(NSString *)type {
    
    NSLog(@"type : %@ Count; %d Data Aray : %@ ", type, dataArray.count, dataArray);

    if ([type isEqualToString:PURCHASED_STORIES]) {
        //Will come empty array...
        self.purchasedBooks = [NSMutableArray arrayWithArray:dataArray];
        [self getLiveStories];
        return;
    }
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if (dataArray.count == 0 && ![type isEqualToString:PURCHASED_STORIES]) {
        return;
    }
    
    if ([type isEqualToString:LIVE_STORIES] || [type isEqualToString:LIVE_STORIES_SEARCH]) {
        if (!_liveStoriesArray) {
            _liveStoriesArray = [[NSMutableArray alloc] init];
        }
        [_liveStoriesArray addObjectsFromArray:dataArray];
        _liveStoriesFetched = YES;
        
        if (_liveStoriesArray) {
            self.liveStoriesFiltered = [[NSMutableDictionary alloc] init];
            [self filterResponse];
        }

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        if (!_featuredStoriesArray) {
            MangoApiController *apiController = [MangoApiController sharedApiController];
            apiController.delegate = self;
            [apiController getListOf:FEATURED_STORIES ForParameters:nil];
        }
    } else if ([type isEqualToString:FEATURED_STORIES]) {
        if (!_featuredStoriesArray) {
            _featuredStoriesArray = [[NSMutableArray alloc] init];
        }
        [_featuredStoriesArray addObjectsFromArray:dataArray];
        _featuredStoriesFetched = YES;
    }
    if (_liveStoriesFetched && _featuredStoriesFetched) {
        [_booksCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        [_storiesCarousel performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }
}

- (void)getBookAtPath:(NSURL *)filePath {
    //[MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    [filePath setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:nil];

    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate unzipExistingJsonBooks];
    
    BooksFromCategoryViewController *booksCategoryViewController=[[BooksFromCategoryViewController alloc]initWithNibName:@"BooksFromCategoryViewController" bundle:nil withInitialIndex:0];
    booksCategoryViewController.toEdit=NO;
    [self.navigationController pushViewController:booksCategoryViewController animated:YES];
}

#pragma mark - Filters

- (void)filterResponse {
//    NSLog(@"Count : %d", _liveStoriesArray.count);
    for (int i = 0; i < self.purchasedBooks.count; i++) {
        NSDictionary *story = self.purchasedBooks[i];
        NSDictionary *storyInfo = [story objectForKey:@"info"];
        NSArray *ageGroups = [storyInfo objectForKey:@"age_groups"];
        
//         NSLog(@"%@", ageGroups);
        
        for (int j = 0; j < ageGroups.count; j++) {
           
            NSMutableArray *array;
            NSString *ageGroup = ageGroups[j];
            
            if ([ageGroup isEqualToString:@"0-2"]) {
                if ([self.liveStoriesFiltered objectForKey:@"0-2"]) {
                    array = [self.liveStoriesFiltered objectForKey:@"0-2"];
                    [array addObject:story];
                    [self.liveStoriesFiltered setObject:array forKey:@"0-2"];
                    continue;
                    NSLog(@"0-2");
                }
                else {
                    array = [NSMutableArray arrayWithObject:story];
                    [self.liveStoriesFiltered setObject:array forKey:@"0-2"];
                    continue;
                }
            }
            
            if ([ageGroup isEqualToString:@"3-5"]) {
                if ([self.liveStoriesFiltered objectForKey:@"3-5"]) {
                    array = [self.liveStoriesFiltered objectForKey:@"3-5"];
                    [array addObject:story];
                    [self.liveStoriesFiltered setObject:array forKey:@"3-5"];
                    continue;
                    NSLog(@"3-5");
                }
                else {
                    array = [NSMutableArray arrayWithObject:story];
                    [self.liveStoriesFiltered setObject:array forKey:@"3-5"];
                    continue;
                }
            }
            
            if ([ageGroup isEqualToString:@"6-8"]) {
                if ([self.liveStoriesFiltered objectForKey:@"6-8"]) {
                    array = [self.liveStoriesFiltered objectForKey:@"6-8"];
                    [array addObject:story];
                    [self.liveStoriesFiltered setObject:array forKey:@"6-8"];
                    continue;
                    NSLog(@"6-8");
                }
                else {
                    array = [NSMutableArray arrayWithObject:story];
                    [self.liveStoriesFiltered setObject:array forKey:@"6-8"];
                    continue;
                }
            }
            
            if ([ageGroup isEqualToString:@"9-12"]) {
                if ([self.liveStoriesFiltered objectForKey:@"9-12"]) {
                    array = [self.liveStoriesFiltered objectForKey:@"9-12"];
                    [array addObject:story];
                    [self.liveStoriesFiltered setObject:array forKey:@"9-12"];
                    continue;
                    NSLog(@"9-12");
                }
                else {
                    array = [NSMutableArray arrayWithObject:story];
                    [self.liveStoriesFiltered setObject:array forKey:@"9-12"];
                    continue;
                }
            }
        }
    }
    [_booksCollectionView reloadData];
}

- (NSArray *)getStoriesForAgeGroup:(NSInteger)section {
    NSArray *stories;
    
    switch (section) {
        case 1: stories = [self.liveStoriesFiltered objectForKey:@"0-2"];
            break;
        case 2: stories = [self.liveStoriesFiltered objectForKey:@"3-5"];
            break;
        case 3: stories = [self.liveStoriesFiltered objectForKey:@"6-8"];
            break;
        case 4: stories = [self.liveStoriesFiltered objectForKey:@"9-12"];
            break;
        default:
            break;
    }
    
//    NSLog(@"%@", stories);
    
    return stories;
}

#pragma mark - Get Purchased Books

- (void)getAllPurchasedBooks {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
    apiController.delegate = self;
    
    NSMutableDictionary *paramsdict = [[NSMutableDictionary alloc] init];
    [paramsdict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:AUTH_TOKEN] forKey:AUTH_TOKEN];
    [paramsdict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:EMAIL] forKey:EMAIL];
    
    [apiController getListOf:PURCHASED_STORIES ForParameters:paramsdict];
}

- (void)getLiveStories {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    MangoApiController *apiController = [MangoApiController sharedApiController];
    apiController.delegate = self;
    [apiController getListOf:LIVE_STORIES ForParameters:nil];
}

- (void)setupInitialUI {
    
    NSUserDefaults * userdefaults = [NSUserDefaults standardUserDefaults];
    NSString * email = [userdefaults objectForKey:EMAIL];
    NSString * authToken = [userdefaults objectForKey:AUTH_TOKEN];
    
    if (email.length>5 && authToken.length >0) {
        [self getAllPurchasedBooks];
    }
    else {
        [self getLiveStories];
    }
    
    CGRect viewFrame = self.view.bounds;
    
    StoreCollectionFlowLayout *layout = [[StoreCollectionFlowLayout alloc] init];
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

- (void)itemType:(int)itemType tappedAtIndex:(int)index withDetail:(NSString *)detail {
    
    [filterPopoverController dismissPopoverAnimated:YES];
    
    MangoStoreCollectionViewController *selectedCategoryViewController = [[MangoStoreCollectionViewController alloc] initWithNibName:@"MangoStoreCollectionViewController" bundle:nil];
    selectedCategoryViewController.tableType = itemType;
    selectedCategoryViewController.selectedItemDetail = detail;
    [self.navigationController pushViewController:selectedCategoryViewController animated:YES];
}

#pragma mark - iCarousel Delegates

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [_featuredStoriesArray count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    
    NSLog(@"Image:%@", [[self.featuredStoriesArray objectAtIndex:index] objectForKey:@"cover"]);
    //TODO: Need to set images to carousel
    UIImageView *storyImageView = [[UIImageView alloc] init];
    [storyImageView setFrame:CGRectMake(0, 0, 400, 250)];
    [storyImageView setImage:[UIImage imageNamed:@"backimageiphonen.png"]];
    [[storyImageView layer] setCornerRadius:12];
    [storyImageView setClipsToBounds:YES];
    return storyImageView;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return YES;
        }
            
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 1.05f;
        }
            
        case iCarouselOptionFadeMax:
        {
            if (carousel.type == iCarouselTypeCustom)
            {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value;
        }
            
        default:
        {
            return value;
        }
            
    }
}

#pragma mark - Local Image Saving Delegate

- (void)saveImage:(UIImage *)image ForUrl:(NSString *)imageUrl {
    [_localImagesDictionary setObject:image forKey:imageUrl];
    [_booksCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    if(section == 0) {
        return 1;
    } else {
        NSLog(@"%d : %d", section, [self getStoriesForAgeGroup:section].count);
        return [self getStoriesForAgeGroup:section].count;
    }
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1+5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0) {
        StoreBookCarouselCell *cell = [cv dequeueReusableCellWithReuseIdentifier:STORE_BOOK_CAROUSEL_CELL_ID forIndexPath:indexPath];
        
        if (!_storiesCarousel) {
            _storiesCarousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, 984, 220)];
            _storiesCarousel.delegate = self;
            _storiesCarousel.dataSource = self;
            _storiesCarousel.type = iCarouselTypeCoverFlow;
            [cell.contentView addSubview:_storiesCarousel];
        }
        
        [_storiesCarousel reloadData];        
        return cell;
    } else {
        StoreBookCell *cell = [cv dequeueReusableCellWithReuseIdentifier:STORE_BOOK_CELL_ID forIndexPath:indexPath];
        
        cell.bookAgeGroupLabel.text = [NSString stringWithFormat:@"For Age %d-%d Yrs", 2*(indexPath.section - 1), 2*(indexPath.section - 1) + 2];
        cell.delegate = self;
        
        NSDictionary *bookDict;
        
        if(self.liveStoriesFiltered)
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        
            bookDict= [self getStoriesForAgeGroup:indexPath.section][indexPath.row];
//        else
//            bookDict = [_liveStoriesArray objectAtIndex:indexPath.row];
        
        cell.bookPriceLabel.text = [bookDict objectForKey:@"price"];//@"Rs. 99";
        
        cell.bookTitleLabel.text = [bookDict objectForKey:@"title"];
        [cell.bookTitleLabel setFrame:CGRectMake(2, cell.bookTitleLabel.frame.origin.y, cell.bookTitleLabel.frame.size.width, [cell.bookTitleLabel.text sizeWithFont:cell.bookTitleLabel.font constrainedToSize:CGSizeMake(cell.bookTitleLabel.frame.size.width, 50)].height)];
        [cell setNeedsLayout];
        
        cell.imageUrlString = [bookDict objectForKey:@"cover"];
        if ([_localImagesDictionary objectForKey:[bookDict objectForKey:@"cover"]]) {
            cell.bookImageView.image = [_localImagesDictionary objectForKey:[bookDict objectForKey:@"cover"]];
        } else {
            [cell getImageForUrl:[bookDict objectForKey:@"cover"]];
        }
        
        return cell;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section != 0) {
        StoreCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HEADER_ID forIndexPath:indexPath];
        headerView.titleLabel.textColor = COLOR_DARK_RED;
        headerView.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        headerView.titleLabel.text = [NSString stringWithFormat:@"For Age %d-%d Years", 2*(indexPath.section - 1), 2*(indexPath.section - 1) + 2];
        
        return headerView;
    } else {
        UICollectionReusableView *headerViewForCarousel = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Section0" forIndexPath:indexPath];
        return headerViewForCarousel;
    }
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
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
//            [self itemProceedToPurchase:productId storeIdentifier:skIdentifier];
//        }
        [self itemProceedToPurchase:productId storeIdentifier:@"752"];
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
    return UIEdgeInsetsMake(20, 20, 20, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.frame.size.width, 20);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return CGSizeMake(984, 240);
    }
    
    return CGSizeMake(150, 270);
}

#pragma mark - In App purchasing..

- (BOOL) isProductPurchased :(NSString *) productId {
    
    BOOL isBookPurchased = NO;
    for (NSDictionary *dataDict in self.purchasedBooks) {
        NSString *bookId = [dataDict objectForKey:@"id"];
        if ([bookId isEqualToString:productId]) {
            isBookPurchased = YES;
            break;
        }
    }
    return isBookPurchased;
}

- (void) itemReadyToUse:(NSString *) productId {
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
    apiController.delegate = self;
    [apiController downloadBookWithId:productId];
}

- (void) itemProceedToPurchase :(NSString *) productId storeIdentifier:(NSString *) productIdentifier{
    
    NSAssert((productIdentifier.length > 0), @"Product identifier should have some characters lenght");
    
    //Observer Method for updated Transactions
    [[CargoBay sharedManager] setPaymentQueueUpdatedTransactionsBlock:^(SKPaymentQueue *queue, NSArray *transactions) {
        NSLog(@"Updated Transactions: %@", transactions);
        
        for (SKPaymentTransaction *transaction in transactions)
        {
            NSLog(@"Payment State: %d", transaction.transactionState);
            switch (transaction.transactionState) {
                    
                case SKPaymentTransactionStatePurchased:
                {
                    NSLog(@"Product Purchased!");
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                    [self validateReceipt:productId amount:self.currentProductPrice storeIdentifier:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]]];
                }
                    break;
                    
                case SKPaymentTransactionStateFailed:
                {
                    NSLog(@"Transaction Failed!");
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                }
                    break;
                    
                case SKPaymentTransactionStateRestored:
                {
                    NSLog(@"Product Restored!");
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                    [self validateReceipt:productId amount:self.currentProductPrice storeIdentifier:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]]];
                }
                    break;
                    
                default:
                    break;
            }
            if (transaction.transactionState != SKPaymentTransactionStatePurchasing) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }
        }
    }];
    
    //Get products from identifires....
    NSSet * productSet = [NSSet setWithArray:@[productIdentifier]];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[CargoBay sharedManager] productsWithIdentifiers:productSet success:^(NSArray *products, NSArray *invalidIdentifiers) {
        if (products.count) {
            NSLog(@"Products: %@", products);
            //Initialise payment queue
            SKProduct * product = products[0];
            self.currentProductPrice = [product.price stringValue];
            SKPayment * payement = [SKPayment paymentWithProduct:product];
            [[SKPaymentQueue defaultQueue] addPayment:payement];
        }
        else {
            //Hide progress HUD if no products found
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSLog(@"LOL:No Product found");
        }
        NSLog(@"Invalid Identifiers: %@", invalidIdentifiers);
    } failure:^(NSError *error) {
        //Hide progress HUD if Error!!
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSLog(@"GetProductError: %@", error);
    }];
}

//Encode receipt data
- (NSString *)encode:(const uint8_t *)input length:(NSInteger)length {
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
	
    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
	
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
			value <<= 8;
			
			if (j < length) {
				value |= (0xFF & input[j]);
			}
        }
		
        NSInteger index = (i / 3) * 4;
        output[index + 0] =                    table[(value >> 18) & 0x3F];
        output[index + 1] =                    table[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
	
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

- (void)validateReceipt:(NSString *) productId amount:(NSString *)amount storeIdentifier:(NSData *) receiptData {
    
    NSString * jsonObjectString = [self encode:(uint8_t *)receiptData.bytes length:receiptData.length];
    
    
    [[MangoApiController sharedApiController] validateReceiptWithData:receiptData amount:amount storyId:productId block:^(id response, NSInteger type, NSString *error) {
       
        if (type == 1) {
            NSLog(@"SuccessResponse:%@", response);
            //If Succeed.
            //[self itemReadyToUse:productId];
        }
        else {
            NSLog(@"ReceiptError:%@", error);
        }
    }];
}


@end