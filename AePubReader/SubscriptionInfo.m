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
@synthesize expirationDate;
@synthesize type;

- (NSString *)type {
    return NSStringFromClass([self class]);
}

- (NSString *)oidPropertyName {
    return @"id";
}

- (NSDictionary *)toDictionary {
    return NSDictionaryOfVariableBindings(expirationDate, type);
}

- (void)fromDictionary:(NSDictionary *)dictionary {
    NSArray *array=[NSArray arrayWithObjects:@"id", @"expirationDate", @"type", nil];
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
    [subscriptionInfo setExpirationDate:expirationDate];
    [subscriptionInfo setType:type];
    return subscriptionInfo;
}

@end
