//
//  CoverViewControllerBetterBookType.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 21/11/13.
//
//

#import <UIKit/UIKit.h>
#import "DismissPopOver.h"
#import "Book.h"
#import "LastPageViewController.h"

@interface CoverViewControllerBetterBookType : UIViewController<DismissPopOver, MangoPostApiProtocol>{
    NSString *currentBookId;
}
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIButton *games;
- (IBAction)optionsToReader:(id)sender;
- (IBAction)libraryButtonClicked:(id)sender;
@property(strong,nonatomic)UIPopoverController *popOverController;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil WithId:(NSString *)identity;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property(strong,nonatomic) NSString *identity;
@property(strong,nonatomic) Book *book;
@property(retain,nonatomic) UIPopoverController *popOverShare;

@property (nonatomic, strong) IBOutlet UIButton *languageLabel;
@property(strong, nonatomic) NSMutableArray *avilableLanguages;

- (IBAction)gameButtonTapped:(id)sender;

- (IBAction)lastPage:(id)sender;

@end
