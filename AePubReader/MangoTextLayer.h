//
//  MangoTextLayer.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 27/11/13.
//
//

#import <Foundation/Foundation.h>
#import "EJDBKit/BSONArchiving.h"

@interface MangoTextLayer : NSObject<BSONArchiving, NSCopying>
@property(retain,nonatomic) NSString *id;
@property(retain,nonatomic) NSString *actualText;
@property(retain,nonatomic) NSString *colour;
@property(retain,nonatomic) NSNumber *fontSize;
@property(retain,nonatomic) NSString *fontStyle;
@property(retain,nonatomic) NSString *fontWeight;
@property(retain,nonatomic) NSNumber *height;
@property(retain,nonatomic) NSNumber *width;
@property(retain,nonatomic) NSNumber *leftRatio;
@property(retain,nonatomic) NSNumber *topRatio;
@property(retain,nonatomic) NSNumber *lineHeight;
@property (nonatomic, assign) BOOL isNew;

@end
