//
//  BooksCollectionViewController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 06/03/14.
//
//

#import <UIKit/UIKit.h>
#import "SettingOptionViewController.h"
#import "BooksCollectionViewCell.h"
#import "BookDetailsViewController.h"
//#import "WEPopoverController.h"

@interface BooksCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, DismissPopOver, SaveBookImage, UIPopoverControllerDelegate, ShowAnalyticsView, MangoPostApiProtocol,BookViewProtocol>{
    int deleteBookIndex;
    //int settingQuesNo;
    
    NSString *userEmail;
    NSString *userDeviceID;
    NSString *ID;
    NSString *viewName;
    
    //Class popoverClass;
    BOOL settingSol;
    int quesSolution;
}

@property (nonatomic, strong) UICollectionView *booksCollectionView;
@property (nonatomic, assign) BOOL toEdit;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) IBOutlet UIButton *settingButton;
@property (nonatomic, retain) NSArray *settingQuesArray;

@property (nonatomic, retain) IBOutlet UIView* settingsProbView;
@property (nonatomic, retain) IBOutlet UIView* settingsProbSupportView;
@property (nonatomic, retain) IBOutlet UITextField *textQuesSolution;
@property (nonatomic, retain) IBOutlet UILabel *labelProblem;
@property (nonatomic, retain) NSMutableArray *arrayFreeBooksId;

- (IBAction)settingsButtonTapped:(id)sender;
- (IBAction)homeButtonTapped:(id)sender;
- (IBAction)libraryButtonTapped:(id)sender;
- (IBAction)trashButtonTapped:(id)sender;

- (IBAction)doneProblem:(id)sender;
- (IBAction)closeSettingProblemView:(id)sender;
- (IBAction)backgroundTap:(id)sender;

@property (nonatomic, strong) IBOutlet UILabel *headerLabel;
@property (nonatomic, weak) NSDictionary *categorySelected;
@property (nonatomic, assign) int fromCreateStoryView;
//@property (nonatomic, strong) WEPopoverController *popoverControlleriPhone;

@end
