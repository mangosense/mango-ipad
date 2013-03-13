//
//  TableOfContentsViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 28/01/13.
//
//

#import <UIKit/UIKit.h>

@protocol TableViewOfTOCdelegate<NSObject>
-(void)loadPage:(NSString *)lastPath;
@end
@interface TableOfContentsViewController : UITableViewController
@property(retain,nonatomic)NSMutableArray *array;
- (id)initWithStyle:(UITableViewStyle)style array:(NSMutableArray *)array;
@property(assign,nonatomic)id<TableViewOfTOCdelegate> delegate;
@end
