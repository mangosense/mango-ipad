
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
#import "BooksCollectionViewController.h"
#import "CoverViewControllerBetterBookType.h"
#import "MangoSubscriptionViewController.h"
#import "BookDetailsViewController.h"

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
@synthesize popoverControlleriPhone;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        userEmail = delegate.loggedInUserInfo.email;
        userDeviceID = delegate.deviceId;
    }
    return self;
}

- (void)setCategoryFlagValue:(BOOL)value {
    
    categoryflag = value;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)setCategoryDictValue:(NSDictionary*)categoryInfoDict {
    categoryDictionary = [[NSDictionary alloc] initWithDictionary:categoryInfoDict];
}

- (void)dealloc {
    //Register observer
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:[CargoBay sharedManager]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    validUserSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
    storyAsAppFilePath = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
    
    NSLog(@"%@", [SIGN_IN valueForKey:@"value"]);
    viewName = @"Store Page";
    popoverClass = [WEPopoverController class];
    // Do any additional setup after loading the view from its nib.
    _localImagesDictionary = [[NSMutableDictionary alloc] init];
    [self setupInitialUI];
    //bookDetailsViewController.priceLabel.text.font = [UIFont fontWithName:@"the_hungry_ghost" size:16.0];
    
    _viewDownloadCounter.layer.cornerRadius = 3.0f;
    [_viewDownloadCounter.layer setBorderWidth:0.5f];
    [_viewDownloadCounter.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    
    //add timer for the  automatic call
    [self setDownloadCounter:0];
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(setDownloadCounter:) userInfo:nil repeats:YES];
    
    //Register observer
    if(categoryflag){
        NSLog(@"Here is our category flagvalue");
        [self itemType:TABLE_TYPE_CATEGORIES tappedWithDetail:categoryDictionary];
    }
    else{
        _tableType = TABLE_TYPE_MAIN_STORE;
        [self getAllAgeGroups];
    }
    
    if(!userEmail){
        ID = userDeviceID;
    }
    else{
        ID = userEmail;
    }
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        displayStoryNo = 4;
        
    }
    else{
        displayStoryNo = 6;
    }
    
    //[[SKPaymentQueue defaultQueue] addTransactionObserver:[CargoBay sharedManager]];
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(!validUserSubscription){
        
        if(appDelegate.subscriptionInfo){
            //provide access
            
            [[MangoApiController sharedApiController]validateSubscription:appDelegate.subscriptionInfo.subscriptionTransctionId andDeviceId:appDelegate.deviceId block:^(id response, NSInteger type, NSString *error){
                NSLog(@"type --- %d", type);
                if ([[response objectForKey:@"status"] integerValue] == 1){
                    
                    NSLog(@"You are already subscribed");
                    [prefs setBool:YES forKey:@"USERISSUBSCRIBED"];
                    
                }
                else{
                    int notFirstTimeDisplay = [[prefs valueForKey:@"FIRSTTIMEDISPLAY"] integerValue];
                    [prefs setBool:NO forKey:@"USERISSUBSCRIBED"];
                    
                    if(!notFirstTimeDisplay){
                    
                        MangoSubscriptionViewController *subscriptionViewController;
                        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
                        
                        subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController_iPhone" bundle:nil];
                        }
                        else{
                            subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController" bundle:nil];
                        }
                        [prefs setBool:YES forKey:@"FIRSTTIMEDISPLAY"];
                        subscriptionViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                        [self presentViewController:subscriptionViewController animated:YES completion:nil];
                    }
                }
                
            }];
        }
        
        else{
            
            
            [[MangoApiController sharedApiController]validateSubscription:appDelegate.subscriptionInfo.subscriptionTransctionId andDeviceId:appDelegate.deviceId block:^(id response, NSInteger type, NSString *error){
                NSLog(@"type --- %d", type);
                if ([[response objectForKey:@"status"] integerValue] == 1){
                    
                    NSLog(@"You are already subscribed");
                    [prefs setBool:YES forKey:@"USERISSUBSCRIBED"];
                }
                else{
                    int notFirstTimeDisplay = [[prefs valueForKey:@"FIRSTTIMEDISPLAY"] integerValue];
                    
                    [prefs setBool:NO forKey:@"USERISSUBSCRIBED"];
                    
                    if(!notFirstTimeDisplay){
                        MangoSubscriptionViewController *subscriptionViewController;
                        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
                        
                            subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController_iPhone" bundle:nil];
                        }
                        else{
                            subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController" bundle:nil];
                        }
                        [prefs setBool:YES forKey:@"FIRSTTIMEDISPLAY"];
                        subscriptionViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                        [self presentViewController:subscriptionViewController animated:YES completion:nil];
                    }
                }
                
            }];
        }
        
    }
}

