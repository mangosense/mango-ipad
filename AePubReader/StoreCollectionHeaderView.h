//
//  StoreCollectionHeaderView.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 04/12/13.
//
//

#import <UIKit/UIKit.h>

@interface StoreCollectionHeaderView : UICollectionReusableView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *seeAllButton;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, assign) int section;

@end
