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

@interface MangoStoreViewController : UIViewController <ItemsDelegate, UIPopoverControllerDelegate, iCarouselDataSource, iCarouselDelegate, iCarouselImageCachingProtocol, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MangoPostApiProtocol, LocalImagesProtocol, PurchaseManagerProtocol ,UITextFieldDelegate>

@property (nonatomic, strong) iCarousel *storiesCarousel;

- (IBAction)goBackToStoryPage:(id)sender;
- (IBAction)filterSelected:(id)sender;

@end
