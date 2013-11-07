//
//  FeaturedStoreDelegate.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 25/10/13.
//
//

#import <Foundation/Foundation.h>
#import "iCarousel.h"
@interface FeaturedStoreDelegate : NSObject<iCarouselDataSource>
@property(nonatomic,retain) NSMutableArray *items;
@property(nonatomic,retain) NSString *string;
-(id)initPrefixString:(NSString *) string;
@end
