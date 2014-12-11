//
//  UserInfo.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 26/02/14.
//
//

#import "UserInfo.h"

@implementation UserInfo

@synthesize id;
@synthesize authToken;
@synthesize email;
@synthesize facebookExpirationDate;
@synthesize username;
@synthesize name;

- (NSString *)type {
    return NSStringFromClass([self class]);
}

- (NSString *)oidPropertyName {
    return @"id";
}

- (NSDictionary *)toDictionary {
    return NSDictionaryOfVariableBindings(authToken, email);
}

- (void)fromDictionary:(NSDictionary *)dictionary {
    NSArray *array=[NSArray arrayWithObjects:@"id", @"authToken", @"email", nil];
    for (NSString *key in array)
    {
        if ([[dictionary allKeys] containsObject:key]) {
            [self setValue:[dictionary objectForKey:key] forKey:key];
        }
    }
}

- (id)copyWithZone:(NSZone *)zone {
    UserInfo *userInfo = [[UserInfo alloc] init];
    [userInfo setEmail:email];
    [userInfo setId:id];
    [userInfo setFacebookExpirationDate:facebookExpirationDate];
    [userInfo setAuthToken:authToken];
    [userInfo setUsername:username];
    [userInfo setName:name];
    return userInfo;
}

@end
