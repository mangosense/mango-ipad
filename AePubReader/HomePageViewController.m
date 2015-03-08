//
//  HomePageViewController.m
//  MangoReader
//
//  Created by Harish on 1/13/15.
//
//

#import "HomePageViewController.h"
#import "AePubReaderAppDelegate.h"
#import "PageNewBookTypeViewController.h"
#import "UserSubscriptionViewController.h"
#import "UserProgressViewController.h"
#import "UserAgeLevelViewController.h"
#import "UserAllBooksViewController.h"
#import "AppInfoViewController.h"
#import "UIImageView+WebCache.h"
#import "HKCircularProgressLayer.h"
#import "HKCircularProgressView.h"

#import "LevelViewController.h"

@interface HomePageViewController ()

@property (nonatomic, assign) int bookProgress;
@property (nonatomic, strong) HKCircularProgressView *progressView;

@end

@implementation HomePageViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentScreen = @"homeScreen";
    _specificLevelBooks = [[NSMutableArray alloc] init];
    
    _storiesCarousel.type = iCarouselTypeRotary;

    UserBookDownloadViewController *bookDownloadClass = [[UserBookDownloadViewController alloc] init];
    _textViewLevel.text = _textLevels;
    //_textViewLevel.text = @"  ";
    bookDownloadClass.delegate = self;
    [bookDownloadClass returnArrayElementa];
    
    CGRect frame;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        frame = CGRectMake(83, 276.0f, 398, 21.0f);
    }
    else{
        frame = CGRectMake(176, 665.0f, 669, 47.0f);
    }
    
    progressView = [[GradientProgressView alloc] initWithFrame:frame];
    [self.view addSubview:progressView];
    [self.view bringSubviewToFront:_settingsProbSupportView];
    [self.view bringSubviewToFront:_settingsProbView];
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    singleTapGestureRecognizer.delegate = self;
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    _textViewLevel.editable = NO;
    _textViewLevel.selectable = NO;
    [_textViewLevel addGestureRecognizer:singleTapGestureRecognizer];
    
    [self setDownloadCounter:0];
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(setDownloadCounter:) userInfo:nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBookProgress:) name:@"HomeBookProgress" object:nil];
    
    _viewDownloadCounter.layer.cornerRadius = 3.0f;
    [_viewDownloadCounter.layer setBorderWidth:0.5f];
    [_viewDownloadCounter.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    // Do any additional setup after loading the view from its nib.
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDate *expireDate = [prefs valueForKey:@"EXPIRETRIALDATE"];
    //if current date is greater than available date
    
    NSDate *today = [NSDate date]; // it will give you current date
    // your date NSDate *newDate = [NSDate dateWithString:@"xxxxxx"];
    
    NSInteger interval = [[[NSCalendar currentCalendar] components: NSDayCalendarUnit
                                                          fromDate: expireDate
                                                            toDate: today
                                                           options: 0] day];
    if(interval<0){
        //date1<date2
        [prefs setBool:YES forKey:@"HASFREETRIALACCESS"];
    }else if (interval>0){
        //date2<date1
        [prefs setBool:NO forKey:@"HASFREETRIALACCESS"];
    }else{
        //date1=date2
    }
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *userAgeObjects = [appDelegate.ejdbController getAllUserAgeValue];
    appDelegate.userInfoAge = [userAgeObjects lastObject];
    //_ageLabel.text = appDelegate.userInfoAge.userAgeValue;
    
    _currentLevel = [prefs valueForKey:@"CURRENTUSERLEVEL"];
    [_currentLevelButton setTitle:_currentLevel forState:UIControlStateNormal];
    NSArray *allLevelValue = [UserBookDownloadViewController returnAllAvailableLevels];
    int indexValue = [allLevelValue indexOfObject:_currentLevel];
    [_nextLevelButton setTitle:[allLevelValue objectAtIndex:indexValue+1] forState:UIControlStateNormal]; //[allLevelValue objectAtIndex:indexValue+1];
    
    for(NSDictionary *element in _allDisplayBooks){
        
        if([[element objectForKey:@"level"] isEqualToString:_currentLevel]){
            [_specificLevelBooks addObject:element];
        }
    }
    [_storiesCarousel reloadData];
    
    
    //first time download remaining free books first time only
    //get all books count in that level if less than 5 then download all else +1 to +5
    int countLevelBooks = [_specificLevelBooks count];
    BOOL firstTimeDownload = [prefs boolForKey:@"FREEFIRSTTIMEDOWNLOAD"];
    if(firstTimeDownload){
        if(countLevelBooks >5){// download from 1 to 5
            countLevelBooks = 5;
        }
        [prefs setBool:FALSE forKey:@"FREEFIRSTTIMEDOWNLOAD"];
        //[[NSUserDefaults standardUserDefaults] synchronize];
        for (int i = 1; i < countLevelBooks; ++i) {
            MangoApiController *apiController = [MangoApiController sharedApiController];
            [apiController downloadBookWithId:[[_specificLevelBooks objectAtIndex:i] valueForKey:@"id"] withDelegate:self ForTransaction:nil];
        }
    }
    
    bool newAppVersion = [self appHasNewVersion];
    if(newAppVersion){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Version is available" message:@"Update your app a new version is available" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if([alertView.title isEqualToString:@"New Version is available"]){
        
        if(buttonIndex == 0){
            
            [self updateAppStoreLink];
        }
    }
}

