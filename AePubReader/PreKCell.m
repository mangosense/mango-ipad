//
//  PreKCell.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 07/10/13.
//
//

#import "PreKCell.h"

@implementation PreKCell

@synthesize cellImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        cellImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];        
        [self.contentView addSubview:cellImageView];
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
