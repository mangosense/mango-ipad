//
//  UserAllBooksViewController.m
//  MangoReader
//
//  Created by Harish on 2/6/15.
//
//

#import "UserAllBooksViewController.h"
#import "HomePageViewController.h"
#import "AePubReaderAppDelegate.h"
#import "UserAllBooksViewController.h"
#import "UIImageView+WebCache.h"
#import "Constants.h"

@interface UserAllBooksViewController ()

@end

@implementation UserAllBooksViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentScreen = @"settingsParentsScreen";
    _storiesCarousel.type = iCarouselTypeRotary;
    UserBookDownloadViewController *bookDownloadClass = [[UserBookDownloadViewController alloc] init];
    
    NSArray *testArray = [UserBookDownloadViewController returnAllAvailableLevels];
    NSString *textLevel= [testArray componentsJoinedByString:@" "];
    _textViewLevel.text = textLevel;
    bookDownloadClass.delegate = self;
    [bookDownloadClass returnArrayElementa];
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    singleTapGestureRecognizer.delegate = self;
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    _textViewLevel.editable = NO;
    _textViewLevel.selectable = NO;
    //displayTextFiel.addGestureRecognizer(singleTapGestureRecognizer)
    [_textViewLevel addGestureRecognizer:singleTapGestureRecognizer];
    
    // Do any additional setup after loading the view from its nib.
    
}

- (void) handleTap :(UITapGestureRecognizer *)getureRecog{
    
    CGPoint point = [getureRecog locationInView:_textViewLevel];
    point.x -= _textViewLevel.textContainerInset.left;
    point.y -= _textViewLevel.textContainerInset.top;
    
    NSUInteger characterIndex = [_textViewLevel.layoutManager characterIndexForPoint:point
                                                                     inTextContainer:_textViewLevel.textContainer
                                            fractionOfDistanceBetweenInsertionPoints:nil];
    
    NSLog(@"%d--%c", (int)characterIndex, [_textViewLevel.text  characterAtIndex:characterIndex]);
    NSString *levelVal =[NSString stringWithFormat:@"%c",[_textViewLevel.text  characterAtIndex:characterIndex]];
    if([levelVal isEqualToString:@" "]){
        levelVal =[NSString stringWithFormat:@"%c",[_textViewLevel.text  characterAtIndex:characterIndex]];
    }
    if([levelVal isEqualToString:@""]){
        levelVal = @"A";
    }
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDictionary *dimensions = @{
                                 PARAMETER_ACTION : @"selectLevel",
                                 PARAMETER_CURRENT_PAGE : currentScreen,
                                 PARAMETER_LEVEL_VALUE : levelVal,
                                 PARAMETER_EVENT_DESCRIPTION : @"select level",
                                 };
    [appDelegate trackEventAnalytic:@"selectLevel" dimensions:dimensions];
    [appDelegate eventAnalyticsDataBrowser:dimensions];
    [appDelegate trackMixpanelEvents:dimensions eventName:@"selectLevel"];
    
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
    
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    BOOL value = [prefs valueForKey: @"SHOWAGEDETAILVIEW"];
//    if(value){
//        [prefs setValue:[NSNumber numberWithBool:NO] forKey:@"SHOWAGEDETAILVIEW"];
//        [self.navigationController popViewControllerAnimated:NO];
//    }
}


- (void) viewDidAppear:(BOOL)animated{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    positionIndex = [[prefs valueForKey:@"USERBOOKINDEX"] integerValue];
    _storiesCarousel.currentItemIndex = positionIndex;
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDictionary *dimensions = @{
                                 PARAMETER_ACTION : currentScreen,
                                 PARAMETER_CURRENT_PAGE : currentScreen,
                                 PARAMETER_EVENT_DESCRIPTION : @"settings Parents Screen open",
                                 };
    [appDelegate trackEventAnalytic:currentScreen dimensions:dimensions];
    [appDelegate eventAnalyticsDataBrowser:dimensions];
    [appDelegate trackMixpanelEvents:dimensions eventName:currentScreen];
}

-(void) viewDidDisappear:(BOOL)animated{
    
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
    
    
    int validUserSubscription = [prefs boolForKey:@"USERSUBSCRIBED"];
    int hasfreeTrial= [prefs boolForKey:@"HASFREETRIALACCESS"];
    
    if(validUserSubscription || hasfreeTrial){/*
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
    */}
    else{/*
        
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
    */}
    
}


