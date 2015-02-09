//
//  AgeDetailsViewController.m
//  MangoReader
//
//  Created by Harish on 1/13/15.
//
//

#import "AgeDetailsViewController.h"
#import "HomePageViewController.h"
#import "GameWhileDownloadViewController.h"
#import "MangoStoreViewController.h"
#import "UserAgeInfo.h"
#import "UserBookDownloadViewController.h"

@interface AgeDetailsViewController ()

@end

@implementation AgeDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *userAgeObjects = [appDelegate.ejdbController getAllUserAgeValue];
    
    if ([userAgeObjects count] > 0) {
        appDelegate.userInfoAge = [userAgeObjects lastObject];
        [self openHomePage:nil];
    }
    
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openHomePage:) name:@"CloseGamesWhileDownload" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//Method to add age value
- (IBAction) addAgeValue:(id)sender{
    
    if([sender isKindOfClass:[UIButton class]]){
        
        NSString *ageVal = [NSString stringWithFormat:@"%d",[sender tag]];
        _ageLabelValue.text = [_ageLabelValue.text stringByAppendingString:ageVal];
    }
}

- (IBAction) moveToGameScreen:(id)sender{
    
    int ageVal = [_ageLabelValue.text integerValue];
    if(!(ageVal > 0 && ageVal < 60)){
        
        UIAlertView *alertWrongAge = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter correct age value" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertWrongAge show];
        _ageLabelValue.text = @"";
        return;
    }
    
    //check if books are already available
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    UserAgeInfo *userAgeInfo = [[UserAgeInfo alloc] init];
    userAgeInfo.userAgeValue = _ageLabelValue.text;
    
    [appDelegate.ejdbController insertOrUpdateObject:userAgeInfo];
    appDelegate.userInfoAge = userAgeInfo;
    
    GameWhileDownloadViewController *gamesView;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        gamesView = [[GameWhileDownloadViewController alloc]initWithNibName:@"GameWhileDownloadViewController_iPhone" bundle:nil];
    }
    else{
        gamesView = [[GameWhileDownloadViewController alloc]initWithNibName:@"GameWhileDownloadViewController" bundle:nil];
    }
    gamesView.ageVal = _ageLabelValue.text;
    [self presentViewController:gamesView animated:NO completion:nil];
    
}


- (IBAction)openHomePage:(id)sender{
    
    //get age value from label text
    HomePageViewController *homePageView;
    
    NSArray *testArray = [UserBookDownloadViewController returnAllAvailableLevels];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        homePageView = [[HomePageViewController alloc]initWithNibName:@"HomePageViewController_iPhone" bundle:nil];
    }
    else{
        homePageView = [[HomePageViewController alloc]initWithNibName:@"HomePageViewController" bundle:nil];
    }
    
    homePageView.textLevels= [testArray componentsJoinedByString:@" "];
    
    [self.navigationController pushViewController:homePageView animated:NO];
    
}


- (IBAction) backSpaceAgeField:(id)sender{
    
    self.ageLabelValue.text = @"";
}

///Just for testing purpose

- (IBAction)storeView:(id)sender{
    
    MangoStoreViewController *storeViewController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        storeViewController = [[MangoStoreViewController alloc] initWithNibName:@"MangoStoreViewController_iPhone" bundle:nil];
    }
    else{
        storeViewController = [[MangoStoreViewController alloc] initWithNibName:@"MangoStoreViewController" bundle:nil];
    }
    
    [self.navigationController pushViewController:storeViewController animated:YES];
}


@end
