//
//  MangoGamesListViewController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 13/12/13.
//
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface MangoGamesListViewController : UIViewController <iCarouselDataSource, iCarouselDelegate, UIWebViewDelegate>

@property (nonatomic, strong) NSString *folderLocation;
@property (nonatomic, strong) NSString *jsonString;

@property (nonatomic, strong) NSArray *gameNames;

@property (nonatomic, strong) IBOutlet iCarousel *gamesCarousel;
@property (nonatomic, strong) IBOutlet UILabel *gameTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *gameDescriptionLabel;
@property (nonatomic, strong) IBOutlet UIButton *closeButton;
@property (nonatomic, strong) NSString *loginUserEmail;

- (IBAction)closeGames:(id)sender;

@end
