//
//  StoreCollectionHeaderView.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 04/12/13.
//
//

#import <UIKit/UIKit.h>

@protocol collectionSeeAllDelegate

- (void)seeAllTapped:(NSInteger)section;

@end

@interface StoreCollectionHeaderView : UICollectionReusableView{
    
    NSString *userEmail;
}

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *seeAllButton;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, assign) int section;
@property (nonatomic, assign) id <collectionSeeAllDelegate> delegate;

@end
