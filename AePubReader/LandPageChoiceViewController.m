//
//  LandPageChoiceViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 19/11/13.
//
//

#import "LandPageChoiceViewController.h"
#import "CustomNavViewController.h"
#import "CategoriesViewController.h"
#import "BooksFromCategoryViewController.h"
#import "MangoStoreViewController.h"
#import "MyStoriesBooksViewController.h"
#import "CategoriesFlexibleViewController.h"
#import "BooksCollectionViewController.h"

#import "MangoDashbProfileViewController.h"
#import "MangoAnalyticsViewController.h"
#import "MangoDashbHelpViewController.h"
#import "MangoFeedbackViewController.h"
#import "EmailSubscriptionLinkViewController.h"
//#import "Fingerprint.h"

@interface LandPageChoiceViewController ()

@end

@implementation LandPageChoiceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        userEmail = delegate.loggedInUserInfo.email;
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    _settingsProbSupportView.alpha = 0.4f;
    currentPage = @"home_screen";
    // Do any additional setup after loading the view from its nib.
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.controller=self;
    
    [delegate applicationDidBecomeActive:[UIApplication sharedApplication]];
    
    //Check if user is subscribed to any plan
    NSArray *subscriptionPlans = [delegate.ejdbController getAllSubscriptionObjects];
    if ([subscriptionPlans count] > 0) {
        delegate.subscriptionInfo = [subscriptionPlans lastObject];
    }
    
    if(!userEmail){
        [_backToLogin setBackgroundImage:[UIImage imageNamed:@"loginLock.png"] forState:UIControlStateNormal];
    }
    else{
        [_backToLogin setBackgroundImage:[UIImage imageNamed:@"icons_settings.png"] forState:UIControlStateNormal];
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int validUserSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
    NSString *storyAsAppFilePath = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
    if(storyAsAppFilePath && (validUserSubscription)){
        [_backToLogin setBackgroundImage:[UIImage imageNamed:@"icons_settings.png"] forState:UIControlStateNormal];
    }
    if(_pushNoteBookId || _pushSubscribe){
        
        [self store:0];
    }
    if(_pushCreateStory){
        [self creatAStory:0];
    }
}

- (void) viewDidAppear:(BOOL)animated{
    //_successSubscription = 1;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int subscriptionSuccess = [[prefs valueForKey:@"SubscriptionSuccess"]integerValue];
    int validateSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
    int isTrialUser = [[prefs valueForKey:@"ISTRIALUSER"]integerValue];
    
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
    [dimensions setObject:@"home_screen" forKey:PARAMETER_ACTION];
    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
    [dimensions setObject:@"Home screen open" forKey:PARAMETER_EVENT_DESCRIPTION];
    if(userEmail){
        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
    }
    [delegate trackEventAnalytic:@"home_screen" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"home_screen"];
}


/*- (void) showFingerPrintHere{
    //NSMutableDictionary* d = [NSMutableDictionary dictionaryWithCapacity:1];
    
    [Fingerprint showHubButton:1];
}

- (void)viewWillAppear:(BOOL)animated{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int validSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
    NSString *fingerPrintPath = [[NSBundle mainBundle] pathForResource:@"Fingerprint" ofType:@"bundle"];
    if(fingerPrintPath && path && validSubscription){
        [self showFingerPrintHere];
    }
}*/


- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)creatAStory:(id)sender {
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
    [dimensions setObject:@"create_click" forKey:PARAMETER_ACTION];
    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
    [dimensions setObject:@"Create story button click" forKey:PARAMETER_EVENT_DESCRIPTION];
    if(userEmail){
        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
    }
    [delegate trackEventAnalytic:@"create_click" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"create_click"];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        
        UIAlertView *iphoneAlert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Create story feature is available only in iPad version!!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [iphoneAlert show];
        return;
    }
    /*MyStoriesBooksViewController *myStoriesBooksViewController = [[MyStoriesBooksViewController alloc] initWithNibName:@"MyStoriesBooksViewController" bundle:nil];
    myStoriesBooksViewController.toEdit = YES;
    
    [self.navigationController pushViewController:myStoriesBooksViewController animated:YES];*/

    /// -----
    /*BooksFromCategoryViewController *booksCategoryViewController=[[BooksFromCategoryViewController alloc]initWithNibName:@"BooksFromCategoryViewController" bundle:nil withInitialIndex:0];
    booksCategoryViewController.toEdit=YES;
    [self.navigationController pushViewController:booksCategoryViewController animated:YES];*/
    
    /// -----
    
    BooksCollectionViewController *booksCollectionViewController = [[BooksCollectionViewController alloc] initWithNibName:@"BooksCollectionViewController" bundle:nil];
    booksCollectionViewController.fromCreateStoryView = 1;
    booksCollectionViewController.toEdit = YES;
    booksCollectionViewController.pushCreateStory = _pushCreateStory;
    [self.navigationController pushViewController:booksCollectionViewController animated:YES];
    
}

