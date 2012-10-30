//
//  Book.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 23/10/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Book : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * downloaded;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * localPathFile;
@property (nonatomic, retain) NSString * localPathImageFile;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSString * sourceFileUrl;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * downloadedDate;

@end
