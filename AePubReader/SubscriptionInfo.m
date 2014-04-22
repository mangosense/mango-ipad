//
//  SubscriptionInfo.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 15/04/14.
//
//

#import "SubscriptionInfo.h"

@implementation SubscriptionInfo

@synthesize id;
@synthesize subscriptionType;

- (NSString *)type {
    return NSStringFromClass([self class]);
}

- (NSString *)oidPropertyName {
    return @"id";
}

- (NSDictionary *)toDictionary {
    return NSDictionaryOfVariableBindings(subscriptionType);
}

- (void)fromDictionary:(NSDictionary *)dictionary {
    NSArray *array=[NSArray arrayWithObjects:@"id", @"subscriptionType", nil];
    for (NSString *key in array)
    {
        if ([[dictionary allKeys] containsObject:key]) {
            [self setValue:[dictionary objectForKey:key] forKey:key];
        }
    }
}

- (id)copyWithZone:(NSZone *)zone {
    SubscriptionInfo *subscriptionInfo = [[SubscriptionInfo alloc] init];
    [subscriptionInfo setId:id];
    [subscriptionInfo setSubscriptionType:subscriptionType];
    return subscriptionInfo;
}

@end
