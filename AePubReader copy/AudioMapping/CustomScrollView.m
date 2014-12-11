//
//  CustomScrollView.m
//  Hi
//
//  Created by Nikhil Dhavale on 22/10/13.
//  Copyright (c) 2013 Nikhil Dhavale. All rights reserved.
//

#import "CustomScrollView.h"

@implementation CustomScrollView

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
    self.minimumZoomScale = 1.0;
    self.minimumZoomScale = 1.0;
    CGRect rectangle = CGRectMake(0, 0,_progress  ,rect.size.height-10);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 240.0/255.0, 189.0/255.0, 35.0/255.0, 1.0);
    CGRect background=rect;
    background.size.height-=10;
    CGContextFillRect(context, background);
    CGContextSetRGBFillColor(context, 132.0/255.0, 197.0/255.0, 78.0/255.0, 1.0);
    
    CGContextFillRect(context, rectangle);
    
}


@end
