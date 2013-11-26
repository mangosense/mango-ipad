//
//  AssetDatasource.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 25/11/13.
//
//

#import <Foundation/Foundation.h>
#import "AssetCell.h"
@interface AssetDatasource : NSObject<UICollectionViewDataSource>
@property(retain,nonatomic)NSArray *array;
-(id)initWithArray:(NSArray *)array;
@end
