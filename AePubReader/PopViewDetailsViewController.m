//
//  PopViewDetailsViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 15/10/12.
//
//

#import "PopViewDetailsViewController.h"
#import "AePubReaderAppDelegate.h"
#import "DataModelControl.h"
#import "Reachability.h"
#import "Flurry.h"
@interface PopViewDetailsViewController ()

@end

@implementation PopViewDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)downloadBook:(id)sender {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
     // if (status==ReachableViaWiFi) {
    long freeSpace=[self getFreeDiskspace];
    if (freeSpace<_size) {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Error" message:@"There is no sufficient space in your device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        
    }else{
      [_store DownloadBook:_bookTapped];
    }
    
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil imageLocation:(NSString *)locationImage indentity:(NSInteger)iden{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _imageLocation=locationImage;
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *) [UIApplication sharedApplication].delegate;
        
        NSString *local=[NSString stringWithFormat:@"%d",iden ];
        _bookTapped=[delegate.dataModel getBookOfId:local];
     //   [_bookTapped retain];
        
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
  //  NSString *value=[NSString stringWithFormat:@"Details page in downloads for id %@ with title %@ entered",_bookTapped.id,_bookTapped.title ];
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    [dictionary setValue:_bookTapped.id forKey:@"identity"];
    [dictionary setValue:_bookTapped.title forKey:@"title"];
    [Flurry logEvent:@"Details page in downloads entered" withParameters:dictionary];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    NSString *value=@"Details page in downloads ";
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    [dictionary setValue:_bookTapped.id forKey:@"identity"];
    [dictionary setValue:_bookTapped.title forKey:@"title"];
    [Flurry logEvent:value withParameters:dictionary];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *done=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeModal:)];
    self.navigationItem.leftBarButtonItem=done;

    UIBarButtonItem *share=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareBook:)];
 
    UIImage *image=[[UIImage alloc]initWithContentsOfFile:_imageLocation];
    _imageView.image=image;
    NSLog(@"frame width %f",_imageView.frame.size.width);
    float size=[_bookTapped.size longLongValue];
    NSLog(@"%@",[NSNumber numberWithLongLong:size] );
    size=size/1024.0f;
     NSLog(@"%@",[NSNumber numberWithLongLong:size] );
    size=size/1024.0f;
     NSLog(@"%@",[NSNumber numberWithLongLong:size] );
    _fileSize.text=[NSString stringWithFormat:@"File Size :%@ MB",[NSNumber numberWithLongLong:size] ];
    _titleBook.text=_bookTapped.title;
    _size=size;
//    NSAttributedString *attr=[[NSAttributedString alloc]initWithString:_bookTapped.desc];
//     NSString *ver= [UIDevice currentDevice].systemVersion;
//    if ([ver floatValue]>5.1) {
//       _textView.attributedText=attr; 
//    }else{
//        _textView.text=_bookTapped.desc;
//    }
//    
    
//    [attr release];
    //NSLog(@"text %@",_textView.text);
    [_detailsWebView loadHTMLString:_bookTapped.desc baseURL:nil];
 //   [image release];
  //  [done release];
    self.navigationItem.rightBarButtonItem=share;
  //  [share release];
    NSLog(@"x=%f y=%f height=%f width=%f",self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.size.height,self.view.frame.size.width);
    _freeSpace.text=[NSString stringWithFormat:@"Free Space :%lld MB",[self getFreeDiskspace]];
    
}
-(void)shareBook:(id)sender{
    NSString *ver= [UIDevice currentDevice].systemVersion;
    if([ver floatValue]>5.1){
        NSString *textToShare=[_bookTapped.link stringByAppendingString:@" great bk from MangoReader"];
        
        
        UIImage *image=[UIImage imageWithContentsOfFile:_imageLocation];
        NSArray *activityItems=@[textToShare,image];
        
        UIActivityViewController *activity=[[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
        activity.excludedActivityTypes=@[UIActivityTypeCopyToPasteboard,UIActivityTypePostToWeibo,UIActivityTypeAssignToContact,UIActivityTypePrint,UIActivityTypeSaveToCameraRoll ];
        if (_popDetails) {
            [_popDetails dismissPopoverAnimated:YES];
        }
        _popDetails=[[UIPopoverController alloc]initWithContentViewController:activity];
        
     //   [activity release];
        [_popDetails presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
     //   [pop release];
        return;
    }
    
    MFMailComposeViewController *mail;
    mail=[[MFMailComposeViewController alloc]init];
    [mail setSubject:@"Found this awesome interactive book on MangoReader"];
    mail.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
    [mail setMailComposeDelegate:self];
    NSString *body=[NSString stringWithFormat:@"Hi,\n%@",_bookTapped.link];
    body =[body stringByAppendingString:@"\nI found this cool book on mangoreader - we bring books to life.The book is interactive with the characters moving on touch and movement, which makes it fun and engaging.The audio and text highlight syncing will make it easier for kids to learn and understand pronunciation.Not only this, I can play cool games in the book, draw and make puzzles and share my scores.\nDownload the MangoReader app from the appstore and try these awesome books."];
    [mail setMessageBody:body isHTML:NO];
    [self presentModalViewController:mail animated:YES];
   // [mail release];
}
-(void)closeModal:(id)sender{
    if (_popDetails) {
        [_popDetails dismissPopoverAnimated:YES];
    }
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskAll;
    
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [controller dismissModalViewControllerAnimated:YES];
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

/*- (void)dealloc {
    [_titleBook release];
  
    [_imageView release];
    [_bookTapped release];
    _imageLocation=nil;
   
    [_fileSize release];
    [_detailsWebView release];
 
    [super dealloc];
}*/
- (void)viewDidUnload {
    [self setTitleBook:nil];
   
    [self setImageView:nil];
  
    [self setFileSize:nil];
    [self setDetailsWebView:nil];

    [self setFreeSpace:nil];
    [super viewDidUnload];
}
-(uint64_t)getFreeDiskspace {
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = dictionary[NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = dictionary[NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    totalFreeSpace=(totalFreeSpace/1024ll)/1024ll;
    return totalFreeSpace;
}
@end
