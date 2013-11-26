//
//  BaseViewAudoMapping.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 25/11/13.
//
//

#import "BaseViewAudoMapping.h"
@interface BaseViewAudoMapping()
@property (nonatomic, assign) CGFloat xDiffToCenter;
@property (nonatomic, assign) CGFloat yDiffToCenter;
@end
@implementation BaseViewAudoMapping

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
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
 [super touchesBegan:touches withEvent:event];
 UITouch *touch = [[event allTouches] anyObject];
 CGPoint location = [touch locationInView:self.superview];
 self.xDiffToCenter = location.x - self.center.x;
 self.yDiffToCenter = location.y - self.center.y;
 
 self.alpha = 0.7f;
 }

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.superview];

    self.center = CGPointMake(MAX(5 + self.frame.size.width/2, MIN(location.x - self.xDiffToCenter, self.superview.frame.size.width - self.frame.size.width/2 - 5)), MAX(5 + self.frame.size.height/2, MIN(location.y - self.yDiffToCenter, self.superview.frame.size.height - self.frame.size.height/2 - 5/* - 150*/)));
    self.alpha = 0.7f;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.superview];

    self.alpha = 1.0f;

    self.center = CGPointMake(MAX(5 + self.frame.size.width/2, MIN(location.x - self.xDiffToCenter, self.superview.frame.size.width - self.frame.size.width/2 - 5)), MAX(5 + self.frame.size.height/2, MIN(location.y - self.yDiffToCenter, self.superview.frame.size.height - self.frame.size.height/2 - 5/* - 150*/)));
    [self resignFirstResponder];
}

@end
