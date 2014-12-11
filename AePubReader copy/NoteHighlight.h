//
//  NoteHighlight.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 25/01/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NoteHighlight : NSManagedObject

@property (nonatomic, retain) NSNumber * bookid;
@property (nonatomic, retain) NSDate * date_added;
@property (nonatomic, retain) NSDate * date_modified;
@property (nonatomic, retain) NSNumber * highlight;
@property (nonatomic, retain) NSNumber * left;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSNumber * pageNo;
@property (nonatomic, retain) NSNumber * srno;
@property (nonatomic, retain) NSString * surroundingtext;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * top;
@property (nonatomic, retain) NSNumber * identity;

@end
