//
//  LastPageViewController.h
//  MangoReader
//
//  Created by Harish on 3/7/14.
//
//

#import <UIKit/UIKit.h>
#import "MangoApiController.h"
#import "CoverViewControllerBetterBookType.h"
#import "Book.h"
#import "BookDetailsViewController.h"

@interface LastPageViewController : UIViewController <MangoPostApiProtocol, BookViewProtocol>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property(strong,nonatomic) NSString *identity;
@property(strong,nonatomic) Book *book;

@property(strong,nonatomic) IBOutlet UIButton *book1;
@property(strong,nonatomic) IBOutlet UIButton *book2;
@property(strong,nonatomic) IBOutlet UIButton *book3;
@property(strong,nonatomic) IBOutlet UIButton *book4;
@property(strong,nonatomic) IBOutlet UIButton *book5;
@property(strong,nonatomic) IBOutlet UILabel *book1Label;
@property(strong,nonatomic) IBOutlet UILabel *book2Label;
@property(strong,nonatomic) IBOutlet UILabel *book3Label;
@property(strong,nonatomic) IBOutlet UILabel *book4Label;
@property(strong,nonatomic) IBOutlet UILabel *book5Label;
@property(strong, nonatomic) NSMutableArray *tempItemArray;
@property(retain,nonatomic) UIPopoverController *popOverShare;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil WithId:(NSString *)identity;
- (IBAction)pushToCoverView:(id)sender;
- (IBAction)gameButtonTapped:(id)sender;
- (IBAction)bookTapped:(id)sender;
- (IBAction)socialSharingOrLike :(id)sender;
- (IBAction)backButtonTap:(id)sender;
- (void) loadRecommendedBooks;

@end
