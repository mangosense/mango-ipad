//
//  MovableTextView.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 08/08/13.
//
//

#import "MovableTextView.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@interface MovableTextView()

@property (nonatomic, assign) CGFloat xDiffToCenter;
@property (nonatomic, assign) CGFloat yDiffToCenter;

@end

@implementation MovableTextView

@synthesize xDiffToCenter;
@synthesize yDiffToCenter;
@synthesize layerId;
@synthesize textDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        //[[self layer] setBorderColor:[COLOR_DARK_GREY CGColor]];
        //[[self layer] setBorderWidth:1.0f];
        
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
        pinchRecognizer.delegate = self;
        [self addGestureRecognizer:pinchRecognizer];
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

#pragma mark - Gesture Handlers

- (void) pinch:(UIPinchGestureRecognizer *)recognizer{
    self.frame = CGRectMake(MAX(self.frame.origin.x - (recognizer.scale - 1)*self.frame.size.width/2, 0), MAX(self.frame.origin.y - (recognizer.scale - 1)*self.frame.size.height/2, 0), MIN(self.superview.frame.size.width, self.frame.size.width*recognizer.scale), MIN(self.superview.frame.size.height, self.frame.size.height*recognizer.scale));
    recognizer.scale = 1;
    
    [textDelegate saveFrame:self.frame AndText:self.text ForLayer:layerId];
}

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
    
    [textDelegate saveFrame:self.frame AndText:self.text ForLayer:layerId];
}

/*
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.superview];
    
    [[self layer] setBackgroundColor:[[UIColor clearColor] CGColor]];
    self.alpha = 1.0f;
    
    self.center = CGPointMake(MAX(5 + self.frame.size.width/2, MIN(location.x - xDiffToCenter, self.superview.frame.size.width - self.frame.size.width/2 - 5)), MAX(5 + self.frame.size.height/2, MIN(location.y - yDiffToCenter, self.superview.frame.size.height - self.frame.size.height/2 - 5)));
    [self resignFirstResponder];
}
*/
@end