- (IBAction)openFreeStories:(id)sender {
    [self store:nil];
}

- (IBAction)store:(id)sender {
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
    [dimensions setObject:@"store_click" forKey:PARAMETER_ACTION];
    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
    [dimensions setObject:@"Store button click" forKey:PARAMETER_EVENT_DESCRIPTION];
    if(userEmail){
        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
    }
    [delegate trackEventAnalytic:@"store_click" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"store_click"];
    
    MangoStoreViewController *storeViewController;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        storeViewController = [[MangoStoreViewController alloc] initWithNibName:@"MangoStoreViewController_iPhone" bundle:nil];
    }
    else{
        storeViewController = [[MangoStoreViewController alloc] initWithNibName:@"MangoStoreViewController" bundle:nil];
    }
    
    storeViewController.pushNoteBookId = _pushNoteBookId;
    storeViewController.pushSubscribe = _pushSubscribe;
        [self.navigationController pushViewController:storeViewController animated:YES];
    
}

- (IBAction)myStories:(id)sender {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
    [dimensions setObject:@"my_stories_click" forKey:PARAMETER_ACTION];
    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
    [dimensions setObject:@"My stories button click" forKey:PARAMETER_EVENT_DESCRIPTION];
    if(userEmail){
        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
    }
    [delegate trackEventAnalytic:@"my_stories_click" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"my_stories_click"];
    
    CategoriesFlexibleViewController *categoryFlexible;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        categoryFlexible=[[CategoriesFlexibleViewController alloc]initWithNibName:@"CategoriesFlexibleViewController_iPhone" bundle:nil];
    }
    else{
        categoryFlexible=[[CategoriesFlexibleViewController alloc]initWithNibName:@"CategoriesFlexibleViewController" bundle:nil];
    }
    
    categoryFlexible.pageNumber = 0;
    [self.navigationController pushViewController:categoryFlexible animated:YES];
}

