//
//  EJDBController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 26/11/13.
//
//

#import "EJDBController.h"
#import "Constants.h"

@implementation EJDBController

- (id)initWithCollectionName:(NSString *)collectionName andDatabaseName:(NSString *)databaseName {
    self = [super init];
    if (self) {
        _db = [[EJDBDatabase alloc]initWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] dbFileName:databaseName];
        [_db openWithError:NULL];
        _collection = [_db ensureCollectionWithName:collectionName error:NULL];
    }
    return self;
}

#pragma mark - Insert Objects

- (BOOL)insertOrUpdateObject:(id)object {
    return [_collection saveObject:object];
}

#pragma mark - Get Objects

- (MangoBook *)getBookForBookId:(NSString *)bookId {
    MangoBook *book = [_collection fetchObjectWithOID:bookId];
    return book;
}

- (MangoPage *)getPageForPageId:(NSString *)pageId {
    MangoPage *page = [_collection fetchObjectWithOID:pageId];
    return page;
}

- (MangoLayer *)getLayerForLayerId:(NSString *)layerId {
    MangoLayer *layer = [_collection fetchObjectWithOID:layerId];
    return layer;
}

#pragma mark - Parse JSON

- (void)parseBookJson:(NSData *)bookJsonData {
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:bookJsonData options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"%@", jsonDict);
    
    MangoBook *book = [[MangoBook alloc] init];
    book.id = [jsonDict objectForKey:@"id"];
    book.title = [jsonDict objectForKey:@"title"];
    
    NSArray *pagesArray = [jsonDict objectForKey:PAGES];
    
    NSMutableArray *pageIdArray = [[NSMutableArray alloc] init];
    for (NSDictionary *pageDict in pagesArray) {
        MangoPage *page = [[MangoPage alloc] init];
        page.id = [pageDict objectForKey:@"id"];
        page.story_id = [pageDict objectForKey:@"story_id"];
        page.name = [pageDict objectForKey:@"name"];
        
        NSMutableArray *layerIdArray = [[NSMutableArray alloc] init];
        for (NSDictionary *layerDict in [pageDict objectForKey:LAYERS]) {
            MangoLayer *layer = [[MangoLayer alloc] init];
            layer.id = [layerDict objectForKey:@"id"];
            layer.name = [layerDict objectForKey:@"name"];
            layer.style = [layerDict objectForKey:@"style"];
            layer.text = [layerDict objectForKey:@"text"];
            layer.type = [layerDict objectForKey:@"type"];
            layer.url = [layerDict objectForKey:@"url"];
            
            if ([self insertOrUpdateObject:layer]) {
                [layerIdArray addObject:layer.id];
            }
        }
        
        page.layers = layerIdArray;
        
        if ([self insertOrUpdateObject:page]) {
            [pageIdArray addObject:page.id];
        }
    }
    
    book.pages = pageIdArray;
    if ([self insertOrUpdateObject:book]) {
        MangoBook *fetchedBook = [self getBookForBookId:book.id];
        NSLog(@"%@", fetchedBook.pages);
        
        MangoPage *fetchedPage = [self getPageForPageId:fetchedBook.pages[5]];
        NSLog(@"%@",fetchedPage.layers);
        MangoLayer *fetchedLayer=[self getLayerForLayerId:fetchedPage.layers[0]];
        NSLog(@"%@ %@",fetchedLayer.id,fetchedLayer.name);
    }
    
}

@end
