//
//  MangoAudioLayer.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 27/11/13.
//
//

#import <Foundation/Foundation.h>
#import "EJDBKit/BSONArchiving.h"

@interface MangoAudioLayer : NSObject<BSONArchiving, NSCopying>
@property(strong,nonatomic) NSString *url;
@property(strong,nonatomic) NSArray *wordMap;
@property(strong,nonatomic) NSArray *wordTimes;
@property(strong,nonatomic) NSString *id;
@property (nonatomic, assign) BOOL isNew;

@end
