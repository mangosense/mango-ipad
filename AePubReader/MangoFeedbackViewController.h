//
//  MangoFeedbackViewController.h
//  MangoReader
//
//  Created by Jagdish on 5/3/14.
//
//

#import <UIKit/UIKit.h>

@interface MangoFeedbackViewController : UIViewController

@property (nonatomic,retain) IBOutlet UIButton *loginButton;
- (IBAction)moveToBack:(id)sender;
- (IBAction)logoutUser:(id)sender;

@end