/*- (void)bookDownloaded:(NSString *)bookId {
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    booksDownloadingCount--;
    [self deleteBookIdFromArray:bookId];
}

- (void)bookDownloadAborted:(NSString *)bookId{
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    booksDownloadingCount--;
    [self deleteBookIdFromArray:bookId];
}*/

/*- (void)updateBookProgress:(int)progress {
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    //[_buyButton setHidden:YES];
    if([_frontBookId isEqualToString: newIDValue]){
        
        //_bookProgress = progress;
        
        if (progress < 100) {
            _displayView.hidden = NO;
            [self performSelectorOnMainThread:@selector(showHudOnButton) withObject:nil waitUntilDone:YES];
            
            //[_closeButton setEnabled:NO];
        } else {
            _displayView.hidden = YES;
            [self performSelectorOnMainThread:@selector(hideHudOnButton) withObject:nil waitUntilDone:YES];
            //[_closeButton setEnabled:YES];
        }
    }
}*/

/*- (void)showHudOnButton {
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
}*/



/*- (void)openBook:(Book *)bk {
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
}*/

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
        /*lockImg =[[UIImageView alloc] initWithFrame:CGRectMake(40,180,40,40)];
        lockImg.image= [UIImage imageNamed:@"loginLock.png"];
        storyImageView.tag = 0;*/
        storyImageView.tag = 0;
        lockImg.image = nil;
    }
    else{
        storyImageView.tag = 0;
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
    
    //check current index lie in i+5 value else send tag value to one
    
    int bookTagValue = [self checkIfBookAcessible:index];
    
    [self.tabBarController setSelectedIndex:0];
    
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
    
    //[self readyBookToOpen:selectedBookId withTag:bookTagValue];
}


- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel{
    
    //[self performSelectorOnMainThread:@selector(hideHudOnButton) withObject:nil waitUntilDone:YES];
    NSInteger indexVal = self.storiesCarousel.currentItemIndex+1;
    if(indexVal >= _allDisplayBooks.count){
        
        indexVal = 0;
    }
    
    NSLog(@"heyyyy current element level is %@",[[_allDisplayBooks objectAtIndex:indexVal] valueForKey:@"level"]);
    NSString *levelVal = [[_allDisplayBooks objectAtIndex:indexVal] valueForKey:@"level"];
   // _specificLevelBooks = [[NSMutableArray alloc] init];
    // Get all books of that level
    /*for(NSDictionary *element in _allDisplayBooks){
        
        if([[element objectForKey:@"level"] isEqualToString:levelVal]){
            [_specificLevelBooks addObject:element];
        }
    }*/
    ///
    
    NSString *levelValue = [[_allDisplayBooks objectAtIndex:indexVal] valueForKey:@"level"];
    //NSString *levelString = _levelsLabel.text;
    _frontBookId = [[_allDisplayBooks objectAtIndex:indexVal] valueForKey:@"id"];
    NSLog(@"Book id %@ - %@", [[_allDisplayBooks objectAtIndex:indexVal] valueForKey:@"id"], [[_allDisplayBooks objectAtIndex:indexVal] valueForKey:@"title"]);
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment                = NSTextAlignmentCenter;
    
    NSMutableAttributedString *levelString = [[NSMutableAttributedString alloc] initWithString:_textViewLevel.text attributes:@{NSParagraphStyleAttributeName:paragraphStyle}];
    UIFont *textFont = _textViewLevel.font;
    
    //Check for iPhone version
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        
        textFont = [UIFont fontWithName:@"Chalkboard SE" size:21];
    }
    else{
        textFont = [UIFont fontWithName:@"Chalkboard SE" size:33];
    }
    
    [levelString addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, [levelString length])];
    
    NSRange levelRangeValue = [_textViewLevel.text rangeOfString:levelValue];
    [levelString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:levelRangeValue];
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        
        [levelString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Chalkboard SE" size:21] range:levelRangeValue];
    }
    else{
        [levelString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Chalkboard SE" size:33] range:levelRangeValue];
    }
    
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
                return value *1.0f;
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

- (IBAction) backToHomePage:(id)sender{
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDictionary *dimensions = @{
                                 PARAMETER_ACTION : @"homeButtonClick",
                                 PARAMETER_CURRENT_PAGE : currentScreen,
                                 PARAMETER_EVENT_DESCRIPTION : @"back to home click",
                                 };
    [appDelegate trackEventAnalytic:@"homeButtonClick" dimensions:dimensions];
    [appDelegate eventAnalyticsDataBrowser:dimensions];
    [appDelegate trackMixpanelEvents:dimensions eventName:@"homeButtonClick"];
    //[self.tabBarController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
