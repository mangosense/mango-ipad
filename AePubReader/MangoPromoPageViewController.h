//
//  MangoPromoPageViewController.h
//  MangoReader
//
//  Created by Harish on 4/21/14.
//
//

#import <UIKit/UIKit.h>

@interface MangoPromoPageViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tablePromoApps;

- (IBAction)backToBookCoverView:(id)sender;

@end
