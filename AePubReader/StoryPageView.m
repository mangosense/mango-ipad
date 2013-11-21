//
//  StoryPageView.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 18/10/13.
//
//

#import "StoryPageView.h"

@implementation StoryPageView

@synthesize backgroundImageView;
@synthesize pageTextViewArray;
@synthesize audioArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createUI];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Create UI

- (void)createUI {
    backgroundImageView.frame = self.frame;
    [self addSubview:backgroundImageView];
}

@end
