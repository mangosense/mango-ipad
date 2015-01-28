//
//  UserAgeInfo.m
//  MangoReader
//
//  Created by Harish on 1/27/15.
//
//

#import "UserAgeInfo.h"

@implementation UserAgeInfo

@synthesize id;
@synthesize userAgeValue;

- (NSString *)type {
    return NSStringFromClass([self class]);
}

- (NSString *)oidPropertyName {
    return @"id";
}


- (NSDictionary *)toDictionary {
    //   NSLog(@"todictionary");
    return NSDictionaryOfVariableBindings(userAgeValue);
}

- (void)fromDictionary:(NSDictionary *)dictionary {
    NSArray *array=[NSArray arrayWithObjects:@"id", @"userAgeValue", nil];
    for (NSString *key in array)
    {
        if ([[dictionary allKeys] containsObject:key]) {
            [self setValue:[dictionary objectForKey:key] forKey:key];
        }
    }
    // NSLog(@"fromDictionary");
}

- (id)copyWithZone:(NSZone *)zone {
    UserAgeInfo *userInfoAge = [[UserAgeInfo alloc] init];
    
    [userInfoAge setId:id];
    [userInfoAge setUserAgeValue:userAgeValue];
    
    
    return userInfoAge;
}

@end
