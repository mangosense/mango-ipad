//
//  FooterView.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 24/07/13.
//
//

#import "FooterView.h"

@implementation FooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        frame.origin.x=frame.size.width/2-50;
        NSLog(@"x= %f ",frame.origin.x);
        frame.origin.y=0;
        frame.size.height=30;
        frame.size.width=100;
        self.button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.button.frame=frame;
        [self.button setTitle:@"Load More" forState:UIControlStateNormal];

        [self addSubview:self.button];
      //  self.backgroundColor=[UIColor redColor];
    }
    return self;
}
-(void)setTarget:(id)target{
    [self.button addTarget:target action:@selector(loadMore:) forControlEvents:UIControlEventTouchUpInside];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
