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
        [[self layer] setCornerRadius:12];
        [self setTag:iCarousel_VIEW_TAG];
        [self setContentMode:UIViewContentModeScaleToFill];
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