- (void)updateAppStoreLink{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                @"itms-apps://itunes.apple.com/us/app/endless-stories-level-reading/id962343105?ls=1&mt=8"]];
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}


- (void)simulateProgress :(float) value {
    
    [progressView setProgress:value];
}

- (void) handleTap :(UITapGestureRecognizer *)getureRecog{
    
    CGPoint point = [getureRecog locationInView:_textViewLevel];    
    point.x -= _textViewLevel.textContainerInset.left;
    point.y -= _textViewLevel.textContainerInset.top;
    
    NSUInteger characterIndex = [_textViewLevel.layoutManager characterIndexForPoint:point
                                                      inTextContainer:_textViewLevel.textContainer
                             fractionOfDistanceBetweenInsertionPoints:nil];
    
    NSLog(@"%d--%c", characterIndex, [_textViewLevel.text  characterAtIndex:characterIndex-1]);
    NSString *levelVal =[NSString stringWithFormat:@"%c",[_textViewLevel.text  characterAtIndex:characterIndex]];
    if([levelVal isEqualToString:@" "]){
        levelVal =[NSString stringWithFormat:@"%c",[_textViewLevel.text  characterAtIndex:characterIndex]];
    }
    if([levelVal isEqualToString:@""]){
        levelVal = @"A";
    }
//      identify level index value and then load that index
//    for(int i = 0; i < _allDisplayBooks.count; ++i){
//            
//        if([[[_allDisplayBooks objectAtIndex:i] valueForKey:@"level"] isEqualToString:levelVal]){
//                
//            _storiesCarousel.currentItemIndex = i-1;
//        }
//    }
    
    for(NSDictionary *element in _allDisplayBooks){
        
        if([[element objectForKey:@"level"] isEqualToString:levelVal]){
            [_specificLevelBooks addObject:element];
        }
    }
    [_storiesCarousel reloadData];
}

- (IBAction)getJsonIntoArray:(NSArray *) bookArray{
    
    _allDisplayBooks = [[NSMutableArray alloc] initWithArray:bookArray];
    [_storiesCarousel reloadData];
    
}


- (void) viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //BOOL value = [prefs boolForKey: @"SHOWAGEDETAILVIEW"];
    
    NSString *currentLevel = [prefs valueForKey:@"CURRENTUSERLEVEL"];
    
