//
//  FooterView.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 24/07/13.
//
//

#import <UIKit/UIKit.h>

@interface FooterView : UICollectionReusableView
@property(retain,nonatomic)UIButton *button;
@property(assign,nonatomic)id target;
- (id)initWithFrame:(CGRect)frame;
@end
