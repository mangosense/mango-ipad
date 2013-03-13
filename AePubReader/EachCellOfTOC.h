//
//  EachCellOfTOC.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 28/01/13.
//
//

#import <Foundation/Foundation.h>

@interface EachCellOfTOC : NSObject
@property(nonatomic,assign)NSInteger playOrder;
@property(nonatomic,retain)NSString *file;
@property(nonatomic,retain)NSString *title;
@end
