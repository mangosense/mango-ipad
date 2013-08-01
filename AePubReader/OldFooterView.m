//
//  OldFooterView.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 31/07/13.
//
//

#import "OldFooterView.h"

@implementation OldFooterView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        frame.origin.x=frame.size.width/2-50;
        NSLog(@"x= %f ",frame.origin.x);
        frame.origin.y=0;
        frame.size.height=30;
        frame.size.width=100;
        self.button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.button.frame=frame;
        [self.button setTitle:@"Load More" forState:UIControlStateNormal];
        
        [self addSubview:self.button];
  
    }
      return self;
}
-(void)setTarget:(id)target{
    [self.button addTarget:target action:@selector(loadMore:) forControlEvents:UIControlEventTouchUpInside];
    
}

@end
