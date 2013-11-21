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
@interface BooksFromCategoryViewController ()

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
    _books= [delegate.dataModel getAllUserBooks];
    NSInteger count=MIN(_books.count, 6);
    NSInteger finalIndex=_inital+count;
    UIImage *maskImage=[UIImage imageNamed:@"circle2.png"];
    UIImage *originalImage;
    for (int i=_inital;i<finalIndex;i++) {
        UIButton *button=_buttonArray[i];
        button.hidden=NO;
        Book *book=_books[i];
        UIImageView *imageView=_imageArray[i];
        NSLog(@"Local Path File %@",book.localPathImageFile);
       originalImage= [UIImage imageWithContentsOfFile:book.localPathImageFile];
        imageView.image=   [self maskImage:originalImage withMask:maskImage];
        CGRect frame=imageView.frame;
        frame.size=maskImage.size;
        frame.origin=button.frame.origin;
        imageView.frame=frame;
        imageView.hidden=NO;
        UILabel *label=_titleLabelArray[i];
        label.text=book.title;
        label.hidden=NO;
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
    NewStoreCoverViewController *controller;
    CoverViewControllerBetterBookType *coverController;
    NSInteger index;
    NSString *identity;
    switch (button.tag) {
        case 0:
            controller=[[NewStoreCoverViewController alloc]initWithNibName:@"NewStoreCoverViewController" bundle:nil shouldShowLibraryButton:YES];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        default:
            index=button.tag;
            index--;
            Book *book=_books[index];
            identity=[NSString stringWithFormat:@"%@",book.id];
            coverController=[[CoverViewControllerBetterBookType alloc]initWithNibName:@"CoverViewControllerBetterBookType" bundle:nil WithId:identity];
            [self.navigationController pushViewController:coverController animated:YES];
            
            break;
    }
}
-(void)dismissPopOver{
    [_popOverController dismissPopoverAnimated:YES];

}
- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
	CGImageRef imgRef = [image CGImage];// you are just refering it not instantiating it so you should not release it.
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