- (void) viewWillAppear:(BOOL)animated{
    
    [self.view bringSubviewToFront:[_viewDownloadCounter superview]];
    [[_viewDownloadCounter superview] bringSubviewToFront:_viewDownloadCounter];
}

-(void) setDownloadCounter:(NSTimer *)timer
{
    int noOfBooks = [BookDetailsViewController booksDownloadingNo];
   // NSLog(@"Calling... %d", noOfBooks);
    if(noOfBooks == 0){
        _viewDownloadCounter.hidden = YES;
    }
    else{
        _viewDownloadCounter.hidden = NO;
    }
    _labelDownloadingCount.text = [NSString stringWithFormat:@"%d", noOfBooks];
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
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

//- (void)textFieldDidEndEditing:(UITextField *)textField {
    /*    MangoApiController *apiController = [MangoApiController sharedApiController];
     //    apiController.delegate = self;
     [apiController getListOf:LIVE_STORIES_SEARCH ForParameters:[NSDictionary dictionaryWithObject:textField.text forKey:@"q"] withDelegate:self];
     */
//}

#pragma mark - Action Methods

- (IBAction)goBackToStoryPage:(id)sender {

    if(storyAsAppFilePath && validUserSubscription){
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    }
    
}

- (IBAction)filterSelected:(id)sender {
    
    [self.searchTextField resignFirstResponder];
    self.searchTextField = nil;
    ItemsListViewController *textTemplatesListViewController = [[ItemsListViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [textTemplatesListViewController.view setFrame:CGRectMake(0, 0, 150, 150)];
    textTemplatesListViewController.delegate = self;
    textTemplatesListViewController.filterTag = [sender tag];
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
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    
        if (!self.popoverControlleriPhone) {
            
            self.popoverControlleriPhone = [[popoverClass alloc] initWithContentViewController:textTemplatesListViewController] ;
            self.popoverControlleriPhone.delegate = self;
            self.popoverControlleriPhone.passthroughViews = [NSArray arrayWithObject:self.view];
            
            [self.popoverControlleriPhone presentPopoverFromRect:button.frame
                                                    inView:self.view
                                  permittedArrowDirections:UIPopoverArrowDirectionUp
                                                  animated:YES];
            
          
        } else {
            [self.popoverControlleriPhone dismissPopoverAnimated:YES];
            self.popoverControlleriPhone = nil;
        }
        
    }
    else{
        self.filterPopoverController = [[UIPopoverController alloc] initWithContentViewController:textTemplatesListViewController];
        [self.filterPopoverController setPopoverContentSize:CGSizeMake(250, 250)];
        self.filterPopoverController.delegate = self;
        [self.filterPopoverController.contentViewController.view setBackgroundColor:COLOR_LIGHT_GREY];
        [self.filterPopoverController presentPopoverFromRect:button.frame inView:self.view.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    
   
}

#pragma mark - Post API Delegate

- (void)reloadViewsWithArray:(NSArray *)dataArray ForType:(NSString *)type {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        [paramDict setObject:[NSNumber numberWithInt:4] forKey:LIMIT];
    }
    else{
        [paramDict setObject:[NSNumber numberWithInt:6] forKey:LIMIT];
    }
   
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
           
            [paramDict setObject:IOS forKey:PLATFORM];
        
            [apiController getListOf:FEATURED_STORIES ForParameters:paramDict withDelegate:self];
        }
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    } else if ([type isEqualToString:FEATURED_STORIES]) {
        if (!_featuredStoriesArray) {
            _featuredStoriesArray = [[NSMutableArray alloc] init];
        }
        [_featuredStoriesArray addObjectsFromArray:dataArray];
        _featuredStoriesFetched = YES;
    } else if ([type rangeOfString:STORY_FILTER_AGE_GROUP].location != NSNotFound && _tableType == TABLE_TYPE_MAIN_STORE) {
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
    
    /*BooksFromCategoryViewController *booksCategoryViewController=[[BooksFromCategoryViewController alloc]initWithNibName:@"BooksFromCategoryViewController" bundle:nil withInitialIndex:0];
    booksCategoryViewController.toEdit = NO;
    [self.navigationController pushViewController:booksCategoryViewController animated:YES];*/
    
    /// -----
    BooksCollectionViewController *booksCollectionViewController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        booksCollectionViewController = [[BooksCollectionViewController alloc] initWithNibName:@"BooksCollectionViewController_iPhone" bundle:nil];
    }
    else{
        booksCollectionViewController = [[BooksCollectionViewController alloc] initWithNibName:@"BooksCollectionViewController" bundle:nil];
    }
    
    booksCollectionViewController.toEdit = NO;
    [self.navigationController pushViewController:booksCollectionViewController animated:YES];
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

- (void)itemReadyToUse:(NSString *)productId ForTransaction:(NSString *)transactionId {
    MangoApiController *apiController = [MangoApiController sharedApiController];
    [apiController downloadBookWithId:productId withDelegate:self ForTransaction:transactionId];
    
    _selectedBookId = productId;
}

#pragma mark - Get Books

- (void)getFilteredStories:(NSString *)filterName {
    filterName = [filterName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    MangoApiController *apiController = [MangoApiController sharedApiController];
    
    NSString *url;
    
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setObject:[NSNumber numberWithInt:100] forKey:LIMIT];
    
    //[paramDict setObject:IOS forKey:PLATFORM];
    
    
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
            NSDictionary *dimensions = @{
                                         PARAMETER_USER_ID : ID,
                                         PARAMETER_DEVICE: IOS,
                                         PARAMETER_SEARCH_KEYWORD: filterName
                                         };
            [delegate trackEvent:[STORE_SEARCH valueForKey:@"description"] dimensions:dimensions];
            PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
            [userObject setObject:[STORE_SEARCH valueForKey:@"value"] forKey:@"eventName"];
            [userObject setObject: [STORE_SEARCH valueForKey:@"description"] forKey:@"eventDescription"];
            [userObject setObject:viewName forKey:@"viewName"];
            [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
            [userObject setObject:delegate.country forKey:@"deviceCountry"];
            [userObject setObject:delegate.language forKey:@"deviceLanguage"];
            [userObject setObject:filterName forKey:@"storeSearchKey"];
            if(userEmail){
                [userObject setObject:ID forKey:@"emailID"];
            }
            [userObject setObject:IOS forKey:@"device"];
            [userObject saveInBackground];
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
    
    CGRect viewFrame = self.view.bounds;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        _booksCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(CGRectGetMinX(viewFrame), 35, CGRectGetWidth(viewFrame), CGRectGetHeight(viewFrame)-38) collectionViewLayout:layout];
        
    }
    else{
        _booksCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(CGRectGetMinX(viewFrame), 80, CGRectGetWidth(viewFrame), CGRectGetHeight(viewFrame)-80) collectionViewLayout:layout];
    }
    
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
    [self.popoverControlleriPhone dismissPopoverAnimated:YES];
    NSString *detailId = [detailDict objectForKey:@"id"];
    NSString *detailTitle = [detailDict objectForKey:@"title"];
    
    if(!detailTitle) {
        detailTitle = detailId;     // id is same as title.... detailTitle will be nil.
    }
    
    _tableType = itemType;
    
    [self getFilteredStories:detailTitle];
}