- (IBAction)backToLoginView:(id)sender{
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    if([_backToLogin.currentBackgroundImage isEqual:[UIImage imageNamed:@"loginLock.png"]]){
        NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
        [dimensions setObject:@"back_login" forKey:PARAMETER_ACTION];
        [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
        [dimensions setObject:@"Back to login click" forKey:PARAMETER_EVENT_DESCRIPTION];
        if(userEmail){
            [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
        }
        [delegate trackEventAnalytic:@"back_login" dimensions:dimensions];
        [delegate eventAnalyticsDataBrowser:dimensions];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
    }
    else{
        NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
        [dimensions setObject:@"settings_click" forKey:PARAMETER_ACTION];
        [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
        [dimensions setObject:@"Settings button click" forKey:PARAMETER_EVENT_DESCRIPTION];
        if(userEmail){
            [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
        }
        [delegate trackEventAnalytic:@"settings_click" dimensions:dimensions];
        [delegate eventAnalyticsDataBrowser:dimensions];
        [delegate trackMixpanelEvents:dimensions eventName:@"settings_click"];
        [self qusetionForSettings];
    }
}

- (void) qusetionForSettings{
    _settingsProbView.hidden = NO;
    _settingsProbSupportView.hidden = NO;
    NSArray *operation = [[NSArray alloc] initWithObjects:@"X", @"+", nil];
    int val1 =  arc4random()%10;
    int val2 =  arc4random()%10;
    int rand = arc4random()%2;
    _labelProblem.text = [NSString stringWithFormat:@"What is %d %@ %d = ?",val1, [operation objectAtIndex:rand],val2 ];
    quesSolution = [self calculate:val1 :val2 :[operation objectAtIndex:rand]];
}

- (int) calculate: (int) value1 :(int)value2 : (NSString *)op{
    
    if([op isEqualToString:@"X"]){
        return (value1 * value2);
    }
    
    else return (value1 + value2);
}

- (IBAction)doneProblem:(id)sender{
    
    [_textQuesSolution resignFirstResponder];
    
    if([_textQuesSolution.text intValue]  == quesSolution){
        
        settingSol = YES;
        
    }
    else{
        settingSol = NO;
    }
    _textQuesSolution.text = @"";
    _settingsProbView.hidden = YES;
    _settingsProbSupportView.hidden = YES;
    [self displaySettingsOrNot];
}

- (void)displaySettingsOrNot {
    
    if(settingSol){
        // [self displaySettings];
        settingSol = NO;
        
        UITabBarController *tabBarController = [[UITabBarController alloc] init];
        
        MangoFeedbackViewController *viewCtr1;
        //MangoAnalyticsViewController *viewCtr2;
        MangoDashbProfileViewController *viewCtr3;
        //MangoDashbHelpViewController *viewCtr4;
        
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            viewCtr1 = [[MangoFeedbackViewController alloc] initWithNibName:@"MangoFeedbackViewController_iPhone" bundle:nil];
            //viewCtr2 = [[MangoAnalyticsViewController alloc] initWithNibName:@"MangoAnalyticsViewController_iPhone" bundle:nil];
            viewCtr3 = [[MangoDashbProfileViewController alloc] initWithNibName:@"MangoDashbProfileViewController_iPhone" bundle:nil];
            //viewCtr4 = [[MangoDashbHelpViewController alloc] initWithNibName:@"MangoDashbHelpViewController_iPhone" bundle:nil];
        }
        
        else{
            
            viewCtr1 = [[MangoFeedbackViewController alloc] initWithNibName:@"MangoFeedbackViewController" bundle:nil];
            //viewCtr2 = [[MangoAnalyticsViewController alloc] initWithNibName:@"MangoAnalyticsViewController" bundle:nil];
            viewCtr3 = [[MangoDashbProfileViewController alloc] initWithNibName:@"MangoDashbProfileViewController" bundle:nil];
            //viewCtr4 = [[MangoDashbHelpViewController alloc] initWithNibName:@"MangoDashbHelpViewController" bundle:nil];
        }
        
        viewCtr1.tabBarItem.image = [UIImage imageNamed:@"feedback.png"];
        //viewCtr2.tabBarItem.image = [UIImage imageNamed:@"analytics.png"];
        viewCtr3.tabBarItem.image = [UIImage imageNamed:@"profile.png"];
        //viewCtr4.tabBarItem.image = [UIImage imageNamed:@"help.png"];
        
        viewCtr1.navigationController.navigationBarHidden=YES;
        //viewCtr2.navigationController.navigationBarHidden=YES;
        viewCtr3.navigationController.navigationBarHidden=YES;
        //viewCtr4.navigationController.navigationBarHidden=YES;
        
        tabBarController.viewControllers= [NSArray arrayWithObjects:viewCtr1, viewCtr3, nil];
        
        [self.navigationController pushViewController:tabBarController animated:YES];
    }
}

- (IBAction)closeSettingProblemView:(id)sender{
    [_textQuesSolution resignFirstResponder];
    _textQuesSolution.text = @"";
    _settingsProbSupportView.hidden = YES;
    _settingsProbView.hidden = YES;
}

- (IBAction)backgroundTap:(id)sender {
    [_textQuesSolution resignFirstResponder];
    
}

- (IBAction)callStoryOfTheDay:(id)sender{
    
    MangoStoreViewController *storeViewController;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSMutableDictionary *dimensions = [[NSMutableDictionary alloc]init];
    [dimensions setObject:@"story_of_the_day" forKey:PARAMETER_ACTION];
    [dimensions setObject:currentPage forKey:PARAMETER_CURRENT_PAGE];
    [dimensions setObject:@"Story of the day button click" forKey:PARAMETER_EVENT_DESCRIPTION];
    if(userEmail){
        [dimensions setObject:userEmail forKey:PARAMETER_USER_EMAIL_ID];
    }
    [delegate trackEventAnalytic:@"story_of_the_day" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"story_of_the_day"];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        storeViewController = [[MangoStoreViewController alloc] initWithNibName:@"MangoStoreViewController_iPhone" bundle:nil];
    }
    else{
        storeViewController = [[MangoStoreViewController alloc] initWithNibName:@"MangoStoreViewController" bundle:nil];
    }
    storeViewController.landingSOTD = 1;
    [self.navigationController pushViewController:storeViewController animated:YES];
}

/*- (void)viewWillDisappear:(BOOL)animated{
    
    [Fingerprint showHubButton:0];
}*/


@end
