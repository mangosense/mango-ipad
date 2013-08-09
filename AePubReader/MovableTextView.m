//
//  MovableTextView.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 08/08/13.
//
//

#import "MovableTextView.h"
#import <QuartzCore/QuartzCore.h>

@interface MovableTextView()

@property (nonatomic, assign) CGFloat xDiffToCenter;
@property (nonatomic, assign) CGFloat yDiffToCenter;

@end

@implementation MovableTextView

@synthesize xDiffToCenter;
@synthesize yDiffToCenter;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
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

#pragma mark - Touch Event Handler Methods

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.superview];
    xDiffToCenter = location.x - self.center.x;
    yDiffToCenter = location.y - self.center.y;
    
    self.alpha = 0.7f;
    [[self layer] setCornerRadius:self.frame.size.height/120];
    [[self layer] setBackgroundColor:[[UIColor lightGrayColor] CGColor]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.superview];
    
    self.center = CGPointMake(MAX(5 + self.frame.size.width/2, MIN(location.x - xDiffToCenter, self.superview.frame.size.width - self.frame.size.width/2 - 5)), MAX(5 + self.frame.size.height/2, MIN(location.y - yDiffToCenter, self.superview.frame.size.height - self.frame.size.height/2 - 5/* - 150*/)));
    self.alpha = 0.7f;
    [[self layer] setCornerRadius:self.frame.size.height/20];
    [[self layer] setBackgroundColor:[[UIColor lightGrayColor] CGColor]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.superview];
    
    [[self layer] setBackgroundColor:[[UIColor clearColor] CGColor]];
    self.alpha = 1.0f;

    self.center = CGPointMake(MAX(5 + self.frame.size.width/2, MIN(location.x - xDiffToCenter, self.superview.frame.size.width - self.frame.size.width/2 - 5)), MAX(5 + self.frame.size.height/2, MIN(location.y - yDiffToCenter, self.superview.frame.size.height - self.frame.size.height/2 - 5/* - 150*/)));
    [self resignFirstResponder];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.superview];
    
    [[self layer] setBackgroundColor:[[UIColor clearColor] CGColor]];
    self.alpha = 1.0f;
    
    self.center = CGPointMake(MAX(5 + self.frame.size.width/2, MIN(location.x - xDiffToCenter, self.superview.frame.size.width - self.frame.size.width/2 - 5)), MAX(5 + self.frame.size.height/2, MIN(location.y - yDiffToCenter, self.superview.frame.size.height - self.frame.size.height/2 - 5/* - 150*/)));
    [self resignFirstResponder];
}

@end
