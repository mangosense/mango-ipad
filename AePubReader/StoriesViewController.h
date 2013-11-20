//
//  StoriesViewController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 16/08/13.
//
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface StoriesViewController : UIViewController <iCarouselDataSource, iCarouselDelegate> {
    
}

@property (nonatomic, strong) IBOutlet iCarousel *carousel;
@property (nonatomic, strong) IBOutlet UIButton *englishLanguageButton;
@property (nonatomic, strong) IBOutlet UIButton *tamilLanguageButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedcontrol;
- (IBAction)languageButtonTapped:(id)sender;
- (IBAction)switchTabButtonClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;

@end
