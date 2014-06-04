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
CGPoint originalPoint;

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
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        panRecognizer.delegate = self;
        [self addGestureRecognizer:panRecognizer];
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
    recognizer.delaysTouchesEnded = FALSE;
    
 /*   float xDis = self.frame.origin.x, yDis = self.frame.origin.y;
    
    if ([recognizer numberOfTouches] >1) {
        
        //getting width and height between gestureCenter and one of my finger
        float x = [recognizer locationInView:self].x - [recognizer locationOfTouch:1 inView:self].x;
        if (x<0) {
            x *= -1;
        }
        float y = [recognizer locationInView:self].y - [recognizer locationOfTouch:1 inView:self].y;
        if (y<0) {
            y *= -1;
        }
        
        //set Border
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            xDis = self.bounds.size.width - x*2;
            yDis = self.bounds.size.height - y*2;
        }
        
        //double size cause x and y is just the way from the middle to my finger
        float width = x*2+xDis;
        float height = y*2+yDis;
       // if (width < 1) {
       //     width = 1;
       // }
        
      //  if (height < 1) {
       //     height = 1;
      //  }
        self.bounds = CGRectMake(self.bounds.origin.x , self.bounds.origin.y , width, height);
        [recognizer setScale:1];
        [[self layer] setBorderWidth:0.0f];
        if(recognizer.state == UIGestureRecognizerStateEnded){
            
            originalPoint = CGPointMake(0.00, 0.00);
        }
        
    }*/
    [textDelegate saveFrame:self.frame AndText:self.text ForLayer:layerId];
    //NSLog(@"textview frame height size %f",);
    
    
}

#pragma mark - Touch Event Handler Methods


-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.superview];
    xDiffToCenter = location.x - self.center.x;
    yDiffToCenter = location.y - self.center.y;
//    NSLog(@"center start point is ------- %f", self.center.x);
    self.alpha = 0.7f;
    [[self layer] setCornerRadius:self.frame.size.height/120];
    [[self layer] setBackgroundColor:[[UIColor lightGrayColor] CGColor]];
}
/*
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.superview]; */
//        self.center = CGPointMake(MAX(5 + self.frame.size.width/2, MIN(location.x - xDiffToCenter, self.superview.frame.size.width - self.frame.size.width/2 - 5)), MAX(5 + self.frame.size.height/2, MIN(location.y - yDiffToCenter, self.superview.frame.size.height - self.frame.size.height/2 - 5/* - 150*/)));
/*    self.alpha = 0.7f;
     NSLog(@"center move point is ------- %f", self.center.x);
    [[self layer] setCornerRadius:self.frame.size.height/20];
    [[self layer] setBackgroundColor:[[UIColor lightGrayColor] CGColor]];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.superview];
    
    [[self layer] setBackgroundColor:[[UIColor clearColor] CGColor]];
    self.alpha = 1.0f;*/

//    self.center = CGPointMake(MAX(5 + self.frame.size.width/2, MIN(location.x - xDiffToCenter, self.superview.frame.size.width - self.frame.size.width/2 - 5)), MAX(5 + self.frame.size.height/2, MIN(location.y - yDiffToCenter, self.superview.frame.size.height - self.frame.size.height/2 - 5/* - 150*/)));
/*    NSLog(@"center end point is ------- %f", self.center.x);
    
    [self resignFirstResponder];
    
    [textDelegate saveFrame:self.frame AndText:self.text ForLayer:layerId];
}*/

//tap geture recognizer -->

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.superview];
    
    if(((recognizer.view.center.x + translation.x) - self.frame.size.width/2) > 0 && ((recognizer.view.center.y + translation.y) - self.frame.size.height/2) > 0 && ((recognizer.view.center.x + translation.x) + self.frame.size.width/2) < (self.superview.frame.size.width) && ((recognizer.view.center.y + translation.y)+self.frame.size.height/2) < (self.superview.frame.size.height)){
        
        originalPoint.x = originalPoint.x + translation.x;
        originalPoint.y = originalPoint.y + translation.y;
        
        recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                             recognizer.view.center.y + translation.y);
        
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.superview];
        
        [textDelegate saveFrame:recognizer.view.frame AndText:self.text ForLayer:layerId];
        
        if(recognizer.state == UIGestureRecognizerStateEnded){
            
            originalPoint = CGPointMake(0.00, 0.00);
        }
        
    }
    [[self layer] setCornerRadius:self.frame.size.height/20];
    
   // [[self layer] setBackgroundColor:[[UIColor clearColor] CGColor]];
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
