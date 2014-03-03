//
//  PageThumbnailView.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 06/02/14.
//
//

#import <UIKit/UIKit.h>

@protocol PageDelete

- (void)deletePageNumber:(int)pageNumber;

@end

@interface PageThumbnailView : UIView

@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, assign) int pageIndex;
@property (nonatomic, assign) id<PageDelete> delegate;
@property (nonatomic, assign) BOOL showDeleteButton;

@end
