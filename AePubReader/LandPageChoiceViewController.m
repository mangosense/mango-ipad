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


@interface LandPageChoiceViewController ()

@end

@implementation LandPageChoiceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        userEmail = delegate.loggedInUserInfo.email;
        userDeviceID = delegate.deviceId;
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    _settingsProbSupportView.alpha = 0.4f;
    viewName = @"Home page";
    
    // Do any additional setup after loading the view from its nib.
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.controller=self;
    
    //Check if user is subscribed to any plan
    NSArray *subscriptionPlans = [delegate.ejdbController getAllSubscriptionObjects];
    if ([subscriptionPlans count] > 0) {
        delegate.subscriptionInfo = [subscriptionPlans lastObject];
    }
    
    if(!userEmail){
        ID = userDeviceID;
        [_backToLogin setBackgroundImage:[UIImage imageNamed:@"loginLock.png"] forState:UIControlStateNormal];
    }
    else{
        ID = userEmail;
        [_backToLogin setBackgroundImage:[UIImage imageNamed:@"icons_settings.png"] forState:UIControlStateNormal];
    }
    
    if(!ID){
        udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        delegate.deviceId = udid;
        ID = udid;
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int validUserSubscription = [[prefs valueForKey:@"ISSUBSCRIPTIONVALID"] integerValue];
    NSString *storyAsAppFilePath = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
    if(storyAsAppFilePath && (validUserSubscription)){
        [_backToLogin setBackgroundImage:[UIImage imageNamed:@"icons_settings.png"] forState:UIControlStateNormal];
    }
    
    
}

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
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSDictionary *dimensions = @{
                                 PARAMETER_USER_ID : ID,
                                 PARAMETER_DEVICE: IOS
                                 
                                 };
    [delegate trackEvent:[HOME_CREATE_STORY valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[HOME_CREATE_STORY valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [HOME_CREATE_STORY valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    if(userEmail){
        [userObject setObject:userEmail forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];
    
    BooksCollectionViewController *booksCollectionViewController = [[BooksCollectionViewController alloc] initWithNibName:@"BooksCollectionViewController" bundle:nil];
    booksCollectionViewController.fromCreateStoryView = 1;
    booksCollectionViewController.toEdit = YES;
    [self.navigationController pushViewController:booksCollectionViewController animated:YES];
    
}

- (IBAction)openFreeStories:(id)sender {
    [self store:nil];
}

- (IBAction)store:(id)sender {
    //NewStoreCoverViewController *controller=[[NewStoreCoverViewController alloc]initWithNibName:@"NewStoreCoverViewController" bundle:nil shouldShowLibraryButton:NO];
    //[self.navigationController pushViewController:controller animated:YES];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *dimensions = @{
                                 PARAMETER_USER_ID : ID,
                                 PARAMETER_DEVICE: IOS
                                 
                                 };
    [delegate trackEvent:[HOME_STORE_VIEW valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[HOME_STORE_VIEW valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [HOME_STORE_VIEW valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    if(userEmail){
        [userObject setObject:userEmail forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];
    
    
    MangoStoreViewController *storeViewController;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        storeViewController = [[MangoStoreViewController alloc] initWithNibName:@"MangoStoreViewController_iPhone" bundle:nil];
    }
    else{
        storeViewController = [[MangoStoreViewController alloc] initWithNibName:@"MangoStoreViewController" bundle:nil];
    }
    
        [self.navigationController pushViewController:storeViewController animated:YES];
    
}

- (IBAction)myStories:(id)sender {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *dimensions = @{
                                 PARAMETER_USER_ID : ID,
                                 PARAMETER_DEVICE: IOS
                                 
                                 };
    [delegate trackEvent:[HOME_MY_STORIES valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[HOME_STORE_VIEW valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [HOME_STORE_VIEW valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    if(userEmail){
        [userObject setObject:userEmail forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];
    
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
    
    if([_backToLogin.currentBackgroundImage isEqual:[UIImage imageNamed:@"loginLock.png"]]){
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
    }
    else{
        
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
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    
    NSDictionary *dimensions1 = @{
                                  PARAMETER_USER_ID : ID,
                                  PARAMETER_DEVICE: IOS,
                                  
                                  };
    
    [delegate trackEvent:[MYSTORIES_SETTINGS valueForKey:@"description"]  dimensions:dimensions1];
    
    [userObject setObject:[MYSTORIES_SETTINGS valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [MYSTORIES_SETTINGS valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    if(userEmail){
        [userObject setObject:ID forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];
    
    [_textQuesSolution resignFirstResponder];
    
    if([_textQuesSolution.text intValue]  == quesSolution){
        
        settingSol = YES;
        
        NSDictionary *dimensions = @{
                                     PARAMETER_USER_ID: ID,
                                     PARAMETER_DEVICE: IOS,
                                     PARAMETER_SETTINGS_QUES_SOL: [NSString stringWithFormat:@"%d", (BOOL)YES],
                                     
                                     };
        [delegate trackEvent:[MySTORIES_SETTINGS_QUES valueForKey:@"description"] dimensions:dimensions];
        
        [userObject setObject:[MySTORIES_SETTINGS_QUES valueForKey:@"value"] forKey:@"eventName"];
        [userObject setObject: [MySTORIES_SETTINGS_QUES valueForKey:@"description"] forKey:@"eventDescription"];
        [userObject setObject:viewName forKey:@"viewName"];
        [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
        [userObject setObject:delegate.country forKey:@"deviceCountry"];
        [userObject setObject:delegate.language forKey:@"deviceLanguage"];
        [userObject setObject:[NSNumber numberWithBool:settingSol] forKey:@"boolValue"];
        if(userEmail){
            [userObject setObject:ID forKey:@"emailID"];
        }
        [userObject setObject:IOS forKey:@"device"];
        [userObject saveInBackground];
        
    }
    else{
        settingSol = NO;
        
        NSDictionary *dimensions = @{
                                     PARAMETER_USER_ID : ID,
                                     PARAMETER_DEVICE: IOS,
                                     PARAMETER_SETTINGS_QUES_SOL: [NSString stringWithFormat:@"%d", (BOOL)NO],
                                     
                                     };
        [delegate trackEvent:[MySTORIES_SETTINGS_QUES valueForKey:@"description"] dimensions:dimensions];
        [userObject setObject:[MySTORIES_SETTINGS_QUES valueForKey:@"value"] forKey:@"eventName"];
        [userObject setObject: [MySTORIES_SETTINGS_QUES valueForKey:@"description"] forKey:@"eventDescription"];
        [userObject setObject:viewName forKey:@"viewName"];
        [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
        [userObject setObject:delegate.country forKey:@"deviceCountry"];
        [userObject setObject:delegate.language forKey:@"deviceLanguage"];
        [userObject setObject:[NSNumber numberWithBool:settingSol] forKey:@"boolValue"];
        if(userEmail){
            [userObject setObject:ID forKey:@"emailID"];
        }
        [userObject setObject:IOS forKey:@"device"];
        [userObject saveInBackground];
        
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
        
        MangoAnalyticsViewController *viewCtr1;
        MangoDashbProfileViewController *viewCtr2;
        MangoDashbHelpViewController *viewCtr3;
        MangoFeedbackViewController *viewCtr4;
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            viewCtr1 = [[MangoAnalyticsViewController alloc] initWithNibName:@"MangoAnalyticsViewController_iPhone" bundle:nil];
            viewCtr2 = [[MangoDashbProfileViewController alloc] initWithNibName:@"MangoDashbProfileViewController_iPhone" bundle:nil];
            viewCtr3 = [[MangoDashbHelpViewController alloc] initWithNibName:@"MangoDashbHelpViewController_iPhone" bundle:nil];
            viewCtr4 = [[MangoFeedbackViewController alloc] initWithNibName:@"MangoFeedbackViewController_iPhone" bundle:nil];
        }
        
        else{
            
            viewCtr1 = [[MangoAnalyticsViewController alloc] initWithNibName:@"MangoAnalyticsViewController" bundle:nil];
            viewCtr2 = [[MangoDashbProfileViewController alloc] initWithNibName:@"MangoDashbProfileViewController" bundle:nil];
            viewCtr3 = [[MangoDashbHelpViewController alloc] initWithNibName:@"MangoDashbHelpViewController" bundle:nil];
            viewCtr4 = [[MangoFeedbackViewController alloc] initWithNibName:@"MangoFeedbackViewController" bundle:nil];
        }
        
        viewCtr1.tabBarItem.image = [UIImage imageNamed:@"analytics.png"];
        viewCtr2.tabBarItem.image = [UIImage imageNamed:@"profile.png"];
        viewCtr3.tabBarItem.image = [UIImage imageNamed:@"help.png"];
        viewCtr4.tabBarItem.image = [UIImage imageNamed:@"feedback.png"];
        
        viewCtr1.navigationController.navigationBarHidden=YES;
        viewCtr2.navigationController.navigationBarHidden=YES;
        viewCtr3.navigationController.navigationBarHidden=YES;
        viewCtr4.navigationController.navigationBarHidden=YES;
        
        tabBarController.viewControllers= [NSArray arrayWithObjects:viewCtr1,viewCtr2, viewCtr3, viewCtr4, nil];
        
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


@end
