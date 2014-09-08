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

#import "GADInterstitial.h"
#import "GADInterstitialDelegate.h"
#import "MangoStoreViewController.h"
#import "EmailSubscriptionLinkViewController.h"

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
    newAudioRate = 1.0f;
    currentPage = @"reading";
    popoverClass = [WEPopoverController class];
    audioMappingViewControllers = [[NSMutableArray alloc] init];
    pageVisited = [[NSMutableString alloc]init];
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
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    validUserSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
    storyAsAppFilePath = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
    
    if (!validUserSubscription && storyAsAppFilePath){
        /*self.interstitial = [[GADInterstitial alloc] init];
        self.interstitial.delegate = self;
        self.interstitial.adUnitID = @"ca-app-pub-2797581562576419/2448803689";
        [self.interstitial loadRequest:[GADRequest request]];*/
        
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            
            [_shareButton setBackgroundImage:[UIImage imageNamed:@"icon_subscribe.png"] forState:UIControlStateNormal];
            _shareButton.tag = 2;
        }
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
    
    _showButtons = NO;
    
    _loginUserName = @"User";
    
    [self hideAllButtons:YES];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    tapGesture.delegate = (id <UIGestureRecognizerDelegate>)self;
    [self.view addGestureRecognizer:tapGesture];
    [_switchAudioControl setOnImage:[UIImage imageNamed:@"next-button_new.png"]];
    [_switchAudioControl setOffImage:[UIImage imageNamed:@"next-button_new.png"]];

    [self setupSwipeGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissMyBookViewBackAgainToCover) name:@"DismissBookPageView" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigateToLandPage) name:@"DismissBook" object:nil];
    
}

- (void) viewDidAppear:(BOOL)animated{
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int subscriptionSuccess = [[prefs valueForKey:@"SubscriptionSuccess"]integerValue];
    if(subscriptionSuccess && !userEmail){
        [prefs setBool:NO forKey:@"SubscriptionSuccess"];
        EmailSubscriptionLinkViewController *emailLinkSubscriptionView;
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            emailLinkSubscriptionView = [[EmailSubscriptionLinkViewController alloc] initWithNibName:@"EmailSubscriptionLinkViewController_iPhone" bundle:nil];
        }
        else{
            emailLinkSubscriptionView = [[EmailSubscriptionLinkViewController alloc] initWithNibName:@"EmailSubscriptionLinkViewController" bundle:nil];
        }
        emailLinkSubscriptionView.modalPresentationStyle = UIModalPresentationFormSheet;
        emailLinkSubscriptionView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:emailLinkSubscriptionView animated:YES completion:nil];
        emailLinkSubscriptionView.view.superview.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            emailLinkSubscriptionView.view.superview.bounds = CGRectMake(0, 0, 440, 300);
        }
        else{
            emailLinkSubscriptionView.view.autoresizesSubviews = NO;
            emailLinkSubscriptionView.view.layer.cornerRadius = 10;
            emailLinkSubscriptionView.view.layer.masksToBounds = YES;
            emailLinkSubscriptionView.view.superview.bounds = CGRectMake(0, 0, 700, 530);
        }
    }
    
    int moveToSignIn = [[prefs valueForKey:@"SubscriptionEmailToSignIn"] integerValue];
    if(moveToSignIn){
        [prefs setBool:NO forKey:@"SubscriptionEmailToSignIn"];
        LoginNewViewController *loginView;
        if([[UIDevice currentDevice] userInterfaceIdiom]== UIUserInterfaceIdiomPhone){
            loginView = [[LoginNewViewController alloc] initWithNibName:@"LoginNewViewController_iPhone" bundle:nil];
        }
        else{
            loginView = [[LoginNewViewController alloc] initWithNibName:@"LoginNewViewController" bundle:nil];
        }
        [self.navigationController pushViewController:loginView animated:YES];
    }
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
    [dimensions setObject:@"reading" forKey:PARAMETER_ACTION];
    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
    [dimensions setObject:@"reading screen open" forKey:PARAMETER_EVENT_DESCRIPTION];
    [dimensions setObject:_book.id forKey:PARAMETER_BOOK_ID];
    [dimensions setObject:_book.title forKey:PARAMETER_BOOK_TITLE];
    [dimensions setObject:bookReadMode forKey:PARAMETER_BOOK_READ_MODE];
    if(userEmail){
        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
    }
    [delegate trackEventAnalytic:@"reading" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"reading"];
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    NSLog(@"Ad is ready to display");
}

- (void) interstitialDidDismissScreen:(GADInterstitial *)ad{
    
    GADRequest *request = [GADRequest request];
    _interstitial = nil;
    self.interstitial = [[GADInterstitial alloc] init];
    self.interstitial.delegate = self;
    self.interstitial.adUnitID = @"ca-app-pub-2797581562576419/2448803689";
    [self.interstitial loadRequest:request];
    [_audioMappingViewController.player play];
}

