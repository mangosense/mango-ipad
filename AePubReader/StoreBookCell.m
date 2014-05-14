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

@synthesize readPreviewButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            _bookImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 110, 95)];
            _frameImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 112, 97)];
            _bookTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, _frameImageView.frame.size.height, 102, 14)];
            _bookPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, _bookTitleLabel.frame.origin.y + _bookTitleLabel.frame.size.height, 102, 16)];
            _bookTitleLabel.font = [UIFont boldSystemFontOfSize:12];
            _bookPriceLabel.font = [UIFont boldSystemFontOfSize:12];
            _bookTitleLabel.textAlignment = NSTextAlignmentCenter;
            _bookPriceLabel.textAlignment = NSTextAlignmentCenter;
            
        }
        else{
            _bookImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 127, 134)];
            _frameImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 130, 137)];
            _bookTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, _frameImageView.frame.size.height, 130, 20)];
            _bookPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, _bookTitleLabel.frame.origin.y + _bookTitleLabel.frame.size.height, 130, 20)];
            _bookTitleLabel.font = [UIFont boldSystemFontOfSize:16];
            _bookPriceLabel.font = [UIFont boldSystemFontOfSize:16];
        }

        
       // _bookImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 127, 134)];
        [_bookImageView setContentMode:UIViewContentModeScaleToFill];
        [[_bookImageView layer] setCornerRadius:12.0f];
        [_bookImageView setClipsToBounds:YES];
        [self addSubview:_bookImageView];
        
      //  _frameImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 130, 137)];
        [_frameImageView setImage:[UIImage imageNamed:@"bookframe.png"]];
       // [self addSubview:_frameImageView];
        
        /*readPreviewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, _frameImageView.frame.size.height + 3, 64, 37)];
        [readPreviewButton setTitle:@"Read" forState:UIControlStateNormal];
        [readPreviewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [readPreviewButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
        [self addSubview:readPreviewButton];
        
        _buyBookButton = [[UIButton alloc] initWithFrame:CGRectMake(readPreviewButton.frame.origin.x + readPreviewButton.frame.size.width, _frameImageView.frame.size.height + 3, 64, 37)];
        [_buyBookButton setTitle:@"Buy" forState:UIControlStateNormal];
        [_buyBookButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_buyBookButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
        [self addSubview:_buyBookButton];*/
        
        //_bookTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, _frameImageView.frame.size.height, 130, 20)];
        _bookTitleLabel.numberOfLines = 2;
        _bookTitleLabel.textColor = COLOR_DARK_RED;
     //   _bookTitleLabel.font = [UIFont boldSystemFontOfSize:16];
        [self addSubview:_bookTitleLabel];
        
        _bookPriceLabel.textColor = COLOR_DARK_RED;
        
        [self addSubview:_bookPriceLabel];

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [readPreviewButton setFrame:CGRectMake(2, _frameImageView.frame.size.height + 3, 64, 37)];
    [_buyBookButton setFrame:CGRectMake(readPreviewButton.frame.origin.x + readPreviewButton.frame.size.width, _frameImageView.frame.size.height + 3, 64, 37)];
    [_textButton setFrame:CGRectMake(_buyBookButton.frame.origin.x + _buyBookButton.frame.size.width, _frameImageView.frame.size.height + 3, 32, 37)];
    [_imageButton setFrame:CGRectMake(_textButton.frame.origin.x + _textButton.frame.size.width, _frameImageView.frame.size.height + 3, 32, 37)];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        _bookPriceLabel.frame = CGRectMake(2, _bookTitleLabel.frame.origin.y + _bookTitleLabel.frame.size.height, 102, 16);
    }
    else{
        _bookPriceLabel.frame = CGRectMake(2, _bookTitleLabel.frame.origin.y + _bookTitleLabel.frame.size.height, 130, 16);
    }
    
    
}

- (void)getImageForUrl:(NSString *)urlString {
    MangoApiController *apiController = [MangoApiController sharedApiController];
    
    [apiController getImageAtUrl:urlString withDelegate:self];
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
    [_bookImageView setImage:nil];

    [super prepareForReuse];
}

#pragma mark - Post API Delegate

- (void)reloadImage:(UIImage *)image forUrl:(NSString *)urlString {
    [MBProgressHUD hideAllHUDsForView:self animated:YES];
    
    [_bookImageView setImage:image];
    [_delegate saveImage:image ForUrl:urlString];
    
    [self setNeedsDisplay];
}

@end
