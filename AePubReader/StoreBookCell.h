//
//  StoreBookCell.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 04/12/13.
//
//

#import <UIKit/UIKit.h>
#import "MangoApiController.h"

@protocol LocalImagesProtocol

@optional
- (void)saveImage:(UIImage *)image ForUrl:(NSString *)imageUrl;

@end

@interface StoreBookCell : UICollectionViewCell <MangoPostApiProtocol>

@property (nonatomic, strong) UIImageView *bookImageView;
@property (nonatomic, strong) UIImageView *frameImageView;
@property (nonatomic, strong) UILabel *bookTitleLabel;
@property (nonatomic, strong) UILabel *bookAgeGroupLabel;
@property (nonatomic, strong) UILabel *bookPriceLabel;
@property (nonatomic, strong) UIButton *readPreviewButton;
@property (nonatomic, strong) UIButton *buyBookButton;
@property (nonatomic, strong) UIButton *textButton;
@property (nonatomic, strong) UIButton *imageButton;
@property (nonatomic, strong) NSString *imageUrlString;
@property (nonatomic, weak) id <LocalImagesProtocol> delegate;
- (void)getImageForUrl:(NSString *)urlString;

@end
