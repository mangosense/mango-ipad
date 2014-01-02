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
#import "MangoApiController.h"
#import "StoreBookCell.h"

@interface MangoStoreViewController : UIViewController <ItemsDelegate, UIPopoverControllerDelegate, iCarouselDataSource, iCarouselDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MangoPostApiProtocol, LocalImagesProtocol, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet iCarousel *storiesCarousel;

- (IBAction)goBackToStoryPage:(id)sender;
- (IBAction)filterSelected:(id)sender;

@end
