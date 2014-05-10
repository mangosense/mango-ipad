//
//  MangoDashbProfileViewController.h
//  MangoReader
//
//  Created by Harish on 4/27/14.
//
//

#import <UIKit/UIKit.h>
#import "PurchaseManager.h"
#import <QuartzCore/QuartzCore.h>
#import "MangoSubscriptionViewController.h"
#import "MangoApiController.h"

@protocol SubscriptionProtocol <NSObject>

- (void)itemReadyToUse:(NSString *)productID ForTransaction:(NSString *)transactionId withReciptData:(NSData*)recipt andAmount:(NSString *)amount;

@end

@interface MangoDashbProfileViewController : UIViewController <PurchaseManagerProtocol, SubscriptionProtocol ,SKProductsRequestDelegate, MangoPostApiProtocol>{
    
    NSString *userId;
    NSString *userEmail;
}

@property (nonatomic,retain) IBOutlet UIButton *loginButton;
- (IBAction)logoutUser:(id)sender;
- (IBAction)moveToBack:(id)sender;
- (IBAction)subscribeButtonTapped:(id)sender;

@property (nonatomic, strong) IBOutlet UIView *monthlySubscriptionView;
@property (nonatomic, strong) IBOutlet UIView *yearlySubscriptionView;
@property (nonatomic, strong) IBOutlet UIView *quarterlySubcriptionView;
@property (nonatomic, strong) IBOutlet UILabel *userEmail;
@property (nonatomic, strong) NSArray *arraySubscriptionPlan;

@property (nonatomic, retain) IBOutlet UIView *viewInfoDisplay;

@end
