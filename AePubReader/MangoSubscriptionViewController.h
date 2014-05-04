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

@protocol SubscriptionProtocol <NSObject>

- (void)itemReadyToUse:(NSString *)productID ForTransaction:(NSString *)transactionId withReciptData:(NSData*)recipt andAmount:(NSString *)amount;

@end

@interface MangoSubscriptionViewController : UIViewController <PurchaseManagerProtocol>{
    
    NSString *userEmail;
    NSString *userDeviceID;
    NSString *userId;
    NSString *ID;
}

@property (nonatomic, strong) IBOutlet UIView *monthlySubscriptionView;
@property (nonatomic, strong) IBOutlet UIView *yearlySubscriptionView;
@property (nonatomic, strong) IBOutlet UIView *quarterlySubcriptionView;

- (IBAction)backButtonTapped:(id)sender;

- (IBAction)restoreSubscription:(id)sender;

@end
