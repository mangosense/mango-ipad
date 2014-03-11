//
//  BooksCollectionViewController.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 06/03/14.
//
//

#import "BooksCollectionViewController.h"
#import "BooksCollectionHeaderView.h"
#import "Constants.h"
#import "AePubReaderAppDelegate.h"
#import "Book.h"
#import "MangoEditorViewController.h"
#import "MangoStoreViewController.h"
#import "CoverViewControllerBetterBookType.h"

@interface BooksCollectionViewController ()

@property (nonatomic, strong) NSArray *allBooksArray;
@property (nonatomic, strong) UIPopoverController *popOverController;
@property (nonatomic, strong) NSMutableDictionary *bookImageDictionary;
@property (nonatomic, assign) BOOL isDeleteMode;

@end

@implementation BooksCollectionViewController

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
    
}

- (void)viewWillAppear:(BOOL)animated {
    if (_allBooksArray) {
        _allBooksArray = nil;
    }
    if (_booksCollectionView) {
        [_booksCollectionView removeFromSuperview];
    }
    _allBooksArray = [self getAllBooks];
    if (!_allBooksArray) {
        _allBooksArray = [NSArray array];
    }
    [self setupUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Get Books

- (NSArray *)booksForCategory:(NSString *)category {
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray *booksForSelectedCategory = [[NSMutableArray alloc] init];
    for (Book *book in [appDelegate.dataModel getAllUserBooks]) {
        if (book.localPathFile && _categorySelected && [appDelegate.ejdbController getBookForBookId:book.id]) {
            NSString *jsonLocation=book.localPathFile;
            NSFileManager *fm = [NSFileManager defaultManager];
            NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
            NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
            NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
            jsonLocation = [jsonLocation stringByAppendingPathComponent:[onlyJson firstObject]];
            
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonLocation] options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"Categories - %@, Selected Category - %@", [[jsonDict objectForKey:@"info"] objectForKey:@"categories"], [_categorySelected objectForKey:NAME]);
            
            if ([[[jsonDict objectForKey:@"info"] objectForKey:@"categories"] containsObject:category] || [category isEqualToString:ALL_BOOKS_CATEGORY]) {
                [booksForSelectedCategory addObject:book];
            }
        }
    }
    return booksForSelectedCategory;
}

- (NSArray *)getAllBooks {
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (_toEdit) {
        return [appDelegate.dataModel getEditedBooks];
    } else {
        return [self booksForCategory:[_categorySelected objectForKey:NAME]];
    }
    return nil;
}

#pragma mark - Setup UI

- (void)setupUI {
    CGRect viewFrame = self.view.bounds;

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    _booksCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(CGRectGetMinX(viewFrame), 90, CGRectGetWidth(viewFrame), CGRectGetHeight(viewFrame) - 150) collectionViewLayout:layout];
    _booksCollectionView.dataSource = self;
    _booksCollectionView.delegate =self;
    [_booksCollectionView registerClass:[BooksCollectionViewCell class] forCellWithReuseIdentifier:BOOK_CELL_ID];
    [_booksCollectionView registerClass:[BooksCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HEADER_ID];
    [_booksCollectionView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_booksCollectionView];
    
    if (_toEdit) {
        _headerLabel.text = @"My Stories";
    } else {
        _headerLabel.text = [_categorySelected objectForKey:NAME];
    }
}

