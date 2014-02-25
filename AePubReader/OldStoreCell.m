//
//  OldStoreCell.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 29/10/13.
//
//

#import "OldStoreCell.h"

@implementation OldStoreCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        /*self.label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont boldSystemFontOfSize:50.0];
        self.label.backgroundColor = [UIColor grayColor];
        self.label.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.label];;
        self.contentView.layer.borderWidth = 1.0f;
        self.contentView.layer.borderColor = [UIColor whiteColor].CGColor;*/
        self.imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
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
