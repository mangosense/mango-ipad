//
//  AFTableViewCell.h
//  AFTabledCollectionView
//
//  Created by Ash Furrow on 2013-03-14.
//  Copyright (c) 2013 Ash Furrow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"
static NSString *CollectionViewCellIdentifier = @"CollectionViewCellIdentifier";

@interface AFTableViewCell : UITableViewCell

@property (nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic,strong) PSTCollectionView *oldCollectionView;
-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource>)dataSource Delegate:(id<UICollectionViewDelegate>)delegate index:(NSInteger)index;
-(void)setCollectionViewOldDataSourceDelegate:(id<PSTCollectionViewDataSource>)dataSource Delegate:(id<PSTCollectionViewDelegate>)delegate index:(NSInteger)index;
@end