//    if(value){
//        
//        [self.navigationController popViewControllerAnimated:NO];
//    }
//    [prefs setBool:NO forKey:@"SHOWAGEDETAILVIEW"];
    
    if(![_currentLevel isEqualToString:currentLevel]){
        _specificLevelBooks = nil;
        _specificLevelBooks = [[NSMutableArray alloc] init];
        [_currentLevelButton setTitle:currentLevel forState:UIControlStateNormal];
        NSArray *allLevelValue = [UserBookDownloadViewController returnAllAvailableLevels];
        int indexValue = (int)[allLevelValue indexOfObject:currentLevel];
        [_nextLevelButton setTitle:[allLevelValue objectAtIndex:indexValue+1] forState:UIControlStateNormal];
        
        for(NSDictionary *element in _allDisplayBooks){
            
            if([[element objectForKey:@"level"] isEqualToString:currentLevel]){
                [_specificLevelBooks addObject:element];
            }
        }
        [_storiesCarousel reloadData];
    }
    
    else if(isNextTapped){
        isNextTapped = FALSE;
        _specificLevelBooks = nil;
        _specificLevelBooks = [[NSMutableArray alloc] init];
        [_currentLevelButton setTitle:_currentLevel forState:UIControlStateNormal];
        NSArray *allLevelValue = [UserBookDownloadViewController returnAllAvailableLevels];
        int indexValue = (int)[allLevelValue indexOfObject:_currentLevel];
        [_nextLevelButton setTitle:[allLevelValue objectAtIndex:indexValue+1] forState:UIControlStateNormal];
        
        for(NSDictionary *element in _allDisplayBooks){
            
            if([[element objectForKey:@"level"] isEqualToString:_currentLevel]){
                [_specificLevelBooks addObject:element];
            }
        }
        [_storiesCarousel reloadData];
    }
    
    NSString *soundFilePath = [NSString stringWithFormat:@"%@/bgPlayHomePage.mp3",
                               [[NSBundle mainBundle] resourcePath]];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL
                                                     error:nil];
    _player.numberOfLoops = -1; //Infinite
    
    [_player play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:YES];
/*    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    positionIndex = [[prefs valueForKey:@"USERBOOKINDEX"] integerValue];
    _storiesCarousel.currentItemIndex = positionIndex;*/
    [super viewDidAppear:animated];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *currentLevel = _currentLevelButton.titleLabel.text;    
    
    int validUserSubscription = [prefs boolForKey:@"USERSUBSCRIBED"];
    int hasfreeTrial= [prefs boolForKey:@"HASFREETRIALACCESS"];
    
    NSArray *result =[appDelegate.dataModel getAllUserReadBooks:currentLevel];
    
    // Starts the moving gradient effect
    float val1 = result.count;
    float val2 = _specificLevelBooks.count;
    float val = val1/val2;
    // Continuously updates the progress value using random values
    
    if((val == 1.0) && (validUserSubscription || hasfreeTrial)){
        
        _specificLevelBooks = nil;
        _specificLevelBooks = [[NSMutableArray alloc] init];
        [prefs setObject:_nextLevelButton.titleLabel.text forKey:@"CURRENTUSERLEVEL"];
        NSString *currentLevel = _nextLevelButton.titleLabel.text;
        
        [_currentLevelButton setTitle:currentLevel forState:UIControlStateNormal];
        NSArray *allLevelValue = [UserBookDownloadViewController returnAllAvailableLevels];
        int indexValue = (int)[allLevelValue indexOfObject:currentLevel];
        [_nextLevelButton setTitle:[allLevelValue objectAtIndex:indexValue+1] forState:UIControlStateNormal];
        
        for(NSDictionary *element in _allDisplayBooks){
            
            if([[element objectForKey:@"level"] isEqualToString:currentLevel]){
                [_specificLevelBooks addObject:element];
            }
        }
        [_storiesCarousel reloadData];
    }
    else{
        [self simulateProgress:val];
    }
    
    NSDictionary *dimensions = @{
                                 
                                 PARAMETER_ACTION : @"homeScreen",
                                 PARAMETER_CURRENT_PAGE : currentScreen,
                                 PARAMETER_EVENT_DESCRIPTION : @"Home Screen open",
                                 };
    [appDelegate trackEventAnalytic:@"homeScreen" dimensions:dimensions];
    [appDelegate eventAnalyticsDataBrowser:dimensions];
    [appDelegate trackMixpanelEvents:dimensions eventName:@"homeScreen"];
}

-(void) viewDidDisappear:(BOOL)animated{
    
    _player = nil;
}

- (BOOL) checkIfBookAvailable :(NSString *) bookId{
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    Book *bk=[appDelegate.dataModel getBookOfEJDBId:bookId];
    
    if(bk){
        return TRUE;
    }
    else{
        return FALSE;
    }
}

- (BOOL) checkIfBookAcessible :(int) value{
    
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    positionIndex = [[prefs valueForKey:@"USERBOOKINDEX"] integerValue];
    
    if(isNextTapped || value > 4){
        
        return FALSE;
    }
    else{
        
        return TRUE;
    }
}



