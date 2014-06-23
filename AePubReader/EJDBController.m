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
#import "LoginNewViewController.h"
#import "MBProgressHUD.h"

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

- (NSArray *)getAllUserInfoObjects {
    NSArray *userInfoObjects = [_db findObjectsWithQuery:@{@"authToken":@{@"$exists":@YES}} inCollection:_collection error:nil];
    return userInfoObjects;
}

- (NSArray *)getAllSubscriptionObjects {
    NSArray *userSubscriptionObjects = [_db findObjectsWithQuery:@{@"subscriptionProductId":@{@"$exists":@YES}} inCollection:_collection error:nil];
    return userSubscriptionObjects;
}

- (BOOL)deleteSubscriptionObject:(SubscriptionInfo *)subInfo {
    return [_collection removeObject:subInfo];
}

- (BOOL) deleteAudioLayer:(MangoAudioLayer *)audiolayer{
    return [_collection removeObject:audiolayer];
}

- (UserInfo *)getUserInfoForId:(NSString *)userId {

    UserInfo *userInfo = [_collection fetchObjectWithOID:userId];
    return userInfo;
}

- (MangoBook *)getBookForBookId:(NSString *)bookId {
    @autoreleasepool {
    MangoBook *book = [_collection fetchObjectWithOID:bookId];
    return book;
    }
}

- (MangoPage *)getPageForPageId:(NSString *)pageId {
    @autoreleasepool {
    MangoPage *page = [_collection fetchObjectWithOID:pageId];
    return page;
    }
}

- (id)getLayerForLayerId:(NSString *)layerId {
    id layer = [_collection fetchObjectWithOID:layerId];
    return layer;
}

#pragma mark - Delete Objects

- (BOOL)deleteObject:(id)object {
    MangoBook *book = (MangoBook *)object;
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.dataModel checkIfIdExists:book.id]) {
        Book *coreDataBook = [appDelegate.dataModel getBookOfId:book.id];
        [appDelegate.dataModel.dataModelContext deleteObject:coreDataBook];
        [appDelegate.dataModel.dataModelContext save:nil];
    }
    return [_collection removeObject:object];
}

#pragma mark - Save Book To Core Data

- (void)saveBook:(MangoBook *)book AtLocation:(NSString *)filePath WithEJDBId:(NSString *)ejdbId {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        NSURL *url = [[NSURL alloc]initFileURLWithPath:filePath];
        [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:nil];
    }

    // adding to database
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    Book *coreDatabook= [appDelegate.dataModel getBookInstance];
    int isBookDownloaded = [coreDatabook.downloaded integerValue];
    if (![appDelegate.dataModel checkIfIdExists:book.id] ) {
        
        coreDatabook.title=book.title;
        coreDatabook.link=nil;
        coreDatabook.localPathImageFile = filePath;
        coreDatabook.localPathFile = [filePath stringByDeletingPathExtension];
        coreDatabook.id = book.id;
        coreDatabook.size = @23068672;
        coreDatabook.date = [NSDate date];
        coreDatabook.textBook = @4;
        coreDatabook.downloadedDate = [NSDate date];
        if(fileNotAvailable){
            coreDatabook.downloaded = [NSNumber numberWithInt:2];
        }
        else{
            coreDatabook.downloaded = @YES;
        }
        coreDatabook.edited = @NO;
        coreDatabook.bookId = ejdbId;
        
        NSError *error=nil;
        if (![appDelegate.managedObjectContext save:&error]) {
            NSLog(@"%@",error);
        }
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setBool:YES forKey:@"ISFREEBOOKAPICALL"];
        //[prefs setBool:YES forKey:@"STORYASAPPCALL"];
        
    }
    
    else if([appDelegate.dataModel checkIfIdExists:book.id] && !fileNotAvailable && !isBookDownloaded){
        NSFetchRequest *fetchRequest=[NSFetchRequest fetchRequestWithEntityName:@"Book"];
        NSPredicate *predicate=[NSPredicate predicateWithFormat:@"bookId == %@",book.id];
        fetchRequest.predicate=predicate;
        Book *newBook = [[appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:nil] lastObject];
        [newBook setValue:@YES forKey:@"downloaded"];
        NSError *error=nil;
        if (![appDelegate.managedObjectContext save:&error]) {
            NSLog(@"%@",error);
        }
        
    }
    fileNotAvailable = NO;
}

