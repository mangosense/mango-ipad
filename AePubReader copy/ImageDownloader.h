//
//  ImageDownloader.h
//  MangoReader
//
//  Created by Nikhil D on 16/10/12.
//
//

#import <UIKit/UIKit.h>

@interface ImageDownloader : NSObject<NSURLConnectionDataDelegate>
@property(nonatomic,retain)NSMutableData *dataMutable;
@property(nonatomic,retain)NSString *localImageLocation;
@end
