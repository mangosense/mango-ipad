//
//  MyStoriesBookCell.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 11/02/14.
//
//

#import "MyStoriesBookCell.h"

@implementation MyStoriesBookCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _bookImageView = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:_bookImageView];
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

#pragma mark - Layout Subviews

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _bookImageView = [[UIImageView alloc] initWithFrame:self.frame];
}

#pragma mark - Reuse

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _bookImageView.image = nil;
}

@end
