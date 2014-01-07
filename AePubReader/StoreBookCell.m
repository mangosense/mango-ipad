//
//  StoreBookCell.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 04/12/13.
//
//

#import "StoreBookCell.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"

@implementation StoreBookCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _bookImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 127, 134)];
        [_bookImageView setContentMode:UIViewContentModeScaleToFill];
        [[_bookImageView layer] setCornerRadius:12.0f];
        [_bookImageView setClipsToBounds:YES];
        [self addSubview:_bookImageView];
        
        _frameImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 130, 137)];
        [_frameImageView setImage:[UIImage imageNamed:@"bookframe.png"]];
        [self addSubview:_frameImageView];
        
        _soundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_soundButton setImage:[UIImage imageNamed:@"sound.png"] forState:UIControlStateNormal];
        [_soundButton setFrame:CGRectMake(2, _frameImageView.frame.size.height + 3, 32, 37)];
        [self addSubview:_soundButton];
        
        _interactiveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_interactiveButton setImage:[UIImage imageNamed:@"interactive.png"] forState:UIControlStateNormal];
        [_interactiveButton setFrame:CGRectMake(_soundButton.frame.origin.x + _soundButton.frame.size.width, _frameImageView.frame.size.height + 3, 32, 37)];
        [self addSubview:_interactiveButton];
        
        _textButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_textButton setImage:[UIImage imageNamed:@"txt.png"] forState:UIControlStateNormal];
        [_textButton setFrame:CGRectMake(_interactiveButton.frame.origin.x + _interactiveButton.frame.size.width, _frameImageView.frame.size.height + 3, 32, 37)];
        [self addSubview:_textButton];
        
        _imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_imageButton setImage:[UIImage imageNamed:@"image.png"] forState:UIControlStateNormal];
        [_imageButton setFrame:CGRectMake(_textButton.frame.origin.x + _textButton.frame.size.width, _frameImageView.frame.size.height + 3, 32, 37)];
        [self addSubview:_imageButton];
        
        _bookTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, _frameImageView.frame.size.height + 40, 130, 20)];
        _bookTitleLabel.numberOfLines = 2;
        _bookTitleLabel.textColor = COLOR_DARK_RED;
        _bookTitleLabel.font = [UIFont boldSystemFontOfSize:16];
        [self addSubview:_bookTitleLabel];

        _bookAgeGroupLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, _bookTitleLabel.frame.origin.y + _bookTitleLabel.frame.size.height, 130, 20)];
        _bookAgeGroupLabel.textColor = COLOR_DARK_RED;
        _bookAgeGroupLabel.font = [UIFont systemFontOfSize:16];
        [self addSubview:_bookAgeGroupLabel];

        _bookPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, _bookAgeGroupLabel.frame.origin.y + _bookAgeGroupLabel.frame.size.height, 130, 20)];
        _bookPriceLabel.textColor = COLOR_DARK_RED;
        _bookPriceLabel.font = [UIFont boldSystemFontOfSize:16];
        [self addSubview:_bookPriceLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_soundButton setFrame:CGRectMake(2, _frameImageView.frame.size.height + 3, 32, 37)];
    [_interactiveButton setFrame:CGRectMake(_soundButton.frame.origin.x + _soundButton.frame.size.width, _frameImageView.frame.size.height + 3, 32, 37)];
    [_textButton setFrame:CGRectMake(_interactiveButton.frame.origin.x + _interactiveButton.frame.size.width, _frameImageView.frame.size.height + 3, 32, 37)];
    [_imageButton setFrame:CGRectMake(_textButton.frame.origin.x + _textButton.frame.size.width, _frameImageView.frame.size.height + 3, 32, 37)];

    _bookAgeGroupLabel.frame = CGRectMake(2, _bookTitleLabel.frame.origin.y + _bookTitleLabel.frame.size.height, 130, 20);
    _bookPriceLabel.frame = CGRectMake(2, _bookAgeGroupLabel.frame.origin.y + _bookAgeGroupLabel.frame.size.height, 130, 20);
}

- (void)getImageForUrl:(NSString *)urlString {
    //[MBProgressHUD showHUDAddedTo:self animated:YES];
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
    apiController.delegate = self;
    
    //urlString = [BASE_URL stringByAppendingString:urlString];
    [apiController getImageAtUrl:urlString];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Reuse

- (void)prepareForReuse {
    [super prepareForReuse];
    _bookImageView.image = nil;
}

#pragma mark - Post API Delegate

- (void)reloadImage:(UIImage *)image forUrl:(NSString *)urlString {
    //[MBProgressHUD hideAllHUDsForView:self animated:YES];
    
    [_bookImageView setImage:image];
    [_delegate saveImage:image ForUrl:urlString];
}

@end
