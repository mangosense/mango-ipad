//
//  MangoAnalyticsViewController.h
//  MangoReader
//
//  Created by Harish on 3/5/14.
//
//

#import "DropDownView.h"
#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "MangoAnalyticsSingleBookView.h"

@interface MangoAnalyticsViewController : UIViewController <iCarouselDataSource, iCarouselDelegate, DropDownViewDelegate>

@property (nonatomic, strong) IBOutlet iCarousel *storiesReadCarousel;

@property (nonatomic, strong) IBOutlet UILabel *lblUserReadSnapshot;
@property (nonatomic, strong) IBOutlet UILabel *lblUserLastStories;
@property (nonatomic, strong) IBOutlet UILabel *lblTimeSpentReading;
@property (nonatomic, strong) IBOutlet UILabel *lblStoriesCompleted;
@property (nonatomic, strong) IBOutlet UILabel *lblPagesRead;
@property (nonatomic, strong) IBOutlet UILabel *lblActivities;


@property (nonatomic, strong) NSArray *testArray;

@property (nonatomic,retain) IBOutlet UIButton *dropDownButton;
@property (nonatomic, retain) NSMutableArray *dropDownArrayData;
@property (nonatomic, retain) DropDownView *dropDownView;

-(IBAction)backView:(id)sender;

-(IBAction)dropDownActionButtonClick;

@end
