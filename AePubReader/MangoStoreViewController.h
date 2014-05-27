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

@interface MangoStoreViewController : UIViewController <ItemsDelegate, UIPopoverControllerDelegate, iCarouselDataSource, iCarouselDelegate, iCarouselImageCachingProtocol, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MangoPostApiProtocol, LocalImagesProtocol, PurchaseManagerProtocol ,UITextFieldDelegate, BookViewProtocol, UITableViewDataSource, UITableViewDelegate, WEPopoverControllerDelegate, UIPopoverControllerDelegate>{
    
    NSInteger categoryflag;
    NSDictionary *categoryDictionary;
    NSString *userEmail;
    NSString *userDeviceID;
    NSString *ID;
    NSString *viewName;
    Class popoverClass;
    int displayStoryNo;
    
    NSString *storyAsAppFilePath;
    int validUserSubscription;
}

@property (nonatomic, strong) iCarousel *storiesCarousel;
@property (nonatomic, assign) int tableType;
@property (nonatomic, strong) UIView *viewiPhonePopup;
@property (nonatomic, retain) WEPopoverController *popoverControlleriPhone;
@property (nonatomic , retain) IBOutlet UIView *viewDownloadCounter;
@property (nonatomic, strong) IBOutlet UILabel *labelDownloadingCount;

- (IBAction)goBackToStoryPage:(id)sender;
- (IBAction)filterSelected:(id)sender;
- (void)setCategoryFlagValue:(BOOL)value;
- (void)setCategoryDictValue:(NSDictionary*)categoryInfoDict;
- (IBAction)showPopover:(id)sender;

@end
