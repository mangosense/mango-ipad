//
//  NotesHighlightViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 18/12/12.
//
//

#import <UIKit/UIKit.h>
#import "SearchResultsViewController.h"
@protocol ActionOnDeleteDelegate<NSObject>
-(void)deleted:(NSInteger)page;
@end
@interface NotesHighlightViewController : UITableViewController
@property(nonatomic,retain)NSMutableArray *array;
@property(nonatomic,assign)NSInteger bookId;
@property(nonatomic,assign)NSInteger pageNumber;
- (id)initWithStyle:(UITableViewStyle)style With:(NSInteger)bookid withPageNo:(NSInteger)pageNumber;
@property(assign,nonatomic)BOOL highlight;
@property(assign,nonatomic)NSInteger count;
@property(assign,nonatomic)NSInteger section;
@property(retain,nonatomic)NSMutableArray *arraySection;
@property(assign,nonatomic)id<SearchResultsDelegate> delegate;
@property(assign,nonatomic) id<ActionOnDeleteDelegate> delegateAction;
@end
