//
//  StoryPageView.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 18/10/13.
//
//

#import <UIKit/UIKit.h>
#import "MovableTextView.h"

@interface StoryPageView : UIView {
    UIImageView *backgroundImageView;
    MovableTextView *pageTextView;
}

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) MovableTextView *pageTextView;

@end
