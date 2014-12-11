//
//  StoryPageView.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 18/10/13.
//
//

#import <UIKit/UIKit.h>
#import "MovableTextView.h"
#import "SmoothDrawingView.h"

@interface StoryPageView : UIView {
    SmoothDrawingView *backgroundImageView;
    NSMutableArray *pageTextViewArray;
    NSMutableArray *audioArray;
}

@property (nonatomic, strong) SmoothDrawingView *backgroundImageView;
@property (nonatomic, strong) NSMutableArray *pageTextViewArray;
@property (nonatomic, strong) NSMutableArray *audioArray;

@end
