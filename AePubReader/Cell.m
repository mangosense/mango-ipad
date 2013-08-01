//
//  Cell.m
//  CollectionViewExample
//
//  Created by Paul Dakessian on 9/6/12.
//  Copyright (c) 2012 Paul Dakessian, CapTech Consulting. All rights reserved.
//

#import "Cell.h"

@implementation Cell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.button=[ShadowButton buttonWithType:UIButtonTypeCustom];
        self.button.frame=CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
    //    self.button = [[UIButton alloc] initWithFrame:];
        
     //   self.label.textAlignment = NSTextAlignmentCenter;
      //  self.label.textColor = [UIColor blackColor];
       // self.label.font = [UIFont boldSystemFontOfSize:35.0];
       // self.label.backgroundColor = [UIColor whiteColor];
     
        [self.contentView addSubview:self.button];;
    }
    return self;
}

@end