//
//  BookDetailsViewController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 12/02/14.
//
//

#import "DropDownView.h"
#import <UIKit/UIKit.h>
#import "MangoApiController.h"
#import "PurchaseManager.h"
#import "Book.h"

@protocol BookViewProtocol <NSObject>

@optional
- (void)openBookViewWithCategory:(NSDictionary *)categoryDict;
- (void)openBook:(Book *)bk;

@end

@interface BookDetailsViewController : UIViewController <MangoPostApiProtocol, PurchaseManagerProtocol, DropDownViewDelegate>{
 
    NSString *userEmail;
    NSString *userDeviceID;
    NSString *ID;
    NSString *viewName;
}

@property (nonatomic, strong) NSString *selectedProductId;
@property (nonatomic, strong) NSString *imageUrlString;

@property (nonatomic, strong) IBOutlet UIImageView *bookImageView;
@property (nonatomic, strong) IBOutlet UILabel *bookTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *ageLabel;
@property (nonatomic, strong) IBOutlet UILabel *readingLevelLabel;
@property (nonatomic, strong) IBOutlet UILabel *numberOfPagesLabel;
@property (nonatomic, strong) IBOutlet UILabel *categoriesLabel;
@property (nonatomic, strong) IBOutlet UILabel *priceLabel;
@property (nonatomic, strong) IBOutlet UIButton *buyButton;
@property (nonatomic, strong) IBOutlet UITextView *descriptionLabel;
@property (nonatomic, strong) IBOutlet UIButton *closeButton;
@property (nonatomic, strong) IBOutlet NSString *displayBookID;

@property (nonatomic, strong) IBOutlet UILabel *bookWrittenBy;
@property (nonatomic, strong) IBOutlet UILabel *bookIllustratedBy;
@property (nonatomic, strong) IBOutlet UILabel *bookNarrateBy;
@property (nonatomic, strong) IBOutlet UILabel *bookTags;
@property (nonatomic, strong) IBOutlet UILabel *bookAvailGamesNo;

@property (nonatomic,strong) IBOutlet UIButton *dropDownButton;
@property (nonatomic, strong) NSMutableArray *dropDownArrayData;
@property (nonatomic, strong) NSMutableArray *dropDownIdArrayData;

@property (nonatomic, retain) DropDownView *dropDownView;

@property (nonatomic, assign) id <BookViewProtocol> delegate;

- (IBAction)buyButtonTapped:(id)sender;
- (IBAction)closeDetails:(id)sender;
-(IBAction)dropDownActionButtonClick;
- (void)setIdOfDisplayBook:(NSString *)book_Id;

@end
