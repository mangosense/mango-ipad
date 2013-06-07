//
//  TableOfContentsHandler.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 28/01/13.
//
//

#import "TableOfContentsHandler.h"

@implementation TableOfContentsHandler
-(void)allocate{
    _textEnable=NO;
    _toc=[[EachCellOfTOC alloc]init];
    _array=[[NSMutableArray alloc]init];
    _toc.playOrder=-1;
}
-(void)parseFileAt:(NSString *)path{
    _parser=[[NSXMLParser alloc]   initWithContentsOfURL:[NSURL fileURLWithPath:path]];
    _parser.delegate=self;
    [_parser parse];

}
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog(@"Error occured : %@",[parseError description]);
}
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    if ([elementName isEqualToString:@"navMap"]) {
        //allocate memory
    }
    if ([elementName isEqualToString:@"navPoint"]) {
        NSLog(@"%@",attributeDict[@"playOrder"]);
        NSString *str=attributeDict[@"playOrder"];
        if (!_toc) {
            _toc=[[EachCellOfTOC alloc]init];
        }

        _toc.playOrder=str.integerValue;
    }
    if ([elementName isEqualToString:@"content"]) {
      
        NSLog(@"%@",attributeDict[@"src"]);
        _toc.file=[[NSString alloc]initWithString:attributeDict[@"src"]];
        
    }
    if ([elementName isEqualToString:@"text"]) {
        
    }
    if ([elementName isEqualToString:@"navLabel"]) {
          _textEnable=YES;
    }
    
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if (_textEnable) {
           NSLog(@"str %@",string);
               _toc.title=[[NSString alloc]initWithString:string];
        
    }
      
    
   
    
}
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([elementName isEqualToString:@"navMap"]) {
      //end
        for (EachCellOfTOC *toc in _array) {
            NSLog(@"playOrder %d file %@ title %@",toc.playOrder,toc.file,toc.title);
        }
        [_delegate listOfTOC:_array];
    //    [_array autorelease];
     //   [self autorelease];
    }
    if ([elementName isEqualToString:@"navPoint"]) {
        EachCellOfTOC *toc=[[EachCellOfTOC alloc]init];
        toc.title=[[NSString alloc]initWithString:_toc.title];
        toc.file=[[NSString alloc]initWithString:_toc.file];
        toc.playOrder=_toc.playOrder;
        [_array addObject:toc];
     //   [toc release];
      //  [_toc release];
      //  _toc=nil;
        _toc=[[EachCellOfTOC alloc]init];
        _toc.playOrder=-1;
    }
    if ([elementName isEqualToString:@"content"]) {
     //   _textEnable=NO;
    }
    if ([elementName isEqualToString:@"text"]) {
        
    }
    if ([elementName isEqualToString:@"navLabel"]) {
        _textEnable=NO;
    }


}
/*-(void)dealloc{
    [_parser release];
   // [_array release];
    [super dealloc];
}*/
@end
