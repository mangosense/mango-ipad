//
//  CategoriesFlexibleViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 20/11/13.
//
//

#import "CategoriesFlexibleViewController.h"
#import "BooksFromCategoryViewController.h"
#import "AePubReaderAppDelegate.h"
#import "SettingOptionViewController.h"
#import "MyStoriesBooksViewController.h"
#import "Constants.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "BooksCollectionViewController.h"
#import "MangoDetailSettingsViewController.h"

#import "MangoDashbProfileViewController.h"
#import "MangoAnalyticsViewController.h"
#import "MangoDashbHelpViewController.h"
#import "MangoFeedbackViewController.h"
#import "ATConnect.h"



#define NUMBER_OF_CATEGORIES_PER_PAGE 6

@interface CategoriesFlexibleViewController () <UITabBarControllerDelegate>

@end

@implementation CategoriesFlexibleViewController

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil pageNumber:(int)pageNumber {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _pageNumber = pageNumber;
    }
    return self;
}

- (IBAction)previousController:(id)sender {
       [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    _settingsProbSupportView.alpha = 0.4f;
    viewName = @"My Stories View";
    popoverClass = [WEPopoverController class];
    // Do any additional setup after loading the view from its nib.
    if (!_categoriesArray) {
        [self getAllCategories];
    } else {
        [self setupUI];
    }
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (_pageNumber == 0 && !appDelegate.arePurchasesDownloading) {
        [self getAllPurchasedBooks];
        [self getAllFreeBooks];
        appDelegate.arePurchasesDownloading = YES;
    }
    
/*    _settingQuesArray = [[NSArray alloc] init];
    // Do any additional setup after loading the view from its nib.
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *pListpath = [bundle pathForResource:@"SettingsQues" ofType:@"plist"];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:pListpath];
    _settingQuesArray = [dictionary valueForKey:@"Problems"];*/
    
    if(!userEmail){
        ID = userDeviceID;
    }
    else{
        ID = userEmail;
    }
    [self.view bringSubviewToFront:[_settingsProbView superview]];
    [[_settingsProbView superview] bringSubviewToFront:_settingsProbView];
}

- (void)viewDidAppear:(BOOL)animated {

    if(![self connected])
    {
        // not connected
//        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Network Connection Error" message:@"Nerwork failed please check your internet connection" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [alert show];
    }
    [self.view bringSubviewToFront:[_settingsProbSupportView superview]];
    [self.view bringSubviewToFront:[_settingsProbView superview]];
    [[_settingsProbView superview] bringSubviewToFront:_settingsProbSupportView];
    [[_settingsProbView superview] bringSubviewToFront:_settingsProbView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openBooks:(id)sender {
    /*MyStoriesBooksViewController *myStoriesBooksViewController = [[MyStoriesBooksViewController alloc] initWithNibName:@"MyStoriesBooksViewController" bundle:nil];
    myStoriesBooksViewController.toEdit = NO;
    
    [self.navigationController pushViewController:myStoriesBooksViewController animated:YES];*/
    
    /// -----
    
    UIButton *button = (UIButton *)sender;
    NSDictionary *categorySelected = [_categoriesArray objectAtIndex:button.tag];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    
    BooksCollectionViewController *booksCollectionViewController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        booksCollectionViewController = [[BooksCollectionViewController alloc] initWithNibName:@"BooksCollectionViewController_iPhone" bundle:nil];
    }
    else{
        booksCollectionViewController = [[BooksCollectionViewController alloc] initWithNibName:@"BooksCollectionViewController" bundle:nil];
    }
    
   // booksCollectionViewController = [[BooksCollectionViewController alloc] initWithNibName:@"BooksCollectionViewController" bundle:nil];
    booksCollectionViewController.toEdit = NO;
    booksCollectionViewController.categorySelected = categorySelected;
    
    NSDictionary *dimensions = @{
                                 PARAMETER_USER_ID : ID,
                                 PARAMETER_DEVICE: IOS,
                                 PARAMETER_BOOK_CATEGORY_VALUE: [categorySelected valueForKey:@"name"],
                                 
                                 };
    [delegate trackEvent:[MYSTORIES_CATEGORY_SELECT valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[MYSTORIES_CATEGORY_SELECT valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [MYSTORIES_CATEGORY_SELECT valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    [userObject setObject:[categorySelected valueForKey:@"name"] forKey:@"categorySelect"];
    if(userEmail){
        [userObject setObject:ID forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];
    
    [self.navigationController pushViewController:booksCollectionViewController animated:YES];
    
    /// -----
    /*BooksFromCategoryViewController *booksCategoryViewController=[[BooksFromCategoryViewController alloc]initWithNibName:@"BooksFromCategoryViewController" bundle:nil withInitialIndex:0];
    booksCategoryViewController.toEdit=NO;
    booksCategoryViewController.categorySelected = categorySelected;
    [self.navigationController pushViewController:booksCategoryViewController animated:YES];*/
}

- (IBAction)homeButton:(id)sender {
   
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *controller=(UIViewController *)delegate.controller;
    [self.navigationController popToViewController:controller animated:YES];
}

- (IBAction)settingsButton:(id)sender {
    
    int rNo = arc4random()%8;
    settingQuesNo = rNo;
    
    if (_popoverControlleriPhone){
        
        [self.popoverControlleriPhone dismissPopoverAnimated:YES];
        self.popoverControlleriPhone = nil;
        
        return;
    }
    
    [self qusetionForSettings];
    
   /* UIAlertView *settingAlert = [[UIAlertView alloc] initWithTitle:@"SOLVE" message:[[_settingQuesArray objectAtIndex:rNo] valueForKey:@"ques"] delegate:self cancelButtonTitle:[[_settingQuesArray objectAtIndex:rNo] valueForKey:@"sol1"] otherButtonTitles:[[_settingQuesArray objectAtIndex:rNo] valueForKey:@"sol2"], nil];
    
    [settingAlert show];*/
    
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

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    self.popoverControlleriPhone = nil;
}

- (void)displaySettingsOrNot {
    
    if(settingSol){
       // [self displaySettings];
        settingSol = NO;
        
        UITabBarController *tabBarController = [[UITabBarController alloc] init];
        tabBarController.delegate = self;
        
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
        
      /*  MangoDetailSettingsViewController *settingsViewController;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            settingsViewController = [[MangoDetailSettingsViewController alloc] initWithNibName:@"MangoDetailSettingsViewController_iPhone" bundle:nil];
            
        }
        else{
            settingsViewController = [[MangoDetailSettingsViewController alloc] initWithNibName:@"MangoDetailSettingsViewController" bundle:nil];
        }

        [settingsViewController setModalPresentationStyle:UIModalPresentationPageSheet];
        [self presentViewController:settingsViewController animated:YES completion:^(void) {
        }];
        
        settingsViewController.view.superview.frame = CGRectMake(([UIScreen mainScreen].applicationFrame.size.width/2)-400, ([UIScreen mainScreen].applicationFrame.size.height/2)-270, 776, 575);*/
    }

}

- (IBAction)closeSettingProblemView:(id)sender{
    [_textQuesSolution resignFirstResponder];
    _textQuesSolution.text = @"";
    _settingsProbSupportView.hidden = YES;
    _settingsProbView.hidden = YES;
}

/*- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
   AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    if([alertView.title isEqualToString:@"SOLVE"]){
        
        if((settingQuesNo % 2) == buttonIndex){
            NSLog(@"CORRECT");
            
            NSDictionary *dimensions = @{
                                         PARAMETER_USER_ID: ID,
                                         PARAMETER_DEVICE: IOS,
                                         PARAMETER_SETTINGS_QUES_SOL: [NSString stringWithFormat:@"%d", (BOOL)YES],
                                         
                                         };
            [delegate trackEvent:[MySTORIES_SETTINGS_QUES valueForKey:@"description"] dimensions:dimensions];
            PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
            [userObject setObject:[MySTORIES_SETTINGS_QUES valueForKey:@"value"] forKey:@"eventName"];
            [userObject setObject: [MySTORIES_SETTINGS_QUES valueForKey:@"description"] forKey:@"eventDescription"];
            [userObject setObject:viewName forKey:@"viewName"];
            [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
            [userObject setObject:delegate.country forKey:@"deviceCountry"];
            [userObject setObject:delegate.language forKey:@"deviceLanguage"];
            [userObject setObject:[NSNumber numberWithBool:YES] forKey:@"boolValue"];
            if(userEmail){
                [userObject setObject:ID forKey:@"emailID"];
            }
            [userObject setObject:IOS forKey:@"device"];
            [userObject saveInBackground];
            
            
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
            
            settingSol = YES;
        }
        
        else{
            NSLog(@"WRONG");
            
            NSDictionary *dimensions = @{
                                         PARAMETER_USER_ID : ID,
                                         PARAMETER_DEVICE: IOS,
                                         PARAMETER_SETTINGS_QUES_SOL: [NSString stringWithFormat:@"%d", (BOOL)NO],
                                         
                                         };
            [delegate trackEvent:[MySTORIES_SETTINGS_QUES valueForKey:@"description"] dimensions:dimensions];
            PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
            [userObject setObject:[MySTORIES_SETTINGS_QUES valueForKey:@"value"] forKey:@"eventName"];
            [userObject setObject: [MySTORIES_SETTINGS_QUES valueForKey:@"description"] forKey:@"eventDescription"];
            [userObject setObject:viewName forKey:@"viewName"];
            [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
            [userObject setObject:delegate.country forKey:@"deviceCountry"];
            [userObject setObject:delegate.language forKey:@"deviceLanguage"];
            [userObject setObject:[NSNumber numberWithBool:NO] forKey:@"boolValue"];
            if(userEmail){
                [userObject setObject:ID forKey:@"emailID"];
            }
            [userObject setObject:IOS forKey:@"device"];
            [userObject saveInBackground];
        }
    }
    else if([alertView.title isEqualToString:@"Network Connection Error"]){
        
        if(buttonIndex ==0){
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}*/

-(void)displaySettings {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        if (!_popoverControlleriPhone) {
            
            SettingOptionViewController *settingsViewController=[[SettingOptionViewController alloc]initWithStyle:UITableViewCellStyleDefault];
            [settingsViewController.view setFrame:CGRectMake(0, 0, 50, 150)];
            settingsViewController.dismissDelegate = self;
            settingsViewController.analyticsDelegate = self;
            settingsViewController.controller = self.navigationController;
            self.popoverControlleriPhone = [[popoverClass alloc] initWithContentViewController:settingsViewController];
            self.popoverControlleriPhone.delegate = self;
            [self.popoverControlleriPhone setPopoverContentSize:CGSizeMake(200, 132)];
            self.popoverControlleriPhone.passthroughViews = nil;
            
            [self.popoverControlleriPhone presentPopoverFromRect:_settingButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            
        } else {
            [self.popoverControlleriPhone dismissPopoverAnimated:YES];
            self.popoverControlleriPhone = nil;
        }
        
    }
    
    else{
        
        SettingOptionViewController *settingsViewController=[[SettingOptionViewController alloc]initWithStyle:UITableViewCellStyleDefault];
        settingsViewController.dismissDelegate = self;
        settingsViewController.controller = self.navigationController;
        _popOverController=[[UIPopoverController alloc]initWithContentViewController:settingsViewController];
        [_popOverController setPopoverContentSize:CGSizeMake(300, 132)];
        [_popOverController presentPopoverFromRect:_settingButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
}

- (IBAction)nextButtonTapped:(id)sender {
    if ((_pageNumber+ 1)*NUMBER_OF_CATEGORIES_PER_PAGE < [_categoriesArray count]) {
        
        CategoriesFlexibleViewController *categoryFlexible;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            categoryFlexible=[[CategoriesFlexibleViewController alloc]initWithNibName:@"CategoriesFlexibleViewController_iPhone" bundle:nil];
        }
        else{
            categoryFlexible=[[CategoriesFlexibleViewController alloc]initWithNibName:@"CategoriesFlexibleViewController" bundle:nil];
        }
        categoryFlexible.pageNumber = _pageNumber + 1;
        categoryFlexible.categoriesArray = _categoriesArray;
        
        [self.navigationController pushViewController:categoryFlexible animated:YES];
    }
}

-(void)dismissPopOver{
    [_popOverController dismissPopoverAnimated:YES];
    [_popoverControlleriPhone dismissPopoverAnimated:YES];
    self.popoverControlleriPhone = nil;
    
}

- (void) showAnalyticsView{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        
        MangoAnalyticsViewController *analyticsViewController = [[MangoAnalyticsViewController alloc] initWithNibName:@"MangoAnalyticsViewController_iPhone" bundle:nil];
        analyticsViewController.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
        [self presentViewController:analyticsViewController animated:YES completion:nil];
    }
}

- (void) showSubscriptionView{
    
  /*  MangoSubscriptionViewController *subscriptionViewController;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        subscriptionViewController = [[MangoSubscriptionViewController alloc] initWithNibName:@"MangoSubscriptionViewController_iPhone" bundle:nil];
        subscriptionViewController.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
        [self presentViewController:subscriptionViewController animated:YES completion:nil];
    }*/
}

#pragma mark - UITabBarControllerDelegate

/*
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (tabBarController.selectedIndex == 3) {
        [[ATConnect sharedConnection] presentMessageCenterFromViewController:self];
    }
}*/


#pragma mark - Get Books Count

- (NSDictionary *)bookCountForCategory {
    NSMutableDictionary *bookCountDict = [NSMutableDictionary dictionary];
    
    for (NSDictionary *categoryDict in _categoriesArray) {
        [bookCountDict setObject:[NSNumber numberWithInt:0] forKey:[categoryDict objectForKey:NAME]];
    }
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *allBooks = [appDelegate.dataModel getAllUserBooks];
    
    int allBooksCount = 0;
    for (Book *book in allBooks) {
        if ([appDelegate.ejdbController getBookForBookId:book.id]) {
            NSString *jsonLocation=book.localPathFile;
            NSFileManager *fm = [NSFileManager defaultManager];
            NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
            NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
            NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
            jsonLocation = [jsonLocation stringByAppendingPathComponent:[onlyJson firstObject]];
            
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonLocation] options:NSJSONReadingAllowFragments error:nil];
            
            NSLog(@"Categories - %@", [[jsonDict objectForKey:@"info"] objectForKey:@"categories"]);
            for (NSString *category in [[jsonDict objectForKey:@"info"] objectForKey:@"categories"]) {
                int bookCount = [[bookCountDict objectForKey:category] intValue];
                bookCount += 1;
                [bookCountDict setObject:[NSNumber numberWithInt:bookCount] forKey:category];
            }
            allBooksCount += 1;
        }
    }
    
    [bookCountDict setObject:[NSNumber numberWithInt:allBooksCount] forKey:ALL_BOOKS_CATEGORY];
    
    return bookCountDict;
}

#pragma mark - Setup UI

- (void)setupUI {
    NSDictionary *bookCountDict = [self bookCountForCategory];
    NSLog(@"%@", bookCountDict);

    NSMutableArray *currentPageCategoriesArray = [[NSMutableArray alloc] init];
    
    NSArray *buttonsArray = [NSArray arrayWithObjects:_categoryButtonOne, _categoryButtonTwo, _categoryButtonThree, _categoryButtonFour, _categoryButtonFive, _categoryButtonSix, nil];
    for (int i = NUMBER_OF_CATEGORIES_PER_PAGE*_pageNumber; i < MIN(NUMBER_OF_CATEGORIES_PER_PAGE*(_pageNumber + 1), [_categoriesArray count]); i++) {
        [currentPageCategoriesArray addObject:[_categoriesArray objectAtIndex:i]];
        UIButton *button = [buttonsArray objectAtIndex:i%NUMBER_OF_CATEGORIES_PER_PAGE];
        NSString *imageName;
        if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Bedtime Stories"]) {
            imageName = @"bedtimestories.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Traditional Tales"]) {
            imageName = @"traditional.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Poems and Songs"]) {
            imageName = @"poems and rhymes.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Holidays and Celebrations"]) {
            imageName = @"celebrations.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Morals and Values"]) {
            imageName = @"values.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Classic Stories"]) {
            imageName = @"classics.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Animals and Nature"]) {
            imageName = @"animals-and-nature.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"My Books"]) {
            imageName = @"my-books.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"School Time"]) {
            imageName = @"school-time.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Family and Friends"]) {
            imageName = @"family-and-friends.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Action and Adventure"]) {
            imageName = @"Action and Adventure.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Comics and Graphic Novels"]) {
            imageName = @"Comics and Graphic Novels.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Financial Literacy"]) {
            imageName = @"Financial Literacy.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"General and Miscellaneous"]) {
            imageName = @"General and Miscellaneous.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Humour"]) {
            imageName = @"Humour.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Mystery and Suspense"]) {
            imageName = @"Mystery and Suspense.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Picture Books"]) {
            imageName = @"Picture Books.png";
        } else if ([[[_categoriesArray objectAtIndex:i] objectForKey:@"name"] isEqualToString:@"Science and Nature"]) {
            imageName = @"Science and Nature.png";
        } else {
            imageName = @"icon_my existing books.png";
        }
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        
        if ([[bookCountDict objectForKey:[[_categoriesArray objectAtIndex:i] objectForKey:@"name"]] intValue] > 0) {
            UILabel *bookcountLabel;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                
                bookcountLabel = [[UILabel alloc] initWithFrame:CGRectMake(button.frame.origin.x + button.frame.size.width - 22, button.frame.origin.y - 14, 32, 32)];
                [bookcountLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
                [[bookcountLabel layer] setCornerRadius:16.0f];
            }
            else{
                bookcountLabel = [[UILabel alloc] initWithFrame:CGRectMake(button.frame.origin.x + button.frame.size.width - 30, button.frame.origin.y - 14, 44, 44)];
                [bookcountLabel setFont:[UIFont boldSystemFontOfSize:32.0f]];
                [[bookcountLabel layer] setCornerRadius:22.0f];
            }

            [bookcountLabel setBackgroundColor:COLOR_LIGHT_GREY];
            [bookcountLabel setAlpha:0.8f];
            [bookcountLabel setTextColor:[UIColor blackColor]];
            [bookcountLabel setTextAlignment:NSTextAlignmentCenter];
                        [bookcountLabel setClipsToBounds:YES];
            [bookcountLabel setText:[NSString stringWithFormat:@"%d", [[bookCountDict objectForKey:[[_categoriesArray objectAtIndex:i] objectForKey:@"name"]] intValue]]];
            [self.view addSubview:bookcountLabel];
        }
    }
    
    for (int i = 0; i < [currentPageCategoriesArray count]; i++) {
        switch (i) {
            case 0:
                _categoryLabelOne.text = [[currentPageCategoriesArray objectAtIndex:i] objectForKey:NAME];
                _categoryButtonOne.tag = _pageNumber*NUMBER_OF_CATEGORIES_PER_PAGE + i;
                break;
                
            case 1:
                _categoryLabelTwo.text = [[currentPageCategoriesArray objectAtIndex:i] objectForKey:NAME];
                _categoryButtonTwo.tag = _pageNumber*NUMBER_OF_CATEGORIES_PER_PAGE + i;
                break;
                
            case 2:
                _categoryLabelThree.text = [[currentPageCategoriesArray objectAtIndex:i] objectForKey:NAME];
                _categoryButtonThree.tag = _pageNumber*NUMBER_OF_CATEGORIES_PER_PAGE + i;
                break;
                
            case 3:
                _categoryLabelFour.text = [[currentPageCategoriesArray objectAtIndex:i] objectForKey:NAME];
                _categoryButtonFour.tag = _pageNumber*NUMBER_OF_CATEGORIES_PER_PAGE + i;
                break;
                
            case 4:
                _categoryLabelFive.text = [[currentPageCategoriesArray objectAtIndex:i] objectForKey:NAME];
                _categoryButtonFive.tag = _pageNumber*NUMBER_OF_CATEGORIES_PER_PAGE + i;
                break;
                
            case 5:
                _categoryLabelSix.text = [[currentPageCategoriesArray objectAtIndex:i] objectForKey:NAME];
                _categoryButtonSix.tag = _pageNumber*NUMBER_OF_CATEGORIES_PER_PAGE + i;
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - Post API

- (void)getBookAtPath:(NSURL *)filePath {
    
    [filePath setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:nil];
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate unzipExistingJsonBooks];
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)reloadViewsWithArray:(NSArray *)dataArray ForType:(NSString *)type {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if ([type isEqualToString:CATEGORIES]) {
        NSMutableArray *categoriesWithMyBooksCategoryArray = [NSMutableArray arrayWithArray:dataArray];
        [categoriesWithMyBooksCategoryArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"My Books", NAME, nil]];
        [categoriesWithMyBooksCategoryArray insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"All Books", NAME, nil] atIndex:0];
        _categoriesArray = [NSArray arrayWithArray:categoriesWithMyBooksCategoryArray];
        
        [self setupUI];
    } //else if ([type isEqualToString:PURCHASED_STORIES] || [type isEqualToString:FREE_STORIES])
   /* else if ([type isEqualToString:FREE_STORIES])
    {
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        
        int numberOfBooksForDownload = 0;
        for (NSDictionary *dataDict in dataArray) {
            NSString *bookId = [dataDict objectForKey:@"id"];
            Book *bk=[delegate.dataModel getBookOfEJDBId:bookId];
            if (!bk) {
                MangoApiController *apiController = [MangoApiController sharedApiController];
                [apiController downloadBookWithId:bookId withDelegate:self ForTransaction:nil];
                numberOfBooksForDownload += 1;
            }
        }
        
        if (numberOfBooksForDownload > 0) {
            UIAlertView *booksDownloadAlertView = [[UIAlertView alloc] initWithTitle:@"Downloading Books" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            if ([type isEqualToString:PURCHASED_STORIES]) {
               // [booksDownloadAlertView setMessage:@"Your purchased books are being downloaded in the background."];
            } else {
                [booksDownloadAlertView setMessage:@"You have 5 free books from MangoReader! They will be downloaded in the background, while you continue exploring the app."];
            }
            [booksDownloadAlertView show];
        }
    }*/
}

#pragma mark - Get Categories

- (void)getAllCategories {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
    [apiController getListOf:CATEGORIES ForParameters:nil withDelegate:self];
}

#pragma mark - Get Books

-(void)getAllFreeBooks {
    MangoApiController *apiController = [MangoApiController sharedApiController];
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.loggedInUserInfo) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //[apiController getListOf:FREE_STORIES ForParameters:nil withDelegate:self];
    }
}

- (void)getAllPurchasedBooks {
    MangoApiController *apiController = [MangoApiController sharedApiController];
    
    NSMutableDictionary *paramsdict = [[NSMutableDictionary alloc] init];
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.loggedInUserInfo) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [paramsdict setObject:appDelegate.loggedInUserInfo.authToken forKey:AUTH_TOKEN];
        [paramsdict setObject:appDelegate.loggedInUserInfo.email forKey:EMAIL];
        
        [apiController getListOf:PURCHASED_STORIES ForParameters:paramsdict withDelegate:self];
    }
}

- (IBAction)backgroundTap:(id)sender {
    [_textQuesSolution resignFirstResponder];
    
}


@end
