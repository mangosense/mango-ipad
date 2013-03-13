//
//  StoreBooks.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 26/12/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface StoreBooks : NSManagedObject

@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSString * book_url;
@property (nonatomic, retain) NSString * bookLink;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * free;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * localImage;
@property (nonatomic, retain) NSNumber * pageNumber;
@property (nonatomic, retain) NSNumber * productIdentity;
@property (nonatomic, retain) NSNumber * purchased;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * textBook;

@end
