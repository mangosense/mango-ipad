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

@interface BooksFromCategoryViewController ()

@property (nonatomic, strong) NSMutableDictionary *bookIdDictionary;

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
    _buttonArray=[NSArray arrayWithObjects:_bookOne,_bookTwo,_bookThree,_bookFour,_bookFive, nil];
    _imageArray=[NSArray arrayWithObjects:_imageOne,_imageTwo,_imageThree,_imageFour,_imageFive, nil];
    _titleLabelArray=[NSArray arrayWithObjects:_labelone,_labelTwo,_labelThree,_labelFour,_labelFive, nil];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    if (_toEdit) {
        _books=[delegate.dataModel getEditedBooks];
    }else{
        _books= [delegate.dataModel getAllUserBooks];
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
            jsonLocation = [jsonLocation stringByAppendingPathComponent:[onlyJson lastObject]];
            
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

@end
