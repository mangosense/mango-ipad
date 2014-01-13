//
//  MangoStoreCollectionViewController.h
//  MangoReader
//
//  Created by Avinash Nehra on 1/13/14.
//
//

#import <UIKit/UIKit.h>
#import "StoreBookCell.h"

@interface MangoStoreCollectionViewController : UIViewController <MangoPostApiProtocol>

@property (nonatomic, copy) NSString *categoryID;

- (IBAction)bacKButtonTapped:(id)sender;

@end
