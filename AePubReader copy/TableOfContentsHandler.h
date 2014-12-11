//
//  TableOfContentsHandler.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 28/01/13.
//
//

#import <Foundation/Foundation.h>
#import "EachCellOfTOC.h"

@protocol TableOfContentDelegate
-(void)listOfTOC:(NSMutableArray *)array;
@end
@interface TableOfContentsHandler : NSObject<NSXMLParserDelegate>
@property(retain,nonatomic)NSXMLParser *parser;
@property(assign,nonatomic)id<TableOfContentDelegate> delegate;
-(void)parseFileAt:(NSString *)path;
@property(assign,nonatomic)BOOL textEnable;
@property(retain,nonatomic)EachCellOfTOC *toc;
@property(retain,nonatomic)NSMutableArray *array;
-(void)allocate;

@end
