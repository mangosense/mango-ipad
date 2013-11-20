//
//  CategoriesViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 19/11/13.
//
//

#import <UIKit/UIKit.h>
#import "DismissPopOver.h"
@interface CategoriesViewController : UIViewController<DismissPopOver>
- (IBAction)backToLandingPage:(id)sender;
- (IBAction)settingsOption:(id)sender;
@property(assign,nonatomic) UIViewController *controller;
@property(retain,nonatomic) UIPopoverController *popOverController;

@end
