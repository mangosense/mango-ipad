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
    
    CGRect rectangle = CGRectMake(0, 0,_progress  ,rect.size.height-10 );
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
    CGContextFillRect(context, rectangle);

}


@end
