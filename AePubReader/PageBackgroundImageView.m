//
//  PageBackgroundImageView.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 09/08/13.
//
//

#import "PageBackgroundImageView.h"
#import <QuartzCore/QuartzCore.h>

#define RED_BUTTON_TAG 1
#define YELLOW_BUTTON_TAG 2
#define GREEN_BUTTON_TAG 3
#define BLUE_BUTTON_TAG 4
#define PEA_GREEN_BUTTON_TAG 5
#define PURPLE_BUTTON_TAG 6
#define ORANGE_BUTTON_TAG 7

#define SMALL_BRUSH_TAG 1
#define MEDIUM_BRUSH_TAG 2
#define LARGE_BRUSH_TAG 3

@implementation PageBackgroundImageView

@synthesize indexOfThisImage;
@synthesize delegate;
@synthesize selectedColor;
@synthesize selectedBrush;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setUserInteractionEnabled:YES];
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

#pragma mark - Touch Event Methods

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    self.location = [touch locationInView:self];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentLocation = [touch locationInView:self];
    
    UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    CGContextSetLineCap(ctx, kCGLineCapRound);
    switch (selectedBrush) {
        case SMALL_BRUSH_TAG:
            CGContextSetLineWidth(ctx, 5.0);
            break;
            
        case MEDIUM_BRUSH_TAG:
            CGContextSetLineWidth(ctx, 10.0);
            break;
            
        case LARGE_BRUSH_TAG:
            CGContextSetLineWidth(ctx, 15.0);
            break;
            
        default:
            CGContextSetLineWidth(ctx, 5.0);
            break;
    }
    CGContextSetShouldAntialias(ctx, false);
    switch (selectedColor) {
        case RED_BUTTON_TAG:
            CGContextSetRGBStrokeColor(ctx, 1.0, 0.0, 0.0, 1.0);
            break;
            
        case GREEN_BUTTON_TAG:
            CGContextSetRGBStrokeColor(ctx, 0.0, 1.0, 0.0, 1.0);
            break;
            
        case BLUE_BUTTON_TAG:
            CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 1.0, 1.0);
            break;
            
        case YELLOW_BUTTON_TAG:
            CGContextSetRGBStrokeColor(ctx, 1.0, 1.0, 0.0, 1.0);
            break;
            
        case PEA_GREEN_BUTTON_TAG:
            CGContextSetRGBStrokeColor(ctx, 0.06, 0.87, 0.69, 1.0);
            break;
            
        case PURPLE_BUTTON_TAG:
            CGContextSetRGBStrokeColor(ctx, 1.0, 0.0, 1.0, 1.0);
            break;
            
        case ORANGE_BUTTON_TAG:
            CGContextSetRGBStrokeColor(ctx, 1.0, 0.5, 0.0, 1.0);
            break;
            
        default:
            break;
    }
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, self.location.x, self.location.y);
    CGContextAddLineToPoint(ctx, currentLocation.x, currentLocation.y);
    CGContextStrokePath(ctx);
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.location = currentLocation;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentLocation = [touch locationInView:self];
    
    UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    CGContextSetLineCap(ctx, kCGLineCapRound);
    switch (selectedBrush) {
        case SMALL_BRUSH_TAG:
            CGContextSetLineWidth(ctx, 5.0);
            break;
            
        case MEDIUM_BRUSH_TAG:
            CGContextSetLineWidth(ctx, 10.0);
            break;
            
        case LARGE_BRUSH_TAG:
            CGContextSetLineWidth(ctx, 15.0);
            break;
            
        default:
            CGContextSetLineWidth(ctx, 5.0);
            break;
    }
    CGContextSetShouldAntialias(ctx, false);
    switch (selectedColor) {
        case RED_BUTTON_TAG:
            CGContextSetRGBStrokeColor(ctx, 1.0, 0.0, 0.0, 1.0);
            break;
            
        case GREEN_BUTTON_TAG:
            CGContextSetRGBStrokeColor(ctx, 0.0, 1.0, 0.0, 1.0);
            break;
            
        case BLUE_BUTTON_TAG:
            CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 1.0, 1.0);
            break;
            
        case YELLOW_BUTTON_TAG:
            CGContextSetRGBStrokeColor(ctx, 1.0, 1.0, 0.0, 1.0);
            break;
            
        case PEA_GREEN_BUTTON_TAG:
            CGContextSetRGBStrokeColor(ctx, 0.0, 204/255, 102/255, 1.0);
            break;
            
        case PURPLE_BUTTON_TAG:
            CGContextSetRGBStrokeColor(ctx, 1.0, 0.0, 1.0, 1.0);
            break;
            
        case ORANGE_BUTTON_TAG:
            CGContextSetRGBStrokeColor(ctx, 1.0, 0.5, 0.0, 1.0);
            break;
            
        default:
            break;
    }
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, self.location.x, self.location.y);
    CGContextAddLineToPoint(ctx, currentLocation.x, currentLocation.y);
    CGContextStrokePath(ctx);
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [delegate replaceImageAtIndex:indexOfThisImage withImage:self.image];
    self.location = currentLocation;
}

@end