- (void)seeAllTapped:(NSInteger)section {
    if (_tableType == TABLE_TYPE_MAIN_STORE) {
        _tableType = TABLE_TYPE_AGE_GROUPS;
        [self getFilteredStories:[self.ageGroupsFoundInResponse[section-1] objectForKey:NAME]];
    } else {
        _tableType = TABLE_TYPE_MAIN_STORE;
        [self getAllAgeGroups];
        self.ageGroupsFoundInResponse = nil;
        _featuredStoriesArray = nil;
        liveStoriesFiltered = nil;
        [_booksCollectionView removeFromSuperview];
        _booksCollectionView = nil;
        [_storiesCarousel removeFromSuperview];
        _storiesCarousel = nil;
        [self setupInitialUI];
    }
    
    //----
    /*MangoStoreCollectionViewController *selectedCategoryViewController = [[MangoStoreCollectionViewController alloc] initWithNibName:@"MangoStoreCollectionViewController" bundle:nil];
    
    selectedCategoryViewController.selectedItemTitle = [self.ageGroupsFoundInResponse[section-1] objectForKey:NAME];
    selectedCategoryViewController.tableType = TABLE_TYPE_AGE_GROUPS;
    NSString *ageGroup = [[self.ageGroupsFoundInResponse objectAtIndex:section-1] objectForKey:NAME];
    selectedCategoryViewController.liveStoriesQueried = [liveStoriesFiltered objectForKey:ageGroup];
    [self.navigationController pushViewController:selectedCategoryViewController animated:YES];*/
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
        
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            storyImageView = [[iCarouselImageView alloc] initWithFrame:CGRectMake(0, 0, 173, 134)];
        }
        else{
            storyImageView = [[iCarouselImageView alloc] initWithFrame:CGRectMake(0, 0, 400, 240)];
        }
        
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
      //  NSMutableArray *tempDropDownArray = [[NSMutableArray alloc] init];
        if(![self connected])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please internet connection appears offline, please try later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        
        BookDetailsViewController *bookDetailsViewController;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            bookDetailsViewController = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController_iPhone" bundle:nil];
            
        }
        else{
            bookDetailsViewController = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController" bundle:nil];
        }
        
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        bookDetailsViewController.delegate = self;
        
        [bookDetailsViewController setModalPresentationStyle:UIModalPresentationPageSheet];
        [self presentViewController:bookDetailsViewController animated:YES completion:^(void) {
            bookDetailsViewController.bookTitleLabel.text = [bookDict objectForKey:@"title"];
            
            bookDetailsViewController.bookWrittenBy.text = [NSString stringWithFormat:@"Written by: %@", [[[bookDict objectForKey:@"authors"] valueForKey:@"name"] componentsJoinedByString:@", "]];
            
            if(![[bookDict objectForKey:@"narrators"] isKindOfClass:[NSNull class]] && ([[[bookDict objectForKey:@"narrators"] valueForKey:@"name"] count])){
                bookDetailsViewController.bookNarrateBy.text = [NSString stringWithFormat:@"Narrated by: %@", [[[bookDict objectForKey:@"narrators"] valueForKey:@"name"] componentsJoinedByString:@", "]];
            }
            else{
                bookDetailsViewController.bookNarrateBy.text = [NSString stringWithFormat:@""];
            }
            
            if(![[bookDict objectForKey:@"illustrators"] isKindOfClass:[NSNull class]] && ([[[bookDict objectForKey:@"illustrators"] valueForKey:@"name"] count])){
                bookDetailsViewController.bookIllustratedBy.text = [NSString stringWithFormat:@"Illustrated by: %@", [[[bookDict objectForKey:@"illustrators"] valueForKey:@"name"] componentsJoinedByString:@", "]];
            }
            else{
                bookDetailsViewController.bookIllustratedBy.text = [NSString stringWithFormat:@""];
            }
            
            if(![[[bookDict objectForKey:@"info"] objectForKey:@"tags"]isKindOfClass:[NSNull class]] && [[bookDict objectForKey:@"info"] objectForKey:@"tags"]){
                bookDetailsViewController.bookTags.text = [NSString stringWithFormat:@"Tags: %@", [[[bookDict objectForKey:@"info"] objectForKey:@"tags"] componentsJoinedByString:@", "]];
            }
            else if([[[bookDict objectForKey:@"info"] objectForKey:@"tags"]isKindOfClass:[NSNull class]] || [[bookDict objectForKey:@"info"] objectForKey:@"tags"]){
                bookDetailsViewController.bookTags.text = [NSString stringWithFormat:@"Tags: -"];
            }
            
            [bookDetailsViewController.dropDownButton setTitle:[[bookDict objectForKey:@"info"] objectForKey:@"language"] forState:UIControlStateNormal];
           // [bookDetailsViewController.dropDownArrayData addObject:@"Record new language"];
           // [tempDropDownArray addObject:[[bookDict objectForKey:@"info"] objectForKey:@"language"]];
           // [tempDropDownArray addObjectsFromArray:[[bookDict objectForKey:@"available_languages"] valueForKey:@"language"]];
            //[bookDetailsViewController.dropDownArrayData addObjectsFromArray:[[NSSet setWithArray:tempDropDownArray] allObjects]];
            
            
          //  [bookDetailsViewController.dropDownView.uiTableView reloadData];
           
            bookDetailsViewController.bookAvailGamesNo.text = [NSString stringWithFormat:@"No. of Games: %@",[bookDict objectForKey:@"widget_count"]];
            
            bookDetailsViewController.ageLabel.text = [NSString stringWithFormat:@"Age Groups: %@", [[[bookDict objectForKey:@"info"] objectForKey:@"age_groups"] componentsJoinedByString:@", "]];
            if(![[[bookDict objectForKey:@"info"] objectForKey:@"learning_levels"] isKindOfClass:[NSNull class]]){
                bookDetailsViewController.readingLevelLabel.text = [NSString stringWithFormat:@"Reading Levels: %@", [[[bookDict objectForKey:@"info"] objectForKey:@"learning_levels"] componentsJoinedByString:@", "]];
            }
            else {
                bookDetailsViewController.readingLevelLabel.text = [NSString stringWithFormat:@"Reading Levels: -"];
            }
            bookDetailsViewController.numberOfPagesLabel.text = [NSString stringWithFormat:@"No. of pages: %d", [[bookDict objectForKey:@"page_count"] intValue]];
            
            bookDetailsViewController.priceLabel.text =  [[bookDict objectForKey:@"info"] valueForKey:@"language"];
           // if([[bookDict objectForKey:@"price"] floatValue] == 0.00){
                bookDetailsViewController.priceLabel.text = [NSString stringWithFormat:@"FREE"];
            //    [bookDetailsViewController.buyButton setImage:[UIImage imageNamed:@"Read-now.png"] forState:UIControlStateNormal];
          //  }
         //   else{
         //   bookDetailsViewController.priceLabel.text = [NSString stringWithFormat:@"$ %.2f", [[bookDict objectForKey:@"price"] floatValue]];
                //[bookDetailsViewController.buyButton setImage:[UIImage imageNamed:@"buynow.png"] forState:UIControlStateNormal];
         //   }
            
            if(![[[bookDict objectForKey:@"info"] objectForKey:@"categories"] isKindOfClass:[NSNull class]]){
                bookDetailsViewController.categoriesLabel.text = [[[bookDict objectForKey:@"info"] objectForKey:@"categories"] componentsJoinedByString:@", "];
            }
            else{
                bookDetailsViewController.categoriesLabel.text = [NSString stringWithFormat:@"Category: -"];
            }
            
            bookDetailsViewController.descriptionLabel.text = [bookDict objectForKey:@"synopsis"];
            
            NSDictionary *dimensions = @{
                                         PARAMETER_USER_ID : ID,
                                         PARAMETER_DEVICE: IOS,
                                         PARAMETER_BOOK_ID : [bookDict objectForKey:@"id"]
                                             
                                         };
            [delegate trackEvent:[STORE_FEATURED_BOOK valueForKey:@"description"] dimensions:dimensions];
            PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
            [userObject setObject:[STORE_FEATURED_BOOK valueForKey:@"value"] forKey:@"eventName"];
            [userObject setObject: [STORE_FEATURED_BOOK valueForKey:@"description"] forKey:@"eventDescription"];
            [userObject setObject:viewName forKey:@"viewName"];
            [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
            [userObject setObject:delegate.country forKey:@"deviceCountry"];
            [userObject setObject:delegate.language forKey:@"deviceLanguage"];
            [userObject setObject:[bookDict objectForKey:@"id"] forKey:@"bookID"];
            if(userEmail){
                [userObject setObject:ID forKey:@"emailID"];
            }
            [userObject setObject:IOS forKey:@"device"];
            [userObject saveInBackground];

            
            [bookDetailsViewController setIdOfDisplayBook:[bookDict objectForKey:@"id"]];
            
            bookDetailsViewController.selectedProductId = [bookDict objectForKey:@"id"];
            bookDetailsViewController.imageUrlString = [[ASSET_BASE_URL stringByAppendingString:[bookDict objectForKey:@"cover"]] stringByReplacingOccurrencesOfString:@"cover_" withString:@"banner_"];
        }];
        bookDetailsViewController.view.superview.frame = CGRectMake(([UIScreen mainScreen].applicationFrame.size.width/2)-400, ([UIScreen mainScreen].applicationFrame.size.height/2)-270, 776, 575);
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
            if([[UIDevice currentDevice] userInterfaceIdiom]== UIUserInterfaceIdiomPhone){
                return value *1.7f;
            }
            else{
                return value * 1.5f;
            }
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
    BooksCollectionViewController *booksCollectionViewController;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        booksCollectionViewController = [[BooksCollectionViewController alloc] initWithNibName:@"BooksCollectionViewController_iPhone" bundle:nil];
    }
    else{
        booksCollectionViewController = [[BooksCollectionViewController alloc] initWithNibName:@"BooksCollectionViewController" bundle:nil];
    }
    
    booksCollectionViewController.toEdit = NO;
    booksCollectionViewController.categorySelected = categoryDict;
    [self.navigationController pushViewController:booksCollectionViewController animated:YES];

    /// -----
    /*BooksFromCategoryViewController *booksCategoryViewController=[[BooksFromCategoryViewController alloc]initWithNibName:@"BooksFromCategoryViewController" bundle:nil withInitialIndex:0];
    booksCategoryViewController.toEdit = NO;
    booksCategoryViewController.categorySelected = categoryDict;
    [self.navigationController pushViewController:booksCategoryViewController animated:YES];*/
}

