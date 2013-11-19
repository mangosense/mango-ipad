//
//  NewStoreControlleriPhone.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 07/11/13.
//
//

#import <UIKit/UIKit.h>
#import "DataSourceForLinear.h"
#import "DataSourceForLinearOld.h"
@protocol CategoryDelegate <NSObject>

-(void)chosenCategory:(NSString *)category;

@end
@interface NewStoreControlleriPhone : UIViewController<UITableViewDelegate,UITableViewDataSource,CategoryDelegate>
- (IBAction)backToLibrary:(id)sender;
- (IBAction)category:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(retain,nonatomic) DataSourceForLinear *linear;
@property(retain,nonatomic) DataSourceForLinearOld *oldLinear;
@end
