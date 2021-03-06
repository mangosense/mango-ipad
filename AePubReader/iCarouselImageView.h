//
//  iCarouselImageView.h
//  MangoReader
//
//  Created by Avinash Nehra on 1/28/14.
//
//

#import <UIKit/UIKit.h>
#import "MangoApiController.h"

@protocol iCarouselImageCachingProtocol <NSObject>

- (void)iCarouselSaveImage:(UIImage *)image ForUrl:(NSString *)imageUrl;

@end

@interface iCarouselImageView : UIImageView <MangoPostApiProtocol>

@property (nonatomic, weak) id <iCarouselImageCachingProtocol> delegate;

- (void)getImageForUrl:(NSString *)urlString;

@end
