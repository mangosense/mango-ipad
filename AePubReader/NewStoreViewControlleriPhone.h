//
//  NewStoreViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 05/11/13.
//
//

#import <UIKit/UIKit.h>
#import "DataSourceForLinear.h"
#import "DataSourceForLinearOld.h"
#import "NewStoreControlleriPhone.h"
@interface NewStoreViewControlleriPhone : UITableViewController<CategoryDelegate>
@property(retain,nonatomic) DataSourceForLinear *linear;
@property(retain,nonatomic) DataSourceForLinearOld *oldLinear;
@property(retain,nonatomic) UILabel *label;
@end
