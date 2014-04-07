//
//  PageNewBookTypeViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 21/11/13.
//
//

#import "PageNewBookTypeViewController.h"
#import "AePubReaderAppDelegate.h"
#import "LanguageChoiceViewController.h"
#import "CustomMappingView.h"
#import "MangoGamesListViewController.h"
#import <Parse/Parse.h>

#define FORK_TAG 9

@interface PageNewBookTypeViewController ()

@property (nonatomic, strong) NSDate *openingTime;

@property (nonatomic, assign) NSInteger gamePageNumber;
@property (nonatomic, strong) NSMutableDictionary *gameDataDict;
@property (nonatomic, assign) BOOL showButtons;

@end

@implementation PageNewBookTypeViewController
@synthesize menuPopoverController;
@synthesize openingTime;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil WithOption:(NSInteger)option BookId:(NSString *)bookID
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _option=option;
        _bookId=bookID;
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        _book= [delegate.dataModel getBookOfId:bookID];
        _loginUserEmail = delegate.loggedInUserInfo.email;
        
                _pageNumber=1;
        NSLog(@"%@",_book.edited);
        userEmail = delegate.loggedInUserInfo.email;
        userDeviceID = delegate.deviceId;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    viewName = @"Book Read View";
    
    if(!userEmail){
        ID = userDeviceID;
    }
    else{
        ID = userEmail;
    }
    
    openingTime = [NSDate date];
    
    // Do any additional setup after loading the view from its nib.
    self.timeCalculate = [NSDate date];
    NSString *jsonLocation=_book.localPathFile;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
    NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
    jsonLocation=     [jsonLocation stringByAppendingPathComponent:[onlyJson firstObject]];

    _jsonContent=[[NSString alloc]initWithContentsOfFile:jsonLocation encoding:NSUTF8StringEncoding error:nil];
    
    [self loadPageWithOption:_option];
    
    _rightView.backgroundColor=[UIColor clearColor];

    NSNumber *numberOfPages = [MangoEditorViewController numberOfPagesInStory:_jsonContent];
    _pageNo=numberOfPages.integerValue;
    
    _showButtons = YES;
    
    _loginUserName = @"User";
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    tapGesture.delegate = (id <UIGestureRecognizerDelegate>)self;
    [self.view addGestureRecognizer:tapGesture];
    
}

- (void)hideAllButtons:(BOOL)hide {
    _showOptionButton.hidden = hide;
    _backButton.hidden = hide;
    _previousPageButton.hidden = hide;
    _nextPageButton.hidden = hide;
    if (hide) {
        _rightView.hidden=YES;
    }
}

