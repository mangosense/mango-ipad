//
//  UserInfo.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 26/02/14.
//
//

#import <Foundation/Foundation.h>
#import "EJDBKit/BSONArchiving.h"

@interface UserInfo : NSObject <BSONArchiving, NSCopying>

@property (nonatomic, strong) NSString *authToken;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *facebookExpirationDate;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *name;

@end
