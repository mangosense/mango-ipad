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
    viewName = @"Book Detail View Page";
    // Do any additional setup after loading the view from its nib.
    _bookImageView.layer.cornerRadius = 3.0;
    _dropDownArrayData = [[NSMutableArray alloc] init];
    _dropDownIdArrayData = [[NSMutableArray alloc] init];
    _descriptionLabel.editable = NO;
    
    if(!userEmail){
        ID = userDeviceID;
    }
    else{
        ID = userEmail;
    }
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
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
       /* if(appDelegate.subscriptionInfo){
            //provide access
            
            [[MangoApiController sharedApiController]validateSubscription:appDelegate.subscriptionInfo.subscriptionTransctionId andDeviceId:appDelegate.deviceId block:^(id response, NSInteger type, NSString *error){
                NSLog(@"type --- %d", type);
                if ([[response objectForKey:@"status"] integerValue] == 1){
                    
                    [_buyButton setTitle: @"Read Now" forState: UIControlStateNormal];
                    NSLog(@"You are already subscribed");
                }
                else{
                    [_buyButton setTitle: @"Subscribe Now" forState: UIControlStateNormal];
                }
                _buyButton.userInteractionEnabled = YES;
            }];
        }*/
        
       /* else{
            
            [[MangoApiController sharedApiController]validateSubscription:appDelegate.subscriptionInfo.subscriptionTransctionId andDeviceId:appDelegate.deviceId block:^(id response, NSInteger type, NSString *error){
                NSLog(@"type --- %d", type);
                if ([[response objectForKey:@"status"] integerValue] == 1){
                    
                    NSLog(@"You are already subscribed");
                    [_buyButton setTitle: @"Read Now" forState: UIControlStateNormal];
                }
                else{
                    [_buyButton setTitle: @"Subscribe Now" forState: UIControlStateNormal];
                }
                _buyButton.userInteractionEnabled = YES;
                
            }];
        }*/
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
    
    //[[SKPaymentQueue defaultQueue] addTransactionObserver:[CargoBay sharedManager]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeDetailBookWithOutAnimation) name:@"CloseDetailView" object:nil];

}



- (void) availLanguagedata{
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
    NSString *url;
    url = LANGUAGES_FOR_BOOK;
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setObject:_displayBookID forKey:@"story_id"];
    [paramDict setObject:IOS forKey:PLATFORM];
    [apiController getListOf:url ForParameters:paramDict withDelegate:self];
}

- (void)reloadViewsWithArray:(NSArray *)dataArray ForType:(NSString *)type {
    _dropDownButton.userInteractionEnabled = YES;
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
        for(int i=0; i< [tempDataArray count]; ++i){
            
            [_dropDownArrayData addObject:[tempDataArray[i] objectForKey:@"language"]];
            NSLog(@"Print %@", [tempDataArray[i] objectForKey:@"language"]);
            [_dropDownIdArrayData addObject:[tempDataArray[i] objectForKey:@"live_story_id"]];
        }
        
        int cellHeight;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            cellHeight = 26;
        }
        else{
            cellHeight = 33;
        }
        
        int paddingTopValue = -(cellHeight+cellHeight*_dropDownIdArrayData.count);
        _dropDownView = [[DropDownView alloc] initWithArrayData:_dropDownArrayData cellHeight:cellHeight heightTableView:(cellHeight+cellHeight*_dropDownIdArrayData.count) paddingTop:paddingTopValue paddingLeft:0  paddingRight:0 refView:_dropDownButton animation:BOTH openAnimationDuration:0.1 closeAnimationDuration:0.5];
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
            _bookWrittenBy.text = [NSString stringWithFormat:@"Written by: %@", [[[bookDict objectForKey:@"authors"] valueForKey:@"name"] componentsJoinedByString:@", "]];
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
        _bookAvailGamesNo.text = [NSString stringWithFormat:@"No. of Games: %@",[bookDict objectForKey:@"widget_count"]];
        
        _ageLabel.text = [NSString stringWithFormat:@"Age Group: %@", [[[bookDict objectForKey:@"info"] objectForKey:@"age_groups"] componentsJoinedByString:@", "]];
        
        if(![[[bookDict objectForKey:@"info"] objectForKey:@"learning_levels"] isKindOfClass:[NSNull class]]){
            _readingLevelLabel.text = [NSString stringWithFormat:@"Reading Levels: %@", [[[bookDict objectForKey:@"info"] objectForKey:@"learning_levels"] componentsJoinedByString:@", "]];
        }
        else {
            _readingLevelLabel.text = [NSString stringWithFormat:@"Reading Levels: -"];
        }
        
        _numberOfPagesLabel.text = [NSString stringWithFormat:@"No. of pages: %d", [[bookDict objectForKey:@"page_count"] intValue]];
        if([[bookDict objectForKey:@"price"] floatValue] == 0.00){
            _priceLabel.text = [NSString stringWithFormat:@"FREE"];
           // [_buyButton setImage:[UIImage imageNamed:@"Read-now.png"] forState:UIControlStateNormal];
        }
        else{
            _priceLabel.text = [NSString stringWithFormat:@"$ %.2f", [[bookDict objectForKey:@"price"] floatValue]];
           // [_buyButton setImage:[UIImage imageNamed:@"buynow.png"] forState:UIControlStateNormal];
        }
        
        if(![[[bookDict objectForKey:@"info"] objectForKey:@"categories"] isKindOfClass:[NSNull class]]){
            _categoriesLabel.text = [[[bookDict objectForKey:@"info"] objectForKey:@"categories"] componentsJoinedByString:@", "];
        }
        else{
            _categoriesLabel.text = [NSString stringWithFormat:@"Category: -"];
        }
        
        _descriptionLabel.text = [bookDict objectForKey:@"synopsis"];
        
        _selectedProductId = [bookDict objectForKey:@"id"];
        _imageUrlString = [[ASSET_BASE_URL stringByAppendingString:[bookDict objectForKey:@"cover"]] stringByReplacingOccurrencesOfString:@"cover_" withString:@"banner_"];
        
        [self getImageForUrl:[_imageUrlString stringByReplacingOccurrencesOfString:@"banner" withString:@"leftright"]];
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
    [self getImageForUrl:[_imageUrlString stringByReplacingOccurrencesOfString:@"banner" withString:@"leftright"]];
}

