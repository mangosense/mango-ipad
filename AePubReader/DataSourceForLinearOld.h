//
//  DataSourceForLinearOld.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 29/10/13.
//
//

#import <Foundation/Foundation.h>
#import "PSTCollectionView.h"

@interface DataSourceForLinearOld : NSObject<PSTCollectionViewDataSource>
@property(retain,nonatomic) NSString *prefix;
-(id)initWithString:(NSString *) string;
@end
