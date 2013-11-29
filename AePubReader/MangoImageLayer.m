//
//  MangoImageLayer.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 27/11/13.
//
//

#import "MangoImageLayer.h"

@implementation MangoImageLayer
@synthesize id;
@synthesize url;
@synthesize alignment;
- (NSString *)type {
    return NSStringFromClass([self class]);
}

- (NSString *)oidPropertyName {
    return @"id";
}

- (NSDictionary *)toDictionary {
    return NSDictionaryOfVariableBindings(url, alignment);
}

- (void)fromDictionary:(NSDictionary *)dictionary {
    NSArray *keysArray = [NSArray arrayWithObjects:@"id", @"url", @"alignment", nil];
    for (NSString *key in keysArray)
    {
        if ([[dictionary allKeys] containsObject:key]) {
            [self setValue:[dictionary objectForKey:key] forKey:key];
        }
    }
}

- (id)copyWithZone:(NSZone *)zone {
    MangoImageLayer *mangoImageLayer = [[MangoImageLayer alloc] init];
    [mangoImageLayer setId:id];
    [mangoImageLayer setUrl:url];
    [mangoImageLayer setAlignment:alignment];
    return mangoImageLayer;
}
@end
