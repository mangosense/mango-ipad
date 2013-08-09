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
@property (nonatomic, strong) NSMutableArray *backgroundImagesArray;

@end
