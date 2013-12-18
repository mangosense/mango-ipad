//
//  MangoPage.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 26/11/13.
//
//

#import <Foundation/Foundation.h>
#import "EJDBKit/BSONArchiving.h"

@interface MangoPage : NSObject <BSONArchiving, NSCopying>

@property (nonatomic, strong) NSString *created_at;
@property (nonatomic, strong) NSString *deleted_at;
@property (nonatomic, assign) BOOL is_avail;
@property (nonatomic, strong) NSArray *layers;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *pageNo;
@property (nonatomic, strong) NSString *story_id;
@property (nonatomic, strong) NSString *updated_at;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *pageable_id;

@end