-(void) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    
    NSFileManager *fileManager= [NSFileManager defaultManager];
    NSError *error = nil;
    if([fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error]) {
        
        if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpg"]) {
            
            NSLog(@"path as - %@", [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]]);
            [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
            
        } else {
            NSLog(@"Image Save Failed\nExtension: (%@) is not recognized, use (JPG)", extension);
        }
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:directoryPath error:nil];
}

-(UIImage *) getImageFromURL:(NSString *)fileURL {
    UIImage * result;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    
    return result;
}

#pragma mark - Parse JSON

- (void)parseBookJson:(NSData *)bookJsonData WithId:(NSNumber *)numberId AtLocation:(NSString *)filePath {
    if (bookJsonData) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:bookJsonData options:NSJSONReadingAllowFragments error:nil];
        
        MangoBook *book = [[MangoBook alloc] init];
        book.id = [jsonDict objectForKey:@"id"];
        book.title = [jsonDict objectForKey:@"title"];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"MangoStory" ofType:@"zip"];
        
        if ([numberId isEqual: [NSNumber numberWithInteger:1]] && !path) {
            
            NSString * documentsDirectoryPath = filePath;
            NSString *imageURLString = [NSString stringWithFormat:@"http://www.mangoreader.com%@",[jsonDict objectForKey:@"cover"]];
            
            UIImage * imageFromURL = [self getImageFromURL:imageURLString];
            
            [self saveImage:imageFromURL withFileName:@"cover" ofType:@"jpg" inDirectory:documentsDirectoryPath];
            
            fileNotAvailable = YES;
        }
        
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
                    if ([[layerDict allKeys] containsObject:@"alignment"]) {
                        if (![layerDict[@"alignment"] isEqual:[NSNull null]]) {
                            imageLayer.alignment=layerDict[@"alignment"];
                        }
                    } else {
                        imageLayer.alignment = @"middle";
                    }
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
                    if (![style[@"top_ratio"] isEqual:[NSNull null]]) {
                        textLayer.topRatio= [NSNumber numberWithFloat:MAX([style[@"top_ratio"] floatValue], 1)];
                    } else {
                        textLayer.topRatio = [NSNumber numberWithInt:500];
                    }
                    if (![style[@"left_ratio"] isEqual:[NSNull null]]) {
                        textLayer.leftRatio = [NSNumber numberWithFloat:MAX([style[@"left_ratio"] floatValue], 1)];
                    } else {
                        textLayer.leftRatio = [NSNumber numberWithInt:500];
                    }
                    textLayer.height = [NSNumber numberWithFloat:MAX([style[@"height"] floatValue], 400)];
                    textLayer.width = [NSNumber numberWithFloat:MAX([style[@"width"] floatValue], 600)];
                    textLayer.imageAlignment = layerDict[IMAGE_ALIGNMENT];
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
                    if ([[layerDict allKeys] containsObject:@"wordTimes"]) {
                        if (![layerDict[@"wordTimes"] isEqual:[NSNull null]]) {
                            audioLayer.wordTimes=layerDict[@"wordTimes"];
                        }
                    }
                    if (!audioLayer.wordTimes) {
                        audioLayer.wordTimes = [NSArray array];
                    }
                    if ([[layerDict allKeys] containsObject:@"wordMap"]) {
                        if (![layerDict[@"wordMap"] isEqual:[NSNull null]]) {
                            NSMutableArray *mutableWordMap=[[NSMutableArray alloc]init];
                            for (NSDictionary *wordMap in layerDict[@"wordMap"]) {
                                NSString *word=wordMap[@"word"];
                                [mutableWordMap addObject:word];
                            }
                            audioLayer.wordMap=mutableWordMap;
                        }
                    }
                    if (!audioLayer.wordMap) {
                        audioLayer.wordMap = [NSArray array];
                    }
                    
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
            
            //MangoPage *fetchedPage = [self getPageForPageId:fetchedBook.pages[5]];
            for (NSString *page in fetchedBook.pages) {
                MangoPage *pageFetched=[self getPageForPageId:page];
                NSLog(@"id - %@   name-%@ ",pageFetched.id,pageFetched.name);
            }
            //NSLog(@"%@",fetchedPage.layers);
            
            AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
            
            Book *bk=[delegate.dataModel getBookOfId:[NSString stringWithFormat:@"%d", [numberId intValue]]];
            if (bk) {
                bk.bookId=book.id;
                [delegate.dataModel saveData:bk];
            } else {
                [self saveBook:book AtLocation:filePath WithEJDBId:book.id];
            }
            
            [delegate.dataModel displayAllData];
        }
    }
}

@end