- (IBAction)showInterstitial:(id)sender {
    
    [_audioMappingViewController.player pause];
    
    [self.interstitial presentFromRootViewController:self];
    
    /*UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(480, 0, 600, 40)];;
    button.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [tapRecognizer setNumberOfTapsRequired:1];
    [button addGestureRecognizer:tapRecognizer];
    
    CALayer *btnLayer = [button layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:12.0f];
    [btnLayer setBorderWidth:3.0f];
    [btnLayer setBorderColor:[UIColor brownColor].CGColor];
    [button setBackgroundColor:[UIColor redColor]]*/
    
    CATextLayer *label = [[CATextLayer alloc] init];
    [label setFont:@"Helvetica-Bold"];
    [label setString:@"Subscribe to access unlimited stories without advertisements"];
    [label setAlignmentMode:kCAAlignmentCenter];
    [label setForegroundColor:[[UIColor blackColor] CGColor]];
    
    CALayer *graphic = nil;
    graphic = [CALayer layer];
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        
        [label setFontSize:12];
        [label setFrame:CGRectMake(110, 6, 1600, 40)];
        graphic.bounds = CGRectMake(30, 0, 1274, 24);
        graphic.position = CGPointMake(40, 309);
    }
    else{
        [label setFontSize:18];
        [label setFrame:CGRectMake(480, 8, 600, 40)];
        graphic.bounds = CGRectMake(40, 0, 1274, 40);
        graphic.position = CGPointMake(400, 750);
    }
    graphic.backgroundColor = [UIColor whiteColor].CGColor;
    graphic.opacity = 0.7f;
    [graphic addSublayer:label];
    //[graphic addSublayer:btnLayer];
    
   
    [self.presentedViewController.view.layer addSublayer:graphic];
}


- (GADRequest *)request {
    GADRequest *request = [GADRequest request];
    request.testDevices = @[GAD_SIMULATOR_ID, @"cb070a3553b00abe94caf7932cf48233"];

    return request;
}

- (void) dismissMyBookViewBackAgainToCover{
    
    refreshCover = true;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) navigateToLandPage{
    
    LandPageChoiceViewController *myViewController;
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        
        myViewController = [[LandPageChoiceViewController alloc] initWithNibName:@"LandPageChoiceViewController_iPhone" bundle:nil];
    }
    else{
        myViewController = [[LandPageChoiceViewController alloc] initWithNibName:@"LandPageChoiceViewController" bundle:nil];
    }
    /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:@"Create, read and customize stories and turn reading into your child's favourite activity" delegate:self cancelButtonTitle:@"Start now" otherButtonTitles:nil, nil];
    [alert show];*/
    myViewController.successSubscription = 1;
    [self.navigationController pushViewController:myViewController animated:YES];
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
    
   /* CGPoint location = [gesture locationInView:self.audioMappingViewController.mangoTextField];
    NSLayoutManager *layoutManager = self.audioMappingViewController.mangoTextField.layoutManager;
    UITextPosition *tapPos = [self.audioMappingViewController.mangoTextField closestPositionToPoint:location];
    
    NSUInteger characterIndex;
    characterIndex = [layoutManager characterIndexForPoint:location
                                           inTextContainer:self.audioMappingViewController.mangoTextField.textContainer
                  fractionOfDistanceBetweenInsertionPoints:NULL];
    
    UITextRange * wr = [self.audioMappingViewController.mangoTextField.tokenizer rangeEnclosingPosition:tapPos withGranularity:UITextGranularityWord inDirection:UITextLayoutDirectionRight];
    
    NSRange searchRange = NSMakeRange(0 , characterIndex);
    NSString *textInRange = [self.audioMappingViewController.mangoTextField.text substringWithRange:searchRange];
    
    NSLog(@"WORD: %@",[self.audioMappingViewController.mangoTextField textInRange:wr]);
    NSString *selectedText = [self.audioMappingViewController.mangoTextField textInRange:wr];
    NSLog(@"selectedText: %@" , selectedText);
    if(selectedText.length<1){
        return;
    }
    NSMutableArray *word = [NSMutableArray arrayWithArray:[self.audioMappingViewController.mangoTextField.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    NSMutableArray *words = [NSMutableArray arrayWithArray:[textInRange componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    //[words removeObject:@""];
    //[word removeObject:@""];
    //int times = [[textInRange componentsSeparatedByString:@"\n"] count]-1;
    int selectedWordIndex;
    selectedWordIndex = [words count]-1;*/
   /* if(times){
        selectedWordIndex = [self getIndexOfWordUsingCharindex:self.audioMappingViewController.mangoTextField.text atIndex:characterIndex]+times-1;
    }
    else{
        selectedWordIndex = [self getIndexOfWordUsingCharindex:self.audioMappingViewController.mangoTextField.text atIndex:characterIndex];
    }*/
  /*  if(selectedWordIndex >= word.count){
        return;
    }
    NSArray *subarray = [words subarrayWithRange:NSMakeRange(0, selectedWordIndex)];
    NSLog(@"selected string %@", textInRange);
    NSLog(@"Selected word index -- %d",selectedWordIndex);
    NSString *subString = [subarray componentsJoinedByString:@" "];
    
    [self.audioMappingViewController.mangoTextField highlightWordAtIndex:selectedWordIndex AfterLength:[subString length]];
    [_audioMappingViewController.timer invalidate];
    [self audioPlayerStopAfterSelection:selectedWordIndex length:[subString length]];*/
    
}

- (int) getIndexOfWordUsingCharindex:(NSString*)textViewString atIndex:(int)charindexval{
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@" " options:NSRegularExpressionCaseInsensitive error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:textViewString options:0 range:NSMakeRange(0, charindexval)];
    return numberOfMatches;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ShowOptions:(id)sender {
    
    _rightView.hidden=NO;
    UIButton *button=(UIButton *)sender;
    button.hidden=YES;
}

