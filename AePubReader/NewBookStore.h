//
//  NewBookStore.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 12/11/13.
//
//

#import <Foundation/Foundation.h>

@interface NewBookStore : NSObject
@property(retain,nonatomic)NSString *bookTitle;
@property(retain,nonatomic)NSString *bookDesc;
@property(retain,nonatomic)NSString *imageUrl;
@property(retain,nonatomic) NSNumber *bookSize;
@property(retain,nonatomic) NSString *category;
@property(retain,nonatomic)NSString *subcategory;
@property(retain,nonatomic) NSString *section;
@property(retain,nonatomic) NSString *imageLocalLoc;
@end
