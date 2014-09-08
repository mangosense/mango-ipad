//
//  MangoStoreViewController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 03/12/13.
//
//


#import <UIKit/UIKit.h>
#import "ItemsListViewController.h"
#import "iCarousel.h"
#import "iCarouselImageView.h"
#import "MangoApiController.h"
#import "StoreBookCell.h"
#import "StoreBookCarouselCell.h"
#import "PurchaseManager.h"
#import "BookDetailsViewController.h"
#import "WEPopoverController.h"
#import "EmailSubscriptionLinkViewController.h"

@interface MangoStoreViewController : UIViewController <ItemsDelegate, UIPopoverControllerDelegate, iCarouselDataSource, iCarouselDelegate, iCarouselImageCachingProtocol, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MangoPostApiProtocol, LocalImagesProtocol, PurchaseManagerProtocol ,UITextFieldDelegate, BookViewProtocol, UITableViewDataSource, UITableViewDelegate, WEPopoverControllerDelegate, UIPopoverControllerDelegate>{
    
    NSInteger categoryflag;
    NSDictionary *categoryDictionary;
    NSString *userEmail;
    //NSString *ID;
    //NSString *viewName;
    NSString *currentPage;
    Class popoverClass;
    int displayStoryNo;
    
    NSString *storyAsAppFilePath;
    int validUserSubscription;
    
    NSString *filterKey;
    int limit;
    int page;
    int indexval;
}

@property (nonatomic, strong) iCarousel *storiesCarousel;
@property (nonatomic, assign) int tableType;
@property (nonatomic, strong) UIView *viewiPhonePopup;
@property (nonatomic, retain) WEPopoverController *popoverControlleriPhone;
@property (nonatomic , retain) IBOutlet UIView *viewDownloadCounter;
@property (nonatomic, strong) IBOutlet UILabel *labelDownloadingCount;
@property (nonatomic, strong) UIActivityIndicatorView *  actIndicator;
@property (nonatomic, strong) IBOutlet UIButton *storeBackButton;
@property (nonatomic, strong) IBOutlet UIButton *buttonForTrialUsers;
@property (nonatomic, assign) NSString *pushNoteBookId;
@property (nonatomic, assign) int landingSOTD;

- (IBAction)goBackToStoryPage:(id)sender;
- (IBAction)filterSelected:(id)sender;
- (void)setCategoryFlagValue:(BOOL)value;
- (void)setCategoryDictValue:(NSDictionary*)categoryInfoDict;
- (IBAction)showPopover:(id)sender;
- (IBAction)testFeaturedBooks:(id)sender;
- (void) dismissPopoverController;
- (IBAction) mangoSubscription;

@end
