//
//  MangoSubscriptionViewController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 10/04/14.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PurchaseManager.h"
#import "MangoApiController.h"
#import "LandPageChoiceViewController.h"



@protocol SubscriptionProtocol <NSObject>

@optional
- (void)itemReadyToUse:(NSString *)productID ForTransaction:(NSString *)transactionId withReciptData:(NSData*)recipt andAmount:(NSString *)amount;

- (void)loadLandingPage;

@end

@interface MangoSubscriptionViewController : UIViewController <PurchaseManagerProtocol>{
    
    NSString *userEmail;
    NSString *userDeviceID;
    NSString *userId;
    NSString *ID;
    int fromBookDetail;
    NSString *path;
    int validSubscription;
}

@property (nonatomic, strong) IBOutlet UIView *monthlySubscriptionView;
@property (nonatomic, strong) IBOutlet UIView *yearlySubscriptionView;
@property (nonatomic, strong) IBOutlet UIView *quarterlySubcriptionView;

@property (nonatomic, strong) NSArray *arraySubscriptionPlan;

@property (nonatomic, strong) UILabel *label1PlanName;
@property (nonatomic, strong) UILabel *label2PlanName;
@property (nonatomic, strong) UILabel *label3PlanName;

@property (nonatomic, strong) UILabel *label1PlanPrice;
@property (nonatomic, strong) UILabel *label2PlanPrice;
@property (nonatomic, strong) UILabel *label3PlanPrice;

@property (nonatomic, strong)IBOutlet UILabel *label2PlanTotalPrice;
@property (nonatomic, strong)IBOutlet UILabel *label3PlanTotalPrice;

@property (nonatomic, strong) UIButton *buttonPlan1;
@property (nonatomic, strong) UIButton *buttonPlan2;
@property (nonatomic, strong) UIButton *buttonPlan3;
@property (nonatomic, assign) id <SubscriptionProtocol> subscriptionDelegate;

@property (nonatomic, retain) IBOutlet UIView* settingsProbView;
@property (nonatomic, retain) IBOutlet UIView* settingsProbSupportView;
@property (nonatomic, retain) IBOutlet UITextField *textQuesSolution;

- (IBAction)backButtonTapped:(id)sender;
- (IBAction)restoreSubscription:(id)sender;
- (void) checkIfViewFromBookDetail : (int) value;
- (IBAction)displySubacriptionOrNot:(id)sender;
- (IBAction)backgroundTap:(id)sender;

@end
