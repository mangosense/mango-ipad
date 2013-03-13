//
//  EachCellOfTOC.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 28/01/13.
//
//

#import "EachCellOfTOC.h"

@implementation EachCellOfTOC
-(void)dealloc{
    [_title release];
    [_file release];
    [super dealloc];
}
@end
