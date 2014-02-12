//
//  BookDetailsViewController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 12/02/14.
//
//

#import <UIKit/UIKit.h>
#import "MangoApiController.h"
#import "PurchaseManager.h"

@interface BookDetailsViewController : UIViewController <MangoPostApiProtocol, PurchaseManagerProtocol>

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
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet UIButton *closeButton;

- (IBAction)buyButtonTapped:(id)sender;
- (IBAction)closeDetails:(id)sender;

@end
