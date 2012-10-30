//
//  DataModelControl.h
//  AePubReader
//
//  Created by Nikhil Dhavale on 25/09/12.
//
//

#import <Foundation/Foundation.h>
#import "Book.h"
#import "ASIHTTPRequest.h"
@interface DataModelControl : NSObject<ASIHTTPRequestDelegate>
@property (nonatomic, retain)NSManagedObjectContext* dataModelContext;
-(id)initWithContext:(NSManagedObjectContext *)context;

-(NSArray *)getDataNotDownloaded;
-(void)saveData:(Book *)book;
-(Book *)getBookOfId:(NSString *)iden;
-(NSArray *)getDataDownloaded;
-(BOOL)insertIfNew:(NSMutableData *)data;
-(void)displayAllData;
@property(nonatomic,assign)   NSInteger  downloadedImage;
@end
