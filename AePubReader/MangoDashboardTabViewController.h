//
//  MangoDashboardTabViewController.h
//  MangoReader
//
//  Created by Harish on 4/27/14.
//
//

#import <UIKit/UIKit.h>
#import "MangoDashbSubscibeViewController.h"
#import "MangoDashbProfileViewController.h"
#import "MangoAnalyticsViewController.h"

@interface MangoDashboardTabViewController : UITabBarController<UITabBarControllerDelegate, UITabBarDelegate>{
    
}

@property (strong, nonatomic) IBOutlet UITabBarController *rootController;

@property (nonatomic, retain) MangoDashbSubscibeViewController *viewCtr1;
@property (nonatomic, retain) MangoDashbProfileViewController *viewCtr2;
@property (nonatomic, retain) MangoAnalyticsViewController *viewCtr3;

@end
