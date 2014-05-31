//
//  BooksCollectionViewCell.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 06/03/14.
//
//

#import <UIKit/UIKit.h>
#import "Book.h"

@protocol SaveBookImage

- (void)saveBookImage:(UIImage *)image ForBook:(Book *)book;
- (UIImage *)getImageForBook:(Book *)book;

@end

@interface BooksCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) Book *book;
@property (nonatomic, weak) id <SaveBookImage> delegate;
@property (nonatomic, strong) UIImageView *bookCoverImageView;
@property (nonatomic, assign) BOOL isDeleteMode;

@end