#pragma mark - UICollectionView Datasource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_allBooksArray count] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BooksCollectionViewCell *bookCell = [collectionView dequeueReusableCellWithReuseIdentifier:BOOK_CELL_ID forIndexPath:indexPath];
    
    bookCell.delegate = self;
    if (indexPath.row > 0) {
        Book *book = [_allBooksArray objectAtIndex:indexPath.row - 1];
        bookCell.book = book;
        bookCell.isDeleteMode = _isDeleteMode;
    } else {
        bookCell.isDeleteMode = NO;
        if (_toEdit) {
            bookCell.bookCoverImageView.image = [UIImage imageNamed:@"create-story-book-icon1.png"];
        } else {
            bookCell.bookCoverImageView.image = [UIImage imageNamed:@"icons_getmorebooks.png"];
        }
    }
    
    return bookCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - UICollectionView Delegate Methods

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
                
                MangoStoreViewController *controller=[[MangoStoreViewController alloc]initWithNibName:@"MangoStoreViewController" bundle:nil];
                if([[_categorySelected valueForKey:@"name"] isEqualToString:@"All Books"] || [[_categorySelected valueForKey:@"name"] isEqualToString:@"My Books"]) {
                    [controller setCategoryFlagValue:0];
                }
                else{
                    [controller setCategoryFlagValue:1];
                }
                
                [controller setCategoryDictValue:[[NSDictionary alloc] initWithObjectsAndKeys:[_categorySelected objectForKey:NAME], @"title", nil, @"id", nil]];
                [self.navigationController pushViewController:controller animated:YES];
            }
        }
            break;
            
        default: {
            Book *book = [_allBooksArray objectAtIndex:indexPath.row - 1];
            if (_isDeleteMode) {
                [self deleteBook:book];
            } else {
                if (_toEdit) {
                    MangoEditorViewController *mangoEditorViewController = [[MangoEditorViewController alloc] initWithNibName:@"MangoEditorViewController" bundle:nil];
                    mangoEditorViewController.isNewBook = NO;
                    mangoEditorViewController.storyBook = book;
                    [self.navigationController.navigationBar setHidden:YES];
                    [self.navigationController pushViewController:mangoEditorViewController animated:YES];
                } else {
                    CoverViewControllerBetterBookType *coverController=[[CoverViewControllerBetterBookType alloc]initWithNibName:@"CoverViewControllerBetterBookType" bundle:nil WithId:book.id];
                    [self.navigationController pushViewController:coverController animated:YES];
                }
            }
        }
            break;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(40, 30, 0, 30);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(200, 240);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 60.0f;
}

#pragma mark - Action Methods

- (IBAction)settingsButtonTapped:(id)sender {
    UIButton *button=(UIButton *) sender;
    SettingOptionViewController *settingsViewController=[[SettingOptionViewController alloc]initWithStyle:UITableViewCellStyleDefault];
    settingsViewController.dismissDelegate = self;
    settingsViewController.controller = self.navigationController;
    _popOverController=[[UIPopoverController alloc]initWithContentViewController:settingsViewController];
    [_popOverController presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)homeButtonTapped:(id)sender {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *contoller=(UIViewController *)delegate.controller;
    [self.navigationController popToViewController:contoller animated:YES];
}

- (IBAction)libraryButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)trashButtonTapped:(id)sender {
    _isDeleteMode = !_isDeleteMode;
    UIButton *trashButton = (UIButton *)sender;
    if (_isDeleteMode) {
        [trashButton setImage:[UIImage imageNamed:@"doneTrash.png"] forState:UIControlStateNormal];
    } else {
        [trashButton setImage:[UIImage imageNamed:@"MangoTrash.png"] forState:UIControlStateNormal];
    }
    [_booksCollectionView reloadData];
}

#pragma mark - Settings Delegate Methods

-(void)dismissPopOver{
    [_popOverController dismissPopoverAnimated:YES];
}

#pragma mark - SaveBookImage Delegate

- (void)saveBookImage:(UIImage *)image ForBook:(Book *)book {
    if (!_bookImageDictionary) {
        _bookImageDictionary = [[NSMutableDictionary alloc] init];
    }
    if (image) {
        [_bookImageDictionary setObject:image forKey:book.id];
    }
}

- (UIImage *)getImageForBook:(Book *)book {
    if (_bookImageDictionary) {
        return [_bookImageDictionary objectForKey:book.id];
    }
    return nil;
}

#pragma mark - Delete Book

- (void)deleteBook:(Book *)book {
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    BOOL deleteSuccess = [appDelegate.ejdbController deleteObject:[appDelegate.ejdbController getBookForBookId:book.id]];
    if (deleteSuccess) {
        NSLog(@"Deleted Book");
        _allBooksArray = [self getAllBooks];
        if (!_allBooksArray) {
            _allBooksArray = [NSArray array];
        }
        [_booksCollectionView reloadData];
    }
    
}

@end
