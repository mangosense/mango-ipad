//
//  EJDBController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 26/11/13.
//
//

#import <Foundation/Foundation.h>
#import "EJDBKit/EJDBKit.h"
#import "MangoBook.h"
#import "MangoPage.h"
#import "MangoLayer.h"

@interface EJDBController : NSObject

@property (nonatomic, strong) EJDBCollection *collection;
@property (nonatomic, strong) EJDBDatabase *db;

- (id)initWithCollectionName:(NSString *)collectionName andDatabaseName:(NSString *)databaseName;
- (BOOL)insertOrUpdateObject:(id)object;
- (void)parseBookJson:(NSData *)bookJsonData;

@end
