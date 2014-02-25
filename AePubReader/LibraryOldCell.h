//
//  LibraryOldCell.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 01/08/13.
//
//

#import <UIKit/UIKit.h>
#import "ShadowButton.h"
#import "ShareButton.h"
#import "PSTCollectionView.h"

@interface LibraryOldCell : PSUICollectionViewCell
@property(nonatomic,retain) ShareButton *shareButton;
@property (retain, nonatomic) ShadowButton *button;
@property(retain,nonatomic) UIButton *showRecording;
@property(retain,nonatomic)UIButton *buttonDelete;
@end
