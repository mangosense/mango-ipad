//
//  BookDetailsViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 12/02/14.
//
//

#import "BookDetailsViewController.h"
#import "MBProgressHUD.h"
#import "CargoBay.h"
#import "HKCircularProgressLayer.h"
#import "HKCircularProgressView.h"
#import "Constants.h"
#import "BooksFromCategoryViewController.h"
#import "AePubReaderAppDelegate.h"
#import "CoverViewControllerBetterBookType.h"
#import "MangoSubscriptionViewController.h"

@interface BookDetailsViewController ()

@property (nonatomic, assign) int bookProgress;
@property (nonatomic, strong) HKCircularProgressView *progressView;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, strong) NSString *bookId;

@end

@implementation BookDetailsViewController

static int booksDownloadingCount;

-(NSMutableArray*) bookIdArray
{
    static NSMutableArray* theArray = nil;
    if (theArray == nil)
    {
        theArray = [[NSMutableArray alloc] init];
    }
    return theArray;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [_bookImageView setContentMode:UIViewContentModeScaleAspectFill];
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        userEmail = delegate.loggedInUserInfo.email;
        userDeviceID = delegate.deviceId;
       
    }
    return self;
}

+ (int) booksDownloadingNo{
    
    return  booksDownloadingCount;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)setIdOfDisplayBook:(NSString *)book_Id {
    
    _displayBookID = book_Id;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //_buyButton.userInteractionEnabled = NO;
    currentPage =  @"show_book";
    // Do any additional setup after loading the view from its nib.
    _bookImageView.layer.cornerRadius = 3.0;
    _dropDownArrayData = [[NSMutableArray alloc] init];
    _dropDownIdArrayData = [[NSMutableArray alloc] init];
    _descriptionLabel.editable = NO;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int validSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
    
    if(!validSubscription){
        
        int isUserSubscribed = [[prefs valueForKey:@"USERISSUBSCRIBED"] integerValue];
        
        if(isUserSubscribed){
            [_buyButton setTitle: @"Read Now" forState: UIControlStateNormal];
            _buyButton.userInteractionEnabled = YES;
        }
        else{
            
            [_buyButton setTitle: @"Subscribe Now" forState: UIControlStateNormal];
            _buyButton.userInteractionEnabled = YES;
        }
    }
    else{
        [_buyButton setTitle: @"Read Now" forState: UIControlStateNormal];
        _buyButton.userInteractionEnabled = YES;
    }
    
    // take current payment queue
    SKPaymentQueue* currentQueue = [SKPaymentQueue defaultQueue];
    // finish ALL transactions in queue
    [currentQueue.transactions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [currentQueue finishTransaction:(SKPaymentTransaction *)obj];
    }];
    
    if(_fromMyStories){
        
        [_buyButton setTitle: @"Read Now" forState: UIControlStateNormal];
        _buyButton.userInteractionEnabled = YES;
    }
    
    //[[SKPaymentQueue defaultQueue] addTransactionObserver:[CargoBay sharedManager]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeDetailBookWithOutAnimation) name:@"CloseDetailView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventListenerDidReceiveNotification:) name:@"BookProgress" object:nil];

}


- (void)eventListenerDidReceiveNotification:(NSNotification *)notif
{
    
    //NSLog(@"Successfully received the notification!");
        
    NSDictionary *userInfo = notif.userInfo;
    
    newIDValue = [userInfo valueForKey:@"bookIdVal"];
    newProgress = [[userInfo valueForKey:@"progressVal"] integerValue];
    if([_displayBookID isEqualToString:newIDValue]){
        [self updateBookProgress:newProgress];
    }
}

