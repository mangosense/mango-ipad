//
//  UserInfo.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 26/02/14.
//
//

#import "UserInfo.h"

@implementation UserInfo

- (NSString *)type {
    return NSStringFromClass([self class]);
}

- (NSString *)oidPropertyName {
    return @"id";
}

- (NSDictionary *)toDictionary {
    return NSDictionaryOfVariableBindings(_authToken, _email);
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
    [userInfo setEmail:_email];
    [userInfo setId:_id];
    [userInfo setFacebookExpirationDate:_facebookExpirationDate];
    [userInfo setAuthToken:_authToken];
    [userInfo setUsername:_username];
    [userInfo setName:_name];
    return userInfo;
}

@end