- (IBAction)readyBookToOpen:(NSString *)bookId withTag:(int) value{
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    Book *bk=[appDelegate.dataModel getBookOfEJDBId:selectedBookId];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    int validUserSubscription = [prefs boolForKey:@"USERSUBSCRIBED"];
    int hasfreeTrial= [prefs boolForKey:@"HASFREETRIALACCESS"];
    
    if(validUserSubscription || hasfreeTrial){
        //check for valid user
        
        if(!bk.localPathFile){//check if book is not available
            
            if(![self connected])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please internet connection appears offline, please try later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            
            //check if book is already downloading
            
            if([self checkIfBookIdIsAvailable:selectedBookId]){
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Error" message:@"Book is already in downloading" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
        
            if(booksDownloadingCount >= 3){
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Error" message:@"You can download only 3 books at a time" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            else{
                booksDownloadingCount ++;
                MangoApiController *apiController = [MangoApiController sharedApiController];
                [apiController downloadBookWithId:bookId withDelegate:self ForTransaction:nil];
                [self addBookIdIntoArray:bookId];
            }
        }
        else{//check if book available
            
            [self openBook:bk];
        }
    }
    else{
        
        if(value){
            
            if(!bk.localPathFile){
                
                //check if book is downloading
                if([self checkIfBookIdIsAvailable:selectedBookId]){
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Error" message:@"Book is already in downloading" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                    return;
                }
                else{
                    //if by mistake book isn't availabe to download, then start download
                    MangoApiController *apiController = [MangoApiController sharedApiController];
                    [apiController downloadBookWithId:bookId withDelegate:self ForTransaction:nil];
                    [self addBookIdIntoArray:bookId];
                }
            }
            else{
               //book is available then open
                [self openBook:bk];
            }
            
        }
        else{
            _settingsProbSupportView.hidden = NO;
            _settingsProbView.hidden= NO;
            isInfo1Settings2Click = 1;
        }
    }
}


- (void) getBookProgress:(NSNotification *)notif
{
    NSDictionary *userInfo = notif.userInfo;
    
    newIDValue = [userInfo valueForKey:@"bookIdVal"];
    int newProgress = [[userInfo valueForKey:@"progressVal"] intValue];
    if([_frontBookId isEqualToString:newIDValue]){
        _bookProgress = newProgress;
        //if bookid matches with current center carousl item
        [self updateBookProgress:newProgress];
    }
    else{
        //if book id not matches then remove the progress bar view from screen
        //[self performSelectorOnMainThread:@selector(hideHudOnButton) withObject:nil waitUntilDone:YES];
    }
}


- (void)bookDownloaded:(NSString *)bookId {
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    booksDownloadingCount--;
    [self deleteBookIdFromArray:bookId];
}

- (void)bookDownloadAborted:(NSString *)bookId{
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    booksDownloadingCount--;
    [self deleteBookIdFromArray:bookId];
}

- (void)updateBookProgress:(int)progress {
    /*if(progress <0){
        progress = 0;
    }*/
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    //[_buyButton setHidden:YES];
    if([_frontBookId isEqualToString: newIDValue]){
        
        if (progress < 100) {
            _displayView.hidden = NO;
            [self performSelectorOnMainThread:@selector(showHudOnButton) withObject:nil waitUntilDone:YES];
        
                } else {
            _displayView.hidden = YES;
            [self performSelectorOnMainThread:@selector(hideHudOnButton) withObject:nil waitUntilDone:YES];
        }
    }
}

- (void)showHudOnButton {
    if (!_progressView) {
        _progressView = [[HKCircularProgressView alloc] initWithFrame:CGRectMake(_displayView.frame.size.width/2 - 50, _displayView.frame.size.height/2 - 50, 100, 100)];
        _progressView.max = 100.0f;
        _progressView.step = 0.0f;
        _progressView.fillRadius = 1;
        _progressView.trackTintColor = COLOR_LIGHT_GREY;
        [_progressView setAlpha:0.6f];
        [_displayView addSubview:_progressView];
        
    }
    NSString *progressVal = [NSString stringWithFormat:@"%d%%",(int)_progressView.current];
   // _progressLabel.text = progressVal;
    _progressView.current = MAX(1, _bookProgress);
    if((int)_progressView.current > 99){
   //     _progressLabel.hidden = YES;
    }
    // NSLog(@"Display progress %f %@",_progressView.current, _bookId);
}

- (void)hideHudOnButton {
    [_progressView removeFromSuperview];
    _progressView = nil;
}



- (void)openBook:(Book *)bk {
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *identity=[NSString stringWithFormat:@"%@", bk.id];
    [appDelegate.dataModel displayAllData];
    
    PageNewBookTypeViewController *controller;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        controller=[[PageNewBookTypeViewController alloc]initWithNibName:@"PageNewBookTypeViewController_iPhone" bundle:nil WithOption:nil BookId:selectedBookId];
        
    }
    else{
        controller=[[PageNewBookTypeViewController alloc]initWithNibName:@"PageNewBookTypeViewController" bundle:nil WithOption:nil BookId:selectedBookId];
    }
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - iCarousel Delegates

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {

    return _specificLevelBooks.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int validUserSubscription = [prefs boolForKey:@"USERSUBSCRIBED"];
    int hasfreeTrial= [prefs boolForKey:@"HASFREETRIALACCESS"];
    
    iCarouselImageView *storyImageView = (iCarouselImageView *)[view viewWithTag:iCarousel_VIEW_TAG];
    
    NSDictionary *bookInfo = [_specificLevelBooks objectAtIndex:index];
    
    NSString *image = [NSString stringWithFormat:@"https://mangoassets.s3.amazonaws.com/uploads/stories/%@/%@",[bookInfo valueForKey:@"id"],[bookInfo valueForKey:@"images"]];
    
    NSString *ImageURL = [image stringByReplacingOccurrencesOfString:@"thumb" withString:@"cover"];
    
    BOOL isAvailable = [self checkIfBookAcessible:index];
    
    [storyImageView setContentMode:UIViewContentModeScaleAspectFill];
    [storyImageView setClipsToBounds:YES];
    UIImageView *lockImg;
        
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            storyImageView = [[iCarouselImageView alloc] initWithFrame:CGRectMake(0, 0, 143, 124)];
    }
    else{
            storyImageView = [[iCarouselImageView alloc] initWithFrame:CGRectMake(0, 0, 310, 260)];
    }
        
    storyImageView.delegate = self;
    [storyImageView setImageWithURL:[NSURL URLWithString:ImageURL]
                       placeholderImage:[UIImage imageNamed:@"newPage.png"]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                              }];
        
    NSLog(@"is avil %d", isAvailable);
    if(!isAvailable){
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            lockImg =[[UIImageView alloc] initWithFrame:CGRectMake(10,95,22,22)];
        }
        else{
            lockImg =[[UIImageView alloc] initWithFrame:CGRectMake(40,180,40,40)];
        }
        if(validUserSubscription || hasfreeTrial){
            lockImg.image= nil;
        }
        else if(isNextTapped || (index > 4)){
            lockImg.image= [UIImage imageNamed:@"loginLock.png"];
        }

        storyImageView.tag = 0;
    }
    else{
        storyImageView.tag = 1;
        lockImg.image = nil;
    }
    
    [storyImageView addSubview:lockImg];
    
    return storyImageView;

}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:[NSString stringWithFormat:@"%d",index] forKey:@"BOOKINDEX"];
    selectedBookId = [[_specificLevelBooks objectAtIndex:index] valueForKey:@"id"];
    
    //check current index lie in i+5 value else send tag value to one
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDictionary *dimensions = @{
                                 PARAMETER_ACTION : @"selectBook",
                                 PARAMETER_CURRENT_PAGE : currentScreen,
                                 PARAMETER_BOOK_ID : selectedBookId,
                                 PARAMETER_EVENT_DESCRIPTION : @"select book",
                                 };
    [appDelegate trackEventAnalytic:@"selectBook" dimensions:dimensions];
    [appDelegate eventAnalyticsDataBrowser:dimensions];
    [appDelegate trackMixpanelEvents:dimensions eventName:@"selectBook"];
    
    int accessValue = [self checkIfBookAcessible:index];