- (void) addProgressBar{
    
    if(!_progressView){
    _progressView = [[HKCircularProgressView alloc] initWithFrame:CGRectMake(_bookImageView.frame.size.width/2 - 50, _bookImageView.frame.size.height/2 - 50, 100, 100)];
    _progressView.max = 100.0f;
    _progressView.step = 1.0f;
    _progressView.fillRadius = 1;
    _progressView.trackTintColor = COLOR_LIGHT_GREY;
    [_progressView setAlpha:0.6f];
    [_bookImageView addSubview:_progressView];
    }
    
    //_progressView.current = MAX(1, _bookProgress);
}

- (void) availLanguagedata{
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
    NSString *url;
    url = LANGUAGES_FOR_BOOK;
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setObject:_displayBookID forKey:@"story_id"];
//    [paramDict setObject:IOS forKey:PLATFORM];
    [apiController getListOf:url ForParameters:paramDict withDelegate:self];
}

- (void)reloadViewsWithArray:(NSArray *)dataArray ForType:(NSString *)type {
    _dropDownButton.userInteractionEnabled = YES;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *storyOfDayId = [prefs valueForKey:@"StoryOfTheDayBookId"];
    NSLog(@"Data array %d", dataArray.count);
    if(![dataArray count]){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        return;
    }
    
    if([type isEqualToString:@"livestories/available_languages"]){
        
        NSMutableArray *tempDataArray = [[NSMutableArray alloc]init];
        NSMutableArray *tempDataArrayCanBeDuplicate = [[NSMutableArray alloc]init];
        _dropDownArrayData = [[NSMutableArray alloc] init];
        _dropDownIdArrayData = [[NSMutableArray alloc] init];
        tempDataArrayCanBeDuplicate = [NSMutableArray arrayWithArray:dataArray];
        [tempDataArray addObjectsFromArray:[[NSSet setWithArray:tempDataArrayCanBeDuplicate] allObjects]];
        _labelAvaillanguageCount.text = [NSString stringWithFormat:@"Available in %d language:",[tempDataArray count]+1];
        for(int i=0; i< [tempDataArray count]; ++i){
            
            [_dropDownArrayData addObject:[tempDataArray[i] objectForKey:@"language"]];
            NSLog(@"Print %@", [tempDataArray[i] objectForKey:@"language"]);
            [_dropDownIdArrayData addObject:[tempDataArray[i] objectForKey:@"live_story_id"]];
        }
        
        int cellHeight;
        
        int countLanguageRows = _dropDownIdArrayData.count;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            cellHeight = 26;
        }
        else{
            cellHeight = 33;
        }
        if(countLanguageRows>5){
            countLanguageRows = 4;
        }
        
        int paddingTopValue = -(cellHeight+cellHeight*countLanguageRows);
        int heightOfTableView = (cellHeight+cellHeight*countLanguageRows);
        _dropDownView = [[DropDownView alloc] initWithArrayData:_dropDownArrayData cellHeight:cellHeight heightTableView:heightOfTableView paddingTop:paddingTopValue paddingLeft:0  paddingRight:0 refView:_dropDownButton animation:BOTH openAnimationDuration:0.1 closeAnimationDuration:0.5];
        _dropDownView.delegate = self;
        
        [self.view addSubview:_dropDownView.view];
        
        [_dropDownView.uiTableView reloadData];
        
        if(_dropDownIdArrayData.count >0){
            [self.dropDownView openAnimation];
        }
    }
    else{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSDictionary *bookDict = [[NSDictionary alloc]init];
        bookDict = dataArray[0];
        _bookTitleLabel.text = [bookDict objectForKey:@"title"];
        
        if(![[bookDict objectForKey:@"authors"] isKindOfClass:[NSNull class]] && ([[[bookDict objectForKey:@"authors"] valueForKey:@"name"] count])){
            _bookWrittenBy.text = [NSString stringWithFormat:@"-by : %@", [[[bookDict objectForKey:@"authors"] valueForKey:@"name"] componentsJoinedByString:@", "]];
        }
        else{
            _bookWrittenBy.text = [NSString stringWithFormat:@""];
        }
        
        
        if(![[[bookDict objectForKey:@"info"] objectForKey:@"tags"]isKindOfClass:[NSNull class]]){
            _bookTags.text = [NSString stringWithFormat:@"Tags: %@", [[[bookDict objectForKey:@"info"] objectForKey:@"tags"] componentsJoinedByString:@", "]];
        }
        else{
            _bookTags.text = [NSString stringWithFormat:@"Tags: -"];
        }
        
        if(![[bookDict objectForKey:@"narrators"] isKindOfClass:[NSNull class]] && ([[[bookDict objectForKey:@"narrators"] valueForKey:@"name"] count])){
            _bookNarrateBy.text = [NSString stringWithFormat:@"Narrated by: %@", [[[bookDict objectForKey:@"narrators"] valueForKey:@"name"] componentsJoinedByString:@", "]];
        }
        else{
            _bookNarrateBy.text = [NSString stringWithFormat:@""];
        }
        
        if(![[bookDict objectForKey:@"illustrators"] isKindOfClass:[NSNull class]] && ([[[bookDict objectForKey:@"illustrators"] valueForKey:@"name"] count])){
            _bookIllustratedBy.text = [NSString stringWithFormat:@"Illustrated by: %@", [[[bookDict objectForKey:@"illustrators"] valueForKey:@"name"] componentsJoinedByString:@", "]];
        }
        else{
            _bookIllustratedBy.text = [NSString stringWithFormat:@""];
        }
        
        //[bookDetailsViewController.dropDownView.uiTableView reloadData];
        _bookAvailGamesNo.text = [NSString stringWithFormat:@"Games : %@",[bookDict objectForKey:@"widget_count"]];
        
        _ageLabel.text = [NSString stringWithFormat:@"Age : %@", [bookDict objectForKey:@"combined_age_group"]];
        
        _gradeLevel.text = [NSString stringWithFormat:@"Grade : %@", [bookDict objectForKey:@"combined_grades"]];
        
        if(![[bookDict objectForKey:@"combined_reading_level"] isKindOfClass:[NSNull class]]){
            _readingLevelLabel.text = [NSString stringWithFormat:@"Reading Level : %@", [bookDict objectForKey:@"combined_reading_level"]];
        }
        else {
            _readingLevelLabel.text = [NSString stringWithFormat:@"Reading Level : -"];
        }
        
        _numberOfPagesLabel.text = [NSString stringWithFormat:@"Pages : %d", [[bookDict objectForKey:@"page_count"] intValue]];
        if([[bookDict objectForKey:@"price"] floatValue] == 0.00){
            _priceLabel.text = [NSString stringWithFormat:@"FREE"];
           // [_buyButton setImage:[UIImage imageNamed:@"Read-now.png"] forState:UIControlStateNormal];
        }
        else{
            _priceLabel.text = [NSString stringWithFormat:@"$ %.2f", [[bookDict objectForKey:@"price"] floatValue]];
           // [_buyButton setImage:[UIImage imageNamed:@"buynow.png"] forState:UIControlStateNormal];
        }
        
        if(![[[bookDict objectForKey:@"info"] objectForKey:@"categories"] isKindOfClass:[NSNull class]]){
            _categoriesLabel.text = [NSString stringWithFormat:@"Category : %@",[[[bookDict objectForKey:@"info"] objectForKey:@"categories"] componentsJoinedByString:@", "]];
            _singleCategoryLabel.text = [NSString stringWithFormat:@"Category : %@",[[[bookDict objectForKey:@"info"] objectForKey:@"categories"] componentsJoinedByString:@", "]];
        }
        else{
            _categoriesLabel.text = [NSString stringWithFormat:@"Category: -"];
        }
        
        if([storyOfDayId isEqualToString:[bookDict objectForKey:@"id"]]){
            [_buyButton setTitle: @"Read Now" forState: UIControlStateNormal];
            _imgStoryOfDay.hidden = NO;
        }
        
        _descriptionLabel.text = [bookDict objectForKey:@"synopsis"];
        
        _selectedProductId = [bookDict objectForKey:@"id"];
        //_imageUrlString = [[ASSET_BASE_URL stringByAppendingString:[bookDict objectForKey:@"cover"]] stringByReplacingOccurrencesOfString:@"cover_" withString:@"banner_"];
        _imageUrlString = [[bookDict objectForKey:@"thumb"] stringByReplacingOccurrencesOfString:@"thumb_new" withString:@"ipad_banner"];
        [self getImageForUrl:_imageUrlString];
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    //Register observer
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:[CargoBay sharedManager]];
}

