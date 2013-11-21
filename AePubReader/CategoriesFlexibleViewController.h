//
//  CategoriesFlexibleViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 20/11/13.
//
//

#import <UIKit/UIKit.h>
#import "DismissPopOver.h"
@interface CategoriesFlexibleViewController : UIViewController<DismissPopOver>
- (IBAction)openBooks:(id)sender;
- (IBAction)homeButton:(id)sender;
- (IBAction)settingsButton:(id)sender;
@property(retain,nonatomic)UIPopoverController *popOverController;
@end
