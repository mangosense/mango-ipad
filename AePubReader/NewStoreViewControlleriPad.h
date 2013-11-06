//
//  NewStoreViewControlleriPad.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 06/11/13.
//
//

#import <UIKit/UIKit.h>
#import "DataSourceForLinear.h"
#import "DataSourceForLinearOld.h"
#import "AFTableViewCell.h"
@interface NewStoreViewControlleriPad : UITableViewController
@property(retain,nonatomic) DataSourceForLinear *linear;
@property(retain,nonatomic) DataSourceForLinearOld *oldLinear;
@end
