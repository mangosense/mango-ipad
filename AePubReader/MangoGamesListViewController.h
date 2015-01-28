//
//  MangoGamesListViewController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 13/12/13.
//
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface MangoGamesListViewController : UIViewController <iCarouselDataSource, iCarouselDelegate, UIWebViewDelegate>{
    NSString *userEmail;
    NSString *userDeviceID;
    NSString *ID;
    NSString *viewName;
    NSString *currentPage;
    int countGames;
}

@property (nonatomic, strong) NSString *folderLocation;
@property (nonatomic, strong) NSString *jsonString;

@property (nonatomic, strong) NSArray *gameNames;
@property (nonatomic, strong) IBOutlet iCarousel *gamesCarousel;
@property (nonatomic, strong) IBOutlet UILabel *gameTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *gameDescriptionLabel;
@property (nonatomic, strong) IBOutlet UIButton *closeButton;
@property (nonatomic, strong) NSString *loginUserEmail;
@property (nonatomic, strong) NSDate *timeCalculate;
@property (nonatomic, strong) NSString *currentBookId;
@property (nonatomic, strong) NSString *currentBookTitle;
@property (nonatomic, strong) UIWebView *webView;

- (IBAction)closeGames:(id)sender;

@end
