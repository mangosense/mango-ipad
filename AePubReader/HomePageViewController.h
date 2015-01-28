//
//  HomePageViewController.h
//  MangoReader
//
//  Created by Harish on 1/13/15.
//
//

#import <UIKit/UIKit.h>
#import "Book.h"
#import "iCarousel.h"
#import "iCarouselImageView.h"
#import "UserBookDownloadViewController.h"


@interface HomePageViewController : UIViewController<iCarouselDataSource,iCarouselDelegate,iCarouselImageCachingProtocol,UITabBarControllerDelegate,BooksJsonAndDownload>{
    
    NSString *selectedBookId;
}

@property (nonatomic, strong) IBOutlet iCarousel *storiesCarousel;
@property (nonatomic, strong) NSMutableArray *allDisplayBooks;
@property (nonatomic, strong) IBOutlet UILabel *levelsLabel;
@property (nonatomic, strong) AVAudioPlayer *player;

- (IBAction) readyBookToOpen:(id)sender;
- (IBAction) SelectLevelValue:(id)sender;
- (IBAction) displayUserSettings:(id)sender;
- (IBAction) presentAppInfoPage:(id)sender;

//jst to check for book downloading
- (IBAction)storeView:(id)sender;

@end
