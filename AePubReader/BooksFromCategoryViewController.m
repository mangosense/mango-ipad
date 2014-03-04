//
//  BooksFromCategoryViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 20/11/13.
//
//

#import "BooksFromCategoryViewController.h"
#import "AePubReaderAppDelegate.h"
#import "SettingOptionViewController.h"
#import "DataModelControl.h"
#import "CoverViewControllerBetterBookType.h"
#import "MangoEditorViewController.h"
#import "MangoStoreViewController.h"
#import "MBProgressHUD.h"
#import "HKCircularProgressLayer.h"
#import "HKCircularProgressView.h"

@interface BooksFromCategoryViewController ()

@property (nonatomic, strong) NSMutableDictionary *bookIdDictionary;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, strong) HKCircularProgressView *progressView;
@property (nonatomic, assign) int bookProgress;

@end

@implementation BooksFromCategoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withInitialIndex:(NSInteger)index
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _inital=index;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    MangoApiController *apiController = [MangoApiController sharedApiController];
    apiController.delegate = self;
    
    _buttonArray=[NSArray arrayWithObjects:_bookOne,_bookTwo,_bookThree,_bookFour,_bookFive, nil];
    _imageArray=[NSArray arrayWithObjects:_imageOne,_imageTwo,_imageThree,_imageFour,_imageFive, nil];
    _titleLabelArray=[NSArray arrayWithObjects:_labelone,_labelTwo,_labelThree,_labelFour,_labelFive, nil];
    
    _categoryTitleLabel.text = [_categorySelected objectForKey:NAME];
    _categoryTitleLabel.font = [UIFont boldSystemFontOfSize:17];
    
    [self setupUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)homeButton:(id)sender {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *contoller=(UIViewController *)delegate.controller;
    [self.navigationController popToViewController:contoller animated:YES];
}

- (IBAction)libraryButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)settingsButton:(id)sender {
    UIButton *button=(UIButton *) sender;
    SettingOptionViewController *settingsViewController=[[SettingOptionViewController alloc]initWithStyle:UITableViewCellStyleDefault];
    settingsViewController.dismissDelegate=self;
    settingsViewController.controller=self.navigationController;
    _popOverController=[[UIPopoverController alloc]initWithContentViewController:settingsViewController];
    [_popOverController presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

}

- (IBAction)booksButtonclicked:(id)sender {
    UIButton *button=(UIButton *)sender;
    MangoStoreViewController *controller;
    CoverViewControllerBetterBookType *coverController;
    NSInteger index;
    NSString *identity;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.pageViewController=self;
    switch (button.tag) {
        case 0:
            if (_toEdit) {
                MangoEditorViewController *newBookEditorViewController = [[MangoEditorViewController alloc] initWithNibName:@"MangoEditorViewController" bundle:nil];
                newBookEditorViewController.isNewBook = YES;
                newBookEditorViewController.storyBook = nil;
                [self.navigationController.navigationBar setHidden:YES];
                [self.navigationController pushViewController:newBookEditorViewController animated:YES];
            } else {
                controller=[[MangoStoreViewController alloc]initWithNibName:@"MangoStoreViewController" bundle:nil];
                
                [self.navigationController pushViewController:controller animated:YES];
            }
            break;
        default:
            if (_toEdit) {
                index=button.tag;
                index--;
                Book *book=[delegate.dataModel getBookOfId:[_bookIdDictionary objectForKey:[NSString stringWithFormat:@"%d", button.tag]]];
                [delegate.dataModel displayAllData];
                identity=[NSString stringWithFormat:@"%@",book.id];
                
                MangoEditorViewController *mangoEditorViewController = [[MangoEditorViewController alloc] initWithNibName:@"MangoEditorViewController" bundle:nil];
                mangoEditorViewController.isNewBook = NO;
                mangoEditorViewController.storyBook = book;
                [self.navigationController.navigationBar setHidden:YES];
                [self.navigationController pushViewController:mangoEditorViewController animated:YES];
            } else {
                index=button.tag;
                index--;
                Book *book=[delegate.dataModel getBookOfId:[_bookIdDictionary objectForKey:[NSString stringWithFormat:@"%d", button.tag]]];
                identity=[NSString stringWithFormat:@"%@",book.id];
                [delegate.dataModel displayAllData];

                coverController=[[CoverViewControllerBetterBookType alloc]initWithNibName:@"CoverViewControllerBetterBookType" bundle:nil WithId:identity];
                [self.navigationController pushViewController:coverController animated:YES];
            }
            
            break;
    }
}
-(void)dismissPopOver{
    [_popOverController dismissPopoverAnimated:YES];

}

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
    return [UIImage imageWithCGImage:masked];
}

#pragma mark  - HUD Methods

- (void)showHudOnButton:(UIButton *)button {
    if (!_progressView) {
        _progressView = [[HKCircularProgressView alloc] initWithFrame:CGRectMake(button.frame.size.width/2 - 25, button.frame.size.height/2 - 25, 50, 50)];
        _progressView.max = 100.0f;
        _progressView.step = 0.0f;
        [button addSubview:_progressView];
    }
    _progressView.current = _bookProgress;
}

