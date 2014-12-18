
//
//  MangoStoreViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 03/12/13.
//
//

#import "MangoStoreViewController.h"
#import "Constants.h"
#import "StoreCollectionFlowLayout.h"
#import "StoreCollectionHeaderView.h"
#import "AePubReaderAppDelegate.h"
#import "MBProgressHUD.h"
#import "BooksFromCategoryViewController.h"
#import "MangoStoreCollectionViewController.h"
#import "iCarouselImageView.h"
#import "CargoBay.h"
#import "HKCircularProgressLayer.h"
#import "HKCircularProgressView.h"
#import "MyStoriesBooksViewController.h"
#import "BooksCollectionViewController.h"
#import "CoverViewControllerBetterBookType.h"
#import "MangoSubscriptionViewController.h"
#import "BookDetailsViewController.h"
#import "UIImageView+WebCache.h"
#import "LoginNewViewController.h"
#import "UINavigationController+KeyboardDismiss.h"  


@interface MangoStoreViewController () <collectionSeeAllDelegate> {
}

@property (nonatomic, strong) UIPopoverController *filterPopoverController;
@property (nonatomic, strong) UICollectionView *booksCollectionView;
@property (nonatomic, strong) IBOutlet UITextField *searchTextField;
@property (nonatomic, strong) NSMutableArray *liveStoriesArray;
@property (nonatomic, strong) NSMutableDictionary *liveStoriesFiltered;
@property (nonatomic, strong) NSMutableArray *liveStoriesFilteredWhole;
@property (nonatomic, strong) NSMutableDictionary *localImagesDictionary;
@property (nonatomic, strong) NSMutableArray *featuredStoriesArray;
@property (nonatomic, strong) NSArray *ageGroupsFoundInResponse;
@property (nonatomic, assign) BOOL liveStoriesFetched;
@property (nonatomic, assign) BOOL featuredStoriesFetched;
@property (nonatomic, strong) NSMutableArray *purchasedBooks;
@property (nonatomic, strong) NSString *currentProductPrice;
@property (nonatomic, strong) HKCircularProgressView *progressView;
@property (nonatomic, strong) NSString *selectedBookId;

@end

@implementation MangoStoreViewController

@synthesize filterPopoverController;
@synthesize liveStoriesFiltered;
@synthesize popoverControlleriPhone;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        userEmail = delegate.loggedInUserInfo.email;
    }
    return self;
}

- (void)setCategoryFlagValue:(BOOL)value {
    
    categoryflag = value;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)setCategoryDictValue:(NSDictionary*)categoryInfoDict {
    categoryDictionary = [[NSDictionary alloc] initWithDictionary:categoryInfoDict];
}

