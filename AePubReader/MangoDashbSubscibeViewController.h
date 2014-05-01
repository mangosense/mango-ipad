//
//  MangoDashbSubscibeViewController.h
//  MangoReader
//
//  Created by Harish on 4/27/14.
//
//

#import <UIKit/UIKit.h>
#import "PurchaseManager.h"
#import "MangoSubscriptionViewController.h"

@interface MangoDashbSubscibeViewController : UIViewController<PurchaseManagerProtocol, SubscriptionProtocol ,SKProductsRequestDelegate>{
    
    NSString *userId;
}

- (IBAction)logoutUser:(id)sender;

- (IBAction)restorePurchase:(id)sender;

@end
