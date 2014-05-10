//
//  LandPageChoiceViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 19/11/13.
//
//

#import <UIKit/UIKit.h>
#import "StoriesViewController.h"
@interface LandPageChoiceViewController : UIViewController{
    
    NSString *userEmail;
    NSString *userDeviceID;
    NSString *ID;
    NSString *viewName;
    BOOL settingSol;
    int quesSolution;
}
- (IBAction)creatAStory:(id)sender;
- (IBAction)openFreeStories:(id)sender;
- (IBAction)store:(id)sender;
- (IBAction)myStories:(id)sender;
- (IBAction)backToLoginView:(id)sender;
- (IBAction)doneProblem:(id)sender;
- (IBAction)backgroundTap:(id)sender;
- (IBAction)closeSettingProblemView:(id)sender;


@property(retain,nonatomic)StoriesViewController *storiesViewController;
@property (nonatomic, retain) IBOutlet UIButton *backToLogin;

@property (nonatomic, retain) IBOutlet UIView* settingsProbView;
@property (nonatomic, retain) IBOutlet UIView* settingsProbSupportView;
@property (nonatomic, strong) IBOutlet UIButton *settingButton;
@property (nonatomic, retain) IBOutlet UITextField *textQuesSolution;
@property (nonatomic, retain) IBOutlet UILabel *labelProblem;

@end
