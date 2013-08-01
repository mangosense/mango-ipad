//
//  OldFooterView.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 31/07/13.
//
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"

@interface OldFooterView : PSUICollectionReusableView
@property(retain,nonatomic)UIButton *button;
@property(assign,nonatomic)id target;
- (id)initWithFrame:(CGRect)frame;
@end
