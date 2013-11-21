//
//  PageNewBookTypeViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 21/11/13.
//
//

#import <UIKit/UIKit.h>
#import "AePubReaderAppDelegate.h"
#import "DataModelControl.h"

@interface PageNewBookTypeViewController : UIViewController
- (IBAction)ShowOptions:(id)sender;
- (IBAction)BackButton:(id)sender;
- (IBAction)closeButton:(id)sender;
- (IBAction)shareButton:(id)sender;
- (IBAction)editButton:(id)sender;
- (IBAction)changeLanguage:(id)sender;
@property(assign,nonatomic) NSInteger option;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil WithOption:(NSInteger )option BookId:(NSString *)bookId;
@property(assign,nonatomic) NSInteger bookId;
@property (weak, nonatomic) IBOutlet UIView *viewBase;

@property(strong,nonatomic) Book *book;
@end