- (void)hideHudOnButton:(UIButton *)button {
    [_progressView removeFromSuperview];
}

#pragma mark - Setup UI

- (void)setupUI {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    if (_toEdit) {
        _books=[delegate.dataModel getEditedBooks];
        [_MoreBooksButton setImage:[UIImage imageNamed:@"create-story-book-icon1.png"] forState:UIControlStateNormal];
    }else{
        _books= [delegate.dataModel getAllUserBooks];
        [_MoreBooksButton setImage:[UIImage imageNamed:@"icons_getmorebooks.png"] forState:UIControlStateNormal];
        
        NSMutableArray *booksForSelectedCategory = [[NSMutableArray alloc] init];
        for (Book *book in _books) {
            if (book.localPathFile && _categorySelected) {
                NSString *jsonLocation=book.localPathFile;
                NSFileManager *fm = [NSFileManager defaultManager];
                NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
                NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
                NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
                jsonLocation = [jsonLocation stringByAppendingPathComponent:[onlyJson firstObject]];
                
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonLocation] options:NSJSONReadingAllowFragments error:nil];
                
                NSLog(@"Categories - %@, Selected Category - %@", [[jsonDict objectForKey:@"info"] objectForKey:@"categories"], [_categorySelected objectForKey:NAME]);
                if ([[[jsonDict objectForKey:@"info"] objectForKey:@"categories"] containsObject:[_categorySelected objectForKey:NAME]] || [[_categorySelected objectForKey:NAME] isEqualToString:ALL_BOOKS_CATEGORY]) {
                    [booksForSelectedCategory addObject:book];
                }
            }
        }
        _books = (NSArray *)booksForSelectedCategory;
    }
    NSInteger count=MIN(_books.count, 5);
    NSInteger finalIndex=_inital+count;
    UIImage *maskImage=[UIImage imageNamed:@"circle2.png"];
    UIImage *originalImage;
    
    _bookIdDictionary = [[NSMutableDictionary alloc] init];
    
    for (int i=_inital;i<finalIndex;i++) {
        UIButton *button=_buttonArray[i];
        button.hidden=NO;
        Book *book=_books[i];
        if (book.localPathFile) {
            UIImageView *imageView=_imageArray[i];
            
            //For Cover Image
            NSString *jsonLocation=book.localPathFile;
            NSFileManager *fm = [NSFileManager defaultManager];
            NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
            NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
            NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
            jsonLocation = [jsonLocation stringByAppendingPathComponent:[onlyJson firstObject]];
            
            NSString *jsonContents=[[NSString alloc]initWithContentsOfFile:jsonLocation encoding:NSUTF8StringEncoding error:nil];
            UIImage *image=[MangoEditorViewController coverPageImageForStory:jsonContents WithFolderLocation:book.localPathFile];
            
            NSLog(@"Local Path File %@",book.localPathImageFile);
            originalImage= image;
            imageView.image=   [self maskImage:originalImage withMask:maskImage];
            CGRect frame=imageView.frame;
            frame.size=maskImage.size;
            frame.origin=button.frame.origin;
            imageView.frame=frame;
            imageView.hidden=NO;
            UILabel *label=_titleLabelArray[i];
            label.text=book.title;
            label.hidden=NO;
            button.tag = i+5; //Random tag
            [_bookIdDictionary setObject:book.id forKey:[NSString stringWithFormat:@"%d", button.tag]];
        }
    }
}

#pragma mark - Post API Delegate

- (void)bookDownloaded {
    [self setupUI];
}

- (void)updateBookProgress:(int)progress {
    _bookProgress = progress;
    
    if (progress < 100) {
        if (_progressView) {
            [self performSelectorOnMainThread:@selector(showHudOnButton:) withObject:nil waitUntilDone:YES];
        }
        
        int lastIndex = -1;
        
        if (!_isDownloading) {
            for (UIButton *button in _buttonArray) {
                if (button.hidden) {
                    lastIndex = [_buttonArray indexOfObject:button] - 1;
                    _isDownloading = YES;
                    break;
                }
            }
        }
        
        if (lastIndex > -1) {
            UIButton *button = [_buttonArray objectAtIndex:lastIndex];
            [self performSelectorOnMainThread:@selector(showHudOnButton:) withObject:button waitUntilDone:YES];
        }
        
        [_homeBtn setEnabled:NO];
        [_libraryBtn setEnabled:NO];
        
    } else {
        int lastIndex = -1;

        for (UIButton *button in _buttonArray) {
            if (button.hidden) {
                lastIndex = [_buttonArray indexOfObject:button] - 1;
                break;
            }
        }
        if (lastIndex > -1) {
            UIButton *button = [_buttonArray objectAtIndex:lastIndex];
            [self performSelectorOnMainThread:@selector(hideHudOnButton:) withObject:button waitUntilDone:YES];
        }
        
        [_homeBtn setEnabled:YES];
        [_libraryBtn setEnabled:YES];

    }
}

@end
