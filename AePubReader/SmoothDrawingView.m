//
//  SmoothDrawingView.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 12/08/13.
//
//

#import "SmoothDrawingView.h"
#import "UIImage-Extensions.h"

#define RED_BUTTON_TAG 1
#define YELLOW_BUTTON_TAG 2
#define GREEN_BUTTON_TAG 3
#define BLUE_BUTTON_TAG 4
#define PEA_GREEN_BUTTON_TAG 5
#define PURPLE_BUTTON_TAG 6
#define ORANGE_BUTTON_TAG 7
#define ERASER_BUTTON_TAG 8

#define SMALL_BRUSH_TAG 1
#define MEDIUM_BRUSH_TAG 2
#define LARGE_BRUSH_TAG 3

UIBezierPath *path;
CGPoint pts[5]; // we now need to keep track of the four points of a Bezier segment and the first control point of the next segment
uint ctr;

@implementation SmoothDrawingView

@synthesize incrementalImage;
@synthesize tempImage;
@synthesize indexOfThisImage;
@synthesize delegate;
@synthesize selectedColor;
@synthesize selectedBrush;
@synthesize selectedEraserWidth;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setMultipleTouchEnabled:NO];
        [self setBackgroundColor:[UIColor clearColor]];
        path = [UIBezierPath bezierPath];
        [path setLineWidth:2.0];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        [self setMultipleTouchEnabled:NO];
        path = [UIBezierPath bezierPath];
        [path setLineCapStyle:kCGLineCapRound];
    }
    return self;
}

- (void)setTempImage:(UIImage *)tempImageFromStory {
    UIGraphicsBeginImageContext(self.bounds.size);
    UIImage *image = tempImageFromStory;
    [image drawInRect:self.frame];
    tempImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [path setLineWidth:selectedBrush];
    
    switch (selectedColor) {
        case RED_BUTTON_TAG:
            [[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0] setStroke];
            break;
            
        case GREEN_BUTTON_TAG:
            [[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0] setStroke];
            break;
            
        case BLUE_BUTTON_TAG:
            [[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0] setStroke];
            break;
            
        case YELLOW_BUTTON_TAG:
            [[UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0] setStroke];
            break;
            
        case PEA_GREEN_BUTTON_TAG:
            [[UIColor colorWithRed:0.06 green:0.87 blue:0.69 alpha:1.0] setStroke];
            break;
            
        case PURPLE_BUTTON_TAG:
            [[UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:1.0] setStroke];
            break;
            
        case ORANGE_BUTTON_TAG:
            [[UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0] setStroke];
            break;
            
        case ERASER_BUTTON_TAG:
            [[UIColor colorWithPatternImage:tempImage] set];
            [path setLineWidth:selectedEraserWidth];
            break;
            
        default:
            [[UIColor redColor] setStroke];
            break;
    }
    
    [incrementalImage drawInRect:rect];
    [path stroke];
}

#pragma mark - Point Calculations

- (void)calculatePositionsForPoint:(CGPoint)p {
    ctr++;
    pts[ctr] = p;
    if (ctr == 4)
    {
        pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
        [path moveToPoint:pts[0]];
        [path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]]; // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
        [self setNeedsDisplay];
        // replace points and get ready to handle the next segment
        pts[0] = pts[3];
        pts[1] = pts[4];
        ctr = 1;
    }
}

#pragma mark - Touch Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    ctr = 0;
    UITouch *touch = [touches anyObject];
    pts[0] = [touch locationInView:self];
    
    CGPoint p = [touch locationInView:self];
    [path moveToPoint:p];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    [self calculatePositionsForPoint:p];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    [path addCurveToPoint:p controlPoint1:p controlPoint2:p];

    [self drawBitmap];
    [self setNeedsDisplay];
    [path removeAllPoints];
    ctr = 0;
    
    [delegate replaceImageAtIndex:indexOfThisImage withImage:incrementalImage];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

#pragma mark - Drawing Methods

- (void)drawSticker:(UIImage *)stickerImage inRect:(CGRect)frame WithTranslation:(CGPoint)tranlatePoint AndRotation:(CGFloat)angle {
    UIGraphicsBeginImageContextWithOptions(self.frame.size, YES, 0.0f);
    if (!incrementalImage) // first time; paint background clear
    {
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.frame];
        [[UIColor clearColor] setFill];
        [rectpath fill];
    }
    
    [incrementalImage drawInRect:self.frame];
    
    stickerImage = [stickerImage imageRotatedByRadians:-angle];
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), tranlatePoint.x - frame.size.width/2, tranlatePoint.y - 20*(frame.size.height/120) - frame.size.height/2);
    [stickerImage drawInRect:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    
    incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setNeedsDisplay];
    
    [delegate replaceImageAtIndex:indexOfThisImage withImage:incrementalImage];
}

- (void)drawBitmap
{
    UIGraphicsBeginImageContextWithOptions(self.frame.size, YES, 0.0f);
    if (!incrementalImage) // first time; paint background clear
    {
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.frame];
        [[UIColor clearColor] setFill];
        [rectpath fill];
    }
    [incrementalImage drawInRect:self.frame];
    
    [path setLineWidth:selectedBrush];
    
    switch (selectedColor) {
        case RED_BUTTON_TAG:
            [[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0] setStroke];
            break;
            
        case GREEN_BUTTON_TAG:
            [[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0] setStroke];
            break;
            
        case BLUE_BUTTON_TAG:
            [[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0] setStroke];
            break;
            
        case YELLOW_BUTTON_TAG:
            [[UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0] setStroke];
            break;
            
        case PEA_GREEN_BUTTON_TAG:
            [[UIColor colorWithRed:0.06 green:0.87 blue:0.69 alpha:1.0] setStroke];
            break;
            
        case PURPLE_BUTTON_TAG:
            [[UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:1.0] setStroke];
            break;
            
        case ORANGE_BUTTON_TAG:
            [[UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0] setStroke];
            break;
            
        case ERASER_BUTTON_TAG:
            [[UIColor colorWithPatternImage:tempImage] set];
            [path setLineWidth:selectedEraserWidth];
            break;
            
        default:
            [[UIColor redColor] setStroke];
            break;
    }
    
    [path stroke];
    incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

@end
