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
@property (nonatomic, copy) NSString *selectedItemDetail;

- (IBAction)bacKButtonTapped:(id)sender;

@end
