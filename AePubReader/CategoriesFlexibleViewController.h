//
//  CategoriesFlexibleViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 20/11/13.
//
//

#import <UIKit/UIKit.h>
#import "DismissPopOver.h"
#import "MangoApiController.h"
#import "WEPopoverController.h"
#import "SettingOptionViewController.h"

@interface CategoriesFlexibleViewController : UIViewController <DismissPopOver, MangoPostApiProtocol,WEPopoverControllerDelegate, UIPopoverControllerDelegate, UITableViewDataSource, UITableViewDelegate, ShowAnalyticsView>{
    int settingQuesNo;
    NSString *userEmail;
    NSString *userDeviceID;
    NSString *ID;
    NSString *viewName;
    Class popoverClass;
    BOOL settingSol;
    int quesSolution;
}
- (IBAction)openBooks:(id)sender;
- (IBAction)homeButton:(id)sender;
- (IBAction)settingsButton:(id)sender;
- (IBAction)nextButtonTapped:(id)sender;
- (IBAction)doneProblem:(id)sender;
- (IBAction)closeSettingProblemView:(id)sender;
- (IBAction)backgroundTap:(id)sender;

@property(retain,nonatomic) UIPopoverController *popOverController;
@property (nonatomic, assign) int pageNumber;
@property (nonatomic, strong) NSArray *categoriesArray;

@property (nonatomic, retain) IBOutlet UIView* settingsProbView;
@property (nonatomic, retain) IBOutlet UIView* settingsProbSupportView;
@property (nonatomic, strong) IBOutlet UIButton *settingButton;
//@property (nonatomic, retain) NSArray *settingQuesArray;
@property (nonatomic, retain) IBOutlet UITextField *textQuesSolution;
@property (nonatomic, retain) IBOutlet UILabel *labelProblem;

@property (nonatomic, strong) IBOutlet UIButton *categoryButtonOne;
@property (nonatomic, strong) IBOutlet UIButton *categoryButtonTwo;
@property (nonatomic, strong) IBOutlet UIButton *categoryButtonThree;
@property (nonatomic, strong) IBOutlet UIButton *categoryButtonFour;
@property (nonatomic, strong) IBOutlet UIButton *categoryButtonFive;
@property (nonatomic, strong) IBOutlet UIButton *categoryButtonSix;
@property (nonatomic, strong) IBOutlet UILabel *categoryLabelOne;
@property (nonatomic, strong) IBOutlet UILabel *categoryLabelTwo;
@property (nonatomic, strong) IBOutlet UILabel *categoryLabelThree;
@property (nonatomic, strong) IBOutlet UILabel *categoryLabelFour;
@property (nonatomic, strong) IBOutlet UILabel *categoryLabelFive;
@property (nonatomic, strong) IBOutlet UILabel *categoryLabelSix;
@property (nonatomic, strong) WEPopoverController *popoverControlleriPhone;

@end
