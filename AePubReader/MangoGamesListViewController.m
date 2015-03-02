//
//  MangoGamesListViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 13/12/13.
//
//

#import "MangoGamesListViewController.h"
#import "MangoEditorViewController.h"
#import "MangoGameViewController.h"
#import "AePubReaderAppDelegate.h"
#import <Parse/Parse.h>
#import "OrderedDictionary.h"

#define GAME_DRAW @"draw"
#define GAME_JIGSAW @"jigsaw"
#define GAME_MATCH_IMAGES @"matchimages"
#define GAME_MATCH_WORDS @"matchwords"
#define GAME_MEMORY @"memory"
#define GAME_QA @"question_answer"
#define GAME_QUIZ @"quiz"
#define GAME_SEQUENCE @"sequence"
#define GAME_SEQUENCE_IMAGES @"sequenceimages"
#define GAME_TRUE_FALSE @"true_false"
#define GAME_WORDSEARCH @"wordsearch"

@interface MangoGamesListViewController ()

@property (nonatomic, strong) NSMutableArray *gamesArray;
@property (nonatomic, strong) NSMutableDictionary *dataDict;


@end

@implementation MangoGamesListViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        _loginUserEmail = delegate.loggedInUserInfo.email;
        userEmail = delegate.loggedInUserInfo.email;
        userDeviceID = delegate.deviceId;
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    viewName = @"Games View";
    currentPage = @"game_screen";
    if(!userEmail){
        ID = userDeviceID;
    }
    else{
        ID = userEmail;
    }
    // Do any additional setup after loading the view from its nib.
    _gamesArray = [NSMutableArray arrayWithObjects:[UIImage imageNamed:@"word-search-game.jpg"], [UIImage imageNamed:@"memory-puzzle.jpg"], [UIImage imageNamed:@"jigsaw-puzzle.jpg"], nil];
//    [_gamesCarousel setType:iCarouselTypeCoverFlow];
//    int scrollToIndex = 0;
//    if ([_gameNames count] > 2) {
//        scrollToIndex = 1;
//    }
    //[_gamesCarousel scrollToItemAtIndex:scrollToIndex animated:YES];
    self.timeCalculate = [NSDate date];
    
    if(_gameNames.count >0){
        
        [self loadGameView:0];
    }
    
    //Direct load the game here and go on
    //Test
    
}

- (void) viewDidAppear:(BOOL)animated{
    
//    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
//    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
//    [dimensions setObject:@"game_screen" forKey:PARAMETER_ACTION];
//    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
//    [dimensions setObject:@"Game screen open" forKey:PARAMETER_EVENT_DESCRIPTION];
//    if(userEmail){
//        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
//    }
//    [delegate trackEventAnalytic:@"game_screen" dimensions:dimensions];
//    [delegate eventAnalyticsDataBrowser:dimensions];
//    [delegate trackMixpanelEvents:dimensions eventName:@"game_screen"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - iCarousel Datasource and Delegate Methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [_gameNames count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    UIImageView *storyImageView = [[UIImageView alloc] init];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        [storyImageView setFrame:CGRectMake(0, 0, 160, 150)];
    }
    else{
        [storyImageView setFrame:CGRectMake(0, 0, 400, 350)];
    }
    
    [storyImageView setImage:[UIImage imageNamed:[_gameNames objectAtIndex:index]]];
    [[storyImageView layer] setCornerRadius:12];
    [storyImageView setClipsToBounds:YES];
    return storyImageView;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    
    
    
    
//    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
//    [dimensions setObject:@"playing" forKey:PARAMETER_ACTION];
//    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
//    [dimensions setObject:gameName forKey:PARAMETER_GAME_NAME];
//    [dimensions setObject:_currentBookId forKey:PARAMETER_BOOK_ID];
//    [dimensions setObject:_currentBookTitle forKey:PARAMETER_BOOK_TITLE];
//    [dimensions setObject:@"Play game" forKey:PARAMETER_EVENT_DESCRIPTION];
//    if(userEmail){
//        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
//    }
//    [delegate trackEventAnalytic:@"playing" dimensions:dimensions];
//    [delegate eventAnalyticsDataBrowser:dimensions];
//    [delegate trackMixpanelEvents:dimensions eventName:@"playing"];
    /*NSDictionary *dimensions = @{
                                 PARAMETER_USER_EMAIL_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_BOOK_ID: currentBookId,
                                 PARAMETER_GAME_NAME : gameName
                                 
                                 };
    [delegate trackEvent:[GAMES valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[GAMES valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [GAMES valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    [userObject setObject:currentBookId forKey:@"bookID"];
    [userObject setObject:gameName forKey:@"gameName"];
    if(userEmail){
        [userObject setObject:ID forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];*/
    
    //NSString * currentBookImageURL = [[NSString stringWithFormat:@"http://www.mangoreader.com/live_stories/%@/%@",[jsonDict objectForKey:@"id"], [jsonDict objectForKey:@"story_image"]] stringByReplacingOccurrencesOfString:@"res/" withString:@"res/cover_"];
    
    //NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    /*PFQuery *query1 = [PFQuery queryWithClassName:@"Analytics"];
    if(_loginUserEmail == nil){
        _loginUserEmail = @"nil";
        [query1 whereKey:@"deviceIDValue" equalTo:udid];
        [query1 whereKey:@"bookID" equalTo:_currentBookId];
    }
    else{
        [query1 whereKey:@"email_ID" equalTo:_loginUserEmail];
        [query1 whereKey:@"bookID" equalTo:_currentBookId];
    }
    [query1 getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            NSLog(@"Book data found");
            
            int totalActivityNo = [[object valueForKey:@"activityCount"] intValue] + 1;
            [object setObject:[NSNumber numberWithInt:totalActivityNo] forKey:@"activityCount"];
            //[object saveInBackground];
            
        }
        else{
            NSLog(@"Book data not foun, so need to create");
            
            PFObject *userObject = [PFObject objectWithClassName:@"Analytics"];
            [userObject setObject:udid forKey:@"deviceIDValue"];
            [userObject setObject:_loginUserEmail forKey:@"email_ID"];
            [userObject setObject:_currentBookId forKey:@"bookID"];
            [userObject setObject:[NSNumber numberWithInt:0]  forKey:@"currentPage"];
            [userObject setObject:[NSNumber numberWithInt:0]forKey:@"availablePage"];
            [userObject setObject:_currentBookTitle forKey:@"bookTitle"];
            [userObject setObject:currentBookGradeLevel forKey:@"gradeLevel"];
            [userObject setObject:[NSNumber numberWithInt:1] forKey:@"activityCount"];
            [userObject setObject:[NSNumber numberWithInt:0] forKey:@"activityPoints"];
            [userObject setObject:[NSNumber numberWithFloat:0.0] forKey:@"readingTime"];
            [userObject setObject:currentBookImageURL forKey:@"bookCoverImageURL"];
            [userObject setObject:[NSNumber numberWithInt:0.0] forKey:@"pagesCompleted"];
            [userObject setObject:[NSNumber numberWithInteger:0] forKey:@"bookCompleted"];
            [userObject setObject:[NSNumber numberWithInt:0] forKey:@"timesNumberBookCompleted"];
            
            //[userObject saveInBackground];
        }
    }];*/
    
