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

@interface MangoSubscriptionViewController : UIViewController <PurchaseManagerProtocol>{
    
    NSString *userEmail;
    NSString *userDeviceID;
}

@property (nonatomic, strong) IBOutlet UIView *monthlySubscriptionView;
@property (nonatomic, strong) IBOutlet UIView *yearlySubscriptionView;
@property (nonatomic, strong) IBOutlet UIView *quarterlySubcriptionView;

- (IBAction)backButtonTapped:(id)sender;

@end