- (void)dealloc {
    //Register observer
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:[CargoBay sharedManager]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    Mixpanel *mixpanel = [Mixpanel sharedInstance];
//    [mixpanel showNotification];
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    validUserSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
    storyAsAppFilePath = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
    page = 0;
    //current view name
    currentPage = @"store_screen";
    popoverClass = [WEPopoverController class];
    // Do any additional setup after loading the view from its nib.
    _localImagesDictionary = [[NSMutableDictionary alloc] init];
    [self setupInitialUI];
    //bookDetailsViewController.priceLabel.text.font = [UIFont fontWithName:@"the_hungry_ghost" size:16.0];
    
    _viewDownloadCounter.layer.cornerRadius = 3.0f;
    [_viewDownloadCounter.layer setBorderWidth:0.5f];
    [_viewDownloadCounter.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    
    //add timer for the  automatic call
    [self setDownloadCounter:0];
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(setDownloadCounter:) userInfo:nil repeats:YES];
    
    //Register observer
    if(categoryflag){
        NSLog(@"Here is our category flagvalue");
        [self itemType:TABLE_TYPE_CATEGORIES tappedWithDetail:categoryDictionary];
    }
    else{
        _tableType = TABLE_TYPE_MAIN_STORE;
        [self getAllAgeGroups];
    }
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView:)];
    
    // Removing temporarily for bug fix
    [_hideCollectionview addGestureRecognizer:tapRecognizer];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        displayStoryNo = 4;
        limit = 12;
        
    }
    else{
        displayStoryNo = 6;
        limit = 18;
    }
    
    //[[SKPaymentQueue defaultQueue] addTransactionObserver:[CargoBay sharedManager]];
    
    if(_pushNoteBookId){
        
        [self getLiveStoryByID:_pushNoteBookId];
        //[prefs setValue:_pushNoteBookId forKey:@"StoryOfTheDayBookId"];
    }
    
    if(_landingSOTD){
        [self getDetailofStoryofDay];
    }
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(_pushSubscribe){
        int isTrialUser = [[prefs valueForKey:@"ISTRIALUSER"]integerValue];
        if(isTrialUser || (!userEmail && !validUserSubscription)){
            
            MangoSubscriptionViewController *subscriptionViewController;
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
    }
    
    if(!validUserSubscription){
        
        if(appDelegate.subscriptionInfo){
            //provide access
            
            [[MangoApiController sharedApiController]validateSubscription:appDelegate.subscriptionInfo.subscriptionTransctionId andDeviceId:appDelegate.deviceId block:^(id response, NSInteger type, NSString *error){
                NSLog(@"type --- %d", type);
                if ([[response objectForKey:@"status"] integerValue] == 1){
                    if([[response objectForKey:@"subscription_type"] isEqualToString:@"trial"]){
                        [prefs setBool:YES forKey:@"ISTRIALUSER"];
                    }
                    else{
                        [prefs setBool:NO forKey:@"ISTRIALUSER"];
                    }
                    NSLog(@"You are already subscribed");
                    [prefs setBool:YES forKey:@"USERISSUBSCRIBED"];
                    [self displayStoryoftheDay];
                }
                else{
                    int notFirstTimeDisplay = [[prefs valueForKey:@"FIRSTTIMEDISPLAY"] integerValue];
                    [prefs setBool:NO forKey:@"USERISSUBSCRIBED"];
                    
                    if(!notFirstTimeDisplay && !userEmail){
                    
                        MangoSubscriptionViewController *subscriptionViewController;
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
                    else{
                        [self displayStoryoftheDay];
                    }
                }
                
            }];
        }
        
        else{
            //no suscription info block
            
            if(!userEmail){
                int notFirstTimeDisplay = [[prefs valueForKey:@"FIRSTTIMEDISPLAY"] integerValue];
                
                [prefs setBool:NO forKey:@"USERISSUBSCRIBED"];
                
                if(!notFirstTimeDisplay){
                    /*MangoSubscriptionViewController *subscriptionViewController;
                    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
                        
                        subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController_iPhone" bundle:nil];
                    }
                    else{
                        subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController" bundle:nil];
                    }
                    [prefs setBool:YES forKey:@"FIRSTTIMEDISPLAY"];
                    subscriptionViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                    [self presentViewController:subscriptionViewController animated:YES completion:nil];*/
                }
                else{
                    [self displayStoryoftheDay];
                }
            }
            else{
            [[MangoApiController sharedApiController]validateSubscription:appDelegate.subscriptionInfo.subscriptionTransctionId andDeviceId:appDelegate.deviceId block:^(id response, NSInteger type, NSString *error){
                NSLog(@"type --- %d", type);
                if ([[response objectForKey:@"status"] integerValue] == 1){
                    if([[response objectForKey:@"subscription_type"] isEqualToString:@"trial"]){
                        [prefs setBool:YES forKey:@"ISTRIALUSER"];
                    }
                    else{
                        [prefs setBool:NO forKey:@"ISTRIALUSER"];
                    }
                    NSLog(@"You are already subscribed");
                    [prefs setBool:YES forKey:@"USERISSUBSCRIBED"];
                    [self displayStoryoftheDay];
                }
                else{
                    int notFirstTimeDisplay = [[prefs valueForKey:@"FIRSTTIMEDISPLAY"] integerValue];
                    
                    //[prefs setBool:NO forKey:@"USERISSUBSCRIBED"];
                    
                    if(!notFirstTimeDisplay){
                       /* MangoSubscriptionViewController *subscriptionViewController;
                        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
                        
                            subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController_iPhone" bundle:nil];
                        }
                        else{
                            subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController" bundle:nil];
                        }
                        [prefs setBool:YES forKey:@"FIRSTTIMEDISPLAY"];
                        subscriptionViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                        [self presentViewController:subscriptionViewController animated:YES completion:nil];*/
                    }
                    else{
                        [self displayStoryoftheDay];
                    }
                }
                
            }];
            }
        }
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)keyboardDidShow: (NSNotification *) notif{
    //self.booksCollectionView.userInteractionEnabled = NO;
    //_hideCollectionview.hidden = NO;
    
}

- (void)keyboardDidHide: (NSNotification *) notif{
    // Do something here
    //self.booksCollectionView.userInteractionEnabled = YES;
   // _hideCollectionview.hidden = YES;
}

- (void) viewWillAppear:(BOOL)animated{
    
    [self.view bringSubviewToFront:[_hideCollectionview superview]];
    [self.view bringSubviewToFront:[_buttonForTrialUsers superview]];
    [self.view bringSubviewToFront:[_viewDownloadCounter superview]];
    [[_hideCollectionview superview] bringSubviewToFront:_hideCollectionview];
    [[_buttonForTrialUsers superview] bringSubviewToFront:_buttonForTrialUsers];
    [[_viewDownloadCounter superview] bringSubviewToFront:_viewDownloadCounter];
    
//    if(!validUserSubscription && storyAsAppFilePath){
//        _storeBackButton.hidden = YES;
//    }
    
}

- (IBAction)testFeaturedBooks:(id)sender{
    
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


- (void) viewDidAppear:(BOOL)animated{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int subscriptionSuccess = [[prefs valueForKey:@"SubscriptionSuccess"]integerValue];
    int validateSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
    int isTrialUser = [[prefs valueForKey:@"ISTRIALUSER"]integerValue];
    if(isTrialUser){
        _buttonForTrialUsers.hidden = NO;
    }
    if(!userEmail && !validateSubscription){

        [_buttonForTrialUsers setTitle: @"Subscribe now to access Unlimited Stories" forState: UIControlStateNormal];
        _buttonForTrialUsers.hidden = NO;
    }
    
    if(subscriptionSuccess && !userEmail){
        [prefs setBool:NO forKey:@"SubscriptionSuccess"];
        EmailSubscriptionLinkViewController *emailLinkSubscriptionView;
        _buttonForTrialUsers.hidden = YES;
        
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
    [dimensions setObject:@"store_screen" forKey:PARAMETER_ACTION];
    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
    [dimensions setObject:@"Store screen open" forKey:PARAMETER_EVENT_DESCRIPTION];
    if(userEmail){
        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
    }
    [delegate trackEventAnalytic:@"store_screen" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"store_screen"];
}

- (void) dismissPopoverController{
    
     [filterPopoverController dismissPopoverAnimated:YES];
}

#pragma StoryOfTheDay
- (void) displayStoryoftheDay{
    
    NSUserDefaults *prefs=[NSUserDefaults standardUserDefaults];
    
    int validateSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
    if(storyAsAppFilePath && !validateSubscription){
        return;
    }
    
    NSString *sOTD=[prefs stringForKey:@"StoryOfTheDayCounter"];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:[NSDate date]];
    if(sOTD.length > 0){
        NSArray *items = [sOTD componentsSeparatedByString:@"_"];
        //if same date
        int currentDay = [components day];
        int dayValue = [items[0] integerValue];
        if(dayValue == currentDay){//same day
            if([items[1] integerValue] >= 2){
                //no story of the day api call
            }
            else{
                //story of the day api call
                
                int times = [items[1] integerValue];
                times ++;
                if(items.count > 2){
                    sOTD = [NSString stringWithFormat:@"%@_%d_%@", items[0], times , items[2]];
                }
                else{
                    sOTD = [NSString stringWithFormat:@"%@_%d", items[0], times];
                }
                [prefs setValue:sOTD forKey:@"StoryOfTheDayCounter"];
                [self getDetailofStoryofDay];
            }
        }
        else{//different day
            [prefs setObject:@"" forKey:@"StoryOfTheDayBookId"];
            int times = 0;
            times +=1;
            if(items.count > 2){
                sOTD = [NSString stringWithFormat:@"%@_%d_%@", items[0], times , items[2]];
            }
            else{
                sOTD = [NSString stringWithFormat:@"%d_%d", [components day], times];
            }
            [prefs setValue:sOTD forKey:@"StoryOfTheDayCounter"];
            [self getDetailofStoryofDay];
        }
        
    }
    else{//else different date
        int times = 0;
        times +=1;
        
        sOTD = [NSString stringWithFormat:@"%d_%d", [components day], times];
        [prefs setValue:sOTD forKey:@"StoryOfTheDayCounter"];
        [self getDetailofStoryofDay];
    }
}

- (void)getDetailofStoryofDay{
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
    NSString *url;
    url = [NSString stringWithFormat:@"%@",StoryOfTheDay];
    
    [apiController getListOf:url ForParameters:nil withDelegate:self];
}



-(void) setDownloadCounter:(NSTimer *)timer
{
    int noOfBooks = [BookDetailsViewController booksDownloadingNo];
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

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.searchTextField = textField;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    //[self.view endEditing:YES];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:textField.text forKey:@"id"];
    
    [_liveStoriesFilteredWhole removeAllObjects];
    page = 0;
    indexval = 0;
    
    [self itemType:TABLE_TYPE_SEARCH tappedWithDetail:dict];
    self.searchTextField = nil;
    return YES;
}

//- (void)textFieldDidEndEditing:(UITextField *)textField {
    /*    MangoApiController *apiController = [MangoApiController sharedApiController];
     //    apiController.delegate = self;
     [apiController getListOf:LIVE_STORIES_SEARCH ForParameters:[NSDictionary dictionaryWithObject:textField.text forKey:@"q"] withDelegate:self];
     */
//}

#pragma mark - Action Methods

- (IBAction)goBackToStoryPage:(id)sender {

    if(!validUserSubscription && storyAsAppFilePath){
        
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
 
   // else{
       // [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
     //   [self.navigationController popViewControllerAnimated:YES];
    //}
    
}

- (IBAction)filterSelected:(id)sender {
    
    [_liveStoriesFilteredWhole removeAllObjects];
    page = 0;
    indexval = 0;
    [self.searchTextField resignFirstResponder];
    self.searchTextField = nil;
    ItemsListViewController *textTemplatesListViewController = [[ItemsListViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [textTemplatesListViewController.view setFrame:CGRectMake(0, 0, 150, 150)];
    textTemplatesListViewController.delegate = self;
    textTemplatesListViewController.filterTag = [sender tag];
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case CATEGORY_TAG: {
            textTemplatesListViewController.tableType = TABLE_TYPE_CATEGORIES;
        }
            break;
            
        case AGE_TAG: {
            textTemplatesListViewController.tableType = TABLE_TYPE_AGE_GROUPS;
        }
            break;
            
        case LANGUAGE_TAG: {
            textTemplatesListViewController.tableType = TABLE_TYPE_LANGUAGE;
        }
            break;
            
        case GRADE_TAG: {
            textTemplatesListViewController.tableType = TABLE_TYPE_GRADE;
        }
            break;
            
        default:
            break;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    
        if (!self.popoverControlleriPhone) {
            
            self.popoverControlleriPhone = [[popoverClass alloc] initWithContentViewController:textTemplatesListViewController] ;
            self.popoverControlleriPhone.delegate = self;
            self.popoverControlleriPhone.passthroughViews = [NSArray arrayWithObject:self.view];
            
            [self.popoverControlleriPhone presentPopoverFromRect:button.frame
                                                    inView:self.view
                                  permittedArrowDirections:UIPopoverArrowDirectionUp
                                                  animated:YES];
            
          
        } else {
            [self.popoverControlleriPhone dismissPopoverAnimated:YES];
            self.popoverControlleriPhone = nil;
        }
        
    }
    else{
        self.filterPopoverController = [[UIPopoverController alloc] initWithContentViewController:textTemplatesListViewController];
        [self.filterPopoverController setPopoverContentSize:CGSizeMake(250, 250)];
        self.filterPopoverController.delegate = self;
        [self.filterPopoverController.contentViewController.view setBackgroundColor:COLOR_LIGHT_GREY];
        [self.filterPopoverController presentPopoverFromRect:button.frame inView:self.view.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    
   
}

- (void) tapOnView:(UIRotationGestureRecognizer *)recognizer{
    
    [self.view.superview endEditing:YES];
    [self.searchTextField resignFirstResponder];
    
    for (UIView *subView in self.view.subviews) {
        if ([subView isFirstResponder]) {
             NSLog(@"%@", subView.class);
        }
    }
    
}

#pragma mark - Post API Delegate

- (BOOL) validBookUrl:(NSString*) livestoryWithUrl{
    
    
    NSString *searchString = livestoryWithUrl;
    NSString *regexString = @"livestories/[A-Z0-9a-z]{24}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexString];
    BOOL isStringValid = [predicate evaluateWithObject:searchString];
    return isStringValid;
}

- (BOOL) validStoryOfTheday :(NSString *) storyofdayurl{
        NSString *searchString = storyofdayurl;
        NSString *regexString = @"campaign/today";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexString];
        BOOL isStringValid = [predicate evaluateWithObject:searchString];
        return isStringValid;
}

- (void)reloadViewsWithArray:(NSArray *)dataArray ForType:(NSString *)type {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [_actIndicator removeFromSuperview];
    NSDictionary *passDictionaryData;
    if(dataArray.count){
        passDictionaryData = dataArray[0];
    }
    else{
        passDictionaryData = nil;
    }
    if([self validBookUrl:type]){
        
        [self showBookDetailsForBook:passDictionaryData];
    }
    else if([self validStoryOfTheday:type]){
        [prefs setObject:[passDictionaryData objectForKey:@"id"] forKey:@"StoryOfTheDayBookId"];
        //[self showBookDetailsForBook:passDictionaryData];
        [self getLiveStoryByID:[passDictionaryData objectForKey:@"id"]];
        
    }
    else{
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
            [paramDict setObject:[NSNumber numberWithInt:4] forKey:LIMIT];
        }
        else{
            [paramDict setObject:[NSNumber numberWithInt:6] forKey:LIMIT];
        }
   
       // [paramDict setObject:IOS forKey:PLATFORM];
        //    [paramDict setObject:VERSION_NO forKey:VERSION];

        if ([type isEqualToString:AGE_GROUPS]) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        self.ageGroupsFoundInResponse = dataArray;
        
        MangoApiController *apiController = [MangoApiController sharedApiController];
        
        //Get Stories For Age Groups
        /*for (NSDictionary *ageGroupDict in self.ageGroupsFoundInResponse) {
            NSString *ageGroup = [ageGroupDict objectForKey:NAME];
            [apiController getListOf:[STORY_FILTER_AGE_GROUP stringByAppendingString:ageGroup] ForParameters:paramDict withDelegate:self];
        }*/
        //
        [apiController getListOf:STORY_FILTER_ALL_AGE_GROUPS ForParameters:paramDict withDelegate:self];
        //Get Featured Stories
        if (!_featuredStoriesArray) {
           
//            [paramDict setObject:IOS forKey:PLATFORM];
        
            [apiController getListOf:FEATURED_STORIES ForParameters:paramDict withDelegate:self];
        }
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }else if ([type isEqualToString:FEATURED_STORIES]) {
            if (!_featuredStoriesArray) {
                _featuredStoriesArray = [[NSMutableArray alloc] init];
            }
            [_featuredStoriesArray addObjectsFromArray:dataArray];
            _featuredStoriesFetched = YES;
        }//else if ([type rangeOfString:STORY_FILTER_AGE_GROUP].location != NSNotFound && _tableType == TABLE_TYPE_MAIN_STORE) {
        else if ([type rangeOfString:STORY_FILTER_ALL_AGE_GROUPS].location != NSNotFound && _tableType == TABLE_TYPE_MAIN_STORE) {
        //NSArray *methodNameComponents = [type componentsSeparatedByString:@"/"];
        //NSString *ageGroup = [methodNameComponents lastObject];
            for (NSDictionary *ageGroupDict in self.ageGroupsFoundInResponse) {
                NSString *ageGroup = [ageGroupDict objectForKey:NAME];
                NSMutableArray *tempBookAgeArray = [[NSMutableArray alloc] init];
                for(NSMutableDictionary *ageGroupBookInfo in dataArray){
                
                    if([[[ageGroupBookInfo objectForKey:@"info"] valueForKey:@"age_group"] isEqualToString:ageGroup]){
                        //NSString  *newCoverImage = [NSString stringWithFormat:@"/live_stories/%@/%@",[ageGroupBookInfo objectForKey:@"id"], [ageGroupBookInfo objectForKey:@"cover"]];
                        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
                        tempDict = [ageGroupBookInfo mutableCopy];
                        //[tempDict setValue:newCoverImage forKey:@"cover"];
                        [tempBookAgeArray addObject:tempDict];
                    }
                }
                if (!liveStoriesFiltered) {
                    liveStoriesFiltered = [[NSMutableDictionary alloc] init];
                }
                [liveStoriesFiltered setObject:tempBookAgeArray forKey:ageGroup];
            }
//        if (!liveStoriesFiltered) {
//            liveStoriesFiltered = [[NSMutableDictionary alloc] init];
//        }
//        [liveStoriesFiltered setObject:dataArray forKey:ageGroup];
        } else {
            NSArray *methodNameComponents = [type componentsSeparatedByString:@"/"];
            NSString *filterString = [methodNameComponents lastObject];
        
        if (!liveStoriesFiltered) {
            liveStoriesFiltered = [[NSMutableDictionary alloc] init];
            
        }
        
        if(indexval >limit){
            [_liveStoriesFilteredWhole addObjectsFromArray:dataArray];
            [liveStoriesFiltered setObject:_liveStoriesFilteredWhole forKey:filterString];
           
        }
        else
        {
        _liveStoriesFilteredWhole = [[NSMutableArray alloc] init];
        [_liveStoriesFilteredWhole addObjectsFromArray:dataArray];
        [liveStoriesFiltered removeAllObjects];
        [liveStoriesFiltered setObject:dataArray forKey:filterString];
        }
        
    }
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
      //  [self.booksCollectionView reloadItemsAtIndexPaths:[self.booksCollectionView indexPathsForVisibleItems]];
       /* for(int i = indexval+1; i <((page+1)*18)-1 ; ++i){
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.booksCollectionView reloadItemsAtIndexPaths:indexPaths];
            });
        }*/
        //[self.booksCollectionView reloadData];
    [_booksCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    [_storiesCarousel performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }
}

- (void)getBookAtPath:(NSURL *)filePath {
    
    /*AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate unzipExistingJsonBooks];*/
    
    /*MyStoriesBooksViewController *myStoriesBooksViewController = [[MyStoriesBooksViewController alloc] initWithNibName:@"MyStoriesBooksViewController" bundle:nil];
    myStoriesBooksViewController.toEdit = NO;
    
    [self.navigationController pushViewController:myStoriesBooksViewController animated:YES];*/
    
    /// -----
    
    /*BooksFromCategoryViewController *booksCategoryViewController=[[BooksFromCategoryViewController alloc]initWithNibName:@"BooksFromCategoryViewController" bundle:nil withInitialIndex:0];
    booksCategoryViewController.toEdit = NO;
    [self.navigationController pushViewController:booksCategoryViewController animated:YES];*/
    
    /// -----
    BooksCollectionViewController *booksCollectionViewController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        booksCollectionViewController = [[BooksCollectionViewController alloc] initWithNibName:@"BooksCollectionViewController_iPhone" bundle:nil];
    }
    else{
        booksCollectionViewController = [[BooksCollectionViewController alloc] initWithNibName:@"BooksCollectionViewController" bundle:nil];
    }
    
    booksCollectionViewController.toEdit = NO;
    [self.navigationController pushViewController:booksCollectionViewController animated:YES];
}

- (void)updateProgress:(NSNumber *)progress {
    if (!_progressView) {
        _progressView = [[HKCircularProgressView alloc] initWithFrame:CGRectMake(self.view.center.x - 50, self.view.center.y - 50, 100, 100)];
        _progressView.max = 100.0f;
        _progressView.step = 0.0f;
        [self.view addSubview:_progressView];
    }
    _progressView.current = [progress floatValue];
}

#pragma mark - Purchased Manager Call Back

- (void)itemReadyToUse:(NSString *)productId ForTransaction:(NSString *)transactionId {
    MangoApiController *apiController = [MangoApiController sharedApiController];
    [apiController downloadBookWithId:productId withDelegate:self ForTransaction:transactionId];
    
    _selectedBookId = productId;
}

#pragma mark - Get Books

- (void)getFilteredStories:(NSString *)filterName {
    filterKey = filterName;
    filterName = [filterName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    MangoApiController *apiController = [MangoApiController sharedApiController];
    
    NSString *url;
    
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    
    //[paramDict setObject:IOS forKey:PLATFORM];
//    [paramDict setObject:VERSION_NO forKey:VERSION];
    [paramDict setObject:[NSNumber numberWithInt:limit] forKey:LIMIT];
    indexval = indexval+limit-1;
    [paramDict setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    
    switch (_tableType) {
        case TABLE_TYPE_CATEGORIES: {
            
            url = [STORY_FILTER_CATEGORY stringByAppendingString:filterName];
        }
            break;
            
        case TABLE_TYPE_AGE_GROUPS: {
            
            url = [STORY_FILTER_AGE_GROUP stringByAppendingString:filterName];
        }
            break;
            
        case TABLE_TYPE_LANGUAGE: {
            
            url = [STORY_FILTER_LANGUAGES stringByAppendingString:filterName];
        }
            break;
            
        case TABLE_TYPE_GRADE: {
            
            url = [STORY_FILTER_GRADE stringByAppendingString:filterName];
        }
            break;
            
        case TABLE_TYPE_SEARCH: {
            
            url = LIVE_STORIES_SEARCH;
            [self.searchTextField endEditing:YES];
            [paramDict setObject:filterKey forKey:@"q"];
            NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
            [dimensions setObject:@"search" forKey:PARAMETER_ACTION];
            [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
            [dimensions setObject:filterName forKey:PARAMETER_SEARCH_KEYWORD];
            [dimensions setObject:@"Store search screen" forKey:PARAMETER_EVENT_DESCRIPTION];
            if(userEmail){
                [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
            }
            [delegate trackEventAnalytic:@"search" dimensions:dimensions];
            [delegate eventAnalyticsDataBrowser:dimensions];
            [delegate trackMixpanelEvents:dimensions eventName:@"search"];
            /*NSDictionary *dimensions = @{
                                         PARAMETER_USER_EMAIL_ID : ID,
                                         PARAMETER_DEVICE: IOS,
                                         PARAMETER_SEARCH_KEYWORD: filterName
                                         };
            [delegate trackEvent:[STORE_SEARCH valueForKey:@"description"] dimensions:dimensions];
            PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
            [userObject setObject:[STORE_SEARCH valueForKey:@"value"] forKey:@"eventName"];
            [userObject setObject: [STORE_SEARCH valueForKey:@"description"] forKey:@"eventDescription"];
            [userObject setObject:viewName forKey:@"viewName"];
            [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
            [userObject setObject:delegate.country forKey:@"deviceCountry"];
            [userObject setObject:delegate.language forKey:@"deviceLanguage"];
            [userObject setObject:filterName forKey:@"storeSearchKey"];
            if(userEmail){
                [userObject setObject:ID forKey:@"emailID"];
            }
            [userObject setObject:IOS forKey:@"device"];
            [userObject saveInBackground];*/
        }
            break;
            
        default:
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            //[_booksCollectionView reloadData];
            return;
    }
    if(page  == 0){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [apiController getListOf:url ForParameters:paramDict withDelegate:self];
}

- (void)getAllAgeGroups {
    MangoApiController *apiController = [MangoApiController sharedApiController];
    [apiController getListOf:AGE_GROUPS ForParameters:nil withDelegate:self];
}

- (void)setupInitialUI {
    
    CGRect viewFrame = self.view.bounds;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        _booksCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(CGRectGetMinX(viewFrame), 35, CGRectGetWidth(viewFrame), CGRectGetHeight(viewFrame)-38) collectionViewLayout:layout];
        
    }
    else{
        _booksCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(CGRectGetMinX(viewFrame), 80, CGRectGetWidth(viewFrame), CGRectGetHeight(viewFrame)-80) collectionViewLayout:layout];
    }
    
    _booksCollectionView.dataSource = self;
    _booksCollectionView.delegate =self;
    [_booksCollectionView registerClass:[StoreBookCarouselCell class] forCellWithReuseIdentifier:STORE_BOOK_CAROUSEL_CELL_ID];
    [_booksCollectionView registerClass:[StoreBookCell class] forCellWithReuseIdentifier:STORE_BOOK_CELL_ID];
    [_booksCollectionView registerClass:[StoreCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HEADER_ID];
    [_booksCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Section0"];
    [_booksCollectionView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_booksCollectionView];
}

#pragma mark - Items Delegate

- (void)itemType:(int)itemType tappedWithDetail:(NSDictionary *)detailDict {
    [self.filterPopoverController dismissPopoverAnimated:YES];
    [self.popoverControlleriPhone dismissPopoverAnimated:YES];
    NSString *detailId = [detailDict objectForKey:@"id"];
    NSString *detailTitle = [detailDict objectForKey:@"title"];
    
    if(!detailTitle) {
        detailTitle = detailId;     // id is same as title.... detailTitle will be nil.
    }
    
    _tableType = itemType;
    
    [self getFilteredStories:detailTitle];
}

- (void)seeAllTapped:(NSInteger)section {
    if (_tableType == TABLE_TYPE_MAIN_STORE) {
        _tableType = TABLE_TYPE_AGE_GROUPS;
        
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
        [dimensions setObject:@"see_more" forKey:PARAMETER_ACTION];
        [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
        [dimensions setObject:@"Store see more click" forKey:PARAMETER_EVENT_DESCRIPTION];
        [dimensions setObject:[self.ageGroupsFoundInResponse[section-1] objectForKey:NAME] forKey:PARAMETER_SEARCH_FILTER];
        if(userEmail){
            [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
        }
        [delegate trackEventAnalytic:@"see_more" dimensions:dimensions];
        [delegate eventAnalyticsDataBrowser:dimensions];
        [delegate trackMixpanelEvents:dimensions eventName:@"see_more"];
        
        [self getFilteredStories:[self.ageGroupsFoundInResponse[section-1] objectForKey:NAME]];
    } else {
        _tableType = TABLE_TYPE_MAIN_STORE;
        [self getAllAgeGroups];
        self.ageGroupsFoundInResponse = nil;
        _featuredStoriesArray = nil;
        liveStoriesFiltered = nil;
        [_booksCollectionView removeFromSuperview];
        _booksCollectionView = nil;
        [_storiesCarousel removeFromSuperview];
        _storiesCarousel = nil;
        [self setupInitialUI];
    }
    
    //----
    /*MangoStoreCollectionViewController *selectedCategoryViewController = [[MangoStoreCollectionViewController alloc] initWithNibName:@"MangoStoreCollectionViewController" bundle:nil];
    
    selectedCategoryViewController.selectedItemTitle = [self.ageGroupsFoundInResponse[section-1] objectForKey:NAME];
    selectedCategoryViewController.tableType = TABLE_TYPE_AGE_GROUPS;
    NSString *ageGroup = [[self.ageGroupsFoundInResponse objectAtIndex:section-1] objectForKey:NAME];
    selectedCategoryViewController.liveStoriesQueried = [liveStoriesFiltered objectForKey:ageGroup];
    [self.navigationController pushViewController:selectedCategoryViewController animated:YES];*/
}

#pragma mark - iCarousel Delegates

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    if (_featuredStoriesArray) {
        return [_featuredStoriesArray count];
    }
    return 5;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    iCarouselImageView *storyImageView = (iCarouselImageView *)[view viewWithTag:iCarousel_VIEW_TAG];
    
    if (!storyImageView) {
        
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            storyImageView = [[iCarouselImageView alloc] initWithFrame:CGRectMake(0, 0, 173, 134)];
        }
        else{
            storyImageView = [[iCarouselImageView alloc] initWithFrame:CGRectMake(0, 0, 342, 256)];
        }
        
        storyImageView.delegate = self;
    }
    [storyImageView setContentMode:UIViewContentModeScaleAspectFill];
    [storyImageView setClipsToBounds:YES];

    if (_featuredStoriesArray) {
        NSString *coverImageUrl = [_featuredStoriesArray[index] objectForKey:@"banner"];
        if (self.featuredStoriesFetched) {
            if ([_localImagesDictionary objectForKey:coverImageUrl]) {
                storyImageView.image = [_localImagesDictionary objectForKey:coverImageUrl];
            } else {
                [storyImageView getImageForUrl:coverImageUrl];
            }
        }
    } else {
        storyImageView.image = [UIImage imageNamed:@"page.png"];
    }
    
    return storyImageView;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    
    //if([self.searchTextField isFirstResponder]){
        
    
    //}
    if (_featuredStoriesArray) {
        //NSDictionary *bookDict = [_featuredStoriesArray objectAtIndex:index];
      //  NSMutableArray *tempDropDownArray = [[NSMutableArray alloc] init];
        if(![self connected])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please internet connection appears offline, please try later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        
        NSString *selectedFeaturedBookId = [[_featuredStoriesArray objectAtIndex:index] valueForKey:@"id"];
        [self getLiveStoryByID:selectedFeaturedBookId];
        
        /*BookDetailsViewController *bookDetailsViewController;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            bookDetailsViewController = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController_iPhone" bundle:nil];
            
        }
        else{
            bookDetailsViewController = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController" bundle:nil];
        }
        
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        bookDetailsViewController.delegate = self;
        
        [bookDetailsViewController setModalPresentationStyle:UIModalPresentationPageSheet];
        [self presentViewController:bookDetailsViewController animated:YES completion:^(void) {
            bookDetailsViewController.bookTitleLabel.text = [bookDict objectForKey:@"title"];
            
            bookDetailsViewController.bookWrittenBy.text = [NSString stringWithFormat:@"Written by: %@", [[[bookDict objectForKey:@"authors"] valueForKey:@"name"] componentsJoinedByString:@", "]];
            
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
            
            if(![[[bookDict objectForKey:@"info"] objectForKey:@"tags"]isKindOfClass:[NSNull class]] && [[bookDict objectForKey:@"info"] objectForKey:@"tags"]){
                bookDetailsViewController.bookTags.text = [NSString stringWithFormat:@"Tags: %@", [[[bookDict objectForKey:@"info"] objectForKey:@"tags"] componentsJoinedByString:@", "]];
            }
            else if([[[bookDict objectForKey:@"info"] objectForKey:@"tags"]isKindOfClass:[NSNull class]] || [[bookDict objectForKey:@"info"] objectForKey:@"tags"]){
                bookDetailsViewController.bookTags.text = [NSString stringWithFormat:@"Tags: -"];
            }
            
            [bookDetailsViewController.dropDownButton setTitle:[[bookDict objectForKey:@"info"] objectForKey:@"language"] forState:UIControlStateNormal];
           // [bookDetailsViewController.dropDownArrayData addObject:@"Record new language"];
           // [tempDropDownArray addObject:[[bookDict objectForKey:@"info"] objectForKey:@"language"]];
           // [tempDropDownArray addObjectsFromArray:[[bookDict objectForKey:@"available_languages"] valueForKey:@"language"]];
            //[bookDetailsViewController.dropDownArrayData addObjectsFromArray:[[NSSet setWithArray:tempDropDownArray] allObjects]];
            
            
          //  [bookDetailsViewController.dropDownView.uiTableView reloadData];
           
            bookDetailsViewController.bookAvailGamesNo.text = [NSString stringWithFormat:@"No. of Games: %@",[bookDict objectForKey:@"widget_count"]];
            
            bookDetailsViewController.ageLabel.text = [NSString stringWithFormat:@"Age Groups: %@", [[[bookDict objectForKey:@"info"] objectForKey:@"age_groups"] componentsJoinedByString:@", "]];
            if(![[[bookDict objectForKey:@"info"] objectForKey:@"learning_levels"] isKindOfClass:[NSNull class]]){
                bookDetailsViewController.readingLevelLabel.text = [NSString stringWithFormat:@"Reading Levels: %@", [[[bookDict objectForKey:@"info"] objectForKey:@"learning_levels"] componentsJoinedByString:@", "]];
            }
            else {
                bookDetailsViewController.readingLevelLabel.text = [NSString stringWithFormat:@"Reading Levels: -"];
            }
            bookDetailsViewController.numberOfPagesLabel.text = [NSString stringWithFormat:@"No. of pages: %d", [[bookDict objectForKey:@"page_count"] intValue]];
            
            bookDetailsViewController.priceLabel.text =  [[bookDict objectForKey:@"info"] valueForKey:@"language"];
           // if([[bookDict objectForKey:@"price"] floatValue] == 0.00){
                bookDetailsViewController.priceLabel.text = [NSString stringWithFormat:@"FREE"];
            //    [bookDetailsViewController.buyButton setImage:[UIImage imageNamed:@"Read-now.png"] forState:UIControlStateNormal];
          //  }
         //   else{
         //   bookDetailsViewController.priceLabel.text = [NSString stringWithFormat:@"$ %.2f", [[bookDict objectForKey:@"price"] floatValue]];
                //[bookDetailsViewController.buyButton setImage:[UIImage imageNamed:@"buynow.png"] forState:UIControlStateNormal];
         //   }
            
            if(![[[bookDict objectForKey:@"info"] objectForKey:@"categories"] isKindOfClass:[NSNull class]]){
                bookDetailsViewController.categoriesLabel.text = [[[bookDict objectForKey:@"info"] objectForKey:@"categories"] componentsJoinedByString:@", "];
            }
            else{
                bookDetailsViewController.categoriesLabel.text = [NSString stringWithFormat:@"Category: -"];
            }
            
            bookDetailsViewController.descriptionLabel.text = [bookDict objectForKey:@"synopsis"];
            
            NSDictionary *dimensions = @{
                                         PARAMETER_USER_ID : ID,
                                         PARAMETER_DEVICE: IOS,
                                         PARAMETER_BOOK_ID : [bookDict objectForKey:@"id"]
                                             
                                         };
            [delegate trackEvent:[STORE_FEATURED_BOOK valueForKey:@"description"] dimensions:dimensions];
            PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
            [userObject setObject:[STORE_FEATURED_BOOK valueForKey:@"value"] forKey:@"eventName"];
            [userObject setObject: [STORE_FEATURED_BOOK valueForKey:@"description"] forKey:@"eventDescription"];
            [userObject setObject:viewName forKey:@"viewName"];
            [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
            [userObject setObject:delegate.country forKey:@"deviceCountry"];
            [userObject setObject:delegate.language forKey:@"deviceLanguage"];
            [userObject setObject:[bookDict objectForKey:@"id"] forKey:@"bookID"];
            if(userEmail){
                [userObject setObject:ID forKey:@"emailID"];
            }
            [userObject setObject:IOS forKey:@"device"];
            [userObject saveInBackground];

            
            [bookDetailsViewController setIdOfDisplayBook:[bookDict objectForKey:@"id"]];
            
            bookDetailsViewController.selectedProductId = [bookDict objectForKey:@"id"];
            bookDetailsViewController.imageUrlString = [[ASSET_BASE_URL stringByAppendingString:[bookDict objectForKey:@"cover"]] stringByReplacingOccurrencesOfString:@"cover_" withString:@"banner_"];
        }];
        bookDetailsViewController.view.superview.frame = CGRectMake(([UIScreen mainScreen].applicationFrame.size.width/2)-400, ([UIScreen mainScreen].applicationFrame.size.height/2)-270, 776, 575);*/
    }
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
                return value * 1.6f;
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

#pragma mark - Book View Delegate

- (void)openBookViewWithCategory:(NSDictionary *)categoryDict {
    /*BooksCollectionViewController *booksCollectionViewController;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        booksCollectionViewController = [[BooksCollectionViewController alloc] initWithNibName:@"BooksCollectionViewController_iPhone" bundle:nil];
    }
    else{
        booksCollectionViewController = [[BooksCollectionViewController alloc] initWithNibName:@"BooksCollectionViewController" bundle:nil];
    }
    
    booksCollectionViewController.toEdit = NO;
    booksCollectionViewController.categorySelected = categoryDict;
    [self.navigationController pushViewController:booksCollectionViewController animated:YES];*/

    /// -----
    /*BooksFromCategoryViewController *booksCategoryViewController=[[BooksFromCategoryViewController alloc]initWithNibName:@"BooksFromCategoryViewController" bundle:nil withInitialIndex:0];
    booksCategoryViewController.toEdit = NO;
    booksCategoryViewController.categorySelected = categoryDict;
    [self.navigationController pushViewController:booksCategoryViewController animated:YES];*/
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

#pragma mark - Local Image Saving Delegate

- (void)iCarouselSaveImage:(UIImage *)image ForUrl:(NSString *)imageUrl {
    if (!image){return;}
    [_localImagesDictionary setObject:image forKey:imageUrl];
}

- (void)saveImage:(UIImage *)image ForUrl:(NSString *)imageUrl {
    [_localImagesDictionary setObject:image forKey:imageUrl];
    //[_booksCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    switch (_tableType) {
        case TABLE_TYPE_MAIN_STORE: {
            if(section == 0) {
                return 1;
            } else {
                NSString *ageGroup = [[self.ageGroupsFoundInResponse objectAtIndex:section-1] objectForKey:NAME];
                
                if ([liveStoriesFiltered objectForKey:ageGroup]) {
                    return MIN(displayStoryNo, [[liveStoriesFiltered objectForKey:ageGroup] count]);
                }
                return displayStoryNo;
            }
        }
            break;
            
        default: {
            
            return [[liveStoriesFiltered objectForKey:[[liveStoriesFiltered allKeys] firstObject]] count];
           
           
        }
            break;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    switch (_tableType) {
        case TABLE_TYPE_MAIN_STORE: {
            return self.ageGroupsFoundInResponse.count + 1;          // +1 for iCarousel at Section - 0.
        }
            break;
            
        default: {
            return 1;
        }
            break;
    }
    return 0;          // +1 for iCarousel at Section - 0.
}

- (void)setupCollectionViewCell:(StoreBookCell *)cell WithDict:(NSDictionary *)bookDict {
    if([[bookDict objectForKey:@"price"] floatValue] == 0.00){
       // cell.bookPriceLabel.text = [NSString stringWithFormat:@"FREE"];
        cell.bookPriceLabel.text = [[bookDict objectForKey:@"info"] valueForKey:@"language"];
    }
    else{
      //  cell.bookPriceLabel.text = [NSString stringWithFormat:@"$ %.2f", [[bookDict objectForKey:@"price"] floatValue]];
        cell.bookPriceLabel.text = [[bookDict objectForKey:@"info"] valueForKey:@"language"];
    }
    cell.bookPriceLabel.font = [UIFont systemFontOfSize:14];
    
    cell.bookTitleLabel.text = [bookDict objectForKey:@"title"];
    [cell.bookTitleLabel setFrame:CGRectMake(2, cell.bookTitleLabel.frame.origin.y, cell.bookTitleLabel.frame.size.width, [cell.bookTitleLabel.text sizeWithFont:cell.bookTitleLabel.font constrainedToSize:CGSizeMake(cell.bookTitleLabel.frame.size.width, 50)].height)];
    [cell setNeedsLayout];
    
    //cell.imageUrlString = [[bookDict objectForKey:@"cover"] stringByReplacingOccurrencesOfString:@"cover_" withString:@"cover_"];
    cell.imageUrlString = [bookDict objectForKey:@"thumb"];
    cell.bookImageView.image = nil;
    
    [cell.bookImageView setImageWithURL:[NSURL URLWithString:cell.imageUrlString]
                       placeholderImage:[UIImage imageNamed:@""]];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (_tableType) {
        case TABLE_TYPE_MAIN_STORE: {
            if(indexPath.section == 0) {
                StoreBookCarouselCell *cell = [cv dequeueReusableCellWithReuseIdentifier:STORE_BOOK_CAROUSEL_CELL_ID forIndexPath:indexPath];
                
                if (!_storiesCarousel) {
                    
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                        
                        _storiesCarousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 10, 984, 130)];
                    }
                    else{
                        _storiesCarousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, 984, 260)];
                        
                    }
                    _storiesCarousel.delegate = self;
                    _storiesCarousel.dataSource = self;
                    _storiesCarousel.type = iCarouselTypeCoverFlow;
                    [cell.contentView addSubview:_storiesCarousel];
                }
                
                [_storiesCarousel reloadData];
                return cell;
            } else {
                StoreBookCell *cell = [cv dequeueReusableCellWithReuseIdentifier:STORE_BOOK_CELL_ID forIndexPath:indexPath];
                cell.delegate = self;
                
                if(liveStoriesFiltered) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    NSString *ageGroup = [[self.ageGroupsFoundInResponse objectAtIndex:indexPath.section-1] objectForKey:NAME];
                    NSDictionary *bookDict= [[liveStoriesFiltered objectForKey:ageGroup] objectAtIndex:indexPath.row];
                    
                    if (bookDict) {
                        [self setupCollectionViewCell:cell WithDict:bookDict];
                    }
                }
                
                return cell;
            }
        }
            break;
            
        default: {
            
            StoreBookCell *cell = [cv dequeueReusableCellWithReuseIdentifier:STORE_BOOK_CELL_ID forIndexPath:indexPath];
            cell.delegate = self;
            cell.bookImageView.tag = indexPath.row;
            cell.bookTitleLabel.tag = indexPath.row;
            NSLog(@"Calling index %d",indexPath.row);
            if(liveStoriesFiltered) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSDictionary *bookDict= [[liveStoriesFiltered objectForKey:[[liveStoriesFiltered allKeys] firstObject]] objectAtIndex:indexPath.row];
                
                if (bookDict) {
                    [self setupCollectionViewCell:cell WithDict:bookDict];
                }
                
                if(indexPath.row == indexval){
                    [self performSelectorOnMainThread:@selector(fetchMore) withObject:nil waitUntilDone:YES];
                    NSLog(@"Calling fetchmore");
                    
                }
            }
            
            return cell;
        }
            break;
    }
    return nil;
}
                     
- (void) fetchMore{
    
    [self addActivityIndicator];
    page ++;
    [self getFilteredStories:filterKey];
}

- (void) addActivityIndicator{
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ){
        
       _actIndicator  = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(250, (485*(page+1)), 70, 70)];
    }
    else{
        _actIndicator  = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(480, (750*(page+1)), 70, 70)];
    }
    _actIndicator.alpha = 1.0f;
    [_actIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.booksCollectionView addSubview:_actIndicator];
    [_actIndicator startAnimating];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    switch (_tableType) {
        case TABLE_TYPE_MAIN_STORE: {
            if(indexPath.section != 0) {
                StoreCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HEADER_ID forIndexPath:indexPath];
                headerView.titleLabel.textColor = COLOR_DARK_RED;
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                    
                    headerView.titleLabel.font = [UIFont boldSystemFontOfSize:12];
                }
                else{
                    headerView.titleLabel.font = [UIFont boldSystemFontOfSize:18];
                }
                
                headerView.titleLabel.text = [[self.ageGroupsFoundInResponse[indexPath.section-1] objectForKey:NAME] stringByAppendingString:@" Years"];
                headerView.section = indexPath.section;
                headerView.delegate = self;
                
                if(liveStoriesFiltered) {
                    headerView.seeAllButton.hidden = NO;
                }
                
                return headerView;
            } else {
                UICollectionReusableView *headerViewForCarousel = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Section0" forIndexPath:indexPath];
                return headerViewForCarousel;
            }
        }
            break;
            
        default: {
            StoreCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HEADER_ID forIndexPath:indexPath];
            headerView.titleLabel.textColor = COLOR_DARK_RED;
            headerView.titleLabel.text = [[[self.liveStoriesFiltered allKeys] objectAtIndex:0] stringByRemovingPercentEncoding];
            headerView.section = indexPath.section;
            headerView.delegate = self;
            
            [headerView.titleLabel setFrame:CGRectMake(headerView.frame.origin.x + 200, 0, headerView.frame.size.width - 400, headerView.frame.size.height)];
            headerView.titleLabel.textAlignment = NSTextAlignmentCenter;
            
            [headerView.seeAllButton setImage:[UIImage imageNamed:@"arrowsideleft.png"] forState:UIControlStateNormal];
            [headerView.seeAllButton setTitle:@"Back" forState:UIControlStateNormal];
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                
                [headerView.seeAllButton setFrame:CGRectMake(0, 0, 120, headerView.frame.size.height)];
                headerView.titleLabel.font = [UIFont boldSystemFontOfSize:16];
            }
            else{
                [headerView.seeAllButton setFrame:CGRectMake(0, 0, 200, headerView.frame.size.height)];
                headerView.titleLabel.font = [UIFont boldSystemFontOfSize:22];
            }
            
            if(liveStoriesFiltered) {
                headerView.seeAllButton.hidden = NO;
            }
            
            return headerView;
        }
            break;
    }
    return nil;
}

