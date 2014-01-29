//
//  iCarouselImageView.h
//  MangoReader
//
//  Created by Avinash Nehra on 1/28/14.
//
//

#import <UIKit/UIKit.h>
#import "MangoApiController.h"

@protocol iCarouselImageCachingProtocol

- (void)iCarouselSaveImage:(UIImage *)image ForUrl:(NSString *)imageUrl;

@end

@interface iCarouselImageView : UIImageView <MangoPostApiProtocol>

@property (nonatomic, assign) id <iCarouselImageCachingProtocol> delegate;

- (void)getImageForUrl:(NSString *)urlString;

@end
