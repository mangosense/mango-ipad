//
//  HomePageViewController.h
//  MangoReader
//
//  Created by Harish on 1/13/15.
//
//

#import <UIKit/UIKit.h>
#import "Book.h"
#import "iCarousel.h"
#import "iCarouselImageView.h"
#import "UserBookDownloadViewController.h"
#import "MangoApiController.h"

@interface HomePageViewController : UIViewController<iCarouselDataSource,iCarouselDelegate,iCarouselImageCachingProtocol,UITabBarControllerDelegate,BooksJsonAndDownload, UIGestureRecognizerDelegate,MangoPostApiProtocol>{
    
    NSString *selectedBookId;
    int positionIndex;
    NSString *newIDValue;
    UserBookDownloadViewController *bookDownload;
    int isInfo1Settings2Click;
}

@property (nonatomic, strong) IBOutlet iCarousel *storiesCarousel;
@property (nonatomic, strong) NSMutableArray *allDisplayBooks;
@property (nonatomic, strong) IBOutlet UILabel *levelsLabel;
@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, strong) IBOutlet UITextView *textViewLevel;
@property (nonatomic, strong) IBOutlet UILabel *progressValue;

@property (nonatomic, strong) NSString *frontBookId;
@property (nonatomic, strong) IBOutlet UIView *displayView;

@property (nonatomic, strong) NSString *textLevels;
@property (nonatomic, strong) IBOutlet UILabel *ageLabelValue;

@property (nonatomic , retain) IBOutlet UIView *viewDownloadCounter;
@property (nonatomic, strong) IBOutlet UILabel *labelDownloadingCount;

@property (nonatomic, retain) IBOutlet UIView* settingsProbView;
@property (nonatomic, retain) IBOutlet UIView* settingsProbSupportView;

- (IBAction) readyBookToOpen:(id)sender;
- (IBAction) SelectLevelValue:(id)sender;
- (IBAction) displayUserSettings:(id)sender;
- (IBAction) presentAppInfoPage:(id)sender;
- (IBAction) addAgeValue:(id)sender;
- (IBAction) backSpaceAgeField:(id)sender;
- (IBAction) dismissParentalControl:(id)sender;

//jst to check for book downloading
- (IBAction)storeView:(id)sender;

@end
