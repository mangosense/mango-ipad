//
//  MangoFeedbackViewController.h
//  MangoReader
//
//  Created by Jagdish on 5/3/14.
//
//

#import <UIKit/UIKit.h>

@interface MangoFeedbackViewController : UIViewController{
    
    NSString *storyAsAppFilePath;
    int validUserSubscription;
    NSString *userEmail;
    NSString *currentPage;
}

@property (nonatomic,retain) IBOutlet UIButton *loginButton;
- (IBAction)moveToBack:(id)sender;
- (IBAction)logoutUser:(id)sender;

- (IBAction)surveyView:(id)sender;
- (IBAction)chatDisscussView:(id)sender;
//- (IBAction)rateApp:(id)sender;

@end
