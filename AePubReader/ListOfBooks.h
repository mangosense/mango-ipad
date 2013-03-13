//
//  ListOfBooks.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 01/10/12.
//
//

#import <Foundation/Foundation.h>
#import "StoreViewController.h"
@interface ListOfBooks : NSObject<NSURLConnectionDelegate>
-(id)initWithViewController:(StoreViewController *)store;
@property(assign,nonatomic)StoreViewController *store;
@property(retain,nonatomic)NSMutableData *dataMutable;
@property(assign,nonatomic)BOOL shouldBuild;
@end
