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

@interface MenuTableViewController : UITableViewController{
    NSString *userEmail;
    NSString *userDeviceID;
    NSString *ID;

}

@property (nonatomic, strong) NSString *bookId;
@property (nonatomic, assign) id <PopControllerDelegate> popDelegate;

@end