//    if(isNextTapped || index > 4){
//        
//        _settingsProbSupportView.hidden = NO;
//        _settingsProbView.hidden= NO;
//        isInfo1Settings2Click = 1;
//    }
//    else{
        [self readyBookToOpen:selectedBookId withTag:accessValue];
//    }
}


- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel{
    
   [self performSelectorOnMainThread:@selector(hideHudOnButton) withObject:nil waitUntilDone:YES];
    _frontBookId = [[_specificLevelBooks objectAtIndex:self.storiesCarousel.currentItemIndex] valueForKey:@"id"];
   /* NSLog(@"heyyyy current element level is %@",[[_allDisplayBooks objectAtIndex:self.storiesCarousel.currentItemIndex] valueForKey:@"level"]);
    NSString *levelValue = [[_allDisplayBooks objectAtIndex:(self.storiesCarousel.currentItemIndex)] valueForKey:@"level"];
    _specificLevelBooks = [[NSMutableArray alloc] init];
    // Get all books of that level
    for(NSDictionary *element in _allDisplayBooks){
        
        if([[element objectForKey:@"level"] isEqualToString:levelValue]){
            [_specificLevelBooks addObject:element];
        }
    }
    
    //NSString *levelString = _levelsLabel.text;
    _frontBookId = [[_allDisplayBooks objectAtIndex:self.storiesCarousel.currentItemIndex] valueForKey:@"id"];
    //NSLog(@"Book id %@ - %@", [[_allDisplayBooks objectAtIndex:self.storiesCarousel.currentItemIndex] valueForKey:@"id"], [[_allDisplayBooks objectAtIndex:self.storiesCarousel.currentItemIndex] valueForKey:@"title"]);
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment                = NSTextAlignmentCenter;
    
    NSMutableAttributedString *levelString = [[NSMutableAttributedString alloc] initWithString:_textViewLevel.text attributes:@{NSParagraphStyleAttributeName:paragraphStyle}];
    UIFont *textFont = _textViewLevel.font;
    textFont = [UIFont fontWithName:@"Chalkboard SE" size:33];
    
    [levelString addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, [levelString length])];
    
    NSRange levelRangeValue = [_textViewLevel.text rangeOfString:levelValue];
    [levelString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:levelRangeValue];
    [levelString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Chalkboard SE" size:33] range:levelRangeValue];
    
    [_textViewLevel setAttributedText:levelString];*/
}

