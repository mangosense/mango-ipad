//
//  CustomLabel.m
//  Hi
//
//  Created by Nikhil Dhavale on 21/10/13.
//  Copyright (c) 2013 Nikhil Dhavale. All rights reserved.
//

#import "CustomLabel.h"
#import "BaseViewSample.h"
#define kResizeThumbSize 15

@implementation CustomLabel

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
// An empty implementation adversely affects performance during animation.*/
/*- (void)drawRect:(CGRect)rect
{
    // Drawing code
}*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
/* if (_isResizing) {
        _touchStart = CGPointMake(_touchStart.x - self.bounds.size.width,
                                 _touchStart.y - self.bounds.size.height);
    }
    CGPoint pt=[[touches anyObject] locationInView:self.superview];
    NSLog(@"%f %f",pt.x,pt.y);*/
    _scrollView.scrollEnabled=NO;
    _point=self.center;
 //   NSLog(@"touchbegan");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
  
    

    if (_isResizing) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                                touchPoint.x - _touchStart.x, touchPoint.y - _touchStart.y);
    } else {
        
        self.center = CGPointMake(self.center.x + touchPoint.x - _touchStart.x,
                                  self.center.y);
    }
  //  NSLog(@"touchmoved");

    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //NSLog(@"touchend");

    
    
    CGPoint pt=[[touches anyObject] locationInView:self.superview.superview];
    if (pt.x>=_xmin&&pt.x<=_xmax) {
        
        self.center=_point;
        _scrollView.scrollEnabled=YES;

        return;
    }
    int i=0;
    for (;i<_arrayOfViews.count;i++) {
        
        BaseViewSample *view=_arrayOfViews[i];
        CGRect frame=view.frame;
        CGFloat xmax=frame.size.width+frame.origin.x;

       // NSLog(view.containsValue ? @"Yes" : @"No");
        if (view.tag!=self.tag&&!view.containsValue) {
        //    NSLog(view.containsValue ? @"Yes" : @"No");

            
            if (frame.origin.x<=pt.x&&pt.x<=xmax&&!view.containsValue) {
           //     NSLog(@"points are in the view number of subviews ");
                //    self.frame=CGRectMake(0, 0,self.frame.size.width, self.frame.size.height);
                BaseViewSample *bseView=(BaseViewSample *)self.superview;
                               [self removeFromSuperview];
                bseView.containsValue=NO;
                self.tag=view.tag;
                //NSLog(@"%@",_cues);
                float val=ceilf(view.value*1000);
                NSLog(@"%f",val);
                NSInteger intVal=val;
                NSLog(@"%d",intVal);
                if (_cues.count>_index+1) {
                    NSNumber *numNext=_cues[_index+1];
                  
                    if (numNext.integerValue<intVal) {
                        [_delegate sampleAudio];

                        return;
                    }
                }
                _cues[_index]=[NSNumber numberWithInteger:intVal];
              //  NSLog(@"%@",_cues);
                [view addSubview:self];
                //  [self.viewToDrag addSubview:self];
                _scrollView.scrollEnabled=YES;
                [_delegate sampleAudio];
                break;
            }
        }
    }
    if (i==_arrayOfViews.count) {
        self.center=_point;

    }
    _scrollView.scrollEnabled=YES;
}
@end
