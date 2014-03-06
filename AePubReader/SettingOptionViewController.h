//
//  SettingOptionViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 20/11/13.
//
//

#import <UIKit/UIKit.h>
#import "DismissPopOver.h"
#import "MangoAnalyticsViewController.h"

@interface SettingOptionViewController : UITableViewController
@property(retain,nonatomic) NSArray *array;
@property(retain,nonatomic) UINavigationController *controller;
@property(assign,nonatomic) id<DismissPopOver> dismissDelegate;
@end
