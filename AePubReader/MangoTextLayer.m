//
//  MangoTextLayer.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 27/11/13.
//
//

#import "MangoTextLayer.h"

@implementation MangoTextLayer
@synthesize id;
@synthesize actualText;
@synthesize colour;
@synthesize fontSize;
@synthesize fontWeight;
@synthesize fontStyle;
@synthesize height;
@synthesize width;
@synthesize leftRatio;
@synthesize topRatio;
@synthesize lineHeight;
- (NSString *)type {
    return NSStringFromClass([self class]);
}

- (NSString *)oidPropertyName {
    return @"id";
}

- (NSDictionary *)toDictionary {
    
    return NSDictionaryOfVariableBindings(actualText,fontSize,
                                          height,width,leftRatio,topRatio,lineHeight);
}

- (void)fromDictionary:(NSDictionary *)dictionary {
    NSArray *keysArray = [NSArray arrayWithObjects:@"id",@"actualText",@"fontSize"
                          @"height",@"width",@"leftRatio",@"topRatio",@"lineHeight", nil];
    for (NSString *key in keysArray)
    {
        if ([[dictionary allKeys] containsObject:key]) {
            [self setValue:[dictionary objectForKey:key] forKey:key];
        }
    }
}

- (id)copyWithZone:(NSZone *)zone {
    MangoTextLayer *mangoTextLayer=[[MangoTextLayer alloc]init];
    [mangoTextLayer setId:id];
    mangoTextLayer.actualText=actualText;
    mangoTextLayer.colour=colour;
    mangoTextLayer.fontSize=fontSize;
    mangoTextLayer.fontStyle=fontStyle;
    mangoTextLayer.fontWeight=fontWeight;
    mangoTextLayer.height=height;
    mangoTextLayer.width=width;
    mangoTextLayer.leftRatio=leftRatio;
    mangoTextLayer.topRatio=topRatio;
    mangoTextLayer.lineHeight=lineHeight;
    return mangoTextLayer;
   
}
@end
