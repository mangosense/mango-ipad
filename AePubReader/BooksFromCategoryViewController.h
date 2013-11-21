//
//  BooksFromCategoryViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 20/11/13.
//
//

#import <UIKit/UIKit.h>
#import "DismissPopOver.h"
#import "Book.h"
#import "NewStoreCoverViewController.h"

@interface BooksFromCategoryViewController : UIViewController<DismissPopOver>
- (IBAction)homeButton:(id)sender;
- (IBAction)libraryButton:(id)sender;
- (IBAction)settingsButton:(id)sender;
- (IBAction)booksButtonclicked:(id)sender;
@property(assign,nonatomic) NSInteger inital;
@property (weak, nonatomic) IBOutlet UIButton *MoreBooksButton;
@property (weak, nonatomic) IBOutlet UIButton *bookOne;
@property (weak, nonatomic) IBOutlet UIImageView *imageOne;
@property (weak, nonatomic) IBOutlet UIButton *bookTwo;
@property (weak, nonatomic) IBOutlet UIImageView *imageTwo;
@property (weak, nonatomic) IBOutlet UIButton *bookThree;
@property (weak, nonatomic) IBOutlet UIImageView *imageThree;
@property (weak, nonatomic) IBOutlet UIButton *bookFour;
@property (weak, nonatomic) IBOutlet UIImageView *imageFour;
@property (weak, nonatomic) IBOutlet UIButton *bookFive;
@property (weak, nonatomic) IBOutlet UIImageView *imageFive;
@property(retain,nonatomic) UIPopoverController *popOverController;
@property (weak, nonatomic) IBOutlet UILabel *labelone;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withInitialIndex:(NSInteger)index;
@property(retain,nonatomic)NSArray *buttonArray;
@property(retain,nonatomic)NSArray *imageArray;
@property(retain,nonatomic) NSArray *books;
@property(retain,nonatomic) NSArray *titleLabelArray;
@property (weak, nonatomic) IBOutlet UILabel *labelTwo;
@property (weak, nonatomic) IBOutlet UILabel *labelThree;
@property (weak, nonatomic) IBOutlet UILabel *labelFour;
@property (weak, nonatomic) IBOutlet UILabel *labelFive;

@end
