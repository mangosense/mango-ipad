//
//  DataSourceForLinear.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 28/10/13.
//
//

#import <Foundation/Foundation.h>
#import "PSTCollectionView.h"
@interface DataSourceForLinear : NSObject<UICollectionViewDataSource>
@property(retain,nonatomic) NSString *prefix;
-(id)initWithString:(NSString *) string;
@end
