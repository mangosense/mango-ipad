//
//  MangoAudioLayer.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 27/11/13.
//
//

#import "MangoAudioLayer.h"

@implementation MangoAudioLayer
@synthesize url;
@synthesize wordMap;
@synthesize wordTimes;
@synthesize id;
- (NSString *)type {
    return NSStringFromClass([self class]);
}

- (NSString *)oidPropertyName {
    return @"id";
}

- (NSDictionary *)toDictionary {
    return NSDictionaryOfVariableBindings(url,wordMap,wordTimes);
}

- (void)fromDictionary:(NSDictionary *)dictionary {
    NSArray *keysArray = [NSArray arrayWithObjects:@"id", @"url",@"wordMap",@"wordTimes", nil];
    for (NSString *key in keysArray)
    {
        if ([[dictionary allKeys] containsObject:key]) {
            [self setValue:[dictionary objectForKey:key] forKey:key];
        }
    }
}

- (id)copyWithZone:(NSZone *)zone {
    MangoAudioLayer *mangoAudioLayer=[[MangoAudioLayer alloc]init];
    mangoAudioLayer.url=url;
    mangoAudioLayer.wordTimes=wordTimes;
    mangoAudioLayer.wordMap=wordMap;
    mangoAudioLayer.id=id;
    return mangoAudioLayer;
    
}
@end
