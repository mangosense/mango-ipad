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
    EpubReaderViewController *viewControllerToPop;
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[EpubReaderViewController class]]) {
            viewControllerToPop=(EpubReaderViewController *)viewController;
            viewControllerToPop.pageNumber=1;

            break;
        }
    }
    [self.navigationController popToViewController:viewControllerToPop animated:NO];}

- (IBAction)readToMe:(id)sender {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.options=1;
    EpubReaderViewController *viewControllerToPop;
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[EpubReaderViewController class]]) {
            viewControllerToPop=(EpubReaderViewController *)viewController;
            viewControllerToPop.pageNumber=1;
            break;
        }
    }
    [self.navigationController popToViewController:viewControllerToPop animated:NO];

}

- (IBAction)goToLibrary:(id)sender {
  //  _epubViewController.callOnBack=YES;
    //if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        
    //}else{
        UIViewController *viewControllerToPop;
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[LibraryViewController class]]) {
                viewControllerToPop=controller;
                break;
            }
        }
        [self.navigationController popToViewController:viewControllerToPop animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

    
    
}

- (IBAction)recordMyVoice:(id)sender {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.options=2;
    EpubReaderViewController *viewControllerToPop;
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[EpubReaderViewController class]]) {
            viewControllerToPop=(EpubReaderViewController *)controller;
            viewControllerToPop.pageNumber=1;

            break;
        }
    }
    [self.navigationController popToViewController:viewControllerToPop animated:NO];

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
    showPopViewController.contentSizeForViewInPopover=CGSizeMake(300, 500);
   _popViewController=[[UIPopoverController alloc]initWithContentViewController:showPopViewController];
    [_popViewController presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    _popViewController.popoverContentSize=CGSizeMake(300, 500);
}

- (IBAction)readInMyVoice:(id)sender {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.options=3;
    EpubReaderViewController *viewControllerToPop;
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[EpubReaderViewController class]]) {
            viewControllerToPop=(EpubReaderViewController *)controller;
            viewControllerToPop.pageNumber=1;
            
            break;
        }
    }
    [self.navigationController popToViewController:viewControllerToPop animated:NO];

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
