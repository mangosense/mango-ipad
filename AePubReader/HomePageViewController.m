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
//store link
#import "MangoStoreViewController.h"

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
    _storiesCarousel.type = iCarouselTypeRotary;
    UserBookDownloadViewController *bookDownloadClass = [[UserBookDownloadViewController alloc] init];
    _textViewLevel.text = _textLevels;
    bookDownloadClass.delegate = self;
    [bookDownloadClass returnArrayElementa];
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    singleTapGestureRecognizer.delegate = self;
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    _textViewLevel.editable = NO;
    _textViewLevel.selectable = NO;
    //displayTextFiel.addGestureRecognizer(singleTapGestureRecognizer)
    [_textViewLevel addGestureRecognizer:singleTapGestureRecognizer];
    
    [self setDownloadCounter:0];
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(setDownloadCounter:) userInfo:nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DismissOtherViewAndLoadAgepage) name:@"EditAgeValue" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBookProgress:) name:@"HomeBookProgress" object:nil];
    
    _viewDownloadCounter.layer.cornerRadius = 3.0f;
    [_viewDownloadCounter.layer setBorderWidth:0.5f];
    [_viewDownloadCounter.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    // Do any additional setup after loading the view from its nib.
}

- (void) handleTap :(UITapGestureRecognizer *)getureRecog{
    
    CGPoint point = [getureRecog locationInView:_textViewLevel];    
    point.x -= _textViewLevel.textContainerInset.left;
    point.y -= _textViewLevel.textContainerInset.top;
    
    NSUInteger characterIndex = [_textViewLevel.layoutManager characterIndexForPoint:point
                                                      inTextContainer:_textViewLevel.textContainer
                             fractionOfDistanceBetweenInsertionPoints:nil];
    
    NSLog(@"%d--%c", characterIndex, [_textViewLevel.text  characterAtIndex:characterIndex-1]);
    NSString *levelVal =[NSString stringWithFormat:@"%c",[_textViewLevel.text  characterAtIndex:characterIndex-1]];
    if([levelVal isEqualToString:@" "]){
        levelVal =[NSString stringWithFormat:@"%c",[_textViewLevel.text  characterAtIndex:characterIndex]];
    }
    if([levelVal isEqualToString:@""]){
        levelVal = @"A";
    }
    //identify level index value and then load that index
    for(int i = 0; i < _allDisplayBooks.count; ++i){
            
        if([[[_allDisplayBooks objectAtIndex:i] valueForKey:@"level"] isEqualToString:levelVal]){
                
            _storiesCarousel.currentItemIndex = i-1;
        }
    }
    
}

- (IBAction)getJsonIntoArray:(NSArray *) bookArray{
    
    _allDisplayBooks = [[NSMutableArray alloc] initWithArray:bookArray];
    [_storiesCarousel reloadData];
    
}


- (void) viewWillAppear:(BOOL)animated{
    
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
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    positionIndex = [[prefs valueForKey:@"USERBOOKINDEX"] integerValue];
    _storiesCarousel.currentItemIndex = positionIndex;
}

-(void) viewDidDisappear:(BOOL)animated{
    
    _player = nil;
}

- (BOOL) checkIfBookAvailable :(NSString *) bookId{
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    Book *bk=[appDelegate.dataModel getBookOfEJDBId:bookId];
    
    //int isDownloaded = [bk.downloaded integerValue];
    
    if(bk){
        return TRUE;
    }
    else{
        return FALSE;
    }
}

- (BOOL) checkIfBookAcessible :(int) value{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    positionIndex = [[prefs valueForKey:@"USERBOOKINDEX"] integerValue];
    
    if((value >= positionIndex) && (value < (positionIndex+5))){
        
        return TRUE;
    }
    else{
        
        return FALSE;
    }
}



- (IBAction)readyBookToOpen:(NSString *)bookId withTag:(int) value{
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    Book *bk=[appDelegate.dataModel getBookOfEJDBId:selectedBookId];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    //int isDownloaded = [bk.downloaded integerValue];
    
//    if(bk.localPathFile){
//        [self openBook:bk];
//    }
//    else{
        //either start downloading for subscribed user or display settings view
    int validUserSubscription = [[prefs valueForKey:@"USERSUBSCRIBED"] integerValue];
        
    if(validUserSubscription){
        //check for valid user
        
        if(!bk.localPathFile){//check if book is not available
            
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
        }
    }
    
}


