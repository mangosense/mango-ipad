//
//  MangoLayer.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 26/11/13.
//
//

#import <Foundation/Foundation.h>
#import "EJDBKit/BSONArchiving.h"

@interface MangoLayer : NSObject <BSONArchiving, NSCopying>

@property (nonatomic, strong) NSString *alignment;
@property (nonatomic, strong) NSString *created_at;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDictionary *style;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *updated_at;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *id;

@end
