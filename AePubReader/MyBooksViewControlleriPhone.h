//
//  MyBooksViewControlleriPhone.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 07/11/13.
//
//

#import <UIKit/UIKit.h>
#import "AePubReaderAppDelegate.h"

@interface MyBooksViewControlleriPhone : UIViewController<UITableViewDataSource,UITableViewDataSource,UIAlertViewDelegate,MFMailComposeViewControllerDelegate>
@property(retain,nonatomic)NSMutableArray *array;
@property(retain,nonatomic)UIAlertView *alertView;
@property(assign,nonatomic)NSInteger identity;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(retain,nonatomic)UIProgressView *progress;
@property(assign,nonatomic)NSInteger index;
@property(assign,nonatomic)BOOL deleted;
@property(assign,nonatomic)BOOL bookOpen;
-(void)downloadComplete:(NSInteger)index;
@property(assign,nonatomic)AePubReaderAppDelegate *delegate;
@end
