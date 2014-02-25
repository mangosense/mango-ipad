//
//  MangoStoreCollectionViewController.h
//  MangoReader
//
//  Created by Avinash Nehra on 1/13/14.
//
//

#import <UIKit/UIKit.h>
#import "StoreBookCell.h"
#import "PurchaseManager.h"

@interface MangoStoreCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, LocalImagesProtocol, MangoPostApiProtocol, PurchaseManagerProtocol>

@property (nonatomic, assign) int tableType;
@property (nonatomic, copy) NSString *selectedItemDetail;           // Row tapped to perform filter.
@property (nonatomic, copy) NSArray *liveStoriesQueried;       //
@property (nonatomic, copy) NSString *selectedItemTitle;

- (IBAction)bacKButtonTapped:(id)sender;

@end
