//
//  ListOfPurchasedBooks.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 04/12/12.
//
//

#import <Foundation/Foundation.h>
#import "DownloadViewControlleriPhone.h"
@interface ListOfPurchasedBooks : NSObject<NSURLConnectionDataDelegate>
-(id)initWithViewController:(DownloadViewControlleriPhone *)store;
@property(assign,nonatomic)DownloadViewControlleriPhone *store;
@property(retain,nonatomic)NSMutableData *dataMutable;
@property(assign,nonatomic)BOOL shouldBuild;
@end
