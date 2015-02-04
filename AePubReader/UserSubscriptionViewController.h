//
//  UserSubscriptionViewController.h
//  MangoReader
//
//  Created by Harish on 1/22/15.
//
//

#import <UIKit/UIKit.h>
#import "PurchaseManager.h"
#import "MBProgressHUD.h"

@interface UserSubscriptionViewController : UIViewController<PurchaseManagerProtocol>{
    
    NSArray *subscriptionProductId;
    NSArray *subscriptionPlanName;
    NSMutableArray *subscriptionPlanPrice;
}

@property (nonatomic, strong) IBOutlet UILabel *weeklyPrice;
@property (nonatomic, strong) IBOutlet UILabel *monthlyPrice;
@property (nonatomic, strong) IBOutlet UILabel *monthlyPerPrice;
@property (nonatomic, strong) IBOutlet UILabel *yearlyPrice;
@property (nonatomic, strong) IBOutlet UILabel *yearlyPerPrice;

@property (nonatomic, strong) IBOutlet UIButton *weeklySubscriptionBtn;
@property (nonatomic, strong) IBOutlet UIButton *monthlySubscriptionBtn;
@property (nonatomic, strong) IBOutlet UIButton *yearlySubscriptionBtn;

- (IBAction) backToHomePage:(id)sender;
- (IBAction)subscribeButtonTapped:(id)sender;

@end
