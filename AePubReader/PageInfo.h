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
    NSMutableArray *textArray;
    NSMutableArray *audioArray;
    UIImage *backgroundImage;
}

@property (nonatomic, strong) NSNumber *pageNumber;
@property (nonatomic, strong) NSMutableArray *textArray;
@property (nonatomic, strong) NSMutableArray *audioArray;
@property (nonatomic, strong) UIImage *backgroundImage;

@end
