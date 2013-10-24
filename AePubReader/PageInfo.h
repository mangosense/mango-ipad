//
//  PageInfo.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 18/10/13.
//
//

#import <Foundation/Foundation.h>

@interface PageInfo : NSObject {
    NSNumber *pageNumber;
    NSData *pageAudioData;
    UIImage *backgroundImage;
    NSString *pageText;
}

@property (nonatomic, strong) NSNumber *pageNumber;
@property (nonatomic, strong) NSData *pageAudioData;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) NSString *pageText;

@end