- (void)iCarouselSaveImage:(UIImage *)image ForUrl:(NSString *)imageUrl {
    if (!image){return;}
    //[_localImagesDictionary setObject:image forKey:imageUrl];
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
                return value *1.1f;
            }
            else{
                return value * 1.0f;
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

- (IBAction) selectNextLevel:(id)sender{
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIButton *btn = (UIButton *)sender;
    if([sender tag] == 2){
        isNextTapped = TRUE;
        //hide progressview from there
        [self hideHudOnButton];
        
        NSDictionary *dimensions = @{
                                     PARAMETER_ACTION : @"clickNextLevel",
                                     PARAMETER_CURRENT_PAGE : currentScreen,
                                     PARAMETER_LEVEL_VALUE :btn.titleLabel.text,
                                     PARAMETER_EVENT_DESCRIPTION : @"select next level books",
                                     };
        [appDelegate trackEventAnalytic:@"clickNextLevel" dimensions:dimensions];
        [appDelegate eventAnalyticsDataBrowser:dimensions];
        [appDelegate trackMixpanelEvents:dimensions eventName:@"clickNextLevel"];
    }
    else{
        isNextTapped = FALSE;
        
        NSDictionary *dimensions = @{
                                     PARAMETER_ACTION : @"clickCurrentLevel",
                                     PARAMETER_CURRENT_PAGE : currentScreen,
                                     PARAMETER_LEVEL_VALUE : btn.titleLabel.text,
                                     PARAMETER_EVENT_DESCRIPTION : @"select current level books",
                                     };
        [appDelegate trackEventAnalytic:@"clickCurrentLevel" dimensions:dimensions];
        [appDelegate eventAnalyticsDataBrowser:dimensions];
        [appDelegate trackMixpanelEvents:dimensions eventName:@"clickCurrentLevel"];
    }
    
    _specificLevelBooks = nil;
    _specificLevelBooks = [[NSMutableArray alloc] init];
    NSString *levelValue = btn.titleLabel.text;
    for(NSDictionary *element in _allDisplayBooks){
        
        if([[element objectForKey:@"level"] isEqualToString:levelValue]){
            [_specificLevelBooks addObject:element];
        }
    }
    [_storiesCarousel reloadData];
}


- (IBAction) displayUserSettings:(id)sender{
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *dimensions = @{
                                 PARAMETER_ACTION : @"selectSettings",
                                 PARAMETER_CURRENT_PAGE : currentScreen,
                                 PARAMETER_EVENT_DESCRIPTION : @"selectSettings",
                                 };
    [appDelegate trackEventAnalytic:@"selectSettings" dimensions:dimensions];
    [appDelegate eventAnalyticsDataBrowser:dimensions];
    [appDelegate trackMixpanelEvents:dimensions eventName:@"selectSettings"];
    
    _ageLabelValue.text = @"";
    _settingsProbSupportView.hidden = NO;
    _settingsProbView.hidden = NO;
    isInfo1Settings2Click = (int)[sender tag];
    //[self displaySettingsView];
}

- (IBAction)displyParentalControlOrNot:(id)sender{
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];

    NSDictionary *dimensions = @{
                                 PARAMETER_ACTION : @"parentalControl",
                                 PARAMETER_CURRENT_PAGE : currentScreen,
                                 PARAMETER_KID_AGE : _ageLabelValue.text,
                                 PARAMETER_EVENT_DESCRIPTION : @"parental Control Appear",
                                 };
    [appDelegate trackEventAnalytic:@"parentalControl" dimensions:dimensions];
    [appDelegate eventAnalyticsDataBrowser:dimensions];
    [appDelegate trackMixpanelEvents:dimensions eventName:@"parentalControl"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *yearString = [formatter stringFromDate:[NSDate date]];
    int parentalControlAge = (int)([yearString integerValue] - [_ageLabelValue.text integerValue]);
    if((parentalControlAge >= 13) && (parentalControlAge <=100)){
        
        _settingsProbSupportView.hidden = YES;
        _settingsProbView.hidden= YES;
        
        if(isInfo1Settings2Click == 2){
            [self appInfo];
        }
        else{
            [self displaySettingsView];
        }
    }
    else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Please enter correct birth year!!" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alert show];
        [self performSelector:@selector(dismiss:) withObject:alert afterDelay:2.0];
    }
}

