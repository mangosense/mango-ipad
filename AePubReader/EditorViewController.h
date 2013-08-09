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

@interface EditorViewController : UIViewController <BackgroundImageDelegate> {
    
}

@property (nonatomic, strong) PageBackgroundImageView *backgroundImageView;
@property (nonatomic, strong) MovableTextView *mainTextView;
@property (nonatomic, strong) IBOutlet UIScrollView *pageScrollView;
@property (nonatomic, strong) IBOutlet UIView *paintPalletView;
@property (nonatomic, strong) NSMutableArray *backgroundImagesArray;

- (IBAction)paintButtonPressed:(id)sender;
- (IBAction)paintBrushButtonPressed:(id)sender;

@end
