//
//  MangoBook.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 26/11/13.
//
//

#import <Foundation/Foundation.h>
#import "EJDBKit/BSONArchiving.h"

@interface MangoBook : NSObject <BSONArchiving, NSCopying>

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *pages;
@property (nonatomic, strong) NSString *created_at;
@property (nonatomic, strong) NSString *updated_at;

@end