-(void)dismiss:(UIAlertView*)alert
{
    _ageLabelValue.text = @"";
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

- (IBAction) dismissParentalControl:(id)sender{
    _settingsProbView.hidden = YES;
    _settingsProbSupportView.hidden =  YES;
}

- (void)displaySettingsView {
    int settingSol =1;
    if(settingSol){
    
        settingSol = NO;
        UITabBarController *tabBarController = [[UITabBarController alloc] init];
        tabBarController.delegate = self;
        
        UserAllBooksViewController *viewCtr3;
        UserAgeLevelViewController *viewCtr0;
        UserSubscriptionViewController *viewCtr1;
        UserProgressViewController *viewCtr2;
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            
            viewCtr0 = [[UserAgeLevelViewController alloc] initWithNibName:@"UserAgeLevelViewController_iPhone" bundle:nil];
            
            viewCtr1 = [[UserSubscriptionViewController alloc] initWithNibName:@"UserSubscriptionViewController_iPhone" bundle:nil];
            
            //viewCtr2 = [[UserProgressViewController alloc] initWithNibName:@"UserProgressViewController_iPhone" bundle:nil];
            
            viewCtr3 = [[UserAllBooksViewController alloc] initWithNibName:@"UserAllBooksViewController_iPhone" bundle:nil];
        }
        
        else{
            
            viewCtr0 = [[UserAgeLevelViewController alloc] initWithNibName:@"UserAgeLevelViewController" bundle:nil];
            
            viewCtr1 = [[UserSubscriptionViewController alloc] initWithNibName:@"UserSubscriptionViewController" bundle:nil];
            
            //viewCtr2 = [[UserProgressViewController alloc] initWithNibName:@"UserProgressViewController" bundle:nil];
            
            viewCtr3 = [[UserAllBooksViewController alloc] initWithNibName:@"UserAllBooksViewController" bundle:nil];
        }
        
        viewCtr0.tabBarItem.image = [UIImage imageNamed:@"analytics.png"];
        
        viewCtr1.tabBarItem.image = [UIImage imageNamed:@"profile.png"];
        
        //viewCtr2.tabBarItem.image = [UIImage imageNamed:@"analytics.png"];
        
        viewCtr3.tabBarItem.image = [UIImage imageNamed:@"ParentIcon.png"];
        
        viewCtr0.navigationController.navigationBarHidden = YES;
        
        viewCtr1.navigationController.navigationBarHidden=YES;
        
        viewCtr2.navigationController.navigationBarHidden=YES;
        
        viewCtr3.navigationController.navigationBarHidden=YES;
        
        tabBarController.viewControllers= [NSArray arrayWithObjects: viewCtr1, viewCtr3, viewCtr0,  nil];
        tabBarController.tabBar.barTintColor = [UIColor brownColor];
        
        [self.navigationController pushViewController:tabBarController animated:YES];
    }
}


- (IBAction) presentAppInfoPage:(id)sender{
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *dimensions = @{
                                 PARAMETER_ACTION : @"selectInfo",
                                 PARAMETER_CURRENT_PAGE : currentScreen,
                                 PARAMETER_EVENT_DESCRIPTION : @"click info icon",
                                 };
    [appDelegate trackEventAnalytic:@"selectInfo" dimensions:dimensions];
    [appDelegate eventAnalyticsDataBrowser:dimensions];
    [appDelegate trackMixpanelEvents:dimensions eventName:@"selectInfo"];
    
    _settingsProbSupportView.hidden = NO;
    _settingsProbView.hidden = NO;
    _ageLabelValue.text = @"";
    isInfo1Settings2Click = (int)[sender tag];
}

- (void) appInfo{
    
    AppInfoViewController *displayAppInfo;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        
        displayAppInfo = [[AppInfoViewController alloc] initWithNibName:@"AppInfoViewController_iPhone" bundle:nil];
        
    }
    else{
        displayAppInfo = [[AppInfoViewController alloc] initWithNibName:@"AppInfoViewController" bundle:nil];
    }
    [self presentViewController:displayAppInfo animated:YES completion:nil];
}


- (void) DismissOtherViewAndLoadAgepage{
    
    [self.navigationController popViewControllerAnimated:NO];
}

-(void) setDownloadCounter:(NSTimer *)timer
{
    int noOfBooks = booksDownloadingCount;
    // NSLog(@"Calling... %d", noOfBooks);
    if(noOfBooks <= 0){
        _viewDownloadCounter.hidden = YES;
    }
    else{
        _viewDownloadCounter.hidden = NO;
    }
    if(noOfBooks > 1){
        _labelDownloadingCount.text = [NSString stringWithFormat:@"%d  books downloading", noOfBooks];
    }
    else{
        _labelDownloadingCount.text = [NSString stringWithFormat:@"%d  book downloading", noOfBooks];
    }
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


- (IBAction) addAgeValue:(id)sender{
    
    if([sender isKindOfClass:[UIButton class]]){
        
        NSString *ageVal = [NSString stringWithFormat:@"%d",(int)[sender tag]];
        _ageLabelValue.text = [_ageLabelValue.text stringByAppendingString:ageVal];
    }
}

- (IBAction) backSpaceAgeField:(id)sender{
    
    self.ageLabelValue.text = @"";
}


//get latest version of app available of app on app store
- (BOOL)appHasNewVersion
{
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleIdentifier = [bundleInfo valueForKey:@"CFBundleIdentifier"];
    
    NSURL *lookupURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@", bundleIdentifier]];
    NSData *lookupResults = [NSData dataWithContentsOfURL:lookupURL];
    if(!lookupResults){
        return NO;
    }
    NSDictionary *jsonResults = [NSJSONSerialization JSONObjectWithData:lookupResults options:0 error:nil];
    
    NSUInteger resultCount = [[jsonResults objectForKey:@"resultCount"] integerValue];
    if (resultCount){
        NSDictionary *appDetails = [[jsonResults objectForKey:@"results"] firstObject];
        NSString *latestVersion = [appDetails objectForKey:@"version"];
        NSString *currentVersion = [bundleInfo objectForKey:@"CFBundleShortVersionString"];
        if (![latestVersion isEqualToString:currentVersion]) return YES;
    }
    return NO;
}


@end
