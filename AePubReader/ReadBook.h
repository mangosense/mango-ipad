//
//  ReadBook.h
//  MangoReader
//
//  Created by Harish on 2/20/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ReadBook : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * starRate;
@property (nonatomic, retain) NSNumber * bookPoints;
@property (nonatomic, retain) NSString * bookTitle;
@property (nonatomic, retain) NSString * bookId;
@property (nonatomic, retain) NSString * levelValue;

@end
