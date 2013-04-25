//
//  MyBooksViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 03/12/12.
//
//

#import <UIKit/UIKit.h>
#import "AePubReaderAppDelegate.h"
#import "DataModelControl.h"
#import "Book.h"

@interface MyBooksViewController : UITableViewController<UIAlertViewDelegate>
@property(retain,nonatomic)NSMutableArray *array;
@property(retain,nonatomic)UIAlertView *alertView;
@property(assign,nonatomic)NSInteger identity;
@property(retain,nonatomic)UIProgressView *progress;
@property(assign,nonatomic)NSInteger index;
@property(assign,nonatomic)BOOL deleted;
@property(assign,nonatomic)BOOL bookOpen;
-(void)downloadComplete:(NSInteger)index;
@property(assign,nonatomic)AePubReaderAppDelegate *delegate;
@end