#pragma mark - UICollectionView Delegate

- (void)showBookDetailsForBook:(NSDictionary *)bookDict {
    
    [self.searchTextField endEditing:YES];
    [self.searchTextField resignFirstResponder];
    self.searchTextField = nil;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    BookDetailsViewController *bookDetailsViewController;
    NSString *storyOfDayId = [prefs valueForKey:@"StoryOfTheDayBookId"];
    if(![self connected])
    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Your internet connection appears to be offline, plase try later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [alert show];
        return;
    }
    
    if(bookDict == nil){
        return;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        bookDetailsViewController = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController_iPhone" bundle:nil];
        
    }
    else{
        bookDetailsViewController = [[BookDetailsViewController alloc] initWithNibName:@"BookDetailsViewController" bundle:nil];
    }
    int availableLanguagesCount = [[bookDict valueForKey:@"available_languages"] count];
    
    bookDetailsViewController.delegate = self;
//  //  NSMutableArray *tempDropDownArray = [[NSMutableArray alloc] init];
   // [bookDetailsViewController setModalPresentationStyle:UIModalPresentationPageSheet];
   // bookDetailsViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    bookDetailsViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    bookDetailsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:bookDetailsViewController animated:YES completion:^(void) {
        bookDetailsViewController.bookTitleLabel.text = [bookDict objectForKey:@"title"];
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        
        if(![[bookDict objectForKey:@"authors"] isKindOfClass:[NSNull class]] && ([[[bookDict objectForKey:@"authors"] valueForKey:@"name"] count])){
            bookDetailsViewController.bookWrittenBy.text = [NSString stringWithFormat:@"-by %@", [[[bookDict objectForKey:@"authors"] valueForKey:@"name"] componentsJoinedByString:@", "]];
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
       // [tempDropDownArray addObject:[[bookDict objectForKey:@"info"] objectForKey:@"language"]];
     //   [tempDropDownArray addObjectsFromArray:[[bookDict objectForKey:@"available_languages"] valueForKey:@"language"]];
        
        //NSDictionary *tempDict = [[NSDictionary alloc] initWithObjectsAndKeys:[[bookDict objectForKey:@"info"] objectForKey:@"language"], @"Language", [bookDict valueForKey:@"id"], @"Id", nil];
        
       // bookDetailsViewController.dropDownSelectedItemData = [[NSMutableArray alloc] initWithObjects:tempDict, nil];
        
        //[bookDetailsViewController.dropDownArrayData addObjectsFromArray:[[NSSet setWithArray:tempDropDownArray] allObjects]];
       // [bookDetailsViewController.dropDownArrayData addObject:@"Record new language"];
        
       // [bookDetailsViewController.dropDownView.uiTableView reloadData];
        bookDetailsViewController.bookAvailGamesNo.text = [NSString stringWithFormat:@"Games : %@",[bookDict objectForKey:@"widget_count"]];
        
        bookDetailsViewController.ageLabel.text = [NSString stringWithFormat:@"Age : %@", [bookDict objectForKey:@"combined_age_group"]];
        [bookDetailsViewController setIdOfDisplayBook:[bookDict objectForKey:@"id"]];
        
        bookDetailsViewController.gradeLevel.text = [NSString stringWithFormat:@"Grade : %@", [bookDict objectForKey:@"combined_grades"]];
        
        if(![[bookDict objectForKey:@"combined_reading_level"] isKindOfClass:[NSNull class]]){
            bookDetailsViewController.readingLevelLabel.text = [NSString stringWithFormat:@"Reading Level : %@", [bookDict objectForKey:@"combined_reading_level"]];
        }
        else {
            bookDetailsViewController.readingLevelLabel.text = [NSString stringWithFormat:@"Reading Levels: -"];
        }
        
        bookDetailsViewController.numberOfPagesLabel.text = [NSString stringWithFormat:@"Pages : %d", [[bookDict objectForKey:@"page_count"] intValue]];
        
       // if([[bookDict objectForKey:@"price"] floatValue] == 0.00){
          //  bookDetailsViewController.priceLabel.text = [NSString stringWithFormat:@"FREE"];
            
       //     [bookDetailsViewController.buyButton setImage:[UIImage imageNamed:@"Read-now.png"] forState:UIControlStateNormal];
      //  }
      //  else{
       //     bookDetailsViewController.priceLabel.text = [NSString stringWithFormat:@"$ %.2f", [[bookDict objectForKey:@"price"] floatValue]];
      //      [bookDetailsViewController.buyButton setImage:[UIImage imageNamed:@"buynow.png"] forState:UIControlStateNormal];
      //  }
        bookDetailsViewController.priceLabel.text = [[bookDict objectForKey:@"info"] valueForKey:@"language"];
        
        if(![[[bookDict objectForKey:@"info"] objectForKey:@"categories"] isKindOfClass:[NSNull class]]){
            bookDetailsViewController.categoriesLabel.text = [NSString stringWithFormat:@"Category : %@",[[[bookDict objectForKey:@"info"] objectForKey:@"categories"] componentsJoinedByString:@", "]];
           // bookDetailsViewController.singleCategoryLabel.text = [NSString stringWithFormat:@"Category %@",[[[bookDict objectForKey:@"info"] objectForKey:@"categories"] objectAtIndex:0]];
            bookDetailsViewController.singleCategoryLabel.text = [NSString stringWithFormat:@"Category : %@",[[[bookDict objectForKey:@"info"] objectForKey:@"categories"] componentsJoinedByString:@", "]];
        }
        else{
            bookDetailsViewController.categoriesLabel.text = [NSString stringWithFormat:@"Category : -"];
        }
        
        if(availableLanguagesCount){
            bookDetailsViewController.labelAvaillanguageCount.text = [NSString stringWithFormat:@"Available in %d languages :", availableLanguagesCount+1];
            
        }
        else{
            bookDetailsViewController.labelAvaillanguageCount.text = [NSString stringWithFormat:@"Available in %d language :", availableLanguagesCount+1];
            bookDetailsViewController.dropDownButton.userInteractionEnabled = NO;
        }
        
        /*NSDictionary *dimensions = @{
                                     PARAMETER_USER_EMAIL_ID : ID,
                                     PARAMETER_DEVICE: IOS,
                                     PARAMETER_BOOK_ID: [bookDict objectForKey:@"id"],
                                     PARAMETER_BOOK_AGE_GROUP :[[[bookDict objectForKey:@"info"] objectForKey:@"age_groups"] componentsJoinedByString:@", "],
                                     
                                     };
        [delegate trackEvent:[STORE_AGE_STORE_BOOK valueForKey:@"description"] dimensions:dimensions];
        PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
        [userObject setObject:[STORE_AGE_STORE_BOOK valueForKey:@"value"] forKey:@"eventName"];
        [userObject setObject: [STORE_AGE_STORE_BOOK valueForKey:@"description"] forKey:@"eventDescription"];
        [userObject setObject:viewName forKey:@"viewName"];
        [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
        [userObject setObject:delegate.country forKey:@"deviceCountry"];
        [userObject setObject:delegate.language forKey:@"deviceLanguage"];
        [userObject setObject:[bookDict objectForKey:@"id"] forKey:@"bookID"];
        if(userEmail){
            [userObject setObject:ID forKey:@"emailID"];
        }
        [userObject setObject:IOS forKey:@"device"];
        [userObject saveInBackground];*/
        
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
        
        bookDetailsViewController.baseNavView = currentPage;
        bookDetailsViewController.descriptionLabel.text = [bookDict objectForKey:@"synopsis"];
        bookDetailsViewController.displayBookID = [bookDict objectForKey:@"id"];
        
        bookDetailsViewController.selectedProductId = [bookDict objectForKey:@"id"];//story_image
        if([storyOfDayId isEqualToString:[bookDict objectForKey:@"id"]]){
            [bookDetailsViewController.buyButton setTitle: @"Read Now" forState: UIControlStateNormal];
            bookDetailsViewController.imgStoryOfDay.hidden = NO;
        }
        bookDetailsViewController.imageUrlString = [[bookDict objectForKey:@"thumb"] stringByReplacingOccurrencesOfString:@"thumb_new" withString:@"ipad_banner"];
        //[bookDetailsViewController availLanguagedata];
    }];
    NSArray *vComp = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    bookDetailsViewController.view.superview.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    bookDetailsViewController.view.layer.cornerRadius = 2.5f;
   // bookDetailsViewController.view.superview.bounds = CGRectMake(0, 0, 976, 529);
    if ([[vComp objectAtIndex:0] intValue] >= 8) {
        bookDetailsViewController.preferredContentSize = CGSizeMake(779, 529);
    }
    else{
        bookDetailsViewController.view.superview.bounds = CGRectMake(0, 0, 779, 529);
    }
    //bookDetailsViewController.view.superview.frame = CGRectMake(([UIScreen mainScreen].applicationFrame.size.width/2)-400, ([UIScreen mainScreen].applicationFrame.size.height/2)-270, 776, 575);
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
}

