//
//  LastPageViewController.m
//  MangoReader
//
//  Created by Harish on 3/7/14.
//
//

#import "LastPageViewController.h"

#import "AePubReaderAppDelegate.h"b
#import "DataModelControl.h"
#import "MBProgressHUD.h"
#import "MangoEditorViewController.h"
#import "MangoGamesListViewController.h"
#import "MangoStoreViewController.h"
#import <Parse/Parse.h>
#import "CargoBay.h"
#import "LandPageChoiceViewController.h"
#import "EmailSubscriptionLinkViewController.h"

@interface LastPageViewController ()

@end

@implementation LastPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil WithId:(NSString *)identity
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _identity=identity;
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        _book= [delegate.dataModel getBookOfId:identity];
        NSLog(@"%@",_book.edited);
        
        userEmail = delegate.loggedInUserInfo.email;
        
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
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    validUserSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
    storyAsAppFilePath = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
    //viewName = @"Book Last Page";
    currentPage = @"reader_end_screen";
    
    _titleLabel.text= [NSString stringWithFormat:@"Thanks for Reading %@", _book.title];
    // Do any additional setup after loading the view from its nib.
    if([_book.title isEqualToString:@"My Book"]) {
        self.recommendedBooksView.hidden = YES;
        //self.mangoreaderLinkView.hidden = NO;
    }
    else {
        
        [self loadRecommendedBooks:_book.id];
    }
    
    [self showOrHideGameButton];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[CargoBay sharedManager]];
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(!validUserSubscription){
        
        if(appDelegate.subscriptionInfo){
            //provide access
            
            [[MangoApiController sharedApiController]validateSubscription:appDelegate.subscriptionInfo.subscriptionTransctionId andDeviceId:appDelegate.deviceId block:^(id response, NSInteger type, NSString *error){
                NSLog(@"type --- %d", type);
                if ([[response objectForKey:@"status"] integerValue] == 1){
                    
                    NSLog(@"You are already subscribed");
                   // [self gotoReviews];
                }
                else{
                        
                        MangoSubscriptionViewController *subscriptionViewController;
                    subscriptionViewController.subscriptionDelegate = self;
                        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
                            
                            subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController_iPhone" bundle:nil];
                        }
                        else{
                            subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController" bundle:nil];
                        }
                        [prefs setBool:YES forKey:@"FIRSTTIMEDISPLAY"];
                        subscriptionViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                        [self presentViewController:subscriptionViewController animated:YES completion:nil];
                    
                }
                
            }];
        }
        
        else{
            
            
            [[MangoApiController sharedApiController]validateSubscription:appDelegate.subscriptionInfo.subscriptionTransctionId andDeviceId:appDelegate.deviceId block:^(id response, NSInteger type, NSString *error){
                NSLog(@"type --- %d", type);
                if ([[response objectForKey:@"status"] integerValue] == 1){
                    
                    NSLog(@"You are already subscribed");
                   // [self gotoReviews];
                }
                else{
                    
                        MangoSubscriptionViewController *subscriptionViewController;
                        subscriptionViewController.subscriptionDelegate = self;
                        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
                            
                            subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController_iPhone" bundle:nil];
                        }
                        else{
                            subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController" bundle:nil];
                        }
                        [prefs setBool:YES forKey:@"FIRSTTIMEDISPLAY"];
                        subscriptionViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                        [self presentViewController:subscriptionViewController animated:YES completion:nil];
                }
                
            }];
        }
    }
}

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
            NSArray *vComp = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
            if ([[vComp objectAtIndex:0] intValue] >= 8) {
                emailLinkSubscriptionView.preferredContentSize = CGSizeMake(700, 530);
            }
            else{
                emailLinkSubscriptionView.view.superview.bounds = CGRectMake(0, 0, 700, 530);
            }
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
    [dimensions setObject:@"reader_end_screen" forKey:PARAMETER_ACTION];
    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
    [dimensions setObject:_book.id forKey:PARAMETER_BOOK_ID];
    [dimensions setObject:_book.title forKey:PARAMETER_BOOK_TITLE];
    [dimensions setObject:@"Reader end screen open" forKey:PARAMETER_EVENT_DESCRIPTION];
    if(userEmail){
        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
    }
    [delegate trackEventAnalytic:@"reader_end_screen" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"reader_end_screen"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)getJsonContentForBook {
    
    NSString *jsonLocation = [AePubReaderAppDelegate returnBookJsonPath:_book];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
    NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
    jsonLocation=     [jsonLocation stringByAppendingPathComponent:[onlyJson firstObject]];
    NSString *jsonContent=[[NSString alloc]initWithContentsOfFile:jsonLocation encoding:NSUTF8StringEncoding error:nil];
    return jsonContent;
}