#pragma mark - Setters

- (void)setImageUrlString:(NSString *)imageUrlString {
    _imageUrlString = imageUrlString;
    [self getImageForUrl:_imageUrlString];
}

#pragma mark - Action Methods

- (IBAction)buyButtonTapped:(id)sender {

    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    if([self checkIfBookIdIsAvailable:_selectedProductId]){
            
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Error" message:@"Book is already in downloading" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [self addProgressBar];
        return;
    }
    
    _buyButton.userInteractionEnabled = NO;
    //if (_selectedProductId) {
    if([_buyButton.titleLabel.text isEqualToString:@"Read Now"]){
        //Temporarily Added For Direct Downloading
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *storyOfDayId = [prefs valueForKey:@"StoryOfTheDayBookId"];
        NSString *event;
        if([storyOfDayId isEqualToString:_displayBookID]){
            event = @"story_of_day_read_btn_click";
        }
        else{
            event = @"read_btn_click";
        }
        
        //[self itemReadyToUse:_selectedProductId ForTransaction:nil];
        
        NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
        [dimensions setObject:event forKey:PARAMETER_ACTION];
        [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
        [dimensions setObject:_displayBookID forKey:PARAMETER_BOOK_ID];
        [dimensions setObject:_baseNavView forKey:PARAMETER_BOOKDETAIL_SOURCE];
        [dimensions setObject:@"Read button click" forKey:PARAMETER_EVENT_DESCRIPTION];
        if(userEmail){
            [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
        }
        [delegate trackEventAnalytic:event dimensions:dimensions];
        [delegate eventAnalyticsDataBrowser:dimensions];
        [delegate trackMixpanelEvents:dimensions eventName:event];
        
        AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
        Book *bk=[appDelegate.dataModel getBookOfEJDBId:_selectedProductId];
        NSString *userTransctionId;
        if(appDelegate.subscriptionInfo.subscriptionTransctionId){
            
            userTransctionId = appDelegate.subscriptionInfo.subscriptionTransctionId;
        }
        if (bk) {
            
            int isDownloaded = [bk.downloaded integerValue];
            if(isDownloaded == 2 || !isDownloaded){
                
                if(booksDownloadingCount >= 3){
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Error" message:@"You can download only 3 books at a time" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                    return;
                }
                booksDownloadingCount ++;
                [self addBookIdIntoArray:_selectedProductId];
                [self itemReadyToUse:_selectedProductId ForTransaction:userTransctionId];
            }
            else{
                if (_delegate && [_delegate respondsToSelector:@selector(openBook:)]) {
                    [self deleteBookIdFromArray:_selectedProductId];
                    [_delegate openBook:bk];
                }
                [self closeDetails:nil];
            }
        } else {
           // [[PurchaseManager sharedManager] itemProceedToPurchase:_selectedProductId storeIdentifier:_selectedProductId withDelegate:self];
            
            if(booksDownloadingCount >= 3){
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Error" message:@"You can download only 3 books at a time" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            
            booksDownloadingCount ++;
            [self addBookIdIntoArray:_selectedProductId];
            [self itemReadyToUse:_selectedProductId ForTransaction:userTransctionId];
        }
        //_buyButton.userInteractionEnabled = YES;
    }
    
    else {
        NSLog(@"Product dose not have relative Id");
        
        MangoSubscriptionViewController *subscriptionViewController;
        
        NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
        [dimensions setObject:@"subscribe_btn_click" forKey:PARAMETER_ACTION];
        [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
        [dimensions setObject:_displayBookID forKey:PARAMETER_BOOK_ID];
        [dimensions setObject:_baseNavView forKey:PARAMETER_BOOKDETAIL_SOURCE];
        [dimensions setObject:@"Subscribe button click" forKey:PARAMETER_EVENT_DESCRIPTION];
        if(userEmail){
            [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
        }
        [delegate trackEventAnalytic:@"subscribe_btn_click" dimensions:dimensions];
        [delegate eventAnalyticsDataBrowser:dimensions];
        [delegate trackMixpanelEvents:dimensions eventName:@"subscribe_btn_click"];
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            
            subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController_iPhone" bundle:nil];
        }
        else{
            subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController" bundle:nil];
        }
        [subscriptionViewController checkIfViewFromBookDetail:1];
        subscriptionViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:subscriptionViewController animated:YES completion:nil];
        
    }
}

- (IBAction)closeDetails:(id)sender {
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
    [dimensions setObject:@"close_dialog" forKey:PARAMETER_ACTION];
    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
    [dimensions setObject:_displayBookID forKey:PARAMETER_BOOK_ID];
    [dimensions setObject:@"Closing the detail dialog" forKey:PARAMETER_EVENT_DESCRIPTION];
    [dimensions setObject:_baseNavView forKey:PARAMETER_BOOKDETAIL_SOURCE];
    if(userEmail){
        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
    }
    [delegate trackEventAnalytic:@"close_dialog" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"close_dialog"];
    
    //self.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
    [self dismissViewControllerAnimated:NO completion:^(void) {
        //[_delegate openBookViewWithCategory:[NSDictionary dictionaryWithObject:[NSArray arrayWithObject:[[_categoriesLabel.text componentsSeparatedByString:@", "] firstObject]] forKey:@"categories"]];
    }];
}

- (void) closeDetailBookWithOutAnimation{
    
    self.modalPresentationStyle = UIModalPresentationNone;
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)openBook:(NSString *)bookId {
    if (_delegate && [_delegate respondsToSelector:@selector(openBookViewWithCategory:)]) {
        [_delegate openBookViewWithCategory:[NSDictionary dictionaryWithObject:[[_categoriesLabel.text componentsSeparatedByString:@", "] firstObject] forKey:NAME]];
    }
    [self closeDetails:nil];
}

#pragma mark - Get Image

- (void)getImageForUrl:(NSString *)urlString {
    MangoApiController *apiController = [MangoApiController sharedApiController];
    
    [MBProgressHUD showHUDAddedTo:_bookImageView animated:YES];
    [apiController getImageAtUrl:urlString withDelegate:self];
}

#pragma mark - Purchased Manager Call Back

- (void)itemReadyToUse:(NSString *)productId ForTransaction:(NSString *)transactionId {
    _bookId = productId;
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
    [apiController downloadBookWithId:productId withDelegate:self ForTransaction:transactionId];
}

#pragma mark - Post API Delegate

- (void)reloadImage:(UIImage *)image forUrl:(NSString *)urlString {
    [MBProgressHUD hideAllHUDsForView:_bookImageView animated:YES];
    
    [_bookImageView setImage:image];
}

- (void)bookDownloaded {
    [self openBook:_bookId];
    booksDownloadingCount--;
    [self deleteBookIdFromArray:_bookId];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Complete" message:@"Your book is downloaded, go to my stories view" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)bookDownloadAborted{
    
    [self deleteBookIdFromArray:_bookId];
    booksDownloadingCount--;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Aborted" message:@"Book download aborted, please try again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
    [self closeDetails:nil];
}

-(void)dropDownCellSelected:(NSInteger)returnIndex{
	
   [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
    [dimensions setObject:@"switch_language" forKey:PARAMETER_ACTION];
    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
    [dimensions setObject:_displayBookID forKey:PARAMETER_BOOK_ID];
    [dimensions setObject:_bookTitleLabel.text forKey:PARAMETER_BOOK_TITLE];
    [dimensions setObject:@"Switching the language" forKey:PARAMETER_EVENT_DESCRIPTION];
    [dimensions setObject:_dropDownButton.titleLabel.text forKey:PARAMETER_BOOK_LANGUAGE];
    [dimensions setObject:[_dropDownIdArrayData objectAtIndex:returnIndex] forKey:PARAMETER_NEWLANG_BOOK_ID];
    [dimensions setObject:[_dropDownArrayData objectAtIndex:returnIndex] forKey:PARAMETER_BOOK_NEW_LANGUAGE_SELECT];
    [dimensions setObject:_baseNavView forKey:PARAMETER_BOOKDETAIL_SOURCE];
    if(userEmail){
        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
    }
    [delegate trackEventAnalytic:@"switch_language" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"switch_language"];
    
        [_dropDownButton setTitle:[_dropDownArrayData objectAtIndex:returnIndex] forState:UIControlStateNormal];
        MangoApiController *apiController = [MangoApiController sharedApiController];
        NSString *url;
        url = [LIVE_STORIES_WITH_ID stringByAppendingString:[NSString stringWithFormat:@"/%@",[_dropDownIdArrayData objectAtIndex:returnIndex]]];
    
    _displayBookID = [_dropDownIdArrayData objectAtIndex:returnIndex];
    _selectedProductId = _displayBookID;
    
        [apiController getListOf:url ForParameters:nil withDelegate:self];

	//handle book language response here ...
}



-(IBAction)dropDownActionButtonClick{
    
    _dropDownButton.userInteractionEnabled = NO;
    [self availLanguagedata];
}

- (void)updateBookProgress:(int)progress {
    if(progress <0){
        progress = 0;
    }
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    _bookProgress = progress;
    //[_buyButton setHidden:YES];
    
    if (progress < 100) {
        [self performSelectorOnMainThread:@selector(showHudOnButton) withObject:nil waitUntilDone:YES];
        //[_closeButton setEnabled:NO];
    } else {
        [self performSelectorOnMainThread:@selector(hideHudOnButton) withObject:nil waitUntilDone:YES];
        //[_closeButton setEnabled:YES];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [_dropDownView closeAnimation];
    }
}

#pragma mark - HUD Methods

- (void)showHudOnButton {
    if (!_progressView) {
        _progressView = [[HKCircularProgressView alloc] initWithFrame:CGRectMake(_bookImageView.frame.size.width/2 - 50, _bookImageView.frame.size.height/2 - 50, 100, 100)];
        _progressView.max = 100.0f;
        _progressView.step = 0.0f;
        _progressView.fillRadius = 1;
        _progressView.trackTintColor = COLOR_LIGHT_GREY;
        [_progressView setAlpha:0.6f];
        [_bookImageView addSubview:_progressView];
        
    }
    NSString *progressVal = [NSString stringWithFormat:@"%d%%",(int)_progressView.current];
    _progressLabel.text = progressVal;
    _progressView.current = MAX(1, _bookProgress);
    if((int)_progressView.current > 99){
        _progressLabel.hidden = YES;
    }
   // NSLog(@"Display progress %f %@",_progressView.current, _bookId);
}

- (void)hideHudOnButton {
    [_progressView removeFromSuperview];
}

- (void) addBookIdIntoArray :(NSString *)bookId{
    
    [[self bookIdArray] addObject:bookId];
}

- (void) deleteBookIdFromArray : (NSString *)bookId{
    [[self bookIdArray] removeObject:bookId];
}

- (BOOL) checkIfBookIdIsAvailable :(NSString *)bookId{
    
    if([[self bookIdArray] containsObject:bookId])
        return YES;
    else
        return  NO;
}

@end
