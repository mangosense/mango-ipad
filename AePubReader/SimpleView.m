//
//  SimpleView.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 10/01/13.
//
//

#import "SimpleView.h"

@implementation SimpleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.backgroundColor=[UIColor clearColor];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_webview touchesBegan:touches withEvent:event];
    [_webview.scrollView touchesBegan:touches withEvent:event];
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [_webview touchesCancelled:touches withEvent:event];

    [_webview.scrollView touchesCancelled:touches withEvent:event];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touch ended %d)",_webview.subviews.count);
    [_webview touchesEnded:touches withEvent:event];
    [_webview.scrollView touchesEnded:touches withEvent:event];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [_webview touchesMoved:touches withEvent:event];
    [_webview.scrollView touchesMoved:touches withEvent:event];
}
@end