- (NSDictionary *)getJsonDictForBook {
    NSString *jsonContent = [self getJsonContentForBook];
    NSData *jsonData = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];

    return jsonDict;
}

- (void)showOrHideGameButton {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int isTrialUser = [[prefs valueForKey:@"ISTRIALUSER"]integerValue];
    
    NSDictionary *jsonDict = [self getJsonDictForBook];
    if ([[jsonDict objectForKey:NUMBER_OF_GAMES] intValue] == 0) {
        _games.hidden = YES;
    }
        
    if(!validUserSubscription || !isTrialUser){
            //_games.hidden= YES;
            _shareButton.hidden = NO;
            //_subscribeButton.hidden = NO;
    }
    else{
            _shareButton.hidden = YES;
            //_subscribeButton.hidden = YES;
    }
    
}

- (IBAction)gameButtonTapped:(id)sender {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    /*NSDictionary *dimensions = @{
                                 PARAMETER_USER_EMAIL_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_BOOK_ID: _book.id,
                                 
                                 };
    [delegate trackEvent:[LASTPAGE_PLAYGAMES valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[LASTPAGE_PLAYGAMES valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [LASTPAGE_PLAYGAMES valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    [userObject setObject:_book.id forKey:@"bookID"];
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
    
    NSDictionary *jsonDict = [self getJsonDictForBook];
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
        gamesListViewController.jsonString = [self getJsonContentForBook];
        
        NSString *jsonLocation = [AePubReaderAppDelegate returnBookJsonPath:_book];
        

        gamesListViewController.folderLocation = jsonLocation;
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

- (IBAction)pushToCoverView:(id)sender{
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
    [dimensions setObject:@"read_btn_click" forKey:PARAMETER_ACTION];
    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
    [dimensions setObject:_book.title forKey:PARAMETER_BOOK_TITLE];
    [dimensions setObject:_book.id forKey:PARAMETER_BOOK_ID];
    [dimensions setObject:@"Read again button click" forKey:PARAMETER_EVENT_DESCRIPTION];
    if(userEmail){
        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
    }
    [delegate trackEventAnalytic:@"read_btn_click" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"read_btn_click"];
    
   // [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:4] animated:YES];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count - 3)] animated:YES];
}

- (void) loadRecommendedBooks:(NSString *)story_Id_value{
    MangoApiController *apiController = [MangoApiController sharedApiController];
    
    NSString *url;
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    url = RECOMMENDED_STORIES;
    [paramDict setObject:story_Id_value forKey:@"story_id"];
//    [paramDict setObject:IOS forKey:PLATFORM];
//    [paramDict setObject:VERSION_NO forKey:VERSION];
    [MBProgressHUD showHUDAddedTo:self.recommendedBooksView animated:YES];
    [apiController getListOf:url ForParameters:paramDict withDelegate:self];
}

- (void)getImageForUrl:(NSString *)urlString {
    MangoApiController *apiController = [MangoApiController sharedApiController];
    
    [apiController getImageAtUrl:urlString withDelegate:self];
}

- (void)reloadViewsWithArray:(NSArray *)dataArray ForType:(NSString *)type {
    if([type hasSuffix:@"recommended"]){
    [MBProgressHUD hideAllHUDsForView:self.recommendedBooksView animated:YES];
    //MangoApiController *apiController = [MangoApiController sharedApiController];
    
    //[apiController getImageAtUrl:urlString withDelegate:self];
    _tempItemArray = [NSMutableArray arrayWithArray:dataArray];
    for(int i = 0; i< _tempItemArray.count; ++i){
        NSString *imageURLString = [_tempItemArray[i] objectForKey:@"thumb"];

        
        for (UIView* view in [_recommendedBooksView subviews]) {
            if([view isKindOfClass:[UILabel class]]){
                UILabel *label = (UILabel*)view;
                if(label.tag == (i+1)){
                    label.text = [_tempItemArray[i] objectForKey:@"title"];
                }
            }
            else if([view isKindOfClass:[UIButton class]]){
                
                UIButton *button = (UIButton*)view;
                if(button.tag == (i+1)){
                    button.userInteractionEnabled = YES;
                   // UIImage *pImage=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLString]]];
                    CALayer *btnLayer = [button layer];
                    [btnLayer setMasksToBounds:YES];
                    [btnLayer setCornerRadius:15.0f];
                    [btnLayer setBorderWidth:3.0f];
                    [btnLayer setBorderColor:[UIColor brownColor].CGColor];
                   // [button setBackgroundImage:pImage forState:UIControlStateNormal];
                    [self downloadImageWithURL:[NSURL URLWithString:imageURLString] completionBlock:^(BOOL succeeded, NSData *data) {
                        if (succeeded) {
                          //  button.imageView.image = [[UIImage alloc] initWithData:data];
                            [button setBackgroundImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
                        }
                    }];
                }
            }
        }
    }
    }
    else{
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSDictionary *passDictionaryData;
        if(dataArray.count){
            passDictionaryData = dataArray[0];
        }
        else{
            passDictionaryData = nil;
        }
            
        [self showBookDetailsForBook:passDictionaryData];
        
    }
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, NSData *data))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            completionBlock(YES, data);
        } else {
            completionBlock(NO, nil);
        }
    }];
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

- (IBAction)bookTapped:(id)sender{
    
    if(![self connected])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please internet connection appears offline, please try later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if([sender tag]){
        
        /*if(!validUserSubscription && storyAsAppFilePath){
            [self clickOnSubscribe:0];
        }
        else{
            [self showBookDetailsForBook:_tempItemArray[[sender tag]-1]];
        }*/
        NSString *bookid = [_tempItemArray[[sender tag]-1] objectForKey:@"id"];
        [self getLiveStoryByID:bookid];
    }
}