- (IBAction)BackButton:(id)sender {
    //AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    [self.navigationController popViewControllerAnimated:YES];
    //[self.navigationController popToViewController:delegate.pageViewController animated:YES];
    
}
//-(void)viewWillDisappear:(BOOL)animated{
    /*[_audioMappingViewController.timer invalidate];
    [_audioMappingViewController.player stop];
    _audioMappingViewController.player = nil;
    */
    
//}
- (IBAction)closeButton:(id)sender {
    _rightView.hidden=YES;
    _showOptionButton.hidden=NO;

    [self.popoverControlleriPhone dismissPopoverAnimated:YES];
    self.popoverControlleriPhone = nil;
}


- (IBAction)displyParentalControl:(id)sender{
    
    if(_shareButton.tag == 2){
        
        MangoSubscriptionViewController *subscriptionViewController;
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            
            subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController_iPhone" bundle:nil];
        }
        subscriptionViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:subscriptionViewController animated:YES completion:nil];
        
    }
    else{
    _settingsProbSupportView.hidden = NO;
    _settingsProbView.hidden = NO;
    }
    
}

- (IBAction)allowParentToShareOrNot:(id)sender{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *yearString = [formatter stringFromDate:[NSDate date]];
    int parentalControlAge = ([yearString integerValue] - [_textQuesSolution.text integerValue]);
    [_textQuesSolution resignFirstResponder];
    if((parentalControlAge >= 13) && (parentalControlAge <=100)){
        //show subscription plans
        
            [self shareButton:0];

    }
    else{
        //close subscription plan
    }
    _settingsProbSupportView.hidden = YES;
    _settingsProbView.hidden = YES;
    _textQuesSolution.text = @"";
}

- (IBAction)closeParentalControl:(id)sender{
    
    _settingsProbSupportView.hidden = YES;
    _settingsProbView.hidden = YES;
}



