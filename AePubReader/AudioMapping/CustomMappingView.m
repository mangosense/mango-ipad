//
//  CustomMappingView.m
//  Hi
//
//  Created by Nikhil Dhavale on 16/10/13.
//  Copyright (c) 2013 Nikhil Dhavale. All rights reserved.
//

#import "CustomMappingView.h"

@implementation CustomMappingView

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
- (void)drawRect:(CGRect)rect
{
    CGPoint pt;
    pt.x=0;
    pt.y=0;
    CGSize size;
    //_textFont=[UIFont systemFontOfSize:14];
    CGRect rectangle = CGRectMake(_x-1, _y, _width+1 , _height);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 132.0/255.0, 197.0/255.0, 78.0/255.0, 1.0);
    //  CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    CGContextFillRect(context, rectangle);
    NSLog(@" rect %f %f",_x,_width);
    CGContextSetRGBFillColor(context, 53.0/255.0, 53.0/255.0, 53.0/255.0, 1.0);

    for (NSString *str in _text) {
        
        if ([UIDevice currentDevice].systemVersion.integerValue<6) {
            size=[str sizeWithFont:_textFont];
            
        }else{
            NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:_textFont, NSFontAttributeName, nil];
            size=   [[[NSAttributedString alloc] initWithString:str attributes:attributes] size];

            
        }
        if ((pt.x+size.width)>(rect.size.width)) {
            pt.x=0;
            pt.y+=size.height;
        }
        
        [str drawAtPoint:pt forWidth:size.width withFont:_textFont fontSize:_textFont.pointSize lineBreakMode:NSLineBreakByCharWrapping baselineAdjustment:UIBaselineAdjustmentNone];
       // NSLog(@" char %@ %f %f",str ,pt.x,size.width);

        pt.x+=size.width+_space.width;
        
    }
    
    
}


@end