- (void)openBook:(Book *)bk {
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *identity=[NSString stringWithFormat:@"%@", bk.id];
    [appDelegate.dataModel displayAllData];
    
    CoverViewControllerBetterBookType *coverController;
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        coverController=[[CoverViewControllerBetterBookType alloc]initWithNibName:@"CoverViewControllerBetterBookType_iPhone" bundle:nil WithId:identity];
    }
    else{
        coverController=[[CoverViewControllerBetterBookType alloc]initWithNibName:@"CoverViewControllerBetterBookType" bundle:nil WithId:identity];
    }
    
    [self.navigationController pushViewController:coverController animated:YES];
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
                    return MIN(displayStoryNo, [[liveStoriesFiltered objectForKey:ageGroup] count]);
                }
                return displayStoryNo;
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
    if([[bookDict objectForKey:@"price"] floatValue] == 0.00){
       // cell.bookPriceLabel.text = [NSString stringWithFormat:@"FREE"];
        cell.bookPriceLabel.text = [[bookDict objectForKey:@"info"] valueForKey:@"language"];
    }
    else{
      //  cell.bookPriceLabel.text = [NSString stringWithFormat:@"$ %.2f", [[bookDict objectForKey:@"price"] floatValue]];
        cell.bookPriceLabel.text = [[bookDict objectForKey:@"info"] valueForKey:@"language"];
    }
    cell.bookPriceLabel.font = [UIFont systemFontOfSize:14];
    
    cell.bookTitleLabel.text = [bookDict objectForKey:@"title"];
    [cell.bookTitleLabel setFrame:CGRectMake(2, cell.bookTitleLabel.frame.origin.y, cell.bookTitleLabel.frame.size.width, [cell.bookTitleLabel.text sizeWithFont:cell.bookTitleLabel.font constrainedToSize:CGSizeMake(cell.bookTitleLabel.frame.size.width, 50)].height)];
    [cell setNeedsLayout];
    
    cell.imageUrlString = [[bookDict objectForKey:@"cover"] stringByReplacingOccurrencesOfString:@"cover_" withString:@"thumb_"];
    cell.bookImageView.image = nil;
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
                    
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                        
                        _storiesCarousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, 984, 130)];
                    }
                    else{
                        _storiesCarousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, 984, 240)];
                        
                    }
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
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                    
                    headerView.titleLabel.font = [UIFont boldSystemFontOfSize:12];
                }
                else{
                    headerView.titleLabel.font = [UIFont boldSystemFontOfSize:18];
                }
                
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
            
        default: {
            StoreCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HEADER_ID forIndexPath:indexPath];
            headerView.titleLabel.textColor = COLOR_DARK_RED;
            headerView.titleLabel.text = [[[self.liveStoriesFiltered allKeys] objectAtIndex:0] stringByRemovingPercentEncoding];
            headerView.section = indexPath.section;
            headerView.delegate = self;
            
            [headerView.titleLabel setFrame:CGRectMake(headerView.frame.origin.x + 200, 0, headerView.frame.size.width - 400, headerView.frame.size.height)];
            headerView.titleLabel.textAlignment = NSTextAlignmentCenter;
            
            [headerView.seeAllButton setImage:[UIImage imageNamed:@"arrowsideleft.png"] forState:UIControlStateNormal];
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                
                [headerView.seeAllButton setFrame:CGRectMake(0, 0, 90, headerView.frame.size.height)];
                headerView.titleLabel.font = [UIFont boldSystemFontOfSize:16];
            }
            else{
                [headerView.seeAllButton setFrame:CGRectMake(0, 0, 200, headerView.frame.size.height)];
                headerView.titleLabel.font = [UIFont boldSystemFontOfSize:22];
            }
            
            if(liveStoriesFiltered) {
                headerView.seeAllButton.hidden = NO;
            }
            
            return headerView;
        }
            break;
    }
    return nil;
}

