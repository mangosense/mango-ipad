//
//  EJDBController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 26/11/13.
//
//

#import "EJDBController.h"

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

@end
