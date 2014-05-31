//
//  StoreCollectionHeaderView.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 04/12/13.
//
//

#import "StoreCollectionHeaderView.h"
#import "Constants.h"

@implementation StoreCollectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, frame.size.width - 100, 20)];
        [self addSubview:_titleLabel];
        
        _lineView = [[UILabel alloc] initWithFrame:CGRectMake(0, -2, frame.size.width, 2)];
        [_lineView setBackgroundColor:COLOR_DARK_RED];
        [_lineView setAlpha:0.3f];
        [self addSubview:_lineView];

        _seeAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            [_seeAllButton setFrame:CGRectMake(frame.size.width - 100, 10, 80, 15)];
        }
        else{
            [_seeAllButton setFrame:CGRectMake(frame.size.width - 100, 10, 100, 20)];
        }
        
        [_seeAllButton setImage:[UIImage imageNamed:@"see all.png"] forState:UIControlStateNormal];
        [_seeAllButton addTarget:self action:@selector(seeAll) forControlEvents:UIControlEventTouchUpInside];        
        _seeAllButton.hidden = YES;
        [self addSubview:_seeAllButton];
    }
    return self;
}

- (void)setSection:(int)sectionFromCollection {
    _section = sectionFromCollection;    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Action Methods

- (void)seeAll {
    [self.delegate seeAllTapped:self.section];
}

@end
