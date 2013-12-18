//
//  EJDBController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 26/11/13.
//
//

#import "EJDBController.h"
#import "Constants.h"
#import "AePubReaderAppDelegate.h"
#import "DataModelControl.h"
#import "Book.h"
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

- (id)getLayerForLayerId:(NSString *)layerId {
    id layer = [_collection fetchObjectWithOID:layerId];
    return layer;
}

#pragma mark - Save Book To Core Data

- (void)saveBook:(MangoBook *)book AtLocation:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        NSURL *url = [[NSURL alloc]initFileURLWithPath:filePath];
        [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:nil];
    }

    // adding to database
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (![appDelegate.dataModel checkIfIdExists:book.id]) {
        Book *coreDatabook= [appDelegate.dataModel getBookInstance];
        coreDatabook.title=book.title;
        coreDatabook.link=nil;
        coreDatabook.localPathImageFile = filePath;
        coreDatabook.localPathFile = [filePath stringByDeletingPathExtension];
        coreDatabook.id = book.id;
        coreDatabook.size = @23068672;
        coreDatabook.date = [NSDate date];
        coreDatabook.textBook = @4;
        coreDatabook.downloadedDate = [NSDate date];
        coreDatabook.downloaded = @YES;
        coreDatabook.edited = @NO;
        NSError *error=nil;
        if (![appDelegate.managedObjectContext save:&error]) {
            NSLog(@"%@",error);
        }
    }
}

#pragma mark - Parse JSON

