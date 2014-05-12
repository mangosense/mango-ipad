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
{
    NSMutableArray *audioMappingViewControllers;
}

@property (nonatomic, strong) NSDate *openingTime;

@property (nonatomic, assign) NSInteger gamePageNumber;
@property (nonatomic, strong) NSMutableDictionary *gameDataDict;
@property (nonatomic, assign) BOOL showButtons;

@end

@implementation PageNewBookTypeViewController
@synthesize menuPopoverController;
@synthesize openingTime;
@synthesize popoverControlleriPhone;

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

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    popoverClass = [WEPopoverController class];
    audioMappingViewControllers = [[NSMutableArray alloc] init];
    viewName = @"Book Read View";
    
    if(!userEmail) {
        if (!userDeviceID) {
            userDeviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.deviceId = userDeviceID;
        }
        ID = userDeviceID;
    }
    else {
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissMyBookViewBackAgainToCover) name:@"DismissBookPageView" object:nil];
    
}

- (void) dismissMyBookViewBackAgainToCover{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)hideAllButtons:(BOOL)hide {
    _showOptionButton.hidden = hide;
    _backButton.hidden = hide;
    _previousPageButton.hidden = hide;
    _nextPageButton.hidden = hide;
    
    [self.popoverControlleriPhone dismissPopoverAnimated:YES];
    self.popoverControlleriPhone = nil;
    
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

    [self.popoverControlleriPhone dismissPopoverAnimated:YES];
    self.popoverControlleriPhone = nil;
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
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            
            [self presentViewController:activity animated:YES completion:nil];
        }
        else{
            _popOverShare=[[UIPopoverController alloc]initWithContentViewController:activity];
            [_popOverShare presentPopoverFromRect:button.frame inView:button.superview permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
        }
        
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
                                                 PARAMETER_BOOL_ISNEW_VERSION :[NSString stringWithFormat:@"NO"]
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
                                                 PARAMETER_BOOL_ISNEW_VERSION :[NSString stringWithFormat:@"YES"]//[NSNumber numberWithBool:YES]
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
    if ([[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"]) {
        UIAlertView *editAlertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"The 'edit' feature is only available in the MangoReader app. Please download the MangoReader app to use this feature!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [editAlertView show];
    } else {
        UIAlertView *editAlertView = [[UIAlertView alloc] initWithTitle:@"Create your own version" message:@"This will create a new version of this book which you can edit. The old version will be saved too. Do you want to continue?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        editAlertView.tag = FORK_TAG;
        [editAlertView show];
    }
}

- (IBAction)changeLanguage:(id)sender {
    //[PFAnalytics trackEvent:EVENT_TRANSLATE_INITIATED dimensions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", [_book.id intValue]], [NSString stringWithFormat:@"%d", _pageNumber], nil] forKeys:[NSArray arrayWithObjects:@"bookId", @"pageNumber", nil]]];
    _languageAvailButton.userInteractionEnabled = NO;
    
    if ([[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"]) {
        UIAlertView *editAlertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"The multiple language feature is only available in the MangoReader app. Please download it to use this feature!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [editAlertView show];
    } else {
        MangoApiController *apiController = [MangoApiController sharedApiController];
        NSString *url;
        url = LANGUAGES_FOR_BOOK;
        NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
        [paramDict setObject:_bookId forKey:@"story_id"];
        [paramDict setObject:IOS forKey:PLATFORM];
        [apiController getListOf:url ForParameters:paramDict withDelegate:self];
    }
}

- (void)reloadViewsWithArray:(NSArray *)dataArray ForType:(NSString *)type {
    
    _languageAvailButton.userInteractionEnabled = YES;
    
    _avilableLanguages = [NSMutableArray arrayWithArray:dataArray];
    NSMutableArray *languageArray = [[NSMutableArray alloc] init];
    
    LanguageChoiceViewController *choiceViewController=[[LanguageChoiceViewController alloc]initWithStyle:UITableViewStyleGrouped];
    choiceViewController.delegate=self;
    
//    _pop=[[UIPopoverController alloc]initWithContentViewController:choiceViewController];
//    CGSize size=_pop.popoverContentSize;
//    size.height=size.height-300;
//    _pop.popoverContentSize=size;
    
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
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            if (!self.popoverControlleriPhone) {
                
                self.popoverControlleriPhone = [[popoverClass alloc] initWithContentViewController:choiceViewController] ;
                self.popoverControlleriPhone.delegate = self;
                self.popoverControlleriPhone.passthroughViews = [NSArray arrayWithObject:self.view];
                
                [self.popoverControlleriPhone presentPopoverFromRect:_languageAvailButton.frame
                                                              inView:self.rightView
                                            permittedArrowDirections:UIPopoverArrowDirectionRight
                                                            animated:YES];
                
                
            } else {
                [self.popoverControlleriPhone dismissPopoverAnimated:YES];
                self.popoverControlleriPhone = nil;
            }
        }
        
        else{
            _pop=[[UIPopoverController alloc]initWithContentViewController:choiceViewController];
            CGSize size=_pop.popoverContentSize;
            size.height=size.height-300;
            size.width = 200;
            _pop.popoverContentSize=size;
            
            [_pop presentPopoverFromRect:_languageAvailButton.frame inView:self.rightView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }
    }
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
        
        LastPageViewController *lastPage;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            lastPage = [[LastPageViewController alloc] initWithNibName:@"LastPageViewController_iPhone" bundle:nil WithId:[_book valueForKey:@"id"]];
        }
        else{
            lastPage = [[LastPageViewController alloc] initWithNibName:@"LastPageViewController" bundle:nil WithId:[_book valueForKey:@"id"]];
        }
        
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
        MangoGamesListViewController *gamesListViewController;
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            
            gamesListViewController = [[MangoGamesListViewController alloc] initWithNibName:@"MangoGamesListViewController_iPhone" bundle:nil];
        }
        else{
            gamesListViewController = [[MangoGamesListViewController alloc] initWithNibName:@"MangoGamesListViewController" bundle:nil];
        }
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
    
    [self.popoverControlleriPhone dismissPopoverAnimated:YES];
    self.popoverControlleriPhone = nil;
        
     
}




-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
//    [_audioMappingViewController.timer invalidate];
//    _audioMappingViewController.timer=nil;
//    _audioMappingViewController.player=nil;
//
//    if (_option==0) {
//     /* Read By readToMe */
//        [self nextButton:nil];
//    }else{
//    }
//
    AudioMappingViewController *vc = nil;
    for (AudioMappingViewController *viewController in audioMappingViewControllers) {
        if ([viewController.player isEqual:player]) {
            vc = viewController;
            break;
        }
    }
    int index = [audioMappingViewControllers indexOfObject:vc];
    NSString *audioText = vc.mangoTextField.text;
    [vc.mangoTextField highlightWordAtIndex:0 AfterLength:[audioText length]];
    [vc.timer invalidate];
    vc.timer=nil;
    vc.player=nil;
    index++;
    if (index < [audioMappingViewControllers count]) {
        AudioMappingViewController *audioMappingViewController = [audioMappingViewControllers objectAtIndex:index];
        NSURL *audioURL = audioMappingViewController.audioUrl;
        NSData *audioData = [NSData dataWithContentsOfURL:audioURL];
        [audioMappingViewController playAudioForReaderWithData:audioData
                                                   AndDelegate:self];
    } else if (_option == 0 && [vc isEqual:[audioMappingViewControllers lastObject]]) {
        [self nextButton:nil];
    }
    [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_play.png"] forState:UIControlStateNormal];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_gameDataDict options:NSJSONReadingAllowFragments error:nil];
    NSString *paramString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"Param: %@", paramString);
    
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"MangoGame.init(%@)", paramString]];
}



