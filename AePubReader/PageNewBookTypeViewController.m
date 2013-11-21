//
//  PageNewBookTypeViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 21/11/13.
//
//

#import "PageNewBookTypeViewController.h"
#import "MangoEditorViewController.h"
@interface PageNewBookTypeViewController ()

@end

@implementation PageNewBookTypeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil WithOption:(NSInteger)option BookId:(NSString *)bookID
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _option=option;
        _bookId=bookID;
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        _book= [delegate.dataModel getBookOfId:bookID];

        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
  //  UIView *view=[MangoEditorViewController readerPage:0 ForStory:<#(NSString *)#> WithFolderLocation:<#(NSString *)#>];
    NSString *jsonLocation=_book.localPathFile;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
    NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
    jsonLocation=     [jsonLocation stringByAppendingPathComponent:[onlyJson lastObject]];
    //  NSLog(@"json location %@",jsonLocation);
    NSString *jsonContents=[[NSString alloc]initWithContentsOfFile:jsonLocation encoding:NSUTF8StringEncoding error:nil];
    UIView *view=[MangoEditorViewController readerPage:1 ForStory:jsonContents WithFolderLocation:_book.localPathFile];
 //   view.frame=self.view.bounds;
  //  [self.view addSubview:view];
    view.backgroundColor=[UIColor grayColor];
    [self.viewBase addSubview:view];
    
    _rightView.backgroundColor=[UIColor clearColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ShowOptions:(id)sender {
    _rightView.hidden=NO;

    UIButton *button=(UIButton *)sender;
    button.hidden=YES;
}

- (IBAction)BackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)closeButton:(id)sender {
    _rightView.hidden=YES;
    _showOptionButton.hidden=NO;
}

- (IBAction)shareButton:(id)sender {
}

- (IBAction)editButton:(id)sender {
}

- (IBAction)changeLanguage:(id)sender {
}
@end