- (void)parseBookJson:(NSData *)bookJsonData WithId:(NSNumber *)numberId AtLocation:(NSString *)filePath {
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:bookJsonData options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"%@", jsonDict);
    
    MangoBook *book = [[MangoBook alloc] init];
    book.id = [jsonDict objectForKey:@"id"];
    book.title = [jsonDict objectForKey:@"title"];
    
    NSArray *pagesArray = [jsonDict objectForKey:PAGES];
    
    NSMutableArray *pageIdArray = [[NSMutableArray alloc] initWithCapacity:pagesArray.count];
    /*populating pageIdArray so that insert at object will not throw Exception*/
    for (int i=0;i<pagesArray.count;i++) {
        [pageIdArray addObject:[NSNull null]];
    }
    for (NSDictionary *pageDict in pagesArray) {
        MangoPage *page = [[MangoPage alloc] init];
        page.id = [pageDict objectForKey:@"id"];
        page.pageable_id = [pageDict objectForKey:@"pageable_id"];
        page.name = [pageDict objectForKey:@"name"];
        
        NSArray *pageArray=[pageDict objectForKey:LAYERS];
        NSMutableArray *layerIdArray = [[NSMutableArray alloc] init];

        for (NSDictionary *layerDict in pageArray) {
           /* MangoLayer *layer = [[MangoLayer alloc] init];
            layer.id = [layerDict objectForKey:@"id"];
            layer.name = [layerDict objectForKey:@"name"];
            layer.style = [layerDict objectForKey:@"style"];
            layer.text = [layerDict objectForKey:@"text"];
            layer.type = [layerDict objectForKey:@"type"];
          
            
            
            layer.url = [layerDict objectForKey:@"url"];
            */
            // Instance should be based on type.
            /*
             When the layer is Image
             */
            if ([[layerDict objectForKey:TYPE] isEqualToString:IMAGE]) {
                MangoImageLayer *imageLayer=[[MangoImageLayer alloc]init];
                imageLayer.id=layerDict[@"id"];
                NSLog(@"for %@ %@",[layerDict objectForKey:TYPE],layerDict[@"url"]);
                imageLayer.url=layerDict[@"url"];
                imageLayer.alignment=layerDict[@"alignment"];
                if ([self insertOrUpdateObject:imageLayer]) {
                    [layerIdArray addObject:imageLayer.id];
                }
            }
            /*
             When the layer is text
             */
            else if([[layerDict objectForKey:TYPE] isEqualToString:TEXT]){
                MangoTextLayer *textLayer=[[MangoTextLayer alloc]init];
                textLayer.id=layerDict[@"id"];
                textLayer.actualText=layerDict[@"text"];
                NSLog(@"%@", textLayer.actualText);
                
                NSDictionary *style=layerDict[@"style"];
                NSLog(@"%@",[style allKeys]);

                textLayer.colour=style[@"color"];
                NSNumber *fontSize=style[@"font-size"];
                NSInteger font=MAX(fontSize.integerValue, 30);
                textLayer.fontSize=[NSNumber numberWithInteger:font];
                textLayer.fontWeight=style[@"font-weight"];
                textLayer.fontStyle=style[@"font-family"];
                NSString *lineHeight=style[@"line-height"];
                NSNumber *numberLineHeight=[NSNumber numberWithFloat:lineHeight.floatValue];
                textLayer.lineHeight=numberLineHeight;
                NSLog(@"%@ %@",style[@"top_ratio"],style[@"left_ratio"]);
                textLayer.topRatio=[NSNumber numberWithFloat:MAX([style[@"top_ratio"] floatValue], 1)];
                textLayer.leftRatio=[NSNumber numberWithFloat:MAX([style[@"left_ratio"] floatValue], 1)];
                textLayer.height=[NSNumber numberWithFloat:MAX([style[@"height"] floatValue], 400)];
                textLayer.width=[NSNumber numberWithFloat:MAX([style[@"width"] floatValue], 600)];
                if ([self insertOrUpdateObject:textLayer]) {
                    [layerIdArray addObject:textLayer.id];
                }
               
            }
            /*
             When the layer is audio
             */
            else if([[layerDict objectForKey:TYPE] isEqualToString:AUDIO]){
                MangoAudioLayer *audioLayer=[[MangoAudioLayer alloc]init];
                audioLayer.id=layerDict[@"id"];
                audioLayer.url=layerDict[@"url"];
                audioLayer.wordTimes=layerDict[@"wordTimes"];
                NSMutableArray *mutableWordMap=[[NSMutableArray alloc]init];
                for (NSDictionary *wordMap in layerDict[@"wordMap"]) {
                    NSString *word=wordMap[@"word"];
                    [mutableWordMap addObject:word];
                }
                
                audioLayer.wordMap=mutableWordMap;
                if ([self insertOrUpdateObject:audioLayer]) {
                    [layerIdArray addObject:audioLayer.id];
                }
            }
           
        }
       
        page.layers = layerIdArray;
        
        if ([self insertOrUpdateObject:page]) {
            /*done so that page ids are saved in order*/
            NSString *name=page.name;
            if ([name isEqualToString:@"Cover"]) {
                [pageIdArray insertObject:page.id atIndex:0];
            }else{
                NSInteger pageNumber=name.integerValue;
                if (pageNumber==0) {
                    [pageIdArray addObject:page.id];

                }else{
                    [pageIdArray insertObject:page.id atIndex:pageNumber];
                }
            }
        }
    }
    [pageIdArray removeObject:[NSNull null]];
    
    book.pages = pageIdArray;
    if ([self insertOrUpdateObject:book]) {// insertion done
        MangoBook *fetchedBook = [self getBookForBookId:book.id];
        NSLog(@"%@", fetchedBook.pages);
        
        MangoPage *fetchedPage = [self getPageForPageId:fetchedBook.pages[5]];
        for (NSString *page in fetchedBook.pages) {
            MangoPage *pageFetched=[self getPageForPageId:page];
            NSLog(@"id - %@   name-%@ ",pageFetched.id,pageFetched.name);
        }
        NSLog(@"%@",fetchedPage.layers);
        
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        
        Book *bk=[delegate.dataModel getBookOfId:[NSString stringWithFormat:@"%d", [numberId intValue]]];
        if (bk) {
            bk.bookId=book.id;
            [delegate.dataModel saveData:bk];
        } else {
            [self saveBook:book AtLocation:filePath];
        }
        
        [delegate.dataModel displayAllData];
    }
    
}

@end
