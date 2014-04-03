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

@interface BookDetailsViewController ()

@property (nonatomic, assign) int bookProgress;
@property (nonatomic, strong) HKCircularProgressView *progressView;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, strong) NSString *bookId;

@end

@implementation BookDetailsViewController

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

- (void)setIdOfDisplayBook:(NSString *)book_Id {
    
    _displayBookID = book_Id;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    // take current payment queue
    SKPaymentQueue* currentQueue = [SKPaymentQueue defaultQueue];
    // finish ALL transactions in queue
    [currentQueue.transactions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [currentQueue finishTransaction:(SKPaymentTransaction *)obj];
    }];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[CargoBay sharedManager]];
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
    
    NSDictionary *dimensions = @{
                                 PARAMETER_USER_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_BOOK_ID : _displayBookID,
                                 PARAMETER_BOOK_LANGUAGE : _dropDownButton.titleLabel.text
                                 };
    [PFAnalytics trackEvent:BOOK_DETAIL_AVAILABLE_LANGUAGE dimensions:dimensions];
    
    NSLog(@"Data array %d", dataArray.count);
    if(![dataArray count]){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        return;
    }
    
    if([type isEqualToString:@"livestories/available_languages"]){
        NSMutableArray *tempDataArray = [[NSMutableArray alloc]init];
        _dropDownArrayData = [[NSMutableArray alloc] init];
        _dropDownIdArrayData = [[NSMutableArray alloc] init];
        tempDataArray = [NSMutableArray arrayWithArray:dataArray];
        for(int i=0; i< [tempDataArray count]; ++i){
            
            [_dropDownArrayData addObject:[tempDataArray[i] objectForKey:@"language"]];
            NSLog(@"Print %@", [tempDataArray[i] objectForKey:@"language"]);
            [_dropDownIdArrayData addObject:[tempDataArray[i] objectForKey:@"live_story_id"]];
        }
        
        _dropDownView = [[DropDownView alloc] initWithArrayData:_dropDownArrayData cellHeight:33 heightTableView:(33+33*_dropDownIdArrayData.count) paddingTop:-65 paddingLeft:0  paddingRight:0 refView:_dropDownButton animation:BOTH openAnimationDuration:0.1 closeAnimationDuration:0.5];
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
            [_buyButton setImage:[UIImage imageNamed:@"Read-now.png"] forState:UIControlStateNormal];
        }
        else{
            _priceLabel.text = [NSString stringWithFormat:@"$ %.2f", [[bookDict objectForKey:@"price"] floatValue]];
            [_buyButton setImage:[UIImage imageNamed:@"buynow.png"] forState:UIControlStateNormal];
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
    if (_selectedProductId) {
        //Temporarily Added For Direct Downloading

        //[self itemReadyToUse:_selectedProductId ForTransaction:nil];
        
        NSDictionary *dimensions = @{
                                     PARAMETER_USER_ID : ID,
                                     PARAMETER_DEVICE: IOS,
                                     PARAMETER_BOOK_ID : _displayBookID
                                     };
        [PFAnalytics trackEvent:BOOK_DETAIL_BUY_BOOK dimensions:dimensions];

        AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
        Book *bk=[appDelegate.dataModel getBookOfEJDBId:_selectedProductId];
        
        if (bk) {
            if (_delegate && [_delegate respondsToSelector:@selector(openBook:)]) {
                [_delegate openBook:bk];
            }
            [self closeDetails:nil];
        } else {
            [[PurchaseManager sharedManager] itemProceedToPurchase:_selectedProductId storeIdentifier:_selectedProductId withDelegate:self];
        }
    }
    else {
        NSLog(@"Product dose not have relative Id");
    }
}

- (IBAction)closeDetails:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void) {
        //[_delegate openBookViewWithCategory:[NSDictionary dictionaryWithObject:[NSArray arrayWithObject:[[_categoriesLabel.text componentsSeparatedByString:@", "] firstObject]] forKey:@"categories"]];
    }];
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
}

-(void)dropDownCellSelected:(NSInteger)returnIndex{
	
   [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
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
    [self availLanguagedata];
 
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

@end
