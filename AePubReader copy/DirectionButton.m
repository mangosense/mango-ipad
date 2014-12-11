//
//  DirectionButton.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 22/03/13.
//
//

#import "DirectionButton.h"

@implementation DirectionButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self setAlpha:1.0f];
    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}
@end
