//
//  ListOfBooks.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 01/10/12.
//
//

#import <Foundation/Foundation.h>
#import "DownloadViewControlleriPad.h"
@interface ListOfBooks : NSObject<NSURLConnectionDelegate>
-(id)initWithViewController:(DownloadViewControlleriPad *)store;
@property(assign,nonatomic)DownloadViewControlleriPad *store;
@property(retain,nonatomic)NSMutableData *dataMutable;
@property(assign,nonatomic)BOOL shouldBuild;
@end
