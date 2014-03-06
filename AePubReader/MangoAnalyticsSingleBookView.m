//
//  MangoAnalyticsSingleBookView.m
//  MangoReader
//
//  Created by Harish on 3/5/14.
//
//

#import "MangoAnalyticsSingleBookView.h"

@implementation MangoAnalyticsSingleBookView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.text = @"Test";
        [self addSubview:label];
        
        _analayticsGradeLevel.text = @"2nd - 3rd";
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

@end
