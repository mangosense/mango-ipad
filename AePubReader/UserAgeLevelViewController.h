//
//  UserAgeLevelViewController.h
//  MangoReader
//
//  Created by Harish on 1/26/15.
//
//

#import <UIKit/UIKit.h>
#import "AePubReaderAppDelegate.h"
#import "DYRateView.h"

@interface UserAgeLevelViewController : UIViewController{
    
    NSString *currentScreen;
}

@property (nonatomic, strong) IBOutlet UILabel *ageLabel;
@property (nonatomic, strong) IBOutlet UILabel *levelLabel;

@property (nonatomic, retain) IBOutlet UILabel *currentLevellabel;
@property (nonatomic, retain) IBOutlet UILabel *totalPoints;
@property (nonatomic, retain) IBOutlet UILabel *totalRatevalue;

@property (nonatomic, retain) IBOutlet UITextField *emailField;

@property (nonatomic, retain) IBOutlet DYRateView *myPicsRate;

- (IBAction) backToHomePage:(id)sender;

- (IBAction) editAgeValue:(id)sender;

- (IBAction) saveEmail:(id)sender;

@end