- (IBAction)shareButton:(id)sender {
   // [PFAnalytics trackEvent:EVENT_BOOK_SHARED dimensions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", [_book.id intValue]], [NSString stringWithFormat:@"%d", _pageNumber], nil] forKeys:[NSArray arrayWithObjects:@"bookId", @"pageNumber", nil]]];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
    [dimensions setObject:@"share_btn_click" forKey:PARAMETER_ACTION];
    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
    [dimensions setObject:[_book valueForKey:@"bookId"] forKey:PARAMETER_BOOK_ID];
    [dimensions setObject:@"Share button click" forKey:PARAMETER_EVENT_DESCRIPTION];
    if(userEmail){
        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
    }
    [delegate trackEventAnalytic:@"share_btn_click" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"share_btn_click"];
    
    //UIButton *button=(UIButton *)sender;
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
            [_popOverShare presentPopoverFromRect:_shareButton.frame inView:_shareButton.superview permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
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
                    
                    /*NSDictionary *dimensions = @{
                                                 PARAMETER_USER_EMAIL_ID : ID,
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
                    [userObject saveInBackground];*/
                    
                    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
                    [dimensions setObject:@"book_fork_click" forKey:PARAMETER_ACTION];
                    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
                    [dimensions setObject:_book.title forKey:PARAMETER_BOOK_TITLE];
                    [dimensions setObject:_book.id forKey:PARAMETER_BOOK_ID];
                    [dimensions setObject:@"Book fork click" forKey:PARAMETER_EVENT_DESCRIPTION];
                    [dimensions setObject:@"FALSE" forKey:PARAMETER_PASS];
                    if(userEmail){
                        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
                    }
                    [delegate trackEventAnalytic:@"book_fork_click" dimensions:dimensions];
                    [delegate eventAnalyticsDataBrowser:dimensions];
                    [delegate trackMixpanelEvents:dimensions eventName:@"book_fork_click"];
                }
                    break;
                    
                case 1: {
                   // [PFAnalytics trackEvent:EVENT_BOOK_FORKED dimensions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", [_book.id intValue]], [NSString stringWithFormat:@"%d", _pageNumber], nil] forKeys:[NSArray arrayWithObjects:@"bookId", @"pageNumber", nil]]];
                    
                    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
                    [dimensions setObject:@"book_fork_click" forKey:PARAMETER_ACTION];
                    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
                    [dimensions setObject:_book.title forKey:PARAMETER_BOOK_TITLE];
                    [dimensions setObject:_book.id forKey:PARAMETER_BOOK_ID];
                    [dimensions setObject:@"Book fork click" forKey:PARAMETER_EVENT_DESCRIPTION];
                    [dimensions setObject:@"TRUE" forKey:PARAMETER_PASS];
                    if(userEmail){
                        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
                    }
                    [delegate trackEventAnalytic:@"book_fork_click" dimensions:dimensions];
                    [delegate eventAnalyticsDataBrowser:dimensions];
                    [delegate trackMixpanelEvents:dimensions eventName:@"book_fork_click"];
                    
                    MangoEditorViewController *mangoEditorViewController= [[MangoEditorViewController alloc] initWithNibName:@"MangoEditorViewController" bundle:nil];
                    mangoEditorViewController.isBookFork = YES;
                    mangoEditorViewController.storyBook=_book;
                    //mangoEditorViewController.mangoStoryBook.title = [NSString stringWithFormat:@"%@-custom", _book.title];
                    
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
    if (!validUserSubscription && storyAsAppFilePath) {
       // UIAlertView *editAlertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"The 'edit' feature is only available in the MangoReader app. Please download the MangoReader app to use this feature!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
       // [editAlertView show];
        MangoSubscriptionViewController *subscriptionViewController;
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            
            subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController_iPhone" bundle:nil];
        }
        else{
            subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController" bundle:nil];
        }
        subscriptionViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:subscriptionViewController animated:YES completion:nil];
        
        
    } else {
        UIAlertView *editAlertView = [[UIAlertView alloc] initWithTitle:@"Create your own version" message:@"This will create a new version of this book which you can edit. The old version will be saved too. Do you want to continue?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        editAlertView.tag = FORK_TAG;
        [editAlertView show];
    }
    
    [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_play.png"] forState:UIControlStateNormal];
}

- (IBAction)changeLanguage:(id)sender {
    //[PFAnalytics trackEvent:EVENT_TRANSLATE_INITIATED dimensions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", [_book.id intValue]], [NSString stringWithFormat:@"%d", _pageNumber], nil] forKeys:[NSArray arrayWithObjects:@"bookId", @"pageNumber", nil]]];
    _languageAvailButton.userInteractionEnabled = NO;
    
   /* if ([[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"]) {
        UIAlertView *editAlertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"The multiple language feature is only available in the MangoReader app. Please download it to use this feature!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [editAlertView show];
    } else {*/
        MangoApiController *apiController = [MangoApiController sharedApiController];
        NSString *url;
        url = LANGUAGES_FOR_BOOK;
        NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
        [paramDict setObject:_bookId forKey:@"story_id"];
//        [paramDict setObject:IOS forKey:PLATFORM];
//        [paramDict setObject:VERSION_NO forKey:VERSION];
        [apiController getListOf:url ForParameters:paramDict withDelegate:self];
  //  }
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
    choiceViewController.oldBookId = _book.id;
    choiceViewController.oldBookTitle = _book.title;
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

#pragma swipe gerture for page control

-(void) setupSwipeGestureRecognizer {
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedScreen:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedScreen:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
}

-(void)swipedScreen:(UISwipeGestureRecognizer*)gesture {
    if (gesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        // NSLog(@"Left");
        [self nextButton:0];
    }
    if(gesture.direction == UISwipeGestureRecognizerDirectionRight) {
        // NSLog(@"Right");
        
        [self previousButton:0];
    }
}


- (IBAction)previousButton:(id)sender {
    NSString *appendString;
    if(pageVisited.length>0){
        appendString = [NSString stringWithFormat:@",%d",_pageNumber];
        [pageVisited appendString:appendString];
    }
    else{
        appendString = [NSString stringWithFormat:@"%d", _pageNumber];
        [pageVisited appendString:appendString];
    }
    _rightView.hidden = YES;
    //[emitter removeFromSuperlayer];
    if (_pageNumber==1) {
        //[self BackButton:nil];
        [self.navigationController popViewControllerAnimated:YES];

    }else{
         _pageNumber--;
             [self loadPageWithOption:_option];
        [_audioMappingViewController.player pause];
        
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setDuration:0.7f];
        animation.startProgress = 0.3;
        animation.endProgress   = 1;
        //[animation setTimingFunction:UIViewAnimationCurveEaseInOut];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [animation setType:@"pageCurl"];
        [animation setSubtype:kCATransitionFromLeft];
        [animation setRemovedOnCompletion:NO];
        [animation setFillMode: @"extended"];
        [animation setRemovedOnCompletion: NO];
        [[_viewBase layer] addAnimation:animation forKey:@"WebPageCurl"];
        //[_audioMappingViewController.player play];
        [self performSelector:@selector(playAudio) withObject:self afterDelay:0.7f];

    }
}

- (void) playAudio{
    [_audioMappingViewController.player play];
}

- (IBAction)nextButton:(id)sender {
    NSString *appendString;
    if(pageVisited.length>0){
        appendString = [NSString stringWithFormat:@",%d",_pageNumber];
        [pageVisited appendString:appendString];
    }
    else{
        appendString = [NSString stringWithFormat:@"%d", _pageNumber];
        [pageVisited appendString:appendString];
    }
    _rightView.hidden = YES;
    ++_pageNumber;
    //[emitter removeFromSuperlayer];
    
    if((_pageNumber % 4) == 0){
        
        if ((!validUserSubscription && storyAsAppFilePath) && !(_pageNo == _pageNumber)){
         //   [self showInterstitial:0];
            NSLog(@"page numbers --- %d -- %d", _pageNumber, _pageNo);
        }
    }
    
    if (_pageNumber<(_pageNo)) {
        [self loadPageWithOption:_option];
        [_audioMappingViewController.player pause];
        
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setDuration:0.7f];
        animation.startProgress = 0.3;
        animation.endProgress   = 1;
        //[animation setTimingFunction:UIViewAnimationCurveEaseInOut];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [animation setType:@"pageCurl"];
        [animation setSubtype:kCATransitionFromRight];
        [animation setRemovedOnCompletion:NO];
        [animation setFillMode: @"extended"];
        [animation setRemovedOnCompletion: NO];
        [[_viewBase layer] addAnimation:animation forKey:@"WebPageCurl"];
        //[_audioMappingViewController.player play];
        [self performSelector:@selector(playAudio) withObject:self afterDelay:0.7f];
        /// default is icons_play.png
        if (_option==0) {
            [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_pause.png"] forState:UIControlStateNormal];
        }else{
            [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_play.png"] forState:UIControlStateNormal];
        }
      
        
    } else {
        _pageNumber = _pageNo - 1;
        
        LastPageViewController *lastPage;
        MangoStoreViewController *storeView;
        
        if(storyAsAppFilePath && !validUserSubscription){
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                
                storeView = [[MangoStoreViewController alloc] initWithNibName:@"MangoStoreViewController_iPhone" bundle:nil];
            }
            else{
                storeView = [[MangoStoreViewController alloc] initWithNibName:@"MangoStoreViewController" bundle:nil];
            }
            [self.navigationController pushViewController:storeView animated:YES];
        }
        
        else{
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            lastPage = [[LastPageViewController alloc] initWithNibName:@"LastPageViewController_iPhone" bundle:nil WithId:[_book valueForKey:@"id"]];
            }
            else{
            lastPage = [[LastPageViewController alloc] initWithNibName:@"LastPageViewController" bundle:nil WithId:[_book valueForKey:@"id"]];
            }
        
            [self.navigationController pushViewController:lastPage animated:YES];
        }
    }
}

