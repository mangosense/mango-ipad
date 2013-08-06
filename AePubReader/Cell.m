//
//  Cell.m
//  CollectionViewExample
//
//  Created by Paul Dakessian on 9/6/12.
//  Copyright (c) 2012 Paul Dakessian, CapTech Consulting. All rights reserved.
//

#import "Cell.h"
#import <QuartzCore/QuartzCore.h>
@implementation Cell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.button=[ShadowButton buttonWithType:UIButtonTypeCustom];
        self.button.frame=CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
        
        [self.contentView addSubview:self.button];;
    }
    return self;
}

@end