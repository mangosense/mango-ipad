//
//  CoverViewControllerBetterBookType.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 21/11/13.
//
//

#import "CoverViewControllerBetterBookType.h"
#import "LanguageChoiceViewController.h"
#import "AePubReaderAppDelegate.h"
#import "DataModelControl.h"
#import "PageNewBookTypeViewController.h"
#import "MangoEditorViewController.h"
#import "MangoGamesListViewController.h"
#import <Parse/Parse.h>
#import "MangoPromoPageViewController.h"
#import "MBProgressHUD.h"
#import "EmailSubscriptionLinkViewController.h"
//#import "Fingerprint.h"

@interface CoverViewControllerBetterBookType ()
@end

@implementation CoverViewControllerBetterBookType
NSString *newIdentityValue;
@synthesize popoverControlleriPhone, popOverShareiPhone;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil WithId:(NSString *)identity
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if (identity) {
            _identity=identity;
            AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
            _book= [delegate.dataModel getBookOfId:identity];
            NSLog(@"%@",_book.edited);
            
            userEmail = delegate.loggedInUserInfo.email;
            //userDeviceID = delegate.deviceId;
        }
    }
    return self;
}

+ (void)setIdentityValue:(NSString *)value {
    
    newIdentityValue = value;
}

- (void)setIdentity:(NSString *)identity {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int validSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
    if ((path) && (!validSubscription)) {
        _identity = identity;
        AePubReaderAppDelegate *delegate = (AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        _book = [delegate.dataModel getBookOfId:identity];
        NSLog(@"%@",_book.edited);
        
        userEmail = delegate.loggedInUserInfo.email;
        //userDeviceID = delegate.deviceId;
        
        [self initialSetup];
        
        [_backButton setHidden:YES];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)initialSetup {
    
    viewName = @"Book cover view";
    _titleLabel.text=_book.title;
    NSString *jsonLocation=_book.localPathFile;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
    NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
    jsonLocation=     [jsonLocation stringByAppendingPathComponent:[onlyJson firstObject]];
    NSString *jsonContents=[[NSString alloc]initWithContentsOfFile:jsonLocation encoding:NSUTF8StringEncoding error:nil];
    UIImage *image=[MangoEditorViewController coverPageImageForStory:jsonContents WithFolderLocation:_book.localPathFile];
        _coverImageView.image=image;
    
    //ID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    //[MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    NSData *jsonData = [jsonContents dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    currentBookId = [jsonDict objectForKey:@"id"];
    
    if(![[jsonDict objectForKey:@"has_audio"] integerValue]){
        
        _buttonReadToMe.hidden = YES;
    }
    if([[jsonDict objectForKey:@"title"] isEqualToString:@"My Book"]){
        _buttonReadToMe.hidden = NO;
    }
    currentBookGradeLevel = [[[jsonDict objectForKey:@"info"] objectForKey:@"grades"] componentsJoinedByString:@", "];
    
    if([jsonDict objectForKey:@"story_image"]){
        currentBookImageURL = [[NSString stringWithFormat:@"http://www.mangoreader.com/live_stories/%@/%@",[jsonDict objectForKey:@"id"], [jsonDict objectForKey:@"story_image"]] stringByReplacingOccurrencesOfString:@"res/" withString:@"res/cover_"];
    }
    else{
        currentBookImageURL = @"nil";
    }
    
    [_languageLabel setTitle:[[jsonDict objectForKey:@"info"] objectForKey:@"language"] forState:UIControlStateNormal];
    if (_languageLabel.titleLabel.text == nil) {
        [_languageLabel setTitle:@"English" forState:UIControlStateNormal];
    }
    
    
    [self showOrHideGameButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    /*if(!delegate.deviceId){
        delegate.deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        userDeviceID = delegate.deviceId;
    }*/
    currentPage =  @"cover_screen";
    popoverClass = [WEPopoverController class];
    self.navigationController.navigationBarHidden=YES;
    if (_identity) {
        [self initialSetup];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCoverViewWithNotification) name:@"ReloadCoverView" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DismissOtherViewAndLoadLangingpage) name:@"LoadLandingPage" object:nil];
    
}

/*- (void) showFingerPrintHere{
    
    [Fingerprint showHubButton:1];
}

- (void)viewWillAppear:(BOOL)animated{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int validSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
    NSString *fingerPrintPath = [[NSBundle mainBundle] pathForResource:@"Fingerprint" ofType:@"bundle"];
    if(fingerPrintPath && path && !validSubscription){
        [self showFingerPrintHere];
    }
}*/

- (void) viewDidAppear:(BOOL)animated{
    
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
    [dimensions setObject:@"reader" forKey:PARAMETER_ACTION];
    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
    [dimensions setObject:[_book valueForKey:@"bookId"] forKey:PARAMETER_BOOK_ID];
    [dimensions setObject:_titleLabel.text forKey:PARAMETER_BOOK_TITLE];
    [dimensions setObject:@"Cover book screen" forKey:PARAMETER_EVENT_DESCRIPTION];
    if(userEmail){
        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
    }
    [delegate trackEventAnalytic:@"reader" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"reader"];

}

- (void) DismissOtherViewAndLoadLangingpage{
    
    NSLog(@"Views in stack are %@", self.navigationController.viewControllers);
    
    NSArray* viewControllerStack = [self.navigationController viewControllers];
    
    for(UIViewController *tempVC in viewControllerStack)
    {
        if(![tempVC isKindOfClass:[CoverViewControllerBetterBookType class]])
        {
            if([tempVC isKindOfClass:[PageNewBookTypeViewController class]]){
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DismissBook" object:self];
                return;
                
            }
            else{
                [tempVC removeFromParentViewController];
            }
        }
        
    }
    
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

- (IBAction)multipleLanguage:(id)sender {
    //UIButton *button=(UIButton *)sender;
    //AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    //new
    
    //
    _languageLabel.userInteractionEnabled = NO;
    /*NSDictionary *dimensions = @{
                                 PARAMETER_USER_EMAIL_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_BOOK_LANGUAGE : _languageLabel.titleLabel.text,
                                 PARAMETER_BOOK_ID : [_book valueForKey:@"bookId"]
                                 
                                 };
    [delegate trackEvent:[BOOKCOVER_AVAILABLE_LANGUAGE valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[BOOKCOVER_AVAILABLE_LANGUAGE valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [BOOKCOVER_AVAILABLE_LANGUAGE valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    [userObject setObject:_languageLabel.titleLabel.text forKey:@"bookLanguage"];
    [userObject setObject:[_book valueForKey:@"bookId"] forKey:@"bookID"];
    if(userEmail){
        [userObject setObject:ID forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];*/

 //   if (![[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"]) {
        MangoApiController *apiController = [MangoApiController sharedApiController];
        NSString *url;
        url = LANGUAGES_FOR_BOOK;
        NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
        [paramDict setObject:currentBookId forKey:@"story_id"];
//        [paramDict setObject:IOS forKey:PLATFORM];
//        [paramDict setObject:VERSION_NO forKey:VERSION];
        [apiController getListOf:url ForParameters:paramDict withDelegate:self];
  //  }
}

- (void)reloadViewsWithArray:(NSArray *)dataArray ForType:(NSString *)type {
    _languageLabel.userInteractionEnabled = YES;
   _avilableLanguages = [NSMutableArray arrayWithArray:dataArray];
    NSMutableArray *languageArray = [[NSMutableArray alloc] init];
    
    LanguageChoiceViewController *choiceViewController=[[LanguageChoiceViewController alloc]initWithStyle:UITableViewStyleGrouped];
    [choiceViewController.view setFrame:CGRectMake(0, 0, 150, 150)];
    choiceViewController.delegate=self;
    
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
    choiceViewController.language = _languageLabel.titleLabel.text;
    if(choiceViewController.array.count>0){
     if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
       if (!self.popoverControlleriPhone) {
           
           self.popoverControlleriPhone = [[popoverClass alloc] initWithContentViewController:choiceViewController] ;
           self.popoverControlleriPhone.delegate = self;
           self.popoverControlleriPhone.passthroughViews = [NSArray arrayWithObject:self.view];
         
               [self.popoverControlleriPhone presentPopoverFromRect:_languageLabel.frame
                                                          inView:self.view
                                        permittedArrowDirections:UIPopoverArrowDirectionUp
                                                     animated:YES];
         
         
       } else {
                  [self.popoverControlleriPhone dismissPopoverAnimated:YES];
                  self.popoverControlleriPhone = nil;
       }
    }
        
    else{
        _popOverController=[[UIPopoverController alloc]initWithContentViewController:choiceViewController];
        CGSize size=_popOverController.popoverContentSize;
        size.height=size.height-300;
        _popOverController.popoverContentSize=size;
        
        [_popOverController presentPopoverFromRect:_languageLabel.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
     }
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)bookCoverSelection:(id)sender {
    UIButton *button=(UIButton *)sender;
    //AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    PageNewBookTypeViewController *controller;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        controller=[[PageNewBookTypeViewController alloc]initWithNibName:@"PageNewBookTypeViewController_iPhone" bundle:nil WithOption:button.tag BookId:_identity];
        
    }
    else{
        controller=[[PageNewBookTypeViewController alloc]initWithNibName:@"PageNewBookTypeViewController" bundle:nil WithOption:button.tag BookId:_identity];
    }
    
    controller.bookGradeLevel = currentBookGradeLevel;
    //add full image url
    controller.bookImageURL = currentBookImageURL;
    
    /*NSDictionary *dimensions = @{
                                 PARAMETER_USER_EMAIL_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_BOOK_ID : _identity
                                 
                                 };
    [delegate trackEvent:[BOOKCOVER_SELECTION valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[BOOKCOVER_SELECTION valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [BOOKCOVER_SELECTION valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    [userObject setObject:_identity forKey:@"bookID"];
    if(userEmail){
        [userObject setObject:ID forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];*/
    
    [self.navigationController pushViewController:controller animated:YES];
}


- (IBAction)optionsToReader:(id)sender {
    UIButton *button=(UIButton *)sender;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    
    
    PageNewBookTypeViewController *controller;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        controller=[[PageNewBookTypeViewController alloc]initWithNibName:@"PageNewBookTypeViewController_iPhone" bundle:nil WithOption:button.tag BookId:_identity];
        
    }
    else{
        controller=[[PageNewBookTypeViewController alloc]initWithNibName:@"PageNewBookTypeViewController" bundle:nil WithOption:button.tag BookId:_identity];
    }

    controller.bookGradeLevel = currentBookGradeLevel;
    //add full image url
    controller.bookImageURL = currentBookImageURL;
    
    if([sender tag] == 1){
        NSLog(@"Read by myself");
        
        NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
        [dimensions setObject:@"read_by_myself_click" forKey:PARAMETER_ACTION];
        [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
        [dimensions setObject:[_book valueForKey:@"bookId"] forKey:PARAMETER_BOOK_ID];
        [dimensions setObject:_titleLabel.text forKey:PARAMETER_BOOK_TITLE];
        [dimensions setObject:@"Read by myself click" forKey:PARAMETER_EVENT_DESCRIPTION];
        if(userEmail){
            [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
        }
        [delegate trackEventAnalytic:@"read_by_myself_click" dimensions:dimensions];
        [delegate eventAnalyticsDataBrowser:dimensions];
        [delegate trackMixpanelEvents:dimensions eventName:@"read_by_myself_click"];
        
    }
    else{
        NSLog(@"Read to me");
        NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
        [dimensions setObject:@"read_to_me_click" forKey:PARAMETER_ACTION];
        [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
        [dimensions setObject:[_book valueForKey:@"bookId"] forKey:PARAMETER_BOOK_ID];
        [dimensions setObject:_titleLabel.text forKey:PARAMETER_BOOK_TITLE];
        [dimensions setObject:@"Read to me click" forKey:PARAMETER_EVENT_DESCRIPTION];
        if(userEmail){
            [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
        }
        [delegate trackEventAnalytic:@"read_to_me_click" dimensions:dimensions];
        [delegate eventAnalyticsDataBrowser:dimensions];
        [delegate trackMixpanelEvents:dimensions eventName:@"read_to_me_click"];
    }
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)libraryButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) dismissPopOver{
    [_popOverController dismissPopoverAnimated:YES];
    [popoverControlleriPhone dismissPopoverAnimated:YES];
}

- (NSString *)getJsonContentForBook {
    NSString *jsonLocation=_book.localPathFile;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
    NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
    jsonLocation = [jsonLocation stringByAppendingPathComponent:[onlyJson firstObject]];
    //  NSLog(@"json location %@",jsonLocation);
    NSString *jsonContent=[[NSString alloc]initWithContentsOfFile:jsonLocation encoding:NSUTF8StringEncoding error:nil];
    return jsonContent;
}

- (void)showOrHideGameButton {
    NSDictionary *jsonDict = [self getJsonDictForBook];
    if ([[jsonDict objectForKey:NUMBER_OF_GAMES] intValue] == 0) {
        _games.hidden = YES;
    } else {
        _games.hidden= NO;
    }
}

- (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
    CGImageRef imgRef = [image CGImage];
    CGImageRef maskRef = [maskImage CGImage];
    CGImageRef actualMask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                              CGImageGetHeight(maskRef),
                                              CGImageGetBitsPerComponent(maskRef),
                                              CGImageGetBitsPerPixel(maskRef),
                                              CGImageGetBytesPerRow(maskRef),
                                              CGImageGetDataProvider(maskRef), NULL, false);
    CGImageRef masked = CGImageCreateWithMask(imgRef, actualMask);
    UIImage *img = [UIImage imageWithCGImage:masked];
    CGImageRelease(masked);
    return img;
}

- (NSDictionary *)getJsonDictForBook {
    NSString *jsonContent = [self getJsonContentForBook];
    NSData *jsonData = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];

    return jsonDict;
}

- (IBAction)gameButtonTapped:(id)sender {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *jsonDict = [self getJsonDictForBook];
    
    /*NSDictionary *dimensions = @{
                                 PARAMETER_USER_EMAIL_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_BOOK_ID : [jsonDict objectForKey:@"story_id"]
                                 };
    [delegate trackEvent:[BOOKCOVER_PLAY_GAMES valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[BOOKCOVER_PLAY_GAMES valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [BOOKCOVER_PLAY_GAMES valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:ID forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    [userObject setObject:[jsonDict objectForKey:@"story_id"] forKey:@"bookID"];
    if(userEmail){
        [userObject setObject:ID forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];*/
    
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
    
    if ([[jsonDict objectForKey:NUMBER_OF_GAMES] intValue] == 0) {
        UIAlertView *noGamesAlert = [[UIAlertView alloc] initWithTitle:@"No Games" message:@"Sorry, this story does not have any games in it." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [noGamesAlert show];
    } else {
        
        MangoGamesListViewController *gamesListViewController;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            gamesListViewController = [[MangoGamesListViewController alloc] initWithNibName:@"MangoGamesListViewController_iPhone" bundle:nil];
        }
        else{
            gamesListViewController = [[MangoGamesListViewController alloc] initWithNibName:@"MangoGamesListViewController" bundle:nil];
        }
        gamesListViewController.currentBookId = _book.id;
        gamesListViewController.currentBookTitle = _book.title;
        gamesListViewController.jsonString = [self getJsonContentForBook];
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

- (IBAction)displyParentalControl:(id)sender{
    
    _settingsProbSupportView.hidden = NO;
    _settingsProbView.hidden = NO;
    
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
    
    
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    /*NSDictionary *dimensions = @{
                                 PARAMETER_USER_EMAIL_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_BOOK_ID : [_book valueForKey:@"bookId"]
                                 
                                 };
    [delegate trackEvent:[BOOKCOVER_SHARE valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[BOOKCOVER_SHARE valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [BOOKCOVER_SHARE valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:ID forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    [userObject setObject:[_book valueForKey:@"bookId"] forKey:@"bookID"];
    if(userEmail){
        [userObject setObject:ID forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];*/
    
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
    
   // UIButton *button=(UIButton *)sender;
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
        activity.excludedActivityTypes=@[UIActivityTypeCopyToPasteboard,UIActivityTypePostToWeibo,UIActivityTypeAssignToContact,UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll,];
        
        
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
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


- (void) reloadCoverViewWithNotification{
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    _book= [delegate.dataModel getBookOfId:newIdentityValue];
    _identity = newIdentityValue;
    
    if (_identity) {
        [self initialSetup];
    }
    
}


- (IBAction)moveToPromoPage:(id)sender{
    
    MangoPromoPageViewController *promoPageView;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        promoPageView=[[MangoPromoPageViewController alloc]initWithNibName:@"MangoPromoPageViewController_iPhone" bundle:nil];
        
    }
    else{
        promoPageView =[[MangoPromoPageViewController alloc]initWithNibName:@"MangoPromoPageViewController" bundle:nil];
    }

    promoPageView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:promoPageView animated:YES completion:nil];
    
}


- (IBAction)backgroundTap:(id)sender {
    [_textQuesSolution resignFirstResponder];
    
}

/*- (void)viewWillDisappear:(BOOL)animated{
    
    [Fingerprint showHubButton:0];
}*/


@end