- (void) getBookProgress:(NSNotification *)notif
{
    NSDictionary *userInfo = notif.userInfo;
    
    newIDValue = [userInfo valueForKey:@"bookIdVal"];
    int newProgress = [[userInfo valueForKey:@"progressVal"] integerValue];
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
        
        //_bookProgress = progress;
        
        if (progress < 100) {
        
            [self performSelectorOnMainThread:@selector(showHudOnButton) withObject:nil waitUntilDone:YES];
        
        //[_closeButton setEnabled:NO];
        } else {
            [self performSelectorOnMainThread:@selector(hideHudOnButton) withObject:nil waitUntilDone:YES];
        //[_closeButton setEnabled:YES];
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

    return _allDisplayBooks.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    iCarouselImageView *storyImageView = (iCarouselImageView *)[view viewWithTag:iCarousel_VIEW_TAG];
    
    NSDictionary *bookInfo = [_allDisplayBooks objectAtIndex:index];
    
    NSString *image = [NSString stringWithFormat:@"https://mangoassets.s3.amazonaws.com/uploads/stories/%@/%@",[bookInfo valueForKey:@"id"],[bookInfo valueForKey:@"images"]];
    
    NSString *ImageURL = [image stringByReplacingOccurrencesOfString:@"thumb" withString:@"cover"];
    
    BOOL isAvailable = [self checkIfBookAcessible:index];
    
    [storyImageView setContentMode:UIViewContentModeScaleAspectFill];
    [storyImageView setClipsToBounds:YES];
    UIImageView *lockImg;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            storyImageView = [[iCarouselImageView alloc] initWithFrame:CGRectMake(0, 0, 173, 134)];
        }
        else{
            storyImageView = [[iCarouselImageView alloc] initWithFrame:CGRectMake(0, 0, 302, 246)];
        }
        
        storyImageView.delegate = self;
        [storyImageView setImageWithURL:[NSURL URLWithString:ImageURL]
                       placeholderImage:[UIImage imageNamed:@"page.png"]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                              }];
        
        NSLog(@"is avil %d", isAvailable);
        if(!isAvailable){
            lockImg =[[UIImageView alloc] initWithFrame:CGRectMake(40,180,40,40)];
            lockImg.image= [UIImage imageNamed:@"loginLock.png"];
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
    selectedBookId = [[_allDisplayBooks objectAtIndex:index] valueForKey:@"id"];
    
//    if([self checkIfBookIdIsAvailable:selectedBookId]){
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Error" message:@"Book is already in downloading" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [alert show];
//        return;
//    }
//    else{
        
        [self readyBookToOpen:selectedBookId withTag:carousel.currentItemView.tag];
//    }
    
}


- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel{
    
   [self performSelectorOnMainThread:@selector(hideHudOnButton) withObject:nil waitUntilDone:YES];
    
        NSLog(@"heyyyy current element level is %@",[[_allDisplayBooks objectAtIndex:self.storiesCarousel.currentItemIndex] valueForKey:@"level"]);
    NSString *levelValue = [[_allDisplayBooks objectAtIndex:(self.storiesCarousel.currentItemIndex)] valueForKey:@"level"];
    //NSString *levelString = _levelsLabel.text;
    _frontBookId = [[_allDisplayBooks objectAtIndex:self.storiesCarousel.currentItemIndex] valueForKey:@"id"];
    NSLog(@"Book id %@ - %@", [[_allDisplayBooks objectAtIndex:self.storiesCarousel.currentItemIndex] valueForKey:@"id"], [[_allDisplayBooks objectAtIndex:self.storiesCarousel.currentItemIndex] valueForKey:@"title"]);
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment                = NSTextAlignmentCenter;
    
    NSMutableAttributedString *levelString = [[NSMutableAttributedString alloc] initWithString:_textViewLevel.text attributes:@{NSParagraphStyleAttributeName:paragraphStyle}];
    UIFont *textFont = _textViewLevel.font;
    textFont = [UIFont fontWithName:@"Chalkboard SE" size:33];
    
    [levelString addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, [levelString length])];
    
    NSRange levelRangeValue = [_textViewLevel.text rangeOfString:levelValue];
    [levelString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:levelRangeValue];
    [levelString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Chalkboard SE" size:33] range:levelRangeValue];
    
    [_textViewLevel setAttributedText:levelString];
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
                return value *1.7f;
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

- (IBAction)SelectLevelValue:(id)sender{
    
    [sender setBackgroundColor:[UIColor lightGrayColor]];
    
}

- (IBAction) displayUserSettings:(id)sender{
    
    _settingsProbSupportView.hidden = NO;
    _settingsProbView.hidden = NO;
    _ageLabelValue.text = @"";
    isInfo1Settings2Click = 2;
    //[self displaySettingsView];
}

- (IBAction)displyParentalControlOrNot:(id)sender{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *yearString = [formatter stringFromDate:[NSDate date]];
    int parentalControlAge = ([yearString integerValue] - [_ageLabelValue.text integerValue]);
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
            
            viewCtr2 = [[UserProgressViewController alloc] initWithNibName:@"UserProgressViewController_iPhone" bundle:nil];
            
            viewCtr3 = [[UserAllBooksViewController alloc] initWithNibName:@"UserAllBooksViewController_iPhone" bundle:nil];
        }
        
        else{
            
            viewCtr0 = [[UserAgeLevelViewController alloc] initWithNibName:@"UserAgeLevelViewController" bundle:nil];
            
            viewCtr1 = [[UserSubscriptionViewController alloc] initWithNibName:@"UserSubscriptionViewController" bundle:nil];
            
            viewCtr2 = [[UserProgressViewController alloc] initWithNibName:@"UserProgressViewController" bundle:nil];
            
            viewCtr3 = [[UserAllBooksViewController alloc] initWithNibName:@"UserAllBooksViewController" bundle:nil];
        }
        
        viewCtr0.tabBarItem.image = [UIImage imageNamed:@"profile.png"];
        
        viewCtr1.tabBarItem.image = [UIImage imageNamed:@"feedback.png"];
        
        viewCtr2.tabBarItem.image = [UIImage imageNamed:@"analytics.png"];
        
        viewCtr3.tabBarItem.image = [UIImage imageNamed:@"feedback.png"];
        
        viewCtr0.navigationController.navigationBarHidden = YES;
        
        viewCtr1.navigationController.navigationBarHidden=YES;
        
        viewCtr2.navigationController.navigationBarHidden=YES;
        
        viewCtr3.navigationController.navigationBarHidden=YES;
        
        tabBarController.viewControllers= [NSArray arrayWithObjects: viewCtr3, viewCtr1, viewCtr0, viewCtr2,  nil];
        
        [self.navigationController pushViewController:tabBarController animated:YES];
    }
}



- (IBAction) presentAppInfoPage:(id)sender{
    
    _settingsProbSupportView.hidden = NO;
    _settingsProbView.hidden = NO;
    _ageLabelValue.text = @"";
    isInfo1Settings2Click = 1;
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
    if(noOfBooks == 0){
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
        
        NSString *ageVal = [NSString stringWithFormat:@"%d",[sender tag]];
        _ageLabelValue.text = [_ageLabelValue.text stringByAppendingString:ageVal];
    }
}

- (IBAction) backSpaceAgeField:(id)sender{
    
    self.ageLabelValue.text = @"";
}



///Just for testing purpose

- (IBAction)storeView:(id)sender{
    
    MangoStoreViewController *storeViewController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        storeViewController = [[MangoStoreViewController alloc] initWithNibName:@"MangoStoreViewController_iPhone" bundle:nil];
    }
    else{
        storeViewController = [[MangoStoreViewController alloc] initWithNibName:@"MangoStoreViewController" bundle:nil];
    }
    
    [self.navigationController pushViewController:storeViewController animated:YES];
}

@end