- (IBAction)playOrPauseButton:(id)sender {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    
    //float timeEndValue = [[NSDate date] timeIntervalSinceDate:self.timeCalculate];
    
    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
    [dimensions setObject:@"playpause_button_click" forKey:PARAMETER_ACTION];
    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
    [dimensions setObject:_book.title forKey:PARAMETER_BOOK_TITLE];
    [dimensions setObject:_book.id forKey:PARAMETER_BOOK_ID];
    [dimensions setObject:@"Play or pause button click" forKey:PARAMETER_EVENT_DESCRIPTION];
    if(userEmail){
        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
    }
    [delegate trackEventAnalytic:@"playpause_button_click" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"playpause_button_click"];
    
    if (_audioMappingViewController.player) {
        if ([_audioMappingViewController.player isPlaying]) {
            //[PFAnalytics trackEvent:EVENT_AUDIO_PAUSED dimensions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", [_book.id intValue]], [NSString stringWithFormat:@"%d", _pageNumber], nil] forKeys:[NSArray arrayWithObjects:@"bookId", @"pageNumber", nil]]];
            //Read to me ---> play(YES)
            
            [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_play.png"] forState:UIControlStateNormal];
            [_audioMappingViewController.player pause];
        }else{
            //[PFAnalytics trackEvent:EVENT_AUDIO_PLAYED dimensions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", [_book.id intValue]], [NSString stringWithFormat:@"%d", _pageNumber], nil] forKeys:[NSArray arrayWithObjects:@"bookId", @"pageNumber", nil]]];
            //Read to me ---> play(NO)
            

            [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_pause.png"] forState:UIControlStateNormal];
            [_audioMappingViewController.player play];
            
            NSLog(@"Timer: %@", _audioMappingViewController.timer);
            _audioMappingViewController.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:_audioMappingViewController selector:@selector(update) userInfo:nil repeats:YES];
            [self closeButton:nil];
            _showButtons = NO;
            [self hideAllButtons:!_showButtons];
        }
    } else {
        //READBOOK_MYSELF - playpause click
        
        [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_pause.png"] forState:UIControlStateNormal];
        
        [self loadPageWithOption:0];
        [self closeButton:nil];
        _showButtons = NO;
        [self hideAllButtons:!_showButtons];
    }
}

- (IBAction)openGameCentre:(id)sender {
    
    [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_play.png"] forState:UIControlStateNormal];
    //float timeEndValue = [[NSDate date] timeIntervalSinceDate:self.timeCalculate];
    //[PFAnalytics trackEvent:EVENT_GAME_CENTER_OPENED dimensions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", [_book.id intValue]], [NSString stringWithFormat:@"%d", _pageNumber], nil] forKeys:[NSArray arrayWithObjects:@"bookId", @"pageNumber", nil]]];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    
    
    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
    [dimensions setObject:@"play_btn_click" forKey:PARAMETER_ACTION];
    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
    [dimensions setObject:_book.title forKey:PARAMETER_BOOK_TITLE];
    [dimensions setObject:_book.id forKey:PARAMETER_BOOK_ID];
    [dimensions setObject:@"Play games button click" forKey:PARAMETER_EVENT_DESCRIPTION];
    if(userEmail){
        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
    }
    [delegate trackEventAnalytic:@"play_btn_click" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"play_btn_click"];
    
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
        gamesListViewController.currentBookId = _book.id;
        gamesListViewController.currentBookTitle = _book.title;

        gamesListViewController.jsonString = _jsonContent;
        gamesListViewController.folderLocation = _book.localPathFile;
        
        NSMutableArray *gameNames = [[NSMutableArray alloc] init];
        for (NSDictionary *pageDict in [jsonDict objectForKey:PAGES]) {
            if ([[pageDict objectForKey:TYPE] isEqualToString:GAME]) {
                [gameNames addObject:[pageDict objectForKey:NAME]];
            }
        }
        gamesListViewController.gameNames = gameNames;
        //_audioMappingViewController.player`
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

- (void) audioPlayerStopAfterSelection:(int)index length:(int)lengthVal{
    
    //AudioMappingViewController *vc = nil;
    //NSString *audioText = vc.mangoTextField.text;
    [self.audioMappingViewController.mangoTextField highlightWordAtIndex:index AfterLength:lengthVal];
    
    /*[vc.timer invalidate];
    vc.timer=nil;*/
    float playTime;
    
    if([[_audioDictForEditMapping objectForKey:@"wordTimes"] count] >index+1){
        
        playTime = [[[_audioDictForEditMapping objectForKey:@"wordTimes"] objectAtIndex:index+1] floatValue]- [[[_audioDictForEditMapping objectForKey:@"wordTimes"] objectAtIndex:index] floatValue];
    }
    else{
        playTime = _audioMappingViewController.player.duration - [[[_audioDictForEditMapping objectForKey:@"wordTimes"] objectAtIndex:index] floatValue];
    }
    
    NSLog(@"play time value %f", playTime);
    _audioMappingViewController.player.currentTime = [[[_audioDictForEditMapping objectForKey:@"wordTimes"] objectAtIndex:index] floatValue];
    [_audioMappingViewController.player play];
    [self performSelector:@selector(pausePlayer) withObject:self afterDelay:playTime];
}

- (void) pausePlayer{
    [_audioMappingViewController.player pause];
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
    [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_pause.png"] forState:UIControlStateNormal];
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
            [backgroundImageView setFrame:CGRectMake(0, 0, pageView.frame.size.width*0.65, pageView.frame.size.height)];
        } else if ([[imageDict objectForKey:ALIGNMENT] isEqualToString:RIGHT_ALIGN]) {
            [backgroundImageView setFrame:CGRectMake(pageView.frame.size.width*0.35, 0, pageView.frame.size.width*0.65, pageView.frame.size.height)];
        } else if ([[imageDict objectForKey:ALIGNMENT] isEqualToString:TOP_ALIGN]) {
            [backgroundImageView setFrame:CGRectMake(0, 0, pageView.frame.size.width, pageView.frame.size.height*0.65)];
        } else if ([[imageDict objectForKey:ALIGNMENT] isEqualToString:BOTTOM_ALIGN]) {
            [backgroundImageView setFrame:CGRectMake(0, pageView.frame.size.height*0.35, pageView.frame.size.width, pageView.frame.size.height)];
        }
    }
    [audioMappingViewControllers removeAllObjects];
    for (NSDictionary *textDict in textLayers) {
        AudioMappingViewController *audioMappingViewcontroller = [[AudioMappingViewController alloc] initWithNibName:@"AudioMappingViewController" bundle:nil];
        audioMappingViewcontroller.audioMappingRate = newAudioRate;
        [audioMappingViewControllers addObject:audioMappingViewcontroller];
        audioMappingViewcontroller.audioMappingDelegate = delegate;
        audioMappingViewcontroller.customView.textFont = [UIFont fontWithName:@"Verdana" size:pageView.frame.size.height * 24.0f/768.0f];
        [audioMappingViewcontroller.customView setBackgroundColor:[UIColor clearColor]];
        //[audioMappingViewcontroller.view setExclusiveTouch:NO];
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
        [pageView bringSubviewToFront:audioMappingViewcontroller.view];
        [audioMappingViewcontroller.view setHidden:YES];
        [audioMappingViewcontroller.customView setBackgroundColor:[UIColor clearColor]];
        //[audioMappingViewcontroller.view setExclusiveTouch:NO];
        //audioMappingViewcontroller.mangoTextField.exclusiveTouch = NO;
        audioMappingViewcontroller.mangoTextField.userInteractionEnabled = YES;
        audioMappingViewcontroller.mangoTextField.text = textOnPage;
        audioMappingViewcontroller.mangoTextField.selectable = NO;
        UIFont *font = [UIFont fontWithName:@"Verdana" size:pageView.frame.size.height*24.0f/768.0f];
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
                    fontSize = @"13";
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
                else if ([trimmedFamily  hasPrefix:@"comic"]) {
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
                else if ([trimmedFamily hasPrefix:@"Arial"]){
                    fFamily = @"ArialMT";
                }

                
                NSString *trimmedStyle = [fontStyle stringByTrimmingCharactersInSet:
                                         [NSCharacterSet whitespaceCharacterSet]];
                // Find the style of the family
                NSString *fStyle;
                if ([fontWeight hasPrefix:@"bold"] && [fontStyle isKindOfClass:NULL]){
                    if([fFamily isEqualToString:@"TimesNewRomanPS"] || [fFamily isEqualToString:@"ArialMT"])
                        fStyle = @"-BoldMT";
                    else if([fFamily isEqualToString:@"mono"])
                        fStyle = @"Bold";
                    else
                        fStyle = @"-Bold";
                    
                }else if ([fontWeight hasPrefix:@"bold"] && [fontStyle hasPrefix:@"italic"]) {
                    if ([fFamily isEqualToString:@"Tahoma"])
                         fStyle = @"-BoldFauxItalic";
                    else if ([fFamily isEqualToString:@"TimesNewRomanPS"] || [fFamily isEqualToString:@"ArialMT"])
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
                    else if ([fFamily isEqualToString:@"TimesNewRomanPS"] || [fFamily isEqualToString:@"ArialMT"])
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
                
                if(!fontSize){
                    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
                        fontSize = @"13";
                    }
                    else{
                        fontSize = @"24";
                    }
                }
                
                font = [UIFont fontWithName:[fFamily stringByAppendingString:fStyle]
                                       size:[fontSize floatValue]];
                
            }
        }
        textFontValue = font;
        audioMappingViewcontroller.mangoTextField.font = font;

        audioMappingViewcontroller.mangoTextField.frame = textFrame;
        audioMappingViewcontroller.mangoTextField.textAlignment = NSTextAlignmentCenter;
        [_pageView bringSubviewToFront:audioMappingViewcontroller.mangoTextField];
        //audioMappingViewcontroller.mangoTextField.backgroundColor = [UIColor redColor];
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
//        audioMappingViewcontroller.mangoTextField.editable = NO;
        [pageView bringSubviewToFront:audioMappingViewcontroller.view];
        
        [pageView bringSubviewToFront:[audioMappingViewcontroller.view superview]];
        // Now, inside that container view, get the "grandchildview" to front.
        [[audioMappingViewcontroller.view superview] bringSubviewToFront:audioMappingViewcontroller.view];
        
        audioMappingViewcontroller.textForMapping = textOnPage;
        
        NSString *audio_id = [textDict objectForKey:@"audio_id"];
        if ([audio_id isKindOfClass:[NSNull class]]) {
            NSLog(@"Text Does not have an audio");
        } else {
            NSPredicate *audioPredicate = [NSPredicate predicateWithFormat:@"id == %@",audio_id];
            NSArray *relatedAudios = [audioLayers filteredArrayUsingPredicate:audioPredicate];
            if ([relatedAudios count]) {
                NSDictionary *audioLayer = [relatedAudios objectAtIndex:0];
                _audioDictForEditMapping = audioLayer;
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
                if ([audioLayer objectForKey:@"highlight"] && ![[audioLayer objectForKey:@"highlight"] isEqual:[NSNull null]]) {
                    audioMappingViewcontroller.mangoTextField.highlightColor = [AePubReaderAppDelegate colorFromRgbString:[audioLayer objectForKey:@"highlight"]];
                    
                } else {
                    audioMappingViewcontroller.mangoTextField.highlightColor = [UIColor yellowColor];
                }
                if (readingOption == 0) {
                    NSNumber *order = [textDict objectForKey:@"order"];
                    if ([order isEqualToNumber:[NSNumber numberWithInt:0]] ||
                        [order isEqualToNumber:[NSNumber numberWithInt:1]] || (order == nil)) {
                        if (![self isPlaying]) {
                            
                            [audioMappingViewcontroller playAudioForReaderWithData:audioData AndDelegate:delegate];
                            _audioMappingViewController = audioMappingViewcontroller;
                        }
                    }
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
        bookReadMode = @"READ_TO_ME";

    }else{
        
        [_playOrPauseButton setImage:[UIImage imageNamed:@"icons_play.png"] forState:UIControlStateNormal];
        bookReadMode = @"READ_BY_MYSELF";
    }
}



- (void) viewDidDisappear:(BOOL)animated{
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    _audioMappingViewController.timer = nil;
    _audioMappingViewController.player = nil;
    float timeEndValue = [[NSDate date] timeIntervalSinceDate:self.timeCalculate];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *bookGrade;
    NSString *appendString;
    if(pageVisited.length>0){
        appendString = [NSString stringWithFormat:@",%d",_pageNumber];
        [pageVisited appendString:appendString];
    }
    else{
        appendString = [NSString stringWithFormat:@"%d", _pageNumber];
        [pageVisited appendString:appendString];
    }
    if(!_bookGradeLevel){
        bookGrade = @"Not available";
    }
    else{
        bookGrade = _bookGradeLevel;
    }
    
    if(_pageNumber+1 >= _pageNo){
        bookStatus =@"complete";
    }
    else{
        bookStatus = @"incomplete";
    }
    int time = (int)(timeEndValue*1000);
    NSString *time1 = [NSString stringWithFormat:@"%d",(int)(timeEndValue *1000)];
    int times = [[pageVisited componentsSeparatedByString:@","] count];
    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *dimensionevent = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *dimensionshist = [[NSMutableDictionary alloc]init];
    [dimensions setObject:@"reading_time" forKey:PARAMETER_ACTION];
    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
    [dimensions setObject:@"Total reading time" forKey:PARAMETER_EVENT_DESCRIPTION];
    [dimensions setObject:_book.id forKey:PARAMETER_BOOK_ID];
    [dimensions setObject:_book.title forKey:PARAMETER_BOOK_TITLE];
    [dimensions setObject:bookStatus forKey:PARAMETER_BOOK_STATUS];
    //[dimensions setObject:[NSNumber numberWithInt:time] forKey:PARAMETER_TIME_TAKEN];
    [dimensions setObject:bookReadMode forKey:PARAMETER_BOOK_READ_MODE];
    [dimensions setObject:pageVisited forKey:PARAMETER_PAGES_VISITED];
    //[dimensions setObject:[NSString stringWithFormat:@"%d",times] forKey:PARAMETER_PAGE_COUNT];
    if(userEmail){
        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
    }
    [dimensionevent setDictionary:dimensions];
    [dimensionevent setObject:time1 forKey:PARAMETER_TIME_TAKEN];
    [dimensionevent setObject:[NSString stringWithFormat:@"%d",times] forKey:PARAMETER_PAGE_COUNT];
    [dimensionshist setDictionary:dimensions];
    [dimensionshist setObject:[NSNumber numberWithInt:time] forKey:PARAMETER_TIME_TAKEN];
    [dimensionshist setObject:[NSNumber numberWithInt:times] forKey:PARAMETER_PAGE_COUNT];
    [delegate trackEventAnalytic:@"reading_time" dimensions:dimensionevent];
    [delegate userHistoryAnalyticsDataBrowser:dimensionshist];
    [delegate trackMixpanelEvents:dimensions eventName:@"reading_time"];
    /*NSDictionary *dimensions = @{
                                 PARAMETER_USER_EMAIL_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_BOOK_ID : _bookId,
                                 PARAMETER_BOOK_PAGE_NO: [NSString stringWithFormat:@"%d",_pageNumber],
                                 PARAMETER_BOOK_TIME_SPEND : [NSString stringWithFormat:@"%f",timeEndValue]
                                 };
    [delegate trackEvent:[READBOOK_CLOSE valueForKey:@"description"] dimensions:dimensions];*/
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
            [object setObject:_bookImageURL forKey:@"bookCoverImageURL"];
            int totalpagesNo = [[object valueForKey:@"pagesCompleted"] floatValue] + _pageNumber+1;
            [object setObject:[NSNumber numberWithInt:totalpagesNo] forKey:@"pagesCompleted"];
            
            if(_pageNumber+1 >= _pageNo){
                NSLog(@"Book Completed here, update total pageno, completebookcount, totaltime and totalactivities");
                if([[object valueForKey:@"bookCompleted"] integerValue]){
                    [object setObject:[NSNumber numberWithInt:([[object valueForKey:@"timesNumberBookCompleted"] integerValue]+1)] forKey:@"timesNumberBookCompleted"];
                    /*NSDictionary *dimensions = @{
                                                 PARAMETER_USER_EMAIL_ID : ID,
                                                 PARAMETER_DEVICE: IOS,
                                                 PARAMETER_BOOK_ID : _bookId,
                                                 PARAMETER_BOOK_TIME_SPEND : [NSString stringWithFormat:@"%f",timeEndValue]
                                                 };
                    [delegate trackEvent:[READBOOK_BOOK_COMPLETE valueForKey:@"description"] dimensions:dimensions];*/
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
                
                /*NSDictionary *dimensions = @{
                                             PARAMETER_USER_EMAIL_ID : ID,
                                             PARAMETER_DEVICE: IOS,
                                             PARAMETER_BOOK_ID : _bookId,
                                             PARAMETER_BOOK_TIME_SPEND : [NSString stringWithFormat:@"%f",timeEndValue]
                                             };
                [delegate trackEvent:[READBOOK_BOOK_COMPLETE valueForKey:@"description"] dimensions:dimensions];*/
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
        if (refreshCover){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadCoverView" object:self];
        }
    }];
   
}

- (IBAction)backgroundTap:(id)sender {
    [_textQuesSolution resignFirstResponder];
    
}

#pragma audiocontrol switch

- (IBAction) audioSwitchControl: (id) sender {
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
    [dimensions setObject:@"audio_rate_change" forKey:PARAMETER_ACTION];
    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
    [dimensions setObject:@"Audio playback rate change" forKey:PARAMETER_EVENT_DESCRIPTION];
    [dimensions setObject:_book.id forKey:PARAMETER_BOOK_ID];
    [dimensions setObject:_book.title forKey:PARAMETER_BOOK_TITLE];
    if(userEmail){
        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
    }
    [delegate trackEventAnalytic:@"audio_rate_change" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"audio_rate_change"];
    
    UISwitch *onoff = (UISwitch *) sender;
    if(onoff.on){
        NSLog(@"Switch is On");
        newAudioRate = 0.6f;
    
    }
    else{
         NSLog(@"Switch is Off");
        newAudioRate = 1.0f;
    }
    //UIFont *newTextFontValue = [textFontValue fontWithSize:35];
    //[_audioMappingViewController.mangoTextField setFont:newTextFontValue];
    [_audioMappingViewController.player pause];
    _audioMappingViewController.player.enableRate = YES;
    _audioMappingViewController.player.rate = newAudioRate;
    [_audioMappingViewController.player play];
    
}

#pragma sparkle view

/*- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    float multiplier = 0.5f;
    
    CGPoint pt = [[touches anyObject] locationInView:self.pageView];
    
    //Create the emitter layer
    emitter = [CAEmitterLayer layer];
    emitter.emitterPosition = pt;
    emitter.emitterMode = kCAEmitterLayerOutline;
    emitter.emitterShape = kCAEmitterLayerCircle;
    emitter.renderMode = kCAEmitterLayerAdditive;
    emitter.emitterSize = CGSizeMake(20 * multiplier, 0);
    
    //Create the emitter cell
    CAEmitterCell* particle = [CAEmitterCell emitterCell];
    particle.emissionLongitude = M_PI-1.0;
    particle.birthRate = multiplier * 1000.0;
    particle.lifetime = 0.4;
    particle.lifetimeRange = multiplier * 0.15;
    particle.velocity = 120;
    particle.velocityRange = 60;
    particle.emissionRange = 0.2;
    particle.scaleSpeed = 0.2; // was 0.3
    particle.color = [[[UIColor yellowColor] colorWithAlphaComponent:0.5f] CGColor];
    particle.contents = (__bridge id)([UIImage imageNamed:@"not.png"].CGImage);
    particle.name = @"particle";
    
    emitter.emitterCells = [NSArray arrayWithObject:particle];
    [self.view.layer addSublayer:emitter];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint pt = [[touches anyObject] locationInView:self.pageView];
    
    // Disable implicit animations
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    emitter.emitterPosition = pt;
    [CATransaction commit];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [emitter removeFromSuperlayer];
    emitter = nil;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}*/

- (void)dealloc {
    _interstitial.delegate = nil;
    _audioMappingViewController.player = nil;
}

@end
