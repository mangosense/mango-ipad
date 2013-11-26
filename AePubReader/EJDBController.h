//
//  EJDBController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 26/11/13.
//
//

#import <Foundation/Foundation.h>
#import "EJDBKit/EJDBKit.h"

@interface EJDBController : NSObject

@property (nonatomic, strong) EJDBCollection *collection;
@property (nonatomic, strong) EJDBDatabase *db;

- (id)initWithCollectionName:(NSString *)collectionName andDatabaseName:(NSString *)databaseName;

@end
