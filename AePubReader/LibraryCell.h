//
//  LibraryCell.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 31/07/13.
//
//

#import <UIKit/UIKit.h>
#import "ShadowButton.h"
#import "ShareButton.h"
@interface LibraryCell : UICollectionViewCell
@property(nonatomic,retain) ShareButton *shareButton;
@property (retain, nonatomic) ShadowButton *button;
@property(retain,nonatomic) UIButton *showRecording;
@property(retain,nonatomic)UIButton *buttonDelete;
@end
