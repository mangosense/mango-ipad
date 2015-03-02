//
//  UserAgeLevelViewController.m
//  MangoReader
//
//  Created by Harish on 1/26/15.
//
//

#import "UserAgeLevelViewController.h"
#import "LevelViewController.h"
#import "HomePageViewController.h"
#import "Constants.h"


@interface UserAgeLevelViewController ()

@end

@implementation UserAgeLevelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentScreen = @"settingsProgressScreen";
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSArray *userAgeObjects = [appDelegate.ejdbController getAllUserAgeValue];
    
    if ([userAgeObjects count] > 0) {
        appDelegate.userInfoAge = [userAgeObjects lastObject];
        _ageLabel.text = appDelegate.userInfoAge.userAgeValue;
    }
    else{
        _ageLabel.text = @"";
    }
    
    _levelLabel.text = [LevelViewController getLevelFromAge:_ageLabel.text];
    
    
    _currentLevellabel.text = [prefs valueForKey:@"CURRENTUSERLEVEL"];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ReadBook" inManagedObjectContext:appDelegate.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSError *error;
    NSArray *array = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    ReadBook *readBook;
    int totalPoints = 0;
    for(ReadBook *info in array){
        readBook = info;
        totalPoints = totalPoints + [readBook.bookPoints intValue];
    }
    float ratingValue = totalPoints/100;
    _totalRatevalue.text = [NSString stringWithFormat:@"%d", totalPoints/100];
    _totalPoints.text = [NSString stringWithFormat:@"%d",totalPoints];
    
    DYRateView *rateView;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        rateView = [[DYRateView alloc] initWithFrame:CGRectMake(120, 200, 190, 75)];
    }
    else{
        rateView = [[DYRateView alloc] initWithFrame:CGRectMake(170, 445, 520, 285)];
    }
    rateView.rate = ratingValue;
    rateView.alignment = RateViewAlignmentRight;
    [self.view addSubview:rateView];

    // Do any additional setup after loading the view from its nib.
}

- (void) viewDidAppear:(BOOL)animated{
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *dimensions = @{
                                 
                                 PARAMETER_ACTION : @"settingsProgressScreen",
                                 PARAMETER_CURRENT_PAGE : currentScreen,
                                 PARAMETER_EVENT_DESCRIPTION : @"settings Progress Screen open",
                                 };
    [delegate trackEventAnalytic:@"settingsProgressScreen" dimensions:dimensions];
    [delegate eventAnalyticsDataBrowser:dimensions];
    [delegate trackMixpanelEvents:dimensions eventName:@"settingsProgressScreen"];
}


- (IBAction) editAgeValue:(id)sender{
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDictionary *dimensions = @{
                                 PARAMETER_ACTION : @"editAge",
                                 PARAMETER_CURRENT_PAGE : currentScreen,
                                 PARAMETER_EVENT_DESCRIPTION : @"edit age value",
                                 };
    [appDelegate trackEventAnalytic:@"editAge" dimensions:dimensions];
    [appDelegate eventAnalyticsDataBrowser:dimensions];
    [appDelegate trackMixpanelEvents:dimensions eventName:@"editAge"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert !!" message:@"Edit age value will delete all level books and related data" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Edit", nil];
    [alert show];
    
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if([alertView.title isEqualToString:@"Alert !!"]){
        
        if(buttonIndex == 1){
            
            [self proceedToEditAge];
        }
    }
}

- (void) proceedToEditAge{
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:YES forKey: @"SHOWAGEDETAILVIEW"];
    if(appDelegate.userInfoAge){
        //UserAgeInfo *userInfoAge = [appDelegate.ejdbController getUserAgeInfoForId:appDelegate.userInfoAge.id];
        UserAgeInfo *UserAgeInfo = [appDelegate.ejdbController getUserAgeInfoForId:appDelegate.userInfoAge.id];
        [appDelegate.ejdbController deleteObject:UserAgeInfo];
        appDelegate.userInfoAge = nil;
    }
    
    NSFetchRequest * allCars = [[NSFetchRequest alloc] init];
    [allCars setEntity:[NSEntityDescription entityForName:@"ReadBook" inManagedObjectContext:appDelegate.managedObjectContext]];
    [allCars setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * allValues = [appDelegate.managedObjectContext executeFetchRequest:allCars error:&error];
    //error handling goes here
    for (NSManagedObject * info in allValues) {
        [appDelegate.managedObjectContext deleteObject:info];
        
    }
    NSError *saveError = nil;
    [appDelegate.managedObjectContext save:&saveError];
    
    //[self.navigationController popViewControllerAnimated:NO];
    [self.navigationController popToRootViewControllerAnimated:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) backToHomePage:(id)sender{
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDictionary *dimensions = @{
                                 PARAMETER_ACTION : @"homeButtonClick",
                                 PARAMETER_CURRENT_PAGE : currentScreen,
                                 PARAMETER_EVENT_DESCRIPTION : @"back to home click",
                                 };
    [appDelegate trackEventAnalytic:@"homeButtonClick" dimensions:dimensions];
    [appDelegate eventAnalyticsDataBrowser:dimensions];
    [appDelegate trackMixpanelEvents:dimensions eventName:@"homeButtonClick"];
    //[self.tabBarController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) saveEmail:(id)sender{
    
    if([self isValidEmail:_emailField.text]){
        //Valid
    }
    else{
         //not valid
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter valid email id" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    [_emailField resignFirstResponder];
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDictionary *dimensions = @{
                                 PARAMETER_ACTION : @"addEmailForPrgressReport",
                                 PARAMETER_CURRENT_PAGE : currentScreen,
                                 PARAMETER_PARENT_EMAIL : _emailField.text,
                                 PARAMETER_EVENT_DESCRIPTION : @"email id sent for report",
                                 };
    [appDelegate trackEventAnalytic:@"addEmailForPrgressReport" dimensions:dimensions];
    [appDelegate eventAnalyticsDataBrowser:dimensions];
    [appDelegate trackMixpanelEvents:dimensions eventName:@"addEmailForPrgressReport"];
    
    PFObject *data = [PFObject objectWithClassName:@"EmailProgressList"];
    [data setObject:_emailField.text forKey:@"email"];
    [data setObject:@"0" forKey:@"status"];
    
    [data saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (!error) {
            // Show success message
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Successfully saved your email id" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
            // Notify table view to reload the recipes from Parse cloud
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTable" object:self];
            
            // Dismiss the controller
            [self dismissViewControllerAnimated:YES completion:nil];
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }
        
    }];

}

//check if email is valid

-(BOOL) isValidEmail:(NSString *)checkString
{
    checkString = [checkString lowercaseString];
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:checkString];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
