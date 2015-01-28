//
//  UserAgeInfo.h
//  MangoReader
//
//  Created by Harish on 1/27/15.
//
//

#import <Foundation/Foundation.h>
#import "EJDBKit/BSONArchiving.h"

@interface UserAgeInfo : NSObject<BSONArchiving,NSCopying>

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *userAgeValue;

@end
