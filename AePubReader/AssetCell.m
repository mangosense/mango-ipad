//
//  AssetCell.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 25/11/13.
//
//

#import "AssetCell.h"

@implementation AssetCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _imageView=[[UIImageView alloc]initWithFrame:self.bounds];
        [self.contentView addSubview:_imageView];
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

@end
