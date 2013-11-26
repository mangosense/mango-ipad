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
 //   NSLog(@"todictionary");
    return NSDictionaryOfVariableBindings(id, title, pages);
}

- (void)fromDictionary:(NSDictionary *)dictionary {
    NSArray *array=[NSArray arrayWithObjects:@"id",@"title", @"pages", nil];
    for (NSString *key in array)
    {
        if ([[dictionary allKeys] containsObject:key]) {
            [self setValue:[dictionary objectForKey:key] forKey:key];
        }
    }
   // NSLog(@"fromDictionary");
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