- (void) getLiveStoryByID :(NSString *)bookID{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    MangoApiController *apiController = [MangoApiController sharedApiController];
    NSString *url;
    url = [LIVE_STORIES_WITH_ID stringByAppendingString:[NSString stringWithFormat:@"/%@",bookID]];
    
    [apiController getListOf:url ForParameters:nil withDelegate:self];
}

- (void) dismisskeyboardinview{
    
    
    [self.searchTextField endEditing:YES];
    [self.searchTextField resignFirstResponder];
    self.searchTextField = nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if([self.searchTextField isFirstResponder]){
    [self performSelectorOnMainThread:@selector(dismisskeyboardinview) withObject:nil
                        waitUntilDone:YES];
        return;
    }
        switch (_tableType) {
        case TABLE_TYPE_MAIN_STORE: {
            if (indexPath.section == 0) {
                
            } else {
                
                NSString *ageGroup = [[self.ageGroupsFoundInResponse objectAtIndex:indexPath.section - 1] objectForKey:NAME];
                NSDictionary *bookDict = [[liveStoriesFiltered objectForKey:ageGroup] objectAtIndex:indexPath.row];
                NSString *bookIdValue = [[[liveStoriesFiltered objectForKey:ageGroup] objectAtIndex:indexPath.row] valueForKey:@"id"];
                
                if (bookDict) {
                    //[self showBookDetailsForBook:bookDict];
                    [self getLiveStoryByID:bookIdValue];
                }
            }
        }
            break;
            
        default: {
            NSDictionary *bookDict = [[liveStoriesFiltered objectForKey:[[liveStoriesFiltered allKeys] firstObject]] objectAtIndex:indexPath.row];
            NSString *bookIdValue = [[[liveStoriesFiltered objectForKey:[[liveStoriesFiltered allKeys] firstObject]] objectAtIndex:indexPath.row] valueForKey:@"id"];
            
            if (bookDict) {
                //[self showBookDetailsForBook:bookDict];
                [self getLiveStoryByID:bookIdValue];
            }
        }
            break;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    switch (_tableType) {
        case TABLE_TYPE_MAIN_STORE: {
            if(section == 0) {
                return UIEdgeInsetsMake(0, 0, 26, 0);
            }
        }
            break;
            
        default:
            break;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        return UIEdgeInsetsMake(-10, 15, 0, 20);
    }
    else{
     return UIEdgeInsetsMake(10, 20, -10, 0);
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        if (_tableType == TABLE_TYPE_MAIN_STORE) {
            return CGSizeMake(collectionView.frame.size.width, 0);
        } else {
            return CGSizeMake(collectionView.frame.size.width, 40);
        }
    } else {
        return CGSizeMake(collectionView.frame.size.width, 40);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (_tableType) {
        case TABLE_TYPE_MAIN_STORE: {
            if (indexPath.section == 0) {
                
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                    return CGSizeMake(984, 130);
                }
                else{
                    return CGSizeMake(984, 240);
                }
                
                
            }
        }
            break;
            
        default:
            break;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        return CGSizeMake(110, 155);
    }
    else{
        return CGSizeMake(150, 180);
    }
}

#pragma mark - Private Methods

- (void)getImageForUrl:(NSString *)urlString {
    MangoApiController *apiController = [MangoApiController sharedApiController];
    [apiController getImageAtUrl:urlString withDelegate:self];
}

# pragma mark - Retrieving/Saving data from/to disk

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.searchTextField ) {
        [self.searchTextField endEditing:YES];
        [self.searchTextField resignFirstResponder];
        self.searchTextField = nil;
    }
}

- (IBAction) mangoSubscription{
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
    [dimensions setObject:@"subscription_bar_click" forKey:PARAMETER_ACTION];
    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
    [dimensions setObject:@"Subscription bar click in store page" forKey:PARAMETER_EVENT_DESCRIPTION];
    if(userEmail){
        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
    }
    [delegate trackEventAnalytic:@"subscription_bar_click" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"subscription_bar_click"];
    
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

- (void)BviewcontrollerDidTapButton: (BookDetailsViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        
        // here you can create a code for presetn C viewcontroller
        MangoSubscriptionViewController *subscriptionViewController;
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            
            subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController_iPhone" bundle:nil];
        }
        else{
            subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController" bundle:nil];
        }
        subscriptionViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:subscriptionViewController animated:YES completion:nil];
        
    }];
}

@end
