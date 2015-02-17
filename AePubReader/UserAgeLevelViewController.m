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


@interface UserAgeLevelViewController ()

@end

@implementation UserAgeLevelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *userAgeObjects = [appDelegate.ejdbController getAllUserAgeValue];
    
    if ([userAgeObjects count] > 0) {
        appDelegate.userInfoAge = [userAgeObjects lastObject];
        _ageLabel.text = appDelegate.userInfoAge.userAgeValue;
    }
    else{
        _ageLabel.text = @"";
    }
    
    _levelLabel.text = [LevelViewController getLevelFromAge:_ageLabel.text];

    // Do any additional setup after loading the view from its nib.
}



- (IBAction) editAgeValue:(id)sender{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:YES forKey:@"SHOWAGEDETAILVIEW"];
    
    [self.navigationController popViewControllerAnimated:NO];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) backToHomePage:(id)sender{
    
    //[self.tabBarController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
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
