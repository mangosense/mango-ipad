//
//  UserAgeLevelViewController.h
//  MangoReader
//
//  Created by Harish on 1/26/15.
//
//

#import <UIKit/UIKit.h>
#import "AePubReaderAppDelegate.h"

@interface UserAgeLevelViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *ageLabel;
@property (nonatomic, strong) IBOutlet UILabel *levelLabel;

- (IBAction) backToHomePage:(id)sender;

- (IBAction) editAgeValue:(id)sender;

@end
