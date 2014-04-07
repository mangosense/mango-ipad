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

@interface MangoStoreViewController : UIViewController <ItemsDelegate, UIPopoverControllerDelegate, iCarouselDataSource, iCarouselDelegate, iCarouselImageCachingProtocol, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MangoPostApiProtocol, LocalImagesProtocol, PurchaseManagerProtocol ,UITextFieldDelegate, BookViewProtocol>{
    
    NSInteger categoryflag;
    NSDictionary *categoryDictionary;
    NSString *userEmail;
    NSString *userDeviceID;
    NSString *ID;
    NSString *viewName;
}

@property (nonatomic, strong) iCarousel *storiesCarousel;
@property (nonatomic, assign) int tableType;

- (IBAction)goBackToStoryPage:(id)sender;
- (IBAction)filterSelected:(id)sender;
- (void)setCategoryFlagValue:(BOOL)value;
- (void)setCategoryDictValue:(NSDictionary*)categoryInfoDict;

@end
