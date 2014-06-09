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
     //   [_bookTitleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
        [_bookTitleLabel setTextColor:[UIColor brownColor]];
        [_bookTitleLabel setNumberOfLines:2];
        
        [self addSubview:_bookTitleLabel];
        [self addSubview:_bookCoverImageView];
        [self addSubview:_frameImageView];
    }
    return self;
}

- (void)layoutSubviews {
    
    NSString *jsonLocation = _book.localPathFile;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        [_frameImageView setFrame:CGRectMake(0, 0, self.frame.size.width -25, self.frame.size.width-25)];
        [_bookCoverImageView setFrame:CGRectMake(0, 0, self.frame.size.width-25, self.frame.size.width-25)];
        [_bookTitleLabel setFrame:CGRectMake(0, _bookCoverImageView.frame.size.height, self.frame.size.width -20, 25)];
        [_bookTitleLabel setFont:[UIFont boldSystemFontOfSize:9.0f]];
        _labelFreeBook = [[UILabel alloc] initWithFrame:CGRectMake(_bookCoverImageView.frame.origin.x-64 + _bookCoverImageView.frame.size.width, _bookCoverImageView.frame.origin.y + 80, 32, 18)];
        [_labelFreeBook setFont:[UIFont boldSystemFontOfSize:10.0f]];
        [[_labelFreeBook layer] setCornerRadius:4.0f];
        [_labelFreeBook.layer setBorderWidth:0.5f];
        
    }
    else{
        [_frameImageView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.width)];
        [_bookCoverImageView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.width)];
        [_bookTitleLabel setFrame:CGRectMake(0, _bookCoverImageView.frame.size.height, self.frame.size.width, 40)];
        [_bookTitleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
        
        _labelFreeBook = [[UILabel alloc] initWithFrame:CGRectMake(_bookCoverImageView.frame.origin.x-105 + _bookCoverImageView.frame.size.width - 30, _bookCoverImageView.frame.origin.y - 14, 70, 32)];
        [_labelFreeBook setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [[_labelFreeBook layer] setCornerRadius:8.0f];
        [_labelFreeBook.layer setBorderWidth:1.0f];
    }
    
    [_labelFreeBook setBackgroundColor:COLOR_LIGHT_GREY];
    [_labelFreeBook setAlpha:0.9f];
    [_labelFreeBook setTextAlignment:NSTextAlignmentCenter];
    [_labelFreeBook setClipsToBounds:YES];
    [_labelFreeBook setText:@"Free"];
    [_labelFreeBook setTextColor:[UIColor darkGrayColor]];
    [_labelFreeBook.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    
    
    if([dirContents containsObject:@"cover.jpg"] && ([dirContents count] == 1)){
        
        [self addSubview:_labelFreeBook];
    }
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
        _labelFreeBook.hidden = YES;
    } else {
        [_frameImageView setImage:[UIImage imageNamed:@"circle1.png"]];
        _labelFreeBook.hidden = NO;
    }
    
}

-(UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    UIImage * result = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@", directoryPath, fileName, extension]];
    
    return result;
}

#pragma mark - Getting Book Info In Background

- (void)getBookCoverImage:(Book *)book {
    NSString *jsonLocation = book.localPathFile;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
    NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
    jsonLocation = [jsonLocation stringByAppendingPathComponent:[onlyJson firstObject]];
    
    UIImage *image;
    if(!onlyJson.count){
        
       // NSString *str = [NSString stringWithFormat:@""]
        image = [self loadImage:@"cover" ofType:@"jpg" inDirectory:jsonLocation];
    }
    else{
    
        NSString *jsonContents = [[NSString alloc]initWithContentsOfFile:jsonLocation encoding:NSUTF8StringEncoding error:nil];
    
        image = [MangoEditorViewController coverPageImageForStory:jsonContents WithFolderLocation:book.localPathFile];
    }
    
    @autoreleasepool {
    [_delegate saveBookImage:[AePubReaderAppDelegate maskImage:image withMask:[UIImage imageNamed:@"circle2.png"]] ForBook:book];
    
    [self performSelectorOnMainThread:@selector(setBookImage:) withObject:[AePubReaderAppDelegate maskImage:image withMask:[UIImage imageNamed:@"circle2.png"]] waitUntilDone:YES];
    }
    
}

@end
