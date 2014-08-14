//
//  EmailSubscriptionLinkViewController.h
//  MangoReader
//
//  Created by Harish on 8/8/14.
//
//

#import <UIKit/UIKit.h>
#import "MangoApiController.h"

@interface EmailSubscriptionLinkViewController : UIViewController<MangoPostApiProtocol>{
    
}

@property (nonatomic, strong) IBOutlet UITextField *emailTextField;

- (IBAction)signUpClick:(id)sender;
- (IBAction)skipClick:(id)sender;

@end