-(BOOL) isPlaying
{
    for (AudioMappingViewController *vc in audioMappingViewControllers) {
        if ([vc.player isPlaying]) {
            return YES;
        }
    }
    return NO;
}


- (UIView *)readerPage:(int)pageNumber ForStory:(NSString *)jsonString WithFolderLocation:(NSString *)folderLocation AndDelegate:(id<AVAudioPlayerDelegate>)delegate Option:(int)readingOption {
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    
    NSArray *readerPagesArray = [[NSMutableArray alloc] initWithArray:[jsonDict objectForKey:PAGES]];
    
    NSDictionary *pageDict;
    NSPredicate *pagePredicate = [NSPredicate predicateWithFormat:@"name == %@",[NSString stringWithFormat:@"%d", pageNumber]];
    
    NSArray *results = [readerPagesArray filteredArrayUsingPredicate:pagePredicate];
    if ([results count]) {
        pageDict = [results objectAtIndex:0];
    }
    
    UIView *pageView;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        pageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 568, 320)];
    } else {
        pageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    }
    NSArray *layersArray = [pageDict objectForKey:LAYERS];
    NSMutableArray *imageLayers = [[NSMutableArray alloc] init];
    NSMutableArray *textLayers = [[NSMutableArray alloc] init];
    NSMutableArray *audioLayers = [[NSMutableArray alloc] init];
    
    NSPredicate *imagePredicate = [NSPredicate predicateWithFormat:@"type == 'image'"];
    [imageLayers addObjectsFromArray:[layersArray filteredArrayUsingPredicate:imagePredicate]];
    NSPredicate *textPredicate = [NSPredicate predicateWithFormat:@"type == 'text'"];
    [textLayers addObjectsFromArray:[layersArray filteredArrayUsingPredicate:textPredicate]];
    
    NSPredicate *audioPredicate = [NSPredicate predicateWithFormat:@"type == 'audio'"];
    [audioLayers addObjectsFromArray:[layersArray filteredArrayUsingPredicate:audioPredicate]];
    
    for (NSDictionary *imageDict in imageLayers) {
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:pageView.bounds];
        [pageView addSubview:backgroundImageView];
        [backgroundImageView setImage:[UIImage imageWithContentsOfFile:[folderLocation stringByAppendingFormat:@"/%@", [imageDict objectForKey:ASSET_URL]]]];
        if ([[imageDict objectForKey:ALIGNMENT] isEqualToString:LEFT_ALIGN]) {
            [backgroundImageView setFrame:CGRectMake(0, 0, pageView.frame.size.width*0.65, 768)];
        } else if ([[imageDict objectForKey:ALIGNMENT] isEqualToString:RIGHT_ALIGN]) {
            [backgroundImageView setFrame:CGRectMake(pageView.frame.size.width*0.35, 0, pageView.frame.size.width*0.65, 768)];
        } else if ([[imageDict objectForKey:ALIGNMENT] isEqualToString:TOP_ALIGN]) {
            [backgroundImageView setFrame:CGRectMake(0, 0, 1024, pageView.frame.size.height*0.65)];
        } else if ([[imageDict objectForKey:ALIGNMENT] isEqualToString:BOTTOM_ALIGN]) {
            [backgroundImageView setFrame:CGRectMake(0, pageView.frame.size.height*0.35, 1024, pageView.frame.size.height)];
        }
    }
    [audioMappingViewControllers removeAllObjects];
    for (NSDictionary *textDict in textLayers) {
        AudioMappingViewController *audioMappingViewcontroller = [[AudioMappingViewController alloc] initWithNibName:@"AudioMappingViewController" bundle:nil];
        [audioMappingViewControllers addObject:audioMappingViewcontroller];
        audioMappingViewcontroller.audioMappingDelegate = delegate;
        audioMappingViewcontroller.customView.textFont = [UIFont fontWithName:@"Verdana" size:pageView.frame.size.height * 25.0f/768.0f];
        [audioMappingViewcontroller.customView setBackgroundColor:[UIColor clearColor]];
        [audioMappingViewcontroller.view setExclusiveTouch:YES];
        [audioMappingViewcontroller.customView setNeedsDisplay];
        
        NSString *textOnPage = [textDict objectForKey:TEXT];
        CGRect textFrame = CGRectMake(100, 100, 600, 400);
        
        if ([[textDict allKeys] containsObject:TEXT_FRAME]) {
            if ([[[textDict objectForKey:TEXT_FRAME] allKeys] containsObject:LEFT_RATIO] && [[[textDict objectForKey:TEXT_FRAME] allKeys] containsObject:TOP_RATIO] && [[[textDict objectForKey:TEXT_FRAME] allKeys] containsObject:TEXT_SIZE_WIDTH] && [[[textDict objectForKey:TEXT_FRAME] allKeys] containsObject:TEXT_SIZE_HEIGHT]) {
                
                CGFloat xOrigin = 0;
                if (![[[textDict objectForKey:TEXT_FRAME] objectForKey:LEFT_RATIO] isEqual:[NSNull null]]) {
                    xOrigin = pageView.frame.size.width/MAX([[[textDict objectForKey:TEXT_FRAME] objectForKey:LEFT_RATIO] floatValue], 1);
                    if (xOrigin >= pageView.frame.size.width || xOrigin < 0) {
                        xOrigin = 0;
                    }
                }
                
                
                CGFloat yOrigin = 0;
                if (![[[textDict objectForKey:TEXT_FRAME] objectForKey:TOP_RATIO] isEqual:[NSNull null]]) {
                    yOrigin = pageView.frame.size.height/MAX([[[textDict objectForKey:TEXT_FRAME] objectForKey:TOP_RATIO] floatValue], 1);
                    if (yOrigin >= pageView.frame.size.height || yOrigin < 0) {
                        yOrigin = 0;
                    }
                }
                textFrame = CGRectMake(xOrigin, yOrigin, pageView.frame.size.width*[[[textDict objectForKey:TEXT_FRAME] objectForKey:TEXT_SIZE_WIDTH] floatValue]/1024.0f, pageView.frame.size.height*[[[textDict objectForKey:TEXT_FRAME] objectForKey:TEXT_SIZE_HEIGHT] floatValue]/768.0f);
                
                audioMappingViewcontroller.customView.frame = textFrame;
            }
        }
        
        if ([[textDict objectForKey:IMAGE_ALIGNMENT] isEqualToString:LEFT_ALIGN]) {
            textFrame = CGRectMake(pageView.frame.size.width*0.65, 0, pageView.frame.size.width*0.35, pageView.frame.size.height);
        } else if ([[textDict objectForKey:IMAGE_ALIGNMENT] isEqualToString:RIGHT_ALIGN]) {
            textFrame = CGRectMake(0, 0, pageView.frame.size.width*0.35, pageView.frame.size.height);
        } else if ([[textDict objectForKey:IMAGE_ALIGNMENT] isEqualToString:TOP_ALIGN]) {
            textFrame = CGRectMake(0, pageView.frame.size.height*0.65, pageView.frame.size.width, pageView.frame.size.height*0.35);
        } else if ([[textDict objectForKey:IMAGE_ALIGNMENT] isEqualToString:BOTTOM_ALIGN]) {
            textFrame = CGRectMake(0, 0, pageView.frame.size.width, pageView.frame.size.height*0.35);
        }
        [pageView addSubview:audioMappingViewcontroller.view];
        [audioMappingViewcontroller.view setHidden:YES];
        [audioMappingViewcontroller.customView setBackgroundColor:[UIColor clearColor]];
        [audioMappingViewcontroller.view setExclusiveTouch:YES];
        
        audioMappingViewcontroller.mangoTextField.text = textOnPage;
        UIFont *font = [UIFont fontWithName:@"Verdana" size:pageView.frame.size.height*25.0f/768.0f];
        NSString *fontFamily = [[textDict objectForKey:@"style"] objectForKey:@"font-family"];
        NSString *fontStyle = [[textDict objectForKey:@"style"] objectForKey:@"font-style"];
        NSString *fontWeight = [[textDict objectForKey:@"style"] objectForKey:@"font-weight"];
        if (![fontFamily isKindOfClass:[NSNull class]]) {
            if ([fontFamily length]) {
                //here will be custom font set
                NSLog(@"fontFamily %@",fontFamily);
//                NSArray *components = [fontFamily componentsSeparatedByString:@","];
//                NSString *familyName = [components objectAtIndex:1];
//                familyName = [familyName substringFromIndex:1];
//                NSArray *fonts = [UIFont fontNamesForFamilyName:familyName];
//                
                NSString *fontSize = [[textDict objectForKey:@"style"] objectForKey:@"font-size"];
                fontSize = [fontSize stringByReplacingOccurrencesOfString:@"px"
                                                               withString:@""];
                if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
                    fontSize = @"12";
                }
                NSString *trimmedFamily = [fontFamily stringByTrimmingCharactersInSet:
                                           [NSCharacterSet whitespaceCharacterSet]];
                
                // Find the target family to be used
                NSString *fFamily;
                if ([trimmedFamily hasPrefix:@"verdana"]) {
                    fFamily = @"Verdana";
                } else if ([trimmedFamily  hasPrefix:@"Comic"]) {
                     fFamily = @"ComicSansMS";
                }
                else if ([trimmedFamily  hasPrefix:@"mono"]) {
                    fFamily = @"FreeMono";
                }
                else if ([trimmedFamily  hasPrefix:@"Tahoma"]) {
                    fFamily = @"Tahoma";
                }
                else if ([trimmedFamily  hasPrefix:@"Times"]) {
                    fFamily = @"TimesNewRomanPS";
                }
                else if ([trimmedFamily hasPrefix:@"Helvetica"]){
                    fFamily = @"HelveticaNeue";
                }

                
                NSString *trimmedStyle = [fontStyle stringByTrimmingCharactersInSet:
                                         [NSCharacterSet whitespaceCharacterSet]];
                // Find the style of the family
                NSString *fStyle;
                if ([fontWeight hasPrefix:@"bold"] && [fontStyle isKindOfClass:NULL]){
                    if([fFamily isEqualToString:@"TimesNewRomanPS"])
                        fStyle = @"-BoldMT";
                    else if([fFamily isEqualToString:@"mono"])
                        fStyle = @"Bold";
                    else
                        fStyle = @"-Bold";
                    
                }else if ([fontWeight hasPrefix:@"bold"] && [fontStyle hasPrefix:@"italic"]) {
                    if ([fFamily isEqualToString:@"Tahoma"])
                         fStyle = @"-BoldFauxItalic";
                    else if ([fFamily isEqualToString:@"TimesNewRomanPS"])
                          fStyle = @"-BoldItalicMT";
                    else if([fFamily isEqualToString:@"mono"])
                        fStyle = @"BoldOblique";
                    else if([fFamily isEqualToString:@"Helvetica"])
                        fStyle = @"-BoldOblique";
                    else
                        fStyle = @"-BoldItalic";
                    
                }else if ([fontStyle hasPrefix:@"bold"] && [fontWeight isKindOfClass:NULL]){
                    if ([fFamily isEqualToString:@"Tahoma"])
                        fStyle = @"-FauxItalic";
                    else if ([fFamily isEqualToString:@"TimesNewRomanPS"])
                        fStyle = @"-ItalicMT";
                    else if([fFamily isEqualToString:@"mono"])
                        fStyle = @"Oblique";
                    else if([fFamily isEqualToString:@"Helvetica"])
                        fStyle = @"-Oblique";
                    else
                        fStyle = @"-Italic";
                    
                }else {
                    fStyle=@"";
                }
                
                font = [UIFont fontWithName:[fFamily stringByAppendingString:fStyle]
                                       size:[fontSize floatValue]];
            }
        }
        audioMappingViewcontroller.mangoTextField.font = font;

        audioMappingViewcontroller.mangoTextField.frame = textFrame;
        audioMappingViewcontroller.mangoTextField.textAlignment = NSTextAlignmentCenter;
        
        if ([[textDict objectForKey:TEXT_FRAME] objectForKey:@"color"] && ![[[textDict objectForKey:TEXT_FRAME] objectForKey:@"color"] isEqual:[NSNull null]]) {
            
            UIColor *color = nil;
            NSString *colorString = [[textDict objectForKey:TEXT_FRAME] objectForKey:@"color"];
            if (![colorString isKindOfClass:[NSNull class]]) {
                if ([colorString hasPrefix:@"#"]) {
                    color = [AePubReaderAppDelegate colorFromHexString:[[textDict objectForKey:TEXT_FRAME] objectForKey:@"color"]];
                } else {
                    colorString = [colorString stringByReplacingOccurrencesOfString:@"rgb("
                                                                         withString:@""];
                    colorString = [colorString substringToIndex:[colorString length] - 1];
                    NSArray *components = [colorString componentsSeparatedByString:@","];
                    
                    color = [UIColor colorWithRed:[[components objectAtIndex:0] floatValue]/255.f
                                            green:[[components objectAtIndex:1] floatValue]/255.f
                                             blue:[[components objectAtIndex:2] floatValue]/255.f
                                            alpha:1.f];
                }
            } else {
                color = [UIColor blackColor];
            }
            audioMappingViewcontroller.mangoTextField.textColor = color;
        } else {
            audioMappingViewcontroller.mangoTextField.textColor = [UIColor blackColor];
        }
        [pageView addSubview:audioMappingViewcontroller.mangoTextField];
        audioMappingViewcontroller.textForMapping = textOnPage;
        
        NSString *audio_id = [textDict objectForKey:@"audio_id"];
        if ([audio_id isKindOfClass:[NSNull class]]) {
            NSLog(@"Text Does not have an audio");
        } else {
            NSPredicate *audioPredicate = [NSPredicate predicateWithFormat:@"id == %@",audio_id];
            NSArray *relatedAudios = [audioLayers filteredArrayUsingPredicate:audioPredicate];
            if ([relatedAudios count]) {
                NSDictionary *audioLayer = [relatedAudios objectAtIndex:0];
                NSString *filePath = [folderLocation stringByAppendingFormat:@"/%@", [audioLayer objectForKey:ASSET_URL]];
                audioMappingViewcontroller.audioUrl = [NSURL fileURLWithPath:filePath];
                NSData *audioData = [NSData dataWithContentsOfURL:audioMappingViewcontroller.audioUrl];
                
                NSArray *wordMapDict=[audioLayer objectForKey:WORDMAP];
                NSMutableArray *wordMap=[[NSMutableArray alloc]init];
                if (![wordMapDict isEqual:[NSNull null]]) {
                    for (NSDictionary *temp in wordMapDict ) {
                        NSString *word=temp[@"word"];
                        [wordMap addObject:word];
                    }
                }
                wordMapDict=[[NSArray alloc]initWithArray:wordMap];/*list of words created*/
                if (![[audioLayer objectForKey:CUES] isEqual:[NSNull null]]) {
                    NSArray *cues=[audioLayer objectForKey:CUES];
                    audioMappingViewcontroller.cues=[[NSMutableArray alloc]initWithArray:cues];
                }
                audioMappingViewcontroller.customView.text=wordMapDict;
                if ([UIDevice currentDevice].systemVersion.integerValue<6) {
                    audioMappingViewcontroller.customView.space=[@" " sizeWithFont:audioMappingViewcontroller.customView.textFont];
                } else {
                    audioMappingViewcontroller.customView.space=   audioMappingViewcontroller.mangoTextField.frame.size;
                }
                
                audioMappingViewcontroller.index=0;
                audioMappingViewcontroller.customView.backgroundColor = [UIColor clearColor];
                if (readingOption == 0) {
                    NSNumber *order = [textDict objectForKey:@"order"];
                    if ([order isEqualToNumber:[NSNumber numberWithInt:0]] ||
                        [order isEqualToNumber:[NSNumber numberWithInt:1]]) {
                        if (![self isPlaying]) {
                            [audioMappingViewcontroller playAudioForReaderWithData:audioData AndDelegate:delegate];
                            _audioMappingViewController = audioMappingViewcontroller;
                        }
                    }
                }
                if ([audioLayer objectForKey:@"highlight"] && ![[audioLayer objectForKey:@"highlight"] isEqual:[NSNull null]]) {
                    audioMappingViewcontroller.mangoTextField.highlightColor = [AePubReaderAppDelegate colorFromRgbString:[audioLayer objectForKey:@"highlight"]];
                } else {
                    audioMappingViewcontroller.mangoTextField.highlightColor = [UIColor yellowColor];
                }
                NSLog(@"MangoTxt Frame: %@", NSStringFromCGRect(audioMappingViewcontroller.mangoTextField.frame));
            }
        }
    }
    if ([[pageView subviews] count] > 0) {
        return pageView;
    }
    return nil;
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
            _pageView=[self readerPage:_pageNumber ForStory:_jsonContent WithFolderLocation:_book.localPathFile AndDelegate:self Option:option];

//            _pageView=[MangoEditorViewController readerPage:_pageNumber ForStory:_jsonContent WithFolderLocation:_book.localPathFile AndAudioMappingViewController:_audioMappingViewController AndDelegate:self Option:option];
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
    NSString *bookGrade;
    
    if(!_bookGradeLevel){
        bookGrade = @"Not available";
    }
    else{
        bookGrade = _bookGradeLevel;
    }
    
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
            [userObject setObject:ID forKey:@"email_ID"];
           // [userObject setObject:@"Harish" forKey:@"userName"];
            [userObject setObject:_bookId forKey:@"bookID"];
            [userObject setObject:[NSNumber numberWithInt:_pageNumber+1]  forKey:@"currentPage"];
            [userObject setObject:[NSNumber numberWithInt:_pageNo]forKey:@"availablePage"];
            [userObject setObject:_book.title forKey:@"bookTitle"];
            [userObject setObject:bookGrade forKey:@"gradeLevel"];
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
