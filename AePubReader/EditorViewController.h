//
//  EditorViewController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 08/08/13.
//
//

#import <UIKit/UIKit.h>
#import "MovableTextView.h"
#import "PageBackgroundImageView.h"
#import "SmoothDrawingView.h"
#import <AVFoundation/AVFoundation.h>

@interface EditorViewController : UIViewController <DoodleDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate> {
    AVAudioPlayer *audioPlayer;
    AVAudioRecorder *audioRecorder;
    
    int recordEncoding;
    enum
    {
        ENC_AAC = 1,
        ENC_ALAC = 2,
        ENC_IMA4 = 3,
        ENC_ILBC = 4,
        ENC_ULAW = 5,
        ENC_PCM = 6,
    } encodingTypes;
}

@property (nonatomic, strong) SmoothDrawingView *backgroundImageView;
@property (nonatomic, strong) MovableTextView *mainTextView;
@property (nonatomic, strong) IBOutlet UIScrollView *pageScrollView;
@property (nonatomic, strong) IBOutlet UIView *paintPalletView;
@property (nonatomic, strong) NSMutableArray *backgroundImagesArray;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;

- (IBAction)paintButtonPressed:(id)sender;
- (IBAction)paintBrushButtonPressed:(id)sender;

@end
