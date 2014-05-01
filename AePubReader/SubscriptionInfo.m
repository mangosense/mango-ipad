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
@synthesize subscriptionProductId;
@synthesize subscriptionTransctionId;
@synthesize subscriptionReceiptData;
@synthesize subscriptionAmount;

- (NSString *)type {
    return NSStringFromClass([self class]);
}

- (NSString *)oidPropertyName {
    return @"id";
}


- (NSDictionary *)toDictionary {
    //   NSLog(@"todictionary");
    return NSDictionaryOfVariableBindings(subscriptionProductId, subscriptionTransctionId, subscriptionReceiptData, subscriptionAmount);
}

- (void)fromDictionary:(NSDictionary *)dictionary {
    NSArray *array=[NSArray arrayWithObjects:@"id", @"subscriptionProductId", @"subscriptionTransctionId", @"subscriptionReceiptData", @"subscriptionAmount", nil];
    for (NSString *key in array)
    {
        if ([[dictionary allKeys] containsObject:key]) {
            [self setValue:[dictionary objectForKey:key] forKey:key];
        }
    }
    // NSLog(@"fromDictionary");
}


/*- (NSDictionary *)toDictionary
{
    return @{@"type" : [self type],@"productid" : subscriptionProductId, @"transctionid" : subscriptionTransctionId, @"reciptdata" : subscriptionReceiptData, @"amount" : subscriptionAmount};
}*/

/*- (NSDictionary *)toDictionary {
    return NSDictionaryOfVariableBindings(subscriptionProductId);
}*/

/*- (void)fromDictionary:(NSDictionary *)dictionary {
    NSArray *array=[NSArray arrayWithObjects:@"subscriptionProductId", @"subscriptionTransctionId", @"subscriptionReceiptData", @"subscriptionAmount", nil];
    for (NSString *key in array)
    {
        if ([[dictionary allKeys] containsObject:key]) {
            [self setValue:[dictionary objectForKey:key] forKey:key];
        }
    }
}*/

/*- (void)fromDictionary:(NSDictionary *)dictionary
{
    for (NSString *key in [dictionary keyEnumerator])
    {
        [self setValue:[dictionary objectForKey:key] forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    value = [key isEqual:@"type"] ? [self type] : [NSNull null];
}*/

- (id)copyWithZone:(NSZone *)zone {
    SubscriptionInfo *subscriptionInfo = [[SubscriptionInfo alloc] init];
    
    [subscriptionInfo setId:id];
    [subscriptionInfo setSubscriptionProductId:subscriptionProductId];
    [subscriptionInfo setSubscriptionTransctionId:subscriptionTransctionId];
    [subscriptionInfo setSubscriptionReceiptData:subscriptionReceiptData];
    [subscriptionInfo setSubscriptionAmount:subscriptionAmount];
    
    return subscriptionInfo;
}

@end
