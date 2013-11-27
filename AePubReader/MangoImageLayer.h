//
//  MangoImageLayer.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 27/11/13.
//
//

#import <Foundation/Foundation.h>
#import "EJDBKit/BSONArchiving.h"

@interface MangoImageLayer : NSObject<BSONArchiving, NSCopying>
@property (nonatomic, strong) NSString *alignment;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *id;

@end
