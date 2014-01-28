//
//  iCarouselImageView.m
//  MangoReader
//
//  Created by Avinash Nehra on 1/28/14.
//
//

#import "iCarouselImageView.h"
#import "Constants.h"
#import "MBProgressHUD.h"

@implementation iCarouselImageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];    
    if (self) {
        // Initialization code
        UIImageView *storyImageView = [[UIImageView alloc] init];
        [storyImageView setFrame:frame];
        [[storyImageView layer] setCornerRadius:12];
        [storyImageView setClipsToBounds:YES];
        [storyImageView setTag:iCarousel_VIEW_TAG];
        [storyImageView setContentMode:UIViewContentModeScaleToFill];
        [self addSubview:storyImageView];
    }
    
    return self;
}

- (void)getImageForUrl:(NSString *)urlString {
    MangoApiController *apiController = [MangoApiController sharedApiController];
    [apiController getImageAtUrl:urlString withDelegate:self];
}

- (void)reloadImage:(UIImage *)image forUrl:(NSString *)urlString {
    [MBProgressHUD hideAllHUDsForView:self animated:YES];
    
    [self setImage:image];
    [self.delegate iCarouselSaveImage:image ForUrl:urlString];
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
