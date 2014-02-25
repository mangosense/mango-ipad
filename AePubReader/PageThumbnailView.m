//
//  PageThumbnailView.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 06/02/14.
//
//

#import "PageThumbnailView.h"

@implementation PageThumbnailView

@synthesize thumbnailImageView;
@synthesize deleteButton;
@synthesize pageIndex;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.origin.x + 10, frame.origin.y + 10, frame.size.width - 20, frame.size.height - 20)];
        
        deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setImage:[UIImage imageNamed:@"close_big_button.png"] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.frame = CGRectMake(frame.size.width - 20, 0, 20, 20);
        
        [self addSubview:thumbnailImageView];
        [self addSubview:deleteButton];
    }
    return self;
}

#define Action Methods

- (void)deleteButtonPressed {
    [delegate deletePageNumber:deleteButton.tag];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