/* ////    _webView = [gameViewDict objectForKey:@"gameView"];
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    _webView.frame = self.view.frame;
    [_webView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth];
    [[_webView scrollView] setBounces:NO];
    
    [self.view addSubview:_webView];
    
    [self.view bringSubviewToFront:_closeButton]; // */
}

- (void) loadGameView : (NSInteger) index{
    countGames ++;
    NSString *gameName = [_gameNames objectAtIndex:index];
    
    NSData *jsonData1 = [_jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict1 = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData1 options:NSJSONReadingAllowFragments error:nil]];
    
    NSMutableArray *readerPagesArray1 = [[NSMutableArray alloc] initWithArray:[jsonDict1 objectForKey:PAGES]];
    NSMutableArray *gamesDataArray = [[NSMutableArray alloc] init];
    for (NSDictionary *readerPageDict in readerPagesArray1){
        if(([[readerPageDict objectForKey:PAGE_NAME] length] >3) && !([[readerPageDict objectForKey:PAGE_NAME] isEqualToString:@"Cover"])){
            NSLog(@"not match - %@", [readerPageDict objectForKey:PAGE_NAME]);
            [gamesDataArray addObject:readerPageDict];
        }
    }
    
    NSMutableDictionary *gameViewDict = [MangoEditorViewController readerGamePagePro:gameName ForStory:gamesDataArray WithFolderLocation:_folderLocation AndOption:index];
    
    _dataDict = [[NSMutableDictionary alloc] initWithDictionary:[gameViewDict objectForKey:@"data"]];
    [_dataDict setObject:[NSNumber numberWithBool:YES] forKey:@"from_mobile"];
    
    NSData *jsonData = [_jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    
    _currentBookId = [jsonDict objectForKey:@"id"];
    _currentBookTitle = [jsonDict objectForKey:@"title"];
    
    _webView = [gameViewDict objectForKey:@"gameView"];
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    _webView.frame = self.view.frame;
    [_webView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth];
    [[_webView scrollView] setBounces:NO];
    
    [self.view addSubview:_webView];
    
    [self.view bringSubviewToFront:_closeButton];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return NO;
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

#pragma mark - Action Methods

- (void)closeGames:(id)sender {
    /*BOOL hasWeView = NO;
    for (UIView *subview in [self.view subviews]) {
        if ([subview isKindOfClass:[UIWebView class]]) {
            [subview removeFromSuperview];
            hasWeView = YES;
            break;
        }
    }
    if (!hasWeView) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }*/
    
    if(countGames == _gameNames.count){
        
        //over games list
        [self dismissViewControllerAnimated:NO completion:^{
            
            
            
        }];
    }
    else{
        // move to next game
        [self loadGameView:countGames];
    }
    
}

- (void) viewWillDisappear:(BOOL)animated{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: _currentBookId, @"bookId", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GoToFinishBook" object:nil userInfo:dict];
}


- (void) testRestartGame{
    
    NSString *methodName = @"restart()";
    [_webView stringByEvaluatingJavaScriptFromString:methodName];
}

#pragma mark - UIWebView Delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_dataDict options:NSJSONReadingMutableContainers error:nil];
    
    NSString *paramString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"Param: %@", paramString);
   
    NSString *resultString = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"MangoGame.init(%@)", paramString]];
    NSLog(@"%@", resultString);
    
    //test to execute javascript menthod to execute method after delay
    //[self performSelector:@selector(hideAlert:) withObject:alert afterDelay:1.5];
    //[self performSelector:@selector(testRestartGame) withObject:nil afterDelay:35.0];
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    return YES;
}


@end
