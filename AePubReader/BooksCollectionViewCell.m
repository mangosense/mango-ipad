//
//  BooksCollectionViewCell.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 06/03/14.
//
//

#import "BooksCollectionViewCell.h"
#import "AePubReaderAppDelegate.h"
#import "MangoEditorViewController.h"

@interface BooksCollectionViewCell ()

@property (nonatomic, strong) UIImageView *frameImageView;
@property (nonatomic, strong) UILabel *bookTitleLabel;

@end

@implementation BooksCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _frameImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle1.png"]];
        _bookCoverImageView = [[UIImageView alloc] init];
        _bookTitleLabel = [[UILabel alloc] init];
        [_bookTitleLabel setTextAlignment:NSTextAlignmentCenter];
        [_bookTitleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
        [_bookTitleLabel setTextColor:[UIColor brownColor]];
        
        [self addSubview:_bookTitleLabel];
        [self addSubview:_bookCoverImageView];
        [self addSubview:_frameImageView];
    }
    return self;
}

- (void)layoutSubviews {
    [_frameImageView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.width)];
    [_bookCoverImageView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.width)];
    [_bookTitleLabel setFrame:CGRectMake(0, _bookCoverImageView.frame.size.height, self.frame.size.width, 30)];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [_bookCoverImageView setImage:nil];
    _bookTitleLabel.text = @"";
    _isDeleteMode = NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Setters

- (void)setBook:(Book *)book {
    _book = book;
    _bookTitleLabel.text = _book.title;
    
    UIImage *image = [_delegate getImageForBook:book];
    if (image) {
        [self setBookImage:image];
    } else {
        [self performSelectorInBackground:@selector(getBookCoverImage:) withObject:_book];
    }
}

- (void)setBookImage:(UIImage *)image {
    _bookCoverImageView.image = image;
}

- (void)setIsDeleteMode:(BOOL)isDeleteMode {
    _isDeleteMode = isDeleteMode;
    if (_isDeleteMode) {
        [_frameImageView setImage:[UIImage imageNamed:@"mango_delete_book.png"]];
    } else {
        [_frameImageView setImage:[UIImage imageNamed:@"circle1.png"]];
    }
}

#pragma mark - Getting Book Info In Background

- (void)getBookCoverImage:(Book *)book {
    NSString *jsonLocation = book.localPathFile;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
    NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
    jsonLocation = [jsonLocation stringByAppendingPathComponent:[onlyJson firstObject]];
    
    NSString *jsonContents = [[NSString alloc]initWithContentsOfFile:jsonLocation encoding:NSUTF8StringEncoding error:nil];
    UIImage *image = [MangoEditorViewController coverPageImageForStory:jsonContents WithFolderLocation:book.localPathFile];
    [_delegate saveBookImage:[AePubReaderAppDelegate maskImage:image withMask:[UIImage imageNamed:@"circle2.png"]] ForBook:book];
    
    [self performSelectorOnMainThread:@selector(setBookImage:) withObject:[AePubReaderAppDelegate maskImage:image withMask:[UIImage imageNamed:@"circle2.png"]] waitUntilDone:NO];
}

@end
