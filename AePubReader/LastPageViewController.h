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
#import "MangoSubscriptionViewController.h"



@interface LastPageViewController : UIViewController <MangoPostApiProtocol, BookViewProtocol, SubscriptionProtocol>{
    NSString *userEmail;
    //NSString *userDeviceID;
    //NSString *ID;
    //NSString *viewName;
    NSString *currentPage;
    NSString *storyAsAppFilePath;
    int validUserSubscription;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property(strong,nonatomic) NSString *identity;
@property(strong,nonatomic) Book *book;
@property (weak, nonatomic) IBOutlet UIButton *games;

@property(strong, nonatomic) IBOutlet UIView *recommendedBooksView;
@property(strong, nonatomic) IBOutlet UIView *mangoreaderLinkView;
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

@property(nonatomic, strong) IBOutlet UIButton *shareButton;
@property(nonatomic, strong) IBOutlet UIButton *subscribeButton;

@property (nonatomic, retain) IBOutlet UIView* settingsProbView;
@property (nonatomic, retain) IBOutlet UIView* settingsProbSupportView;
@property (nonatomic, retain) IBOutlet UITextField *textQuesSolution;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil WithId:(NSString *)identity;
- (IBAction)pushToCoverView:(id)sender;
- (IBAction)gameButtonTapped:(id)sender;
- (IBAction)bookTapped:(id)sender;
- (IBAction)socialSharingOrLike :(id)sender;
- (IBAction)backButtonTap:(id)sender;
- (void) loadRecommendedBooks;
- (IBAction)clickOnSubscribe:(id)sender;

- (IBAction)displyParentalControl:(id)sender;
- (IBAction)allowParentToShareOrNot:(id)sender;
- (IBAction)closeParentalControl:(id)sender;

@end
