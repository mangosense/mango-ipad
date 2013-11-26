//
//  MangoBook.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 26/11/13.
//
//

#import "MangoBook.h"

@implementation MangoBook

@synthesize id;
@synthesize title;
@synthesize pages;
@synthesize created_at;
@synthesize updated_at;

- (NSString *)type {
    return NSStringFromClass([self class]);
}

- (NSString *)oidPropertyName {
    return @"id";
}

- (NSDictionary *)toDictionary {
    return NSDictionaryOfVariableBindings(id, title, pages, created_at, updated_at);
}

- (void)fromDictionary:(NSDictionary *)dictionary {
    for (NSString *key in [dictionary keyEnumerator])
    {
        [self setValue:[dictionary objectForKey:key] forKey:key];
    }
}

- (id)copyWithZone:(NSZone *)zone {
    MangoBook *mangoBook = [[MangoBook alloc] init];
    [mangoBook setId:id];
    [mangoBook setTitle:title];
    [mangoBook setPages:pages];
    [mangoBook setCreated_at:created_at];
    [mangoBook setUpdated_at:updated_at];
    return mangoBook;
}

@end