#pragma mark - Action Methods

- (IBAction)buyButtonTapped:(id)sender {
    
   /* if([self bookIdArray].count >= 3){
        
        return;
    }*/
        
    if([self checkIfBookIdIsAvailable:_selectedProductId]){
            
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Error" message:@"Book is already in downloading" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    _buyButton.userInteractionEnabled = NO;
    //if (_selectedProductId) {
    if([_buyButton.titleLabel.text isEqualToString:@"Read Now"]){
        //Temporarily Added For Direct Downloading
        
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        //[self itemReadyToUse:_selectedProductId ForTransaction:nil];
        
        NSDictionary *dimensions = @{
                                     PARAMETER_USER_ID : ID,
                                     PARAMETER_DEVICE: IOS,
                                     PARAMETER_BOOK_ID : _displayBookID
                                     };
        [delegate trackEvent:[BOOK_DETAIL_BUY_BOOK valueForKey:@"description"] dimensions:dimensions];
        PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
        [userObject setObject:[BOOK_DETAIL_BUY_BOOK valueForKey:@"value"] forKey:@"eventName"];
        [userObject setObject: [BOOK_DETAIL_BUY_BOOK valueForKey:@"description"] forKey:@"eventDescription"];
        [userObject setObject:viewName forKey:@"viewName"];
        [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
        [userObject setObject:delegate.country forKey:@"deviceCountry"];
        [userObject setObject:delegate.language forKey:@"deviceLanguage"];
        [userObject setObject:_displayBookID forKey:@"bookID"];
        if(userEmail){
            [userObject setObject:ID forKey:@"emailID"];
        }
        [userObject setObject:IOS forKey:@"device"];
        [userObject saveInBackground];
        
        AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
        Book *bk=[appDelegate.dataModel getBookOfEJDBId:_selectedProductId];
        NSString *userTransctionId;
        if(appDelegate.subscriptionInfo.subscriptionTransctionId){
            
            userTransctionId = appDelegate.subscriptionInfo.subscriptionTransctionId;
            
        }
        //userTransctionId = @"1000000109171478";
        if (bk) {
            if (_delegate && [_delegate respondsToSelector:@selector(openBook:)]) {
                [self deleteBookIdFromArray:_selectedProductId];
                [_delegate openBook:bk];
            }
            [self closeDetails:nil];
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
    [self dismissViewControllerAnimated:YES completion:^(void) {
        //[_delegate openBookViewWithCategory:[NSDictionary dictionaryWithObject:[NSArray arrayWithObject:[[_categoriesLabel.text componentsSeparatedByString:@", "] firstObject]] forKey:@"categories"]];
    }];
}

- (void) closeDetailBookWithOutAnimation{
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Complete" message:@"Your book is downloaded, go to my stories view" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)bookDownloadAborted{
    
    [self deleteBookIdFromArray:_bookId];
    booksDownloadingCount--;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Aborted" message:@"Book download aborted, please try again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
    [self closeDetails:nil];
}

-(void)dropDownCellSelected:(NSInteger)returnIndex{
	
   [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *dimensions = @{
                                 PARAMETER_USER_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_BOOK_ID : _displayBookID,
                                 PARAMETER_BOOK_LANGUAGE : _dropDownButton.titleLabel.text,
                                 PARAMETER_BOOK_NEW_LANGUAGE_SELECT : [_dropDownArrayData objectAtIndex:returnIndex]
                                 };
    [delegate trackEvent:[BOOK_DETAIL_NEW_LANGUAGE valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[BOOK_DETAIL_NEW_LANGUAGE valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [BOOK_DETAIL_NEW_LANGUAGE valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    [userObject setObject:_displayBookID forKey:@"bookID"];
    [userObject setObject: _dropDownButton.titleLabel.text forKey:@"bookLanguage"];
    [userObject setObject: [_dropDownArrayData objectAtIndex:returnIndex] forKey:@"bookNewLanguageSelect"];
    if(userEmail){
        [userObject setObject:ID forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];
    
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
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *dimensions = @{
                                 PARAMETER_USER_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_BOOK_ID : _displayBookID,
                                 PARAMETER_BOOK_LANGUAGE : _dropDownButton.titleLabel.text
                                 };
    [delegate trackEvent:[BOOK_DETAIL_AVAILABLE_LANGUAGE valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[BOOK_DETAIL_AVAILABLE_LANGUAGE valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [BOOK_DETAIL_AVAILABLE_LANGUAGE valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    [userObject setObject:_displayBookID forKey:@"bookID"];
    [userObject setObject: _dropDownButton.titleLabel.text forKey:@"bookLanguage"];
    if(userEmail){
        [userObject setObject:ID forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];
 
//    if(_dropDownArrayData.count>0){
//        _dropDownButton.userInteractionEnabled = YES;
//     //   [self.dropDownView openAnimation];
//    }
//    else{
//        _dropDownButton.userInteractionEnabled = NO;
//    }
}

- (void)updateBookProgress:(int)progress {
    _bookProgress = progress;
    [_buyButton setHidden:YES];
    
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
    _progressView.current = MAX(1, _bookProgress);
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
