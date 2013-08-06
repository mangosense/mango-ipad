//
//  CoverViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 08/05/13.
//
//

#import "CoverViewController.h"
#import "AePubReaderAppDelegate.h"
#import "LibraryViewController.h"
#import "ShowPopViewController.h"
@interface CoverViewController ()

@end

@implementation CoverViewController

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
    UIImage *image=[UIImage imageWithContentsOfFile:_imageLocation];
    [_imageView setImage:image];
    [self.navigationController.navigationBar setHidden:YES];
    [self.tabBarController.tabBar setHidden:YES];

    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    UIViewController *c=[[UIViewController alloc]init];
    c.view.backgroundColor=[UIColor clearColor];
    [self presentViewController:c animated:YES completion:^(void){
        [c dismissViewControllerAnimated:YES completion:nil];
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    NSString *path=[[NSUserDefaults standardUserDefaults] objectForKey:@"recordingDirectory"];
    NSInteger iden=[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"];
    //ima4
    NSString *appenLoc=[[NSString alloc]initWithFormat:@"%d/1.ima4",iden ];
    NSString *loc=[path stringByAppendingPathComponent:appenLoc];
    if (![[NSFileManager defaultManager] fileExistsAtPath:loc]) {
        [_readInMyVoiceButton setHidden:YES];
    }else{
        [_readInMyVoiceButton setHidden:NO];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)readByMyself:(id)sender {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.options=0;
    EpubReaderViewController *epubViewController=[[EpubReaderViewController alloc]initWithNibName:@"View" bundle:nil];
    epubViewController.pageNumber=1;
    epubViewController._strFileName=__strFileName;
    epubViewController.imageLocation=_imageLocation;
    epubViewController.url=_url;
    self.tabBarController.hidesBottomBarWhenPushed=YES;
    epubViewController.hidesBottomBarWhenPushed=YES;
    epubViewController.titleOfBook=_titleOfBook;
       [self.navigationController pushViewController:epubViewController animated:NO];

}

- (IBAction)readToMe:(id)sender {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.options=1;
    EpubReaderViewController *epubViewController=[[EpubReaderViewController alloc]initWithNibName:@"View" bundle:nil];
    epubViewController.pageNumber=1;
    epubViewController._strFileName=__strFileName;
    epubViewController.imageLocation=_imageLocation;
    epubViewController.url=_url;
    self.tabBarController.hidesBottomBarWhenPushed=YES;
    epubViewController.hidesBottomBarWhenPushed=YES;
    epubViewController.titleOfBook=_titleOfBook;    [self.navigationController pushViewController:epubViewController animated:NO];

}

- (IBAction)goToLibrary:(id)sender {
  //  _epubViewController.callOnBack=YES;
    //if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        
    //}else{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    self.navigationController.navigationBarHidden=NO;
    [self.navigationController popViewControllerAnimated:YES];
    [self.tabBarController.tabBar setHidden:NO];

    
}

- (IBAction)recordMyVoice:(id)sender {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.options=2;
    EpubReaderViewController *epubViewController=[[EpubReaderViewController alloc]initWithNibName:@"View" bundle:nil];
    epubViewController.pageNumber=1;
    epubViewController._strFileName=__strFileName;
    epubViewController.imageLocation=_imageLocation;
    epubViewController.url=_url;
    self.tabBarController.hidesBottomBarWhenPushed=YES;
    epubViewController.hidesBottomBarWhenPushed=YES;
    epubViewController.titleOfBook=_titleOfBook;    [self.navigationController popToViewController:epubViewController animated:NO];

}

- (IBAction)shareTheBook:(id)sender {
    @try {
        
   
    UIButton *button=(UIButton *)sender;
    NSString *ver= [UIDevice currentDevice].systemVersion;
    NSInteger bookId= [[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"];
    NSString *bookIdString=[NSString stringWithFormat:@"%d",bookId ];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    Book *book=  [delegate.dataModel getBookOfId:bookIdString];

    if([ver floatValue]>5.1){
        NSString *textToShare=[book.link stringByAppendingString:@" great bk from MangoReader"];
        
        
        UIImage *image=[UIImage imageWithContentsOfFile:_imageLocation];
        NSArray *activityItems=@[textToShare,image];
        
        UIActivityViewController *activity=[[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
        activity.excludedActivityTypes=@[UIActivityTypeCopyToPasteboard,UIActivityTypePostToWeibo,UIActivityTypeAssignToContact,UIActivityTypePrint,UIActivityTypeSaveToCameraRoll];
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
            [self presentModalViewController:activity animated:YES];
            //  [activity release];
            return;
        }
        _popViewController=[[UIPopoverController alloc]initWithContentViewController:activity];
        
        //  [activity release];
  [_popViewController presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];        // you dont release this
        return;
    }
    MFMailComposeViewController *mail;
    mail=[[MFMailComposeViewController alloc]init];
    [mail setSubject:@"Found this awesome interactive book on MangoReader"];
    mail.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
    
    [mail setMailComposeDelegate:self];
    NSString *body=[NSString stringWithFormat:@"Hi,\n%@",[book.link stringByAppendingString:@" great bk from MangoReader"]];
    body =[body stringByAppendingString:@"\nI found this cool book on mangoreader - we bring books to life.The book is interactive with the characters moving on touch and movement, which makes it fun and engaging.The audio and text highlight syncing will make it easier for kids to learn and understand pronunciation.Not only this, I can play cool games in the book, draw and make puzzles and share my scores.\nDownload the MangoReader app from the appstore and try these awesome books."];
    [mail setMessageBody:body isHTML:NO];
    [self presentModalViewController:mail animated:YES];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [controller dismissModalViewControllerAnimated:YES];

}

- (void)viewDidUnload {
    [self setImageView:nil];
    [self setImageView:nil];
    [self setReadInMyVoiceButton:nil];
    [super viewDidUnload];
}
- (IBAction)description:(id)sender {
    UIButton *button=(UIButton *)sender;
   NSInteger bookId= [[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"];
    NSString *bookIdString=[NSString stringWithFormat:@"%d",bookId ];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
  Book *book=  [delegate.dataModel getBookOfId:bookIdString];
    ShowPopViewController *showPopViewController =[[ShowPopViewController alloc]initWithNibName:@"ShowPopViewController" bundle:nil withString:book.desc];

    if (!book.desc || [book.desc length] == 0) {
        book.desc = @"No Description";
    }
    
    CGFloat descriptionHeight = [book.desc sizeWithFont:[UIFont systemFontOfSize:17.0f] constrainedToSize:CGSizeMake(300, 10000) lineBreakMode:NSLineBreakByWordWrapping].height + 20;
    UIWebView *descriptionWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 300, MIN(500, descriptionHeight))];
    [descriptionWebView loadHTMLString:book.desc baseURL:nil];
    showPopViewController.contentSizeForViewInPopover=CGSizeMake(300, descriptionHeight);
    [showPopViewController.view addSubview:descriptionWebView];
    
   _popViewController=[[UIPopoverController alloc]initWithContentViewController:showPopViewController];
    [_popViewController presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    _popViewController.popoverContentSize=CGSizeMake(300, descriptionHeight);
}

- (IBAction)readInMyVoice:(id)sender {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.options=3;
    EpubReaderViewController *epubViewController=[[EpubReaderViewController alloc]initWithNibName:@"View" bundle:nil];
    epubViewController.pageNumber=1;
    epubViewController._strFileName=__strFileName;
    epubViewController.imageLocation=_imageLocation;
    epubViewController.url=_url;
    self.tabBarController.hidesBottomBarWhenPushed=YES;
    epubViewController.hidesBottomBarWhenPushed=YES;
    epubViewController.titleOfBook=_titleOfBook;
    [self.navigationController pushViewController:epubViewController animated:NO];
}
- (IBAction)feedback:(id)sender {
    @try {
      MFMailComposeViewController *mail;
    mail=[[MFMailComposeViewController alloc]init];
    NSInteger bookId= [[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"];
    NSString *bookIdString=[NSString stringWithFormat:@"%d",bookId ];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    Book *book=  [delegate.dataModel getBookOfId:bookIdString];
    NSString *feedbackSubject=[NSString stringWithFormat:@"Feedback for book titled %@",book.title ];
    [mail setSubject:feedbackSubject];
    mail.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
    [mail setToRecipients:@[@"ios@mangosense.com"]];

    [mail setMailComposeDelegate:self];
   
    [self presentModalViewController:mail animated:YES];
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }

}
@end
