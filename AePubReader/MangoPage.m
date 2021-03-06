//
//  MangoPage.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 26/11/13.
//
//

#import "MangoPage.h"

@implementation MangoPage

@synthesize id;
@synthesize created_at;
@synthesize updated_at;
@synthesize deleted_at;
@synthesize story_id;
@synthesize is_avail;
@synthesize name;
@synthesize layers;
@synthesize pageNo;
@synthesize pageable_id;

- (NSString *)type {
    return NSStringFromClass([self class]);
}

- (NSString *)oidPropertyName {
    return @"id";
}

- (NSDictionary *)toDictionary {
    return NSDictionaryOfVariableBindings(name, layers, pageable_id);
}

- (void)fromDictionary:(NSDictionary *)dictionary {
    NSArray *keysArray = [NSArray arrayWithObjects:@"id", @"name", @"layers", @"pageable_id", nil];
    for (NSString *key in keysArray)
    {
        if ([[dictionary allKeys] containsObject:key]) {
            [self setValue:[dictionary objectForKey:key] forKey:key];
        }
    }
}

- (id)copyWithZone:(NSZone *)zone {
    MangoPage *mangoPage = [[MangoPage alloc] init];
    [mangoPage setId:id];
    [mangoPage setCreated_at:created_at];
    [mangoPage setUpdated_at:updated_at];
    [mangoPage setDeleted_at:deleted_at];
    [mangoPage setStory_id:story_id];
    [mangoPage setIs_avail:is_avail];
    [mangoPage setName:name];
    [mangoPage setLayers:layers];
    [mangoPage setPageNo:pageNo];
    [mangoPage setPageable_id:pageable_id];
    return mangoPage;
}

@end
