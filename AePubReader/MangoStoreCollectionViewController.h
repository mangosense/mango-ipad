//
//  MangoStoreCollectionViewController.h
//  MangoReader
//
//  Created by Avinash Nehra on 1/13/14.
//
//

#import <UIKit/UIKit.h>
#import "StoreBookCell.h"

@interface MangoStoreCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, LocalImagesProtocol, MangoPostApiProtocol>

@property (nonatomic, assign) int tableType;
@property (nonatomic, copy) NSString *selectedItemDetail;           // Row tapped to perform filter Or [Age Group in case of "See All" button].
@property (nonatomic, copy) NSDictionary *liveStoriesQueried;       //
@property (nonatomic, copy) NSString *selectedItemTitle;

- (IBAction)bacKButtonTapped:(id)sender;

@end