#pragma mark - UICollectionView Delegate

- (void)showBookDetailsForBook:(NSDictionary *)bookDict {
    
    BookDetailsViewController *bookDetailsViewController;
    if(![self connected])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Your internet connection appears to be offline, plase try later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        bookDetailsViewController = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController_iPhone" bundle:nil];
        
    }
    else{
        bookDetailsViewController = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController" bundle:nil];
    }
    
    bookDetailsViewController.delegate = self;
  //  NSMutableArray *tempDropDownArray = [[NSMutableArray alloc] init];
    [bookDetailsViewController setModalPresentationStyle:UIModalPresentationPageSheet];
    [self presentViewController:bookDetailsViewController animated:YES completion:^(void) {
        bookDetailsViewController.bookTitleLabel.text = [bookDict objectForKey:@"title"];
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        
        if(![[bookDict objectForKey:@"authors"] isKindOfClass:[NSNull class]] && ([[[bookDict objectForKey:@"authors"] valueForKey:@"name"] count])){
            bookDetailsViewController.bookWrittenBy.text = [NSString stringWithFormat:@"Written by: %@", [[[bookDict objectForKey:@"authors"] valueForKey:@"name"] componentsJoinedByString:@", "]];
        }
        else{
            bookDetailsViewController.bookWrittenBy.text = [NSString stringWithFormat:@""];
        }
        
        
        if(![[[bookDict objectForKey:@"info"] objectForKey:@"tags"]isKindOfClass:[NSNull class]]){
            bookDetailsViewController.bookTags.text = [NSString stringWithFormat:@"Tags: %@", [[[bookDict objectForKey:@"info"] objectForKey:@"tags"] componentsJoinedByString:@", "]];
        }
        else{
            bookDetailsViewController.bookTags.text = [NSString stringWithFormat:@"Tags: -"];
        }
        
        if(![[bookDict objectForKey:@"narrators"] isKindOfClass:[NSNull class]] && ([[[bookDict objectForKey:@"narrators"] valueForKey:@"name"] count])){
            bookDetailsViewController.bookNarrateBy.text = [NSString stringWithFormat:@"Narrated by: %@", [[[bookDict objectForKey:@"narrators"] valueForKey:@"name"] componentsJoinedByString:@", "]];
        }
        else{
            bookDetailsViewController.bookNarrateBy.text = [NSString stringWithFormat:@""];
        }
        
        if(![[bookDict objectForKey:@"illustrators"] isKindOfClass:[NSNull class]] && ([[[bookDict objectForKey:@"illustrators"] valueForKey:@"name"] count])){
            bookDetailsViewController.bookIllustratedBy.text = [NSString stringWithFormat:@"Illustrated by: %@", [[[bookDict objectForKey:@"illustrators"] valueForKey:@"name"] componentsJoinedByString:@", "]];
        }
        else{
            bookDetailsViewController.bookIllustratedBy.text = [NSString stringWithFormat:@""];
        }
        
        [bookDetailsViewController.dropDownButton setTitle:[[bookDict objectForKey:@"info"] objectForKey:@"language"] forState:UIControlStateNormal];
       // [tempDropDownArray addObject:[[bookDict objectForKey:@"info"] objectForKey:@"language"]];
     //   [tempDropDownArray addObjectsFromArray:[[bookDict objectForKey:@"available_languages"] valueForKey:@"language"]];
        
        //NSDictionary *tempDict = [[NSDictionary alloc] initWithObjectsAndKeys:[[bookDict objectForKey:@"info"] objectForKey:@"language"], @"Language", [bookDict valueForKey:@"id"], @"Id", nil];
        
       // bookDetailsViewController.dropDownSelectedItemData = [[NSMutableArray alloc] initWithObjects:tempDict, nil];
        
        //[bookDetailsViewController.dropDownArrayData addObjectsFromArray:[[NSSet setWithArray:tempDropDownArray] allObjects]];
       // [bookDetailsViewController.dropDownArrayData addObject:@"Record new language"];
        
       // [bookDetailsViewController.dropDownView.uiTableView reloadData];
        bookDetailsViewController.bookAvailGamesNo.text = [NSString stringWithFormat:@"No. of Games: %@",[bookDict objectForKey:@"widget_count"]];
        
        bookDetailsViewController.ageLabel.text = [NSString stringWithFormat:@"Age Group: %@", [[[bookDict objectForKey:@"info"] objectForKey:@"age_groups"] componentsJoinedByString:@", "]];
        
        if(![[[bookDict objectForKey:@"info"] objectForKey:@"learning_levels"] isKindOfClass:[NSNull class]]){
            bookDetailsViewController.readingLevelLabel.text = [NSString stringWithFormat:@"Reading Levels: %@", [[[bookDict objectForKey:@"info"] objectForKey:@"learning_levels"] componentsJoinedByString:@", "]];
        }
        else {
            bookDetailsViewController.readingLevelLabel.text = [NSString stringWithFormat:@"Reading Levels: -"];
        }
        
        bookDetailsViewController.numberOfPagesLabel.text = [NSString stringWithFormat:@"No. of pages: %d", [[bookDict objectForKey:@"page_count"] intValue]];
        
       // if([[bookDict objectForKey:@"price"] floatValue] == 0.00){
          //  bookDetailsViewController.priceLabel.text = [NSString stringWithFormat:@"FREE"];
            
       //     [bookDetailsViewController.buyButton setImage:[UIImage imageNamed:@"Read-now.png"] forState:UIControlStateNormal];
      //  }
      //  else{
       //     bookDetailsViewController.priceLabel.text = [NSString stringWithFormat:@"$ %.2f", [[bookDict objectForKey:@"price"] floatValue]];
      //      [bookDetailsViewController.buyButton setImage:[UIImage imageNamed:@"buynow.png"] forState:UIControlStateNormal];
      //  }
        bookDetailsViewController.priceLabel.text =  [[bookDict objectForKey:@"info"] valueForKey:@"language"];
        
        if(![[[bookDict objectForKey:@"info"] objectForKey:@"categories"] isKindOfClass:[NSNull class]]){
            bookDetailsViewController.categoriesLabel.text = [[[bookDict objectForKey:@"info"] objectForKey:@"categories"] componentsJoinedByString:@", "];
        }
        else{
            bookDetailsViewController.categoriesLabel.text = [NSString stringWithFormat:@"Category: -"];
        }
        
        NSDictionary *dimensions = @{
                                     PARAMETER_USER_ID : ID,
                                     PARAMETER_DEVICE: IOS,
                                     PARAMETER_BOOK_ID: [bookDict objectForKey:@"id"],
                                     PARAMETER_BOOK_AGE_GROUP :[[[bookDict objectForKey:@"info"] objectForKey:@"age_groups"] componentsJoinedByString:@", "],
                                     
                                     };
        [delegate trackEvent:[STORE_AGE_STORE_BOOK valueForKey:@"description"] dimensions:dimensions];
        PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
        [userObject setObject:[STORE_AGE_STORE_BOOK valueForKey:@"value"] forKey:@"eventName"];
        [userObject setObject: [STORE_AGE_STORE_BOOK valueForKey:@"description"] forKey:@"eventDescription"];
        [userObject setObject:viewName forKey:@"viewName"];
        [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
        [userObject setObject:delegate.country forKey:@"deviceCountry"];
        [userObject setObject:delegate.language forKey:@"deviceLanguage"];
        [userObject setObject:[bookDict objectForKey:@"id"] forKey:@"bookID"];
        if(userEmail){
            [userObject setObject:ID forKey:@"emailID"];
        }
        [userObject setObject:IOS forKey:@"device"];
        [userObject saveInBackground];
        
        bookDetailsViewController.descriptionLabel.text = [bookDict objectForKey:@"synopsis"];
        [bookDetailsViewController setIdOfDisplayBook:[bookDict objectForKey:@"id"]];
        
        bookDetailsViewController.selectedProductId = [bookDict objectForKey:@"id"];
        bookDetailsViewController.imageUrlString = [[ASSET_BASE_URL stringByAppendingString:[bookDict objectForKey:@"cover"]] stringByReplacingOccurrencesOfString:@"cover_" withString:@"banner_"];
    }];
    bookDetailsViewController.view.superview.frame = CGRectMake(([UIScreen mainScreen].applicationFrame.size.width/2)-400, ([UIScreen mainScreen].applicationFrame.size.height/2)-270, 776, 575);
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
                return UIEdgeInsetsMake(0, 0, 10, 0);
            }
        }
            break;
            
        default:
            break;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        return UIEdgeInsetsMake(-10, 15, 0, 20);
    }
    else{
     return UIEdgeInsetsMake(20, 20, 0, 0);
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        if (_tableType == TABLE_TYPE_MAIN_STORE) {
            return CGSizeMake(collectionView.frame.size.width, 0);
        } else {
            return CGSizeMake(collectionView.frame.size.width, 40);
        }
    } else {
        return CGSizeMake(collectionView.frame.size.width, 40);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (_tableType) {
        case TABLE_TYPE_MAIN_STORE: {
            if (indexPath.section == 0) {
                
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                    return CGSizeMake(984, 130);
                }
                else{
                    return CGSizeMake(984, 240);
                }
                
                
            }
        }
            break;
            
        default:
            break;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        return CGSizeMake(110, 155);
    }
    else{
        return CGSizeMake(150, 240);
    }
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
