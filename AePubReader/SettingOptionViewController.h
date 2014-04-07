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
#import "MangoApiController.h"
#import "PurchaseManager.h"
#import <StoreKit/StoreKit.h>

@interface SettingOptionViewController : UITableViewController <PurchaseManagerProtocol, MangoPostApiProtocol, SKProductsRequestDelegate>{
    
    NSString *userEmail;
    NSString *userDeviceID;
    NSString *ID;
    NSString *viewName;
}
@property(retain,nonatomic) NSArray *array;
@property(retain,nonatomic) UINavigationController *controller;
@property(assign,nonatomic) id<DismissPopOver> dismissDelegate;
@end
