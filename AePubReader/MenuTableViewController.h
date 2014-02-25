//
//  MenuTableViewController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 08/11/13.
//
//

#import <UIKit/UIKit.h>

@protocol PopControllerDelegate

- (void)goToStoriesList;

@end

@interface MenuTableViewController : UITableViewController

@property (nonatomic, assign) id <PopControllerDelegate> popDelegate;

@end