- (void) getLiveStoryByID :(NSString *)bookID{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    MangoApiController *apiController = [MangoApiController sharedApiController];
    NSString *url;
    url = [LIVE_STORIES_WITH_ID stringByAppendingString:[NSString stringWithFormat:@"/%@",bookID]];
    
    [apiController getListOf:url ForParameters:nil withDelegate:self];
}

- (void)showBookDetailsForBook:(NSDictionary *)bookDict {
    
    BookDetailsViewController *bookDetailsViewController;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *storyOfDayId = [prefs valueForKey:@"StoryOfTheDayBookId"];
    if(bookDict == nil){
        return;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        bookDetailsViewController = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController_iPhone" bundle:nil];
        
    }
    else{
        bookDetailsViewController = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController" bundle:nil];
    }
    
    bookDetailsViewController.delegate = self;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
  //  NSMutableArray *tempDropDownArray = [[NSMutableArray alloc] init];
    bookDetailsViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    bookDetailsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:bookDetailsViewController animated:YES completion:^(void) {
        bookDetailsViewController.bookTitleLabel.text = [bookDict objectForKey:@"title"];
        
        if(![[bookDict objectForKey:@"authors"] isKindOfClass:[NSNull class]] && ([[[bookDict objectForKey:@"authors"] valueForKey:@"name"] count])){
            bookDetailsViewController.bookWrittenBy.text = [NSString stringWithFormat:@"by %@", [[[bookDict objectForKey:@"authors"] valueForKey:@"name"] componentsJoinedByString:@", "]];
        }
        else{
            bookDetailsViewController.bookWrittenBy.text = [NSString stringWithFormat:@""];
        }
        
        
        if(![[[bookDict objectForKey:@"info"] objectForKey:@"tags"]isKindOfClass:[NSNull class]]){
            bookDetailsViewController.bookTags.text = [NSString stringWithFormat:@"Tags: %@", [[[bookDict objectForKey:@"info"] objectForKey:@"tags"] componentsJoinedByString:@", "]];
        }
        else{
            bookDetailsViewController.bookTags.text = [NSString stringWithFormat:@"Tags: -"];
        }
        
        if(![[bookDict objectForKey:@"narrators"] isKindOfClass:[NSNull class]] && ([[[bookDict objectForKey:@"narrators"] valueForKey:@"name"] count])){
            bookDetailsViewController.bookNarrateBy.text = [NSString stringWithFormat:@"Narrated by: %@", [[[bookDict objectForKey:@"narrators"] valueForKey:@"name"] componentsJoinedByString:@", "]];
        }
        else{
            bookDetailsViewController.bookNarrateBy.text = [NSString stringWithFormat:@""];
        }
        
        if(![[bookDict objectForKey:@"illustrators"] isKindOfClass:[NSNull class]] && ([[[bookDict objectForKey:@"illustrators"] valueForKey:@"name"] count])){
            bookDetailsViewController.bookIllustratedBy.text = [NSString stringWithFormat:@"Illustrated by: %@", [[[bookDict objectForKey:@"illustrators"] valueForKey:@"name"] componentsJoinedByString:@", "]];
        }
        else{
            bookDetailsViewController.bookIllustratedBy.text = [NSString stringWithFormat:@""];
        }
        
        [bookDetailsViewController.dropDownButton setTitle:[[bookDict objectForKey:@"info"] objectForKey:@"language"] forState:UIControlStateNormal];
      //  [tempDropDownArray addObject:[[bookDict objectForKey:@"info"] objectForKey:@"language"]];
      //  [tempDropDownArray addObjectsFromArray:[[bookDict objectForKey:@"available_languages"] valueForKey:@"language"]];
       // [bookDetailsViewController.dropDownArrayData addObjectsFromArray:[[NSSet setWithArray:tempDropDownArray] allObjects]];
        // [bookDetailsViewController.dropDownArrayData addObject:@"Record new language"];
        
        //[bookDetailsViewController.dropDownView.uiTableView reloadData];
        bookDetailsViewController.bookAvailGamesNo.text = [NSString stringWithFormat:@"Games # %@",[bookDict objectForKey:@"widget_count"]];
        
        bookDetailsViewController.ageLabel.text = [NSString stringWithFormat:@"Age %@", [bookDict objectForKey:@"combined_age_group"]];
        
        bookDetailsViewController.gradeLevel.text = [NSString stringWithFormat:@"Grade %@", [bookDict objectForKey:@"combined_grades"]];
        
        if(![[[bookDict objectForKey:@"info"] objectForKey:@"learning_levels"] isKindOfClass:[NSNull class]]){
            bookDetailsViewController.readingLevelLabel.text = [NSString stringWithFormat:@"Reading Level : %@", [bookDict objectForKey:@"combined_reading_level"]];
        }
        else {
            bookDetailsViewController.readingLevelLabel.text = [NSString stringWithFormat:@"Reading Level : -"];
        }
        
        bookDetailsViewController.numberOfPagesLabel.text = [NSString stringWithFormat:@"Pages # %d", [[bookDict objectForKey:@"page_count"] intValue]];
        if([[bookDict objectForKey:@"price"] floatValue] == 0.00){
            bookDetailsViewController.priceLabel.text = [NSString stringWithFormat:@"FREE"];
       //     [bookDetailsViewController.buyButton setImage:[UIImage imageNamed:@"Read-now.png"] forState:UIControlStateNormal];
        }
        else{
            bookDetailsViewController.priceLabel.text = [NSString stringWithFormat:@"$ %.2f", [[bookDict objectForKey:@"price"] floatValue]];
        //    [bookDetailsViewController.buyButton setImage:[UIImage imageNamed:@"buynow.png"] forState:UIControlStateNormal];
        }
        
        if(![[[bookDict objectForKey:@"info"] objectForKey:@"categories"] isKindOfClass:[NSNull class]]){
            bookDetailsViewController.categoriesLabel.text = [NSString stringWithFormat:@"Categories : %@",[[[bookDict objectForKey:@"info"] objectForKey:@"categories"] componentsJoinedByString:@", "]];
            bookDetailsViewController.singleCategoryLabel.text = [NSString stringWithFormat:@"Categories : %@",[[[bookDict objectForKey:@"info"] objectForKey:@"categories"] componentsJoinedByString:@", "]];
        }
        else{
            bookDetailsViewController.categoriesLabel.text = [NSString stringWithFormat:@"Category: -"];
        }
        
        int availableLanguagesCount = [[bookDict valueForKey:@"available_languages"] count];
        if(availableLanguagesCount){
            bookDetailsViewController.labelAvaillanguageCount.text = [NSString stringWithFormat:@"Available in %d languages :", availableLanguagesCount+1];
        }
        else{
            bookDetailsViewController.labelAvaillanguageCount.text = [NSString stringWithFormat:@"Available in %d language :", availableLanguagesCount+1];
            bookDetailsViewController.dropDownButton.userInteractionEnabled = NO;
        }
        
        [bookDetailsViewController setIdOfDisplayBook:[bookDict objectForKey:@"id"]];
        bookDetailsViewController.descriptionLabel.text = [bookDict objectForKey:@"synopsis"];
        
        NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
        [dimensions setObject:@"show_book" forKey:PARAMETER_ACTION];
        [dimensions setObject:@"show_book" forKey:PARAMETER_CURRENT_PAGE];
        [dimensions setObject:@"Show book details" forKey:PARAMETER_EVENT_DESCRIPTION];
        [dimensions setObject:[bookDict objectForKey:@"id"] forKey:PARAMETER_BOOK_ID];
        [dimensions setObject:[bookDict objectForKey:@"title"] forKey:PARAMETER_BOOK_TITLE];
        [dimensions setObject:currentPage forKey:PARAMETER_BOOKDETAIL_SOURCE];
        if(userEmail){
            [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
        }
        [delegate trackEventAnalytic:@"show_book" dimensions:dimensions];
        [delegate eventAnalyticsDataBrowser:dimensions];
        [delegate trackMixpanelEvents:dimensions eventName:@"show_book"];
        
        if([storyOfDayId isEqualToString:[bookDict objectForKey:@"id"]]){
            [bookDetailsViewController.buyButton setTitle: @"Read Now" forState: UIControlStateNormal];
            bookDetailsViewController.imgStoryOfDay.hidden = NO;
        }
        else{
            [bookDetailsViewController.buyButton setTitle: @"Subscribe Now" forState: UIControlStateNormal];
        }
        
        bookDetailsViewController.selectedProductId = [bookDict objectForKey:@"id"];
        [bookDetailsViewController setIdOfDisplayBook:[bookDict objectForKey:@"id"]];
        bookDetailsViewController.baseNavView = currentPage;
        bookDetailsViewController.imageUrlString = [[bookDict objectForKey:@"thumb"] stringByReplacingOccurrencesOfString:@"thumb_new" withString:@"ipad_banner"];
    }];
    bookDetailsViewController.view.superview.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    bookDetailsViewController.view.layer.cornerRadius = 2.5;
    NSArray *vComp = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[vComp objectAtIndex:0] intValue] >= 8) {
        bookDetailsViewController.preferredContentSize = CGSizeMake(779, 529);
    }
    else{
        bookDetailsViewController.view.superview.bounds = CGRectMake(0, 0, 779, 529);
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
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
        
        [self socialSharingOrLike:0];
    }
    else{
        //close subscription plan
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Please enter correct birth year!!" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alert show];
        [self performSelector:@selector(hideAlert:) withObject:alert afterDelay:1.5];
    }
    _settingsProbSupportView.hidden = YES;
    _settingsProbView.hidden = YES;
    _textQuesSolution.text = @"";
}

