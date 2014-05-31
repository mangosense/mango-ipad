//
//  MyStoriesBooksViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 11/02/14.
//
//

#import "MyStoriesBooksViewController.h"
#import "AePubReaderAppDelegate.h"
#import "MangoEditorViewController.h"
#import "MyStoriesBookCell.h"
#import "Constants.h"
#import "Book.h"
#import "MangoStoreViewController.h"
#import "CoverViewControllerBetterBookType.h"

@interface MyStoriesBooksViewController ()

@property (nonatomic, strong) UICollectionView *booksCollectionView;

@end

@implementation MyStoriesBooksViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Get all books initially from local db
    _booksArray = [self getInitialBooks];
    
    //Setup UI
    [self setupInitialUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Get Books

- (NSMutableArray *)getInitialBooks {
    NSArray *allBooksArray;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    if (_toEdit) {
        allBooksArray = [delegate.dataModel getEditedBooks];
    }else{
        allBooksArray = [delegate.dataModel getAllUserBooks];
    }

    //TODO: Dumb fix for nil id. Need to find root cause.
    Book *bookToDelete;
    for (Book *book in allBooksArray) {
        if (!book.id) {
            bookToDelete = book;
            break;
        }
    }
    NSMutableArray *tempBooksArray = [NSMutableArray arrayWithArray:allBooksArray];
    [tempBooksArray removeObject:bookToDelete];
    allBooksArray = tempBooksArray;
    
    return [NSMutableArray arrayWithArray:allBooksArray];
}

#pragma mark - UI Setup

- (void)setupInitialUI {
    CGRect viewFrame = self.view.bounds;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    _booksCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(CGRectGetMinX(viewFrame) + 100, 100, CGRectGetWidth(viewFrame) - 200, CGRectGetHeight(viewFrame) - 100) collectionViewLayout:layout];
    _booksCollectionView.dataSource = self;
    _booksCollectionView.delegate = self;
    _booksCollectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [_booksCollectionView registerClass:[MyStoriesBookCell class] forCellWithReuseIdentifier:MY_STORIES_BOOK_CELL];
    [_booksCollectionView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_booksCollectionView];
}

- (UIImage *)maskedCoverImageForBookJson:(NSString *)jsonString AtLocation:(NSString *)filePath{
    UIImage *maskedCoverImage;
    
    UIImage *unmaskedImage = [MangoEditorViewController coverPageImageForStory:jsonString WithFolderLocation:filePath];
    maskedCoverImage = [self maskImage:unmaskedImage withMask:[UIImage imageNamed:@"circle2.png"]];
    
    return maskedCoverImage;
}

#pragma mark - Image Masking

- (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
	CGImageRef imgRef = [image CGImage];
    CGImageRef maskRef = [maskImage CGImage];
    CGImageRef actualMask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                              CGImageGetHeight(maskRef),
                                              CGImageGetBitsPerComponent(maskRef),
                                              CGImageGetBitsPerPixel(maskRef),
                                              CGImageGetBytesPerRow(maskRef),
                                              CGImageGetDataProvider(maskRef), NULL, false);
    CGImageRef masked = CGImageCreateWithMask(imgRef, actualMask);
    UIImage *img = [UIImage imageWithCGImage:masked];
    CGImageRelease(imgRef);
    CGImageRelease(maskRef);
    CGImageRelease(actualMask);
    CGImageRelease(masked);
    return img;
}

#pragma mark - Book Details

- (NSString *)jsonForBook:(Book *)book {
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:book.localPathFile error:nil];
    
    NSArray *jsonFiles = [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"]];
    NSString *jsonFileLocation = [book.localPathFile stringByAppendingPathComponent:[jsonFiles firstObject]];
    
    NSString *jsonString = [[NSString alloc]initWithContentsOfFile:jsonFileLocation encoding:NSUTF8StringEncoding error:nil];
    return jsonString;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_booksArray count] + 1;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MyStoriesBookCell *bookCell = [collectionView dequeueReusableCellWithReuseIdentifier:MY_STORIES_BOOK_CELL forIndexPath:indexPath];
    if (!bookCell) {
        bookCell = [[MyStoriesBookCell alloc] init];
    }
    UIImage *bookImage;

    switch (indexPath.row) {
        case 0: {
            bookImage = [UIImage imageNamed:@"icons_getmorebooks.png"];
        }
            break;
            
        default: {
            Book *book = [_booksArray objectAtIndex:indexPath.row - 1];
            NSString *bookJsonString = [self jsonForBook:book];
            bookImage = [self maskedCoverImageForBookJson:bookJsonString AtLocation:book.localPathFile];
        }
            break;
    }
    bookCell.bookImageView.image = bookImage;
    
    return bookCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            if (_toEdit) {
                MangoEditorViewController *newBookEditorViewController = [[MangoEditorViewController alloc] initWithNibName:@"MangoEditorViewController" bundle:nil];
                newBookEditorViewController.isNewBook = YES;
                newBookEditorViewController.storyBook = nil;
                [self.navigationController.navigationBar setHidden:YES];
                
                [self.navigationController pushViewController:newBookEditorViewController animated:YES];
            } else {
                MangoStoreViewController *storeController=[[MangoStoreViewController alloc]initWithNibName:@"MangoStoreViewController" bundle:nil];
                
                [self.navigationController pushViewController:storeController animated:YES];
            }
        }
            break;
            
        default: {
            if (_toEdit) {
                MangoEditorViewController *mangoEditorViewController = [[MangoEditorViewController alloc] initWithNibName:@"MangoEditorViewController" bundle:nil];
                mangoEditorViewController.isNewBook = NO;
                mangoEditorViewController.storyBook = [_booksArray objectAtIndex:indexPath.row - 1];
                [self.navigationController.navigationBar setHidden:YES];
                
                [self.navigationController pushViewController:mangoEditorViewController animated:YES];
            } else {
                Book *book = [_booksArray objectAtIndex:indexPath.row - 1];
                CoverViewControllerBetterBookType *coverController=[[CoverViewControllerBetterBookType alloc]initWithNibName:@"CoverViewControllerBetterBookType" bundle:nil WithId:book.id];
                
                [self.navigationController pushViewController:coverController animated:YES];
            }
        }
            break;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(220, 220);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 80.0f;
}

@end
