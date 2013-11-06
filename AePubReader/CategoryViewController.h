//
//  CategoryViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 06/11/13.
//
//

#import <UIKit/UIKit.h>
#import "NewStoreViewControlleriPhone.h"
@interface CategoryViewController : UITableViewController
@property(retain,nonatomic) NSArray *array;
@property(assign,nonatomic) id<CategoryDelegate> delegate;
@end
