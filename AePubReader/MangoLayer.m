//
//  MangoLayer.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 26/11/13.
//
//

#import "MangoLayer.h"

@implementation MangoLayer

@synthesize alignment;
@synthesize created_at;
@synthesize name;
@synthesize style;
@synthesize text;
@synthesize type;
@synthesize updated_at;
@synthesize url;
@synthesize id;
@synthesize wordMap;
@synthesize wordTimes;

- (NSString *)type {
    return NSStringFromClass([self class]);
}

- (NSString *)oidPropertyName {
    return @"id";
}

- (NSDictionary *)toDictionary {
    return NSDictionaryOfVariableBindings(name, style);
}

- (void)fromDictionary:(NSDictionary *)dictionary {
    NSArray *keysArray = [NSArray arrayWithObjects:@"id", @"name", @"style", nil];
    for (NSString *key in keysArray)
    {
        if ([[dictionary allKeys] containsObject:key]) {
            [self setValue:[dictionary objectForKey:key] forKey:key];
        }
    }
}

- (id)copyWithZone:(NSZone *)zone {
    MangoLayer *mangoLayer = [[MangoLayer alloc] init];
    [mangoLayer setId:id];
    [mangoLayer setCreated_at:created_at];
    [mangoLayer setUpdated_at:updated_at];
    [mangoLayer setName:name];
    [mangoLayer setAlignment:alignment];
    [mangoLayer setStyle:style];
    [mangoLayer setText:text];
    [mangoLayer setType:type];
    [mangoLayer setUrl:url];
    [mangoLayer setWordMap:wordMap];
    [mangoLayer setWordTimes:wordTimes];
    return mangoLayer;
}

@end
