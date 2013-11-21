//
//  MangoEditorViewController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 14/11/13.
//
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "SmoothDrawingView.h"
#import <AVFoundation/AVFoundation.h>
#import "ItemsListViewController.h"

@interface MangoEditorViewController : UIViewController <iCarouselDataSource, iCarouselDelegate, DoodleDelegate, AVAudioPlayerDelegate, UIGestureRecognizerDelegate, UITextViewDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, ItemsDelegate> {
    IBOutlet SmoothDrawingView *pageImageView;
    
    IBOutlet UIButton *mangoButton;
    IBOutlet UIButton *menuButton;
    IBOutlet UIButton *imageButton;
    IBOutlet UIButton *textButton;
    IBOutlet UIButton *audioButton;
    IBOutlet UIButton *gamesButton;
    IBOutlet UIButton *collaborationButton;
    IBOutlet UIButton *playStoryButton;
    IBOutlet UIButton *doodleButton;
    
    IBOutlet iCarousel *pagesCarousel;
    
    int recordEncoding;
}

@property (nonatomic, strong) IBOutlet UIButton *mangoButton;
@property (nonatomic, strong) IBOutlet UIButton *menuButton;
@property (nonatomic, strong) IBOutlet UIButton *imageButton;
@property (nonatomic, strong) IBOutlet UIButton *textButton;
@property (nonatomic, strong) IBOutlet UIButton *audioButton;
@property (nonatomic, strong) IBOutlet UIButton *gamesButton;
@property (nonatomic, strong) IBOutlet UIButton *collaborationButton;
@property (nonatomic, strong) IBOutlet UIButton *playStoryButton;
@property (nonatomic, strong) IBOutlet UIButton *doodleButton;
@property (nonatomic, strong) IBOutlet iCarousel *pagesCarousel;
@property (nonatomic, strong) IBOutlet SmoothDrawingView *pageImageView;
@property (nonatomic, assign) int chosenBookTag;

- (IBAction)mangoButtonTapped:(id)sender;
- (IBAction)menuButtonTapped:(id)sender;
- (IBAction)imageButtonTapped:(id)sender;
- (IBAction)textButtonTapped:(id)sender;
- (IBAction)audioButtonTapped:(id)sender;
- (IBAction)gamesButtonTapped:(id)sender;
- (IBAction)collaborationButtonTapped:(id)sender;
- (IBAction)playStoryButtonTapped:(id)sender;
- (IBAction)doodleButtonTapped:(id)sender;

+ (UIView *)readerPage:(NSDictionary *)pageDict;
+ (UIImage *)coverPageImage:(NSDictionary *)pageDict;

@end
