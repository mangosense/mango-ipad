//
//  AFTableViewCell.m
//  AFTabledCollectionView
//
//  Created by Ash Furrow on 2013-03-14.
//  Copyright (c) 2013 Ash Furrow. All rights reserved.
//

#import "AFTableViewCell.h"
#import "StoreCell.h"
#import "OldStoreCell.h"
@implementation AFTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    if ([UIDevice currentDevice].systemVersion.integerValue<7) {
        
        PSTCollectionViewFlowLayout *layout=[[PSTCollectionViewFlowLayout alloc]init];
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 9, 10);
        layout.itemSize = CGSizeMake(44, 44);
        [layout setMinimumInteritemSpacing:10];
        [layout setMinimumLineSpacing:10];
        [layout setSectionInset:UIEdgeInsetsMake(10, 0, 20, 0)];
        layout.scrollDirection = PSTCollectionViewScrollDirectionHorizontal;
        CGRect fr=self.frame;
        fr.origin=CGPointMake(0, 0);
        fr.size.height=150;
        self.oldCollectionView=[[PSTCollectionView alloc]initWithFrame:fr collectionViewLayout:layout];
        [self.oldCollectionView registerClass:[OldStoreCell class] forCellWithReuseIdentifier:@"MY_CELL"];
        self.oldCollectionView.backgroundColor = [UIColor whiteColor];
        self.oldCollectionView.showsHorizontalScrollIndicator = NO;
        [self.contentView addSubview:self.oldCollectionView];
   
     }
    else{
    
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 9, 10);
        layout.itemSize = CGSizeMake(44, 44);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [self.collectionView registerClass:[StoreCell class] forCellWithReuseIdentifier:@"MY_CELL"];
        self.collectionView.backgroundColor = [UIColor whiteColor];
        self.collectionView.showsHorizontalScrollIndicator = NO;
        [self.contentView addSubview:self.collectionView];

    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.collectionView.frame = self.contentView.bounds;
}

-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource>)dataSource Delegate:(id<UICollectionViewDelegate>)delegate index:(NSInteger)index
{
    self.collectionView.dataSource = dataSource;
    self.collectionView.delegate = delegate;
    self.collectionView.tag = index;
    
    [self.collectionView reloadData];
}
-(void)setCollectionViewOldDataSourceDelegate:(id<PSTCollectionViewDataSource>)dataSource Delegate:(id<PSTCollectionViewDelegate>)delegate index:(NSInteger)index{
    self.oldCollectionView.dataSource=dataSource;
    self.oldCollectionView.delegate=delegate;
    self.oldCollectionView.tag=index;
    [self.oldCollectionView reloadData];
    
    PSTCollectionViewFlowLayout *layout=[[PSTCollectionViewFlowLayout alloc]init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 9, 10);
    layout.itemSize = CGSizeMake(44, 44);
    [layout setMinimumInteritemSpacing:10];
    [layout setMinimumLineSpacing:10];
    [layout setSectionInset:UIEdgeInsetsMake(10, 0, 20, 0)];
    layout.scrollDirection = PSTCollectionViewScrollDirectionHorizontal;
    [self.oldCollectionView setCollectionViewLayout:layout animated:YES];
}
@end