-(void)hideAlert:(UIAlertView*)alert
{
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

- (IBAction)closeParentalControl:(id)sender{
    
    [self.textQuesSolution endEditing:YES];
    _settingsProbSupportView.hidden = YES;
    _settingsProbView.hidden = YES;
}


- (IBAction)socialSharingOrLike :(id)sender{
    //action for social sharing or like of the app
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
    [dimensions setObject:@"share_btn_click" forKey:PARAMETER_ACTION];
    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
    [dimensions setObject:_book.title forKey:PARAMETER_BOOK_TITLE];
    [dimensions setObject:_book.id forKey:PARAMETER_BOOK_ID];
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
    
}

- (IBAction)backButtonTap:(id)sender{
    //three conditions path & valid subscription, path and non-valid and other
    NSLog(@"nav ctrs %@", self.navigationController.viewControllers);
    if (storyAsAppFilePath) {
        /*if(!validUserSubscription){
        
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            //[self.navigationController popToRootViewControllerAnimated:YES];
            [self.navigationController popViewControllerAnimated:YES];
        }*/
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count - 3)] animated:YES];
        
        
    } else {
        //[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:] animated:YES];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count - 3)] animated:YES];
    }
}

- (IBAction)mangoReaderAppStoreLink:(id)sender{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                @"itms-apps://itunes.apple.com/us/app/mangoreader-interactive-kids/id568003822?mt=8&uo=4"]];
    
}

- (void)openBook:(Book *)bk {
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *identity=[NSString stringWithFormat:@"%@", bk.id];
    [appDelegate.dataModel displayAllData];
    
    CoverViewControllerBetterBookType *coverController;
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        
        coverController=[[CoverViewControllerBetterBookType alloc]initWithNibName:@"CoverViewControllerBetterBookType_iPhone" bundle:nil WithId:identity];
    }
    else{
        coverController=[[CoverViewControllerBetterBookType alloc]initWithNibName:@"CoverViewControllerBetterBookType" bundle:nil WithId:identity];
    }
    
    [self.navigationController pushViewController:coverController animated:YES];
}

#pragma delegate move to landing page

- (void)loadLandingPage{
    
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (IBAction)clickOnSubscribe:(id)sender{
    
    if(![self connected]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Your internet connection appears to be offline!!" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    MangoSubscriptionViewController *subscriptionViewController;

    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        
        subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController_iPhone" bundle:nil];
    }
    else{
        subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController" bundle:nil];
    }

    subscriptionViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:subscriptionViewController animated:YES completion:nil];
}

- (IBAction)backgroundTap:(id)sender {
    [_textQuesSolution resignFirstResponder];
    
}

@end
