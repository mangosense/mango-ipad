//
//  DetailViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 04/12/12.
//
//

#import "DetailViewController.h"
#import "AePubReaderAppDelegate.h"
#import "DataModelControl.h"
#import "Flurry.h"
@interface DetailViewController ()

@end

@implementation DetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)backButton:(id)sender {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.PortraitOrientation=YES;
    [self dismissModalViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *string=[NSString stringWithFormat:@"%d",_identity ];
  Book *book=  [delegate.dataModel getBookOfId:string];
    _imageView.image=[UIImage imageWithContentsOfFile:book.localPathImageFile];
    [_webView loadHTMLString:book.desc baseURL:nil];
    _titleLabel.text=book.title;
    _topToolbar.tintColor=[UIColor blackColor];
      CGRect screenRect = [[UIScreen mainScreen] bounds];
    // CGFloat screenWidth=screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    // CGFloat screenWidht=screenRect.size.width;
    if (screenHeight>500.0&& [[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone){
        CGRect frame=  _webView.frame;
        frame.origin.x=frame.origin.x+60;
        _webView.frame=frame;
    }
    float size=[book.size floatValue];

    // NSLog(@"%@",[NSNumber numberWithLongLong:size] );
    size=size/1024.0f;
    //NSLog(@"%@",[NSNumber numberWithLongLong:size] );
    size=size/1024.0f;
    _fileSizeLabel.text=[NSString stringWithFormat:@"File Size : %0.2f MB",size];
    NSString *flurry=@"DetailsViewController entered to view details";
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    [dictionary setValue:@(_identity) forKey:@"identity"];
    [Flurry logEvent:flurry withParameters:dictionary];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:YES];
    [self.tabBarController.tabBar setHidden:YES];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    [self.tabBarController.tabBar setHidden:NO];
    NSString *flurry=@"DetailsViewController exited";
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    [dictionary setValue:@(_identity) forKey:@"identity"];
    [Flurry logEvent:flurry withParameters:dictionary];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
- (void)dealloc {
    [_imageView release];
    [_titleLabel release];
    [_textView release];
    [_downloadButton release];
    [_topToolbar release];
    [_bckButton release];
    [_fileSizeLabel release];
    [super dealloc];
}*/
- (void)viewDidUnload {
    [self setImageView:nil];
    [self setTitleLabel:nil];

    [self setDownloadButton:nil];
    [self setTopToolbar:nil];
    [self setBckButton:nil];
    [self setFileSizeLabel:nil];
    [self setWebView:nil];
    [super viewDidUnload];
}
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}
- (IBAction)downloadBook:(id)sender {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    if (delegate.downloadBook) {
        UIAlertView *down=[[UIAlertView alloc]initWithTitle:@"Downloading.." message:@"Cannot start downloading as previous download is not complete" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [down show];
      //  [down release];
        return;
    }
    [self dismissModalViewControllerAnimated:YES];

    NSString *string=[NSString stringWithFormat:@"%d",_identity ];
    Book *book=  [delegate.dataModel getBookOfId:string];
    book.downloaded=@YES;
    book.date=[NSDate date];
    book.downloadedDate=[NSDate date];
      [delegate.dataModel saveData:book];
    [_booksMy downloadComplete:_identity];
    NSString *flurry=@"Downloading... book ";
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    [dictionary setValue:@(_identity) forKey:@"identity"];
    [Flurry logEvent:flurry withParameters:dictionary];
    //add download code
}

- (IBAction)backButtonPressed:(id)sender {
       AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.PortraitOrientation=YES;
    [self dismissModalViewControllerAnimated:YES];
}
@end
