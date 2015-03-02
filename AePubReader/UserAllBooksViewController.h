//
//  UserAllBooksViewController.h
//  MangoReader
//
//  Created by Harish on 2/6/15.
//
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import "Book.h"
#import "iCarousel.h"
#import "iCarouselImageView.h"
#import "UserBookDownloadViewController.h"


@interface UserAllBooksViewController : UIViewController<iCarouselDataSource,iCarouselDelegate,iCarouselImageCachingProtocol,UITabBarControllerDelegate,BooksJsonAndDownload, UIGestureRecognizerDelegate>{
    
    NSString *selectedBookId;
    int positionIndex;
    NSString *newIDValue;
    UserBookDownloadViewController *bookDownload;
    int isInfo1Settings2Click;
    NSString *currentScreen;
    
}

@property (nonatomic, strong) IBOutlet iCarousel *storiesCarousel;
@property (nonatomic, strong) NSMutableArray *allDisplayBooks;
@property (nonatomic, strong) IBOutlet UILabel *levelsLabel;

@property (nonatomic, strong) IBOutlet UITextView *textViewLevel;

@property (nonatomic, strong) NSString *frontBookId;
@property (nonatomic, strong) IBOutlet UIView *displayView;

@property (nonatomic, strong) NSString *textLevels;


- (IBAction) readyBookToOpen:(id)sender;
- (IBAction) SelectLevelValue:(id)sender;

- (IBAction) backToHomePage:(id)sender;

@end