- (void)didTap:(UITapGestureRecognizer *)gesture {
    _showButtons = !_showButtons;
    [self hideAllButtons:!_showButtons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ShowOptions:(id)sender {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    _rightView.hidden=NO;
    NSDictionary *dimensions = @{
                                 PARAMETER_USER_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_BOOK_ID : _bookId
                                 
                                 };
    [delegate trackEvent:[READBOOK_OPTIONS valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[READBOOK_OPTIONS valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [READBOOK_OPTIONS valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    [userObject setObject:_bookId forKey:@"bookID"];
    if(userEmail){
        [userObject setObject:ID forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];
    
    UIButton *button=(UIButton *)sender;
    button.hidden=YES;
}

- (IBAction)BackButton:(id)sender {
    //AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    [self.navigationController popViewControllerAnimated:YES];
    //[self.navigationController popToViewController:delegate.pageViewController animated:YES];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [_audioMappingViewController.timer invalidate];
    [_audioMappingViewController.player stop];
}
- (IBAction)closeButton:(id)sender {
    _rightView.hidden=YES;
    _showOptionButton.hidden=NO;
}

- (IBAction)shareButton:(id)sender {
   // [PFAnalytics trackEvent:EVENT_BOOK_SHARED dimensions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", [_book.id intValue]], [NSString stringWithFormat:@"%d", _pageNumber], nil] forKeys:[NSArray arrayWithObjects:@"bookId", @"pageNumber", nil]]];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *dimensions = @{
                                 PARAMETER_USER_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_BOOK_ID : _bookId,
                                 PARAMETER_BOOK_PAGE_NO: [NSString stringWithFormat:@"%d",_pageNumber],
                                
                                 };
    [delegate trackEvent:[READBOOK_SHARE valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[READBOOK_SHARE valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [READBOOK_SHARE valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    [userObject setObject:_bookId forKey:@"bookID"];
    [userObject setObject:[NSNumber numberWithInt:_pageNumber] forKey:@"bookPageNo"];
    if(userEmail){
        [userObject setObject:ID forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];

    
    UIButton *button=(UIButton *)sender;
    NSString *ver=[UIDevice currentDevice].systemVersion;
    if([ver floatValue]>5.1){
        
        AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
        MangoBook *book=[appDelegate.ejdbController.collection fetchObjectWithOID:_book.id];
        NSString *textToShare=[_book.title stringByAppendingFormat:@"\n\nI found this cool book - %@ - on MangoReader!\n\nApp Link- https://itunes.apple.com/in/app/mangoreader-interactive-kids/id568003822?mt=8\n\n Read it here - %@ !", _book.title, [NSString stringWithFormat:@"www.mangoreader.com/live_stories/%@", book.id]];
        
        UIImage *image=[UIImage imageWithContentsOfFile:_book.localPathImageFile];
        NSMutableArray *activityItems= [[NSMutableArray alloc] init];
        if (textToShare) {
            [activityItems addObject:textToShare];
        }
        if (image) {
            [activityItems addObject:image];
        }
        
        UIActivityViewController *activity=[[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
        activity.excludedActivityTypes=@[UIActivityTypeCopyToPasteboard,UIActivityTypePostToWeibo,UIActivityTypeAssignToContact,UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll];
        _popOverShare=[[UIPopoverController alloc]initWithContentViewController:activity];
        
        [_popOverShare presentPopoverFromRect:button.frame inView:button.superview permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
        
        return;
    }
    
    /// for IOS 5 code below;
   /* MFMailComposeViewController *mail;
    
    mail=[[MFMailComposeViewController alloc]init];
    [mail setSubject:@"Found this awesome interactive book on MangoReader"];
    mail.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
    [mail setMailComposeDelegate:self];
    NSString *body=[NSString stringWithFormat:@"Hi,\n%@",buttonShadow.stringLink];
    body =[body stringByAppendingString:@"\nI found this cool book on mangoreader - we bring books to life.The book is interactive with the characters moving on touch and movement, which makes it fun and engaging.The audio and text highlight syncing will make it easier for kids to learn and understand pronunciation.Not only this, I can play cool games in the book, draw and make puzzles and share my scores.\nDownload the MangoReader app from the appstore and try these awesome books."];
    [mail setMessageBody:body isHTML:NO];
    [self presentModalViewController:mail animated:YES];*/

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    switch (alertView.tag) {
        case FORK_TAG: {
            switch (buttonIndex) {
                case 0: {
                    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
                    
                    NSDictionary *dimensions = @{
                                                 PARAMETER_USER_ID : ID,
                                                 PARAMETER_DEVICE: IOS,
                                                 PARAMETER_BOOK_ID : _bookId,
                                                 PARAMETER_BOOK_PAGE_NO: [NSString stringWithFormat:@"%d",_pageNumber],
                                                 PARAMETER_BOOL_ISNEW_VERSION :[NSNumber numberWithBool:NO]
                                                 };
                    [delegate trackEvent:[READBOOK_NEW_VERSION valueForKey:@"description"] dimensions:dimensions];
                    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
                    [userObject setObject:[READBOOK_NEW_VERSION valueForKey:@"value"] forKey:@"eventName"];
                    [userObject setObject: [READBOOK_NEW_VERSION valueForKey:@"description"] forKey:@"eventDescription"];
                    [userObject setObject:viewName forKey:@"viewName"];
                    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
                    [userObject setObject:delegate.country forKey:@"deviceCountry"];
                    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
                    [userObject setObject:_bookId forKey:@"bookID"];
                    [userObject setObject:[NSNumber numberWithInt:_pageNumber] forKey:@"bookPageNo"];
                    [userObject setObject:[NSNumber numberWithBool:NO] forKey:@"boolValue"];
                    if(userEmail){
                        [userObject setObject:ID forKey:@"emailID"];
                    }
                    [userObject setObject:IOS forKey:@"device"];
                    [userObject saveInBackground];
                    
                }
                    break;
                    
                case 1: {
                   // [PFAnalytics trackEvent:EVENT_BOOK_FORKED dimensions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", [_book.id intValue]], [NSString stringWithFormat:@"%d", _pageNumber], nil] forKeys:[NSArray arrayWithObjects:@"bookId", @"pageNumber", nil]]];
                    
                    NSDictionary *dimensions = @{
                                                 PARAMETER_USER_ID : ID,
                                                 PARAMETER_DEVICE: IOS,
                                                 PARAMETER_BOOK_ID : _bookId,
                                                 PARAMETER_BOOK_PAGE_NO: [NSString stringWithFormat:@"%d",_pageNumber],
                                                 PARAMETER_BOOL_ISNEW_VERSION :[NSNumber numberWithBool:YES]
                                                 };
                    [delegate trackEvent:[READBOOK_NEW_VERSION valueForKey:@"description"] dimensions:dimensions];
                    [delegate trackEvent:[READBOOK_NEW_VERSION valueForKey:@"description"] dimensions:dimensions];
                    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
                    [userObject setObject:[READBOOK_NEW_VERSION valueForKey:@"value"] forKey:@"eventName"];
                    [userObject setObject: [READBOOK_NEW_VERSION valueForKey:@"description"] forKey:@"eventDescription"];
                    [userObject setObject:viewName forKey:@"viewName"];
                    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
                    [userObject setObject:delegate.country forKey:@"deviceCountry"];
                    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
                    [userObject setObject:_bookId forKey:@"bookID"];
                    [userObject setObject:[NSNumber numberWithInt:_pageNumber] forKey:@"bookPageNo"];
                    [userObject setObject:[NSNumber numberWithBool:YES] forKey:@"boolValue"];
                    if(userEmail){
                        [userObject setObject:ID forKey:@"emailID"];
                    }
                    [userObject setObject:IOS forKey:@"device"];
                    [userObject saveInBackground];
                    
                    MangoEditorViewController *mangoEditorViewController= [[MangoEditorViewController alloc] initWithNibName:@"MangoEditorViewController" bundle:nil];
                    mangoEditorViewController.storyBook=_book;
                    [self.navigationController pushViewController:mangoEditorViewController animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)editButton:(id)sender {
    UIAlertView *editAlertView = [[UIAlertView alloc] initWithTitle:@"Create your own version" message:@"This will create a new version of this book which you can edit. The old version will be saved too. Do you want to continue?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    editAlertView.tag = FORK_TAG;
    [editAlertView show];
}

- (IBAction)changeLanguage:(id)sender {
    //[PFAnalytics trackEvent:EVENT_TRANSLATE_INITIATED dimensions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", [_book.id intValue]], [NSString stringWithFormat:@"%d", _pageNumber], nil] forKeys:[NSArray arrayWithObjects:@"bookId", @"pageNumber", nil]]];
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
    NSString *url;
    url = LANGUAGES_FOR_BOOK;
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setObject:_bookId forKey:@"story_id"];
    [paramDict setObject:IOS forKey:PLATFORM];
    [apiController getListOf:url ForParameters:paramDict withDelegate:self];
    
}

- (void)reloadViewsWithArray:(NSArray *)dataArray ForType:(NSString *)type {
    
    _avilableLanguages = [NSMutableArray arrayWithArray:dataArray];
    NSMutableArray *languageArray = [[NSMutableArray alloc] init];
    
    LanguageChoiceViewController *choiceViewController=[[LanguageChoiceViewController alloc]initWithStyle:UITableViewStyleGrouped];
    choiceViewController.delegate=self;
    _pop=[[UIPopoverController alloc]initWithContentViewController:choiceViewController];
    CGSize size=_pop.popoverContentSize;
    size.height=size.height-300;
    _pop.popoverContentSize=size;
    
    choiceViewController.bookIDArray = [[NSMutableArray alloc] init];
    for(int i=0; i< [_avilableLanguages count]; ++i){
        [languageArray addObject:[_avilableLanguages[i] objectForKey:@"language"]];
        NSLog(@"Print %@", [_avilableLanguages[i] objectForKey:@"language"]);
        [choiceViewController.bookIDArray addObject:[_avilableLanguages[i] objectForKey:@"live_story_id"]];
    }
    
    NSString *jsonLocation=_book.localPathFile;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
    NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
    jsonLocation=     [jsonLocation stringByAppendingPathComponent:[onlyJson firstObject]];
    //  NSLog(@"json location %@",jsonLocation);
    NSString *jsonContent=[[NSString alloc]initWithContentsOfFile:jsonLocation encoding:NSUTF8StringEncoding error:nil];
    
    NSData *jsonData = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    choiceViewController.array = [jsonDict objectForKey:@"available_languages"];
    choiceViewController.array = [[NSArray alloc] initWithArray:languageArray];
    choiceViewController.bookDict = jsonDict;
    choiceViewController.language = [[jsonDict objectForKey:@"info"] objectForKey:@"language"];
    choiceViewController.isReadPage = 1;
    if(choiceViewController.array.count>0){
        
        [_pop presentPopoverFromRect:_languageAvailButton.frame inView:_rightView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    }
    
    
  //  [_pop presentPopoverFromRect:button.frame inView:self.rightView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}


- (IBAction)previousButton:(id)sender {
    
    if (_pageNumber==1) {
        //[self BackButton:nil];
        [self.navigationController popViewControllerAnimated:YES];

    }else{
         _pageNumber--;
             [self loadPageWithOption:_option];

    }
}

- (IBAction)nextButton:(id)sender {
    ++_pageNumber;
    
    if (_pageNumber<(_pageNo)) {
        [self loadPageWithOption:_option];
        
        /// default is icons_play.png
        if (_option==0) {
            [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_pause.png"] forState:UIControlStateNormal];
        }else{
            [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_play.png"] forState:UIControlStateNormal];
        }
      
        
    } else {
        _pageNumber = _pageNo - 1;
        LastPageViewController *lastPage = [[LastPageViewController alloc] initWithNibName:@"LastPageViewController" bundle:nil WithId:[_book valueForKey:@"id"]];
        [self.navigationController pushViewController:lastPage animated:YES];
    }
   
}

- (IBAction)playOrPauseButton:(id)sender {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    
    float timeEndValue = [[NSDate date] timeIntervalSinceDate:self.timeCalculate];
    
    if (_audioMappingViewController.player) {
        if ([_audioMappingViewController.player isPlaying]) {
            //[PFAnalytics trackEvent:EVENT_AUDIO_PAUSED dimensions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", [_book.id intValue]], [NSString stringWithFormat:@"%d", _pageNumber], nil] forKeys:[NSArray arrayWithObjects:@"bookId", @"pageNumber", nil]]];
            
            NSDictionary *dimensions = @{
                                         PARAMETER_USER_ID : ID,
                                         PARAMETER_DEVICE: IOS,
                                         PARAMETER_BOOK_ID : _bookId,
                                         PARAMETER_BOOK_PAGE_NO: [NSString stringWithFormat:@"%d",_pageNumber],
                                         PARAMETER_BOOK_TIME_SPEND : [NSString stringWithFormat:@"%f",timeEndValue],
                                         PARAMETER_BOOL_ISPLAYING : [NSString stringWithFormat:@"%d", (BOOL)YES]
                                         
                                         };
            [delegate trackEvent:[READBOOK_READTOME_AUDIO_PLAYING valueForKey:@"description"] dimensions:dimensions];
            PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
            [userObject setObject:[READBOOK_READTOME_AUDIO_PLAYING valueForKey:@"value"] forKey:@"eventName"];
            [userObject setObject: [READBOOK_READTOME_AUDIO_PLAYING valueForKey:@"description"] forKey:@"eventDescription"];
            [userObject setObject:viewName forKey:@"viewName"];
            [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
            [userObject setObject:delegate.country forKey:@"deviceCountry"];
            [userObject setObject:delegate.language forKey:@"deviceLanguage"];
            [userObject setObject:_bookId forKey:@"bookID"];
            [userObject setObject:[NSNumber numberWithInt:_pageNumber] forKey:@"bookPageNo"];
            [userObject setObject:[NSNumber numberWithFloat:timeEndValue] forKey:@"bookTimeSpend"];
            [userObject setObject:[NSNumber numberWithBool:YES] forKey:@"boolValue"];
            if(userEmail){
                [userObject setObject:ID forKey:@"emailID"];
            }
            [userObject setObject:IOS forKey:@"device"];
            [userObject saveInBackground];
            
            [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_play.png"] forState:UIControlStateNormal];
            [_audioMappingViewController.player pause];
        }else{
            //[PFAnalytics trackEvent:EVENT_AUDIO_PLAYED dimensions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", [_book.id intValue]], [NSString stringWithFormat:@"%d", _pageNumber], nil] forKeys:[NSArray arrayWithObjects:@"bookId", @"pageNumber", nil]]];
            
            NSDictionary *dimensions = @{
                                         PARAMETER_USER_ID : ID,
                                         PARAMETER_DEVICE: IOS,
                                         PARAMETER_BOOK_ID : _bookId,
                                         PARAMETER_BOOK_PAGE_NO: [NSString stringWithFormat:@"%d",_pageNumber],
                                         PARAMETER_BOOK_TIME_SPEND : [NSString stringWithFormat:@"%f",timeEndValue],
                                         PARAMETER_BOOL_ISPLAYING : [NSString stringWithFormat:@"%d", (BOOL)NO]
                                         
                                         };
            [delegate trackEvent:[READBOOK_READTOME_AUDIO_PLAYING valueForKey:@"description"] dimensions:dimensions];
            PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
            [userObject setObject:[READBOOK_READTOME_AUDIO_PLAYING valueForKey:@"value"] forKey:@"eventName"];
            [userObject setObject: [READBOOK_READTOME_AUDIO_PLAYING valueForKey:@"description"] forKey:@"eventDescription"];
            [userObject setObject:viewName forKey:@"viewName"];
            [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
            [userObject setObject:delegate.country forKey:@"deviceCountry"];
            [userObject setObject:delegate.language forKey:@"deviceLanguage"];
            [userObject setObject:_bookId forKey:@"bookID"];
            [userObject setObject:[NSNumber numberWithInt:_pageNumber] forKey:@"bookPageNo"];
            [userObject setObject:[NSNumber numberWithFloat:timeEndValue] forKey:@"bookTimeSpend"];
            [userObject setObject:[NSNumber numberWithBool:NO] forKey:@"boolValue"];
            if(userEmail){
                [userObject setObject:ID forKey:@"emailID"];
            }
            [userObject setObject:IOS forKey:@"device"];
            [userObject saveInBackground];

            [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_pause.png"] forState:UIControlStateNormal];
            [_audioMappingViewController.player play];
            NSLog(@"Timer: %@", _audioMappingViewController.timer);
            _audioMappingViewController.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:_audioMappingViewController selector:@selector(update) userInfo:nil repeats:YES];
            [self closeButton:nil];
            _showButtons = NO;
            [self hideAllButtons:!_showButtons];
        }
    } else {
        
        NSDictionary *dimensions = @{
                                     PARAMETER_USER_ID : ID,
                                     PARAMETER_DEVICE: IOS,
                                     PARAMETER_BOOK_ID : _bookId,
                                     PARAMETER_BOOK_PAGE_NO: [NSString stringWithFormat:@"%d",_pageNumber],
                                     PARAMETER_BOOK_TIME_SPEND : [NSString stringWithFormat:@"%f",timeEndValue]
                                     
                                     };
        [delegate trackEvent:[READBOOK_MYSELF_PLAY_PAUSE valueForKey:@"description"] dimensions:dimensions];
        PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
        [userObject setObject:[READBOOK_MYSELF_PLAY_PAUSE valueForKey:@"value"] forKey:@"eventName"];
        [userObject setObject: [READBOOK_MYSELF_PLAY_PAUSE valueForKey:@"description"] forKey:@"eventDescription"];
        [userObject setObject:viewName forKey:@"viewName"];
        [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
        [userObject setObject:delegate.country forKey:@"deviceCountry"];
        [userObject setObject:delegate.language forKey:@"deviceLanguage"];
        [userObject setObject:_bookId forKey:@"bookID"];
        [userObject setObject:[NSNumber numberWithInt:_pageNumber] forKey:@"bookPageNo"];
        [userObject setObject:[NSNumber numberWithFloat:timeEndValue] forKey:@"bookTimeSpend"];
        if(userEmail){
            [userObject setObject:ID forKey:@"emailID"];
        }
        [userObject setObject:IOS forKey:@"device"];
        [userObject saveInBackground];
        
        [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_pause.png"] forState:UIControlStateNormal];
        
        [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_pause.png"] forState:UIControlStateNormal];
        [self loadPageWithOption:0];
        [self closeButton:nil];
        _showButtons = NO;
        [self hideAllButtons:!_showButtons];
    }
}

- (IBAction)openGameCentre:(id)sender {
    float timeEndValue = [[NSDate date] timeIntervalSinceDate:self.timeCalculate];
    //[PFAnalytics trackEvent:EVENT_GAME_CENTER_OPENED dimensions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", [_book.id intValue]], [NSString stringWithFormat:@"%d", _pageNumber], nil] forKeys:[NSArray arrayWithObjects:@"bookId", @"pageNumber", nil]]];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *dimensions = @{
                                 PARAMETER_USER_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_BOOK_ID : _bookId,
                                 PARAMETER_BOOK_PAGE_NO: [NSString stringWithFormat:@"%d",_pageNumber],
                                 PARAMETER_BOOK_TIME_SPEND : [NSString stringWithFormat:@"%f",timeEndValue]
                                 };
    [delegate trackEvent:[READBOOK_PLAYGAMES valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[READBOOK_PLAYGAMES valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [READBOOK_PLAYGAMES valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    [userObject setObject:_bookId forKey:@"bookID"];
    [userObject setObject:[NSNumber numberWithInt:_pageNumber] forKey:@"bookPageNo"];
    [userObject setObject:[NSNumber numberWithFloat:timeEndValue] forKey:@"bookTimeSpend"];
    if(userEmail){
        [userObject setObject:ID forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];
    
    
    NSData *jsonData = [_jsonContent dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];

    if ([[jsonDict objectForKey:NUMBER_OF_GAMES] intValue] == 0) {
        UIAlertView *noGamesAlert = [[UIAlertView alloc] initWithTitle:@"No Games" message:@"Sorry, this story does not have any games in it." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [noGamesAlert show];
    } else {
        MangoGamesListViewController *gamesListViewController = [[MangoGamesListViewController alloc] initWithNibName:@"MangoGamesListViewController" bundle:nil];
        gamesListViewController.jsonString = _jsonContent;
        gamesListViewController.folderLocation = _book.localPathFile;
        
        NSMutableArray *gameNames = [[NSMutableArray alloc] init];
        for (NSDictionary *pageDict in [jsonDict objectForKey:PAGES]) {
            if ([[pageDict objectForKey:TYPE] isEqualToString:GAME]) {
                [gameNames addObject:[pageDict objectForKey:NAME]];
            }
        }
        gamesListViewController.gameNames = gameNames;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:gamesListViewController];
        [navController.navigationBar setHidden:YES];
        
        [self.navigationController presentViewController:navController animated:YES completion:^{
            
        }];
    }
}
- (void)showComingSoonPopover:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    UILabel *comingSoonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 250)];
    comingSoonLabel.text = @"Coming Soon...";
    comingSoonLabel.textAlignment = NSTextAlignmentCenter;
    comingSoonLabel.font = [UIFont boldSystemFontOfSize:24];
    comingSoonLabel.textColor = COLOR_GREY;
    
    UIViewController *comingSoonController = [[UIViewController alloc] init];
    [comingSoonController.view addSubview:comingSoonLabel];
    
    menuPopoverController = [[UIPopoverController alloc] initWithContentViewController:comingSoonController];
    [menuPopoverController setPopoverContentSize:CGSizeMake(250, 250) animated:YES];
    [menuPopoverController setPopoverLayoutMargins:UIEdgeInsetsMake(0, 0, 100, 100)];
    [menuPopoverController presentPopoverFromRect:button.frame inView:button.superview permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}
-(void)dismissPopOver{
    [_pop dismissPopoverAnimated:YES];
}
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [_audioMappingViewController.timer invalidate];
    _audioMappingViewController.timer=nil;
    _audioMappingViewController.player=nil;

    if (_option==0) {
     /* Read By readToMe */
        [self nextButton:nil];
    }else{
    }
    [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_play.png"] forState:UIControlStateNormal];

}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_gameDataDict options:NSJSONReadingAllowFragments error:nil];
    NSString *paramString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"Param: %@", paramString);
    
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"MangoGame.init(%@)", paramString]];
}

-(void)loadPageWithOption:(NSInteger)option{
    [_audioMappingViewController.timer invalidate];
    _audioMappingViewController.timer=nil;
    [_pageView removeFromSuperview];
    _audioMappingViewController = [[AudioMappingViewController alloc] initWithNibName:@"AudioMappingViewController" bundle:nil];
    NSLog(_book.edited ? @"Yes" : @"No");
    if (_book.edited.boolValue) {

        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        MangoBook *book=[delegate.ejdbController.collection fetchObjectWithOID:_book.id];
        _pageView=[MangoEditorViewController readerPage:_pageNumber ForEditedStory:book WithFolderLocation:_book.localPathFile WithAudioMappingViewController:_audioMappingViewController andDelegate:self Option:option];
    } else {
        NSData *jsonData = [_jsonContent dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
        int numberOfGames = [[jsonDict objectForKey:NUMBER_OF_GAMES] intValue];
        NSArray *pagesArray = [jsonDict objectForKey:PAGES];

        if (_pageNumber < [pagesArray count] - numberOfGames) {
            _pageView=[MangoEditorViewController readerPage:_pageNumber ForStory:_jsonContent WithFolderLocation:_book.localPathFile AndAudioMappingViewController:_audioMappingViewController AndDelegate:self Option:option];
        } else {
            
          /*  NSMutableArray *gameNamesArray = [[NSMutableArray alloc] init];
            for (NSDictionary *pageDict in pagesArray) {
                if ([[pageDict objectForKey:TYPE] isEqualToString:GAME]) {
                    [gameNamesArray addObject:[pageDict objectForKey:NAME]];
                }
            }
            
            if ([gameNamesArray count] > 0) {
                NSMutableDictionary * gameViewDict = [MangoEditorViewController readerGamePage:[gameNamesArray objectAtIndex:_pageNumber - ([pagesArray count] - numberOfGames)] ForStory:_jsonContent WithFolderLocation:_book.localPathFile AndOption:option];
                _gameDataDict = [[NSMutableDictionary alloc] initWithDictionary:[gameViewDict objectForKey:@"data"]];
                [_gameDataDict setObject:[NSNumber numberWithBool:YES] forKey:@"from_mobile"];
                UIWebView *gameView = [gameViewDict objectForKey:@"gameView"];
                gameView.delegate = self;
                
                [_pageView addSubview:gameView];
            }*/
        }
    }
    _pageView.frame=self.view.bounds;
    /*for (UIView *subview in [_pageView subviews]) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            subview.frame = self.view.bounds;
        }
    }*/
    [self.viewBase addSubview:_pageView];
    if (option==0) {
        
        [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_pause.png"] forState:UIControlStateNormal];

    }else{
        
        [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_play.png"] forState:UIControlStateNormal];

    }
}

- (void) viewDidDisappear:(BOOL)animated{
    
    float timeEndValue = [[NSDate date] timeIntervalSinceDate:self.timeCalculate];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *dimensions = @{
                                 PARAMETER_USER_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_BOOK_ID : _bookId,
                                 PARAMETER_BOOK_PAGE_NO: [NSString stringWithFormat:@"%d",_pageNumber],
                                 PARAMETER_BOOK_TIME_SPEND : [NSString stringWithFormat:@"%f",timeEndValue]
                                 };
    [delegate trackEvent:[READBOOK_CLOSE valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[READBOOK_CLOSE valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [READBOOK_CLOSE valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    [userObject setObject:_bookId forKey:@"bookID"];
    [userObject setObject:[NSNumber numberWithInt:_pageNumber] forKey:@"bookPageNo"];
    [userObject setObject:[NSNumber numberWithFloat:timeEndValue] forKey:@"bookTimeSpend"];
    if(userEmail){
        [userObject setObject:ID forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];
    
    NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    PFQuery *query1 = [PFQuery queryWithClassName:@"Analytics"];
    [query1 whereKey:@"bookID" equalTo:_bookId];
    if(_loginUserEmail == nil){
        _loginUserEmail = @"nil";
        [query1 whereKey:@"deviceIDValue" equalTo:udid];
    }
    else{
        [query1 whereKey:@"email_ID" equalTo:_loginUserEmail];
    }
    [query1 getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            
            float totalTime = [[object valueForKey:@"readingTime"] floatValue] + timeEndValue;
            
            [object setObject:[NSNumber numberWithFloat:totalTime] forKey:@"readingTime"];
            
            [object setObject:[NSNumber numberWithInt:_pageNumber+1] forKey:@"currentPage"];
            
            [object setObject:[NSNumber numberWithInt:_pageNo]forKey:@"availablePage"];
            
            int totalpagesNo = [[object valueForKey:@"pagesCompleted"] floatValue] + _pageNumber+1;
            [object setObject:[NSNumber numberWithInt:totalpagesNo] forKey:@"pagesCompleted"];
            
            if(_pageNumber+1 >= _pageNo){
                NSLog(@"Book Completed here, update total pageno, completebookcount, totaltime and totalactivities");
                if([[object valueForKey:@"bookCompleted"] integerValue]){
                    [object setObject:[NSNumber numberWithInt:([[object valueForKey:@"timesNumberBookCompleted"] integerValue]+1)] forKey:@"timesNumberBookCompleted"];
                    NSDictionary *dimensions = @{
                                                 PARAMETER_USER_ID : ID,
                                                 PARAMETER_DEVICE: IOS,
                                                 PARAMETER_BOOK_ID : _bookId,
                                                 PARAMETER_BOOK_TIME_SPEND : [NSString stringWithFormat:@"%f",timeEndValue]
                                                 };
                    [delegate trackEvent:[READBOOK_BOOK_COMPLETE valueForKey:@"description"] dimensions:dimensions];
                    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
                    [userObject setObject:[READBOOK_BOOK_COMPLETE valueForKey:@"value"] forKey:@"eventName"];
                    [userObject setObject: [READBOOK_BOOK_COMPLETE valueForKey:@"description"] forKey:@"eventDescription"];
                    [userObject setObject:viewName forKey:@"viewName"];
                    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
                    [userObject setObject:delegate.country forKey:@"deviceCountry"];
                    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
                    [userObject setObject:_bookId forKey:@"bookID"];
                    [userObject setObject:[NSNumber numberWithInt:_pageNumber] forKey:@"bookPageNo"];
                    [userObject setObject:[NSNumber numberWithFloat:timeEndValue] forKey:@"bookTimeSpend"];
                    if(userEmail){
                        [userObject setObject:ID forKey:@"emailID"];
                    }
                    [userObject setObject:IOS forKey:@"device"];
                    [userObject saveInBackground];
                }
                else{
                    [object setObject:[NSNumber numberWithInteger:1] forKey:@"bookCompleted"];
                    [object setObject:[NSNumber numberWithInt:1] forKey:@"timesNumberBookCompleted"];
                }
            }
            else{
               // no need to set as pages are not completed
            }
            
            //[object setObject:@"111111" forKey:@"activityPoints"];
            [object saveInBackground];
        }
        else{
            NSLog(@"object not found here then add object here...");
            PFObject *userObject = [PFObject objectWithClassName:@"Analytics"];
            [userObject setObject:udid forKey:@"deviceIDValue"];
            [userObject setObject:_loginUserEmail forKey:@"email_ID"];
            [userObject setObject:@"Harish" forKey:@"userName"];
            [userObject setObject:_bookId forKey:@"bookID"];
            [userObject setObject:[NSNumber numberWithInt:_pageNumber+1]  forKey:@"currentPage"];
            [userObject setObject:[NSNumber numberWithInt:_pageNo]forKey:@"availablePage"];
            [userObject setObject:_book.title forKey:@"bookTitle"];
            [userObject setObject:_bookGradeLevel forKey:@"gradeLevel"];
            [userObject setObject:[NSNumber numberWithInt:0] forKey:@"activityCount"];
            [userObject setObject:[NSNumber numberWithInt:0] forKey:@"activityPoints"];
            [userObject setObject:[NSNumber numberWithFloat:timeEndValue] forKey:@"readingTime"];
            [userObject setObject:_bookImageURL forKey:@"bookCoverImageURL"];
            [userObject setObject:[NSNumber numberWithInt:_pageNumber+1] forKey:@"pagesCompleted"];
            
            if(_pageNumber+1 >= _pageNo){
                NSLog(@"Book Completed here, update total pageno, completebookcount, totaltime and totalactivities");
                [userObject setObject:[NSNumber numberWithInteger:1] forKey:@"bookCompleted"];
                [userObject setObject:[NSNumber numberWithInt:1] forKey:@"timesNumberBookCompleted"];
                
                NSDictionary *dimensions = @{
                                             PARAMETER_USER_ID : ID,
                                             PARAMETER_DEVICE: IOS,
                                             PARAMETER_BOOK_ID : _bookId,
                                             PARAMETER_BOOK_TIME_SPEND : [NSString stringWithFormat:@"%f",timeEndValue]
                                             };
                [delegate trackEvent:[READBOOK_BOOK_COMPLETE valueForKey:@"description"] dimensions:dimensions];
                PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
                [userObject setObject:[READBOOK_BOOK_COMPLETE valueForKey:@"value"] forKey:@"eventName"];
                [userObject setObject: [READBOOK_BOOK_COMPLETE valueForKey:@"description"] forKey:@"eventDescription"];
                [userObject setObject:viewName forKey:@"viewName"];
                [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
                [userObject setObject:delegate.country forKey:@"deviceCountry"];
                [userObject setObject:delegate.language forKey:@"deviceLanguage"];
                [userObject setObject:_bookId forKey:@"bookID"];
                [userObject setObject:[NSNumber numberWithInt:_pageNumber] forKey:@"bookPageNo"];
                [userObject setObject:[NSNumber numberWithFloat:timeEndValue] forKey:@"bookTimeSpend"];
                if(userEmail){
                    [userObject setObject:ID forKey:@"emailID"];
                }
                [userObject setObject:IOS forKey:@"device"];
                [userObject saveInBackground];
            }
            else{
                [userObject setObject:[NSNumber numberWithInteger:0] forKey:@"bookCompleted"];
                [userObject setObject:[NSNumber numberWithInt:0] forKey:@"timesNumberBookCompleted"];
            }
            
            [userObject saveInBackground];
        }
    }];
}

@end
