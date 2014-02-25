//
//  ShadowButton.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 28/09/12.
//
//

#import "ShadowButton.h"
#import <QuartzCore/QuartzCore.h>
#import "LibraryViewController.h"
#import "DownloadViewControlleriPad.h"
@implementation ShadowButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
      //  [self setupView];
    }
    return self;
}
-(id)init{
    self=[super init];
    if (self) {
       // [self setupView];
    }
    return self;
}

-(void)share:(id)sender{
    NSString *ver= [UIDevice currentDevice].systemVersion;
    if([ver floatValue]>5.1){
        NSString *textToShare=[_stringLink stringByAppendingString:@"great bk from MangoReader"];
    
        
        UIImage *image=[UIImage imageWithContentsOfFile:_imageLocalLocation];
        NSArray *activityItems=@[textToShare,image];
        
        UIActivityViewController *activity=[[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
        activity.excludedActivityTypes=@[UIActivityTypeCopyToPasteboard,UIActivityTypePostToWeibo];
        UIPopoverController *pop=[[UIPopoverController alloc]initWithContentViewController:activity];
       
     //   [activity release];
        [pop presentPopoverFromRect:self.frame inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
       // [pop release];
        // you dont release pop
        return;
    }

    MFMailComposeViewController *mail;
    mail=[[MFMailComposeViewController alloc]init];
   [mail setSubject:@"Found this awesome interactive book on MangoReader"];
      mail.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
    [mail setMailComposeDelegate:self];
    NSString *body=[NSString stringWithFormat:@"Hi,\n%@",_stringLink];
    body =[body stringByAppendingString:@"\nI found this cool book on mangoreader - we bring books to life.The book is interactive with the characters moving on touch and movement, which makes it fun and engaging.The audio and text highlight syncing will make it easier for kids to learn and understand pronunciation.Not only this, I can play cool games in the book, draw and make puzzles and share my scores.\nDownload the MangoReader app from the appstore and try these awesome books."];
    [mail setMessageBody:body isHTML:NO];
    if (_storeViewController&&mail!=nil) {
        [_storeViewController presentModalViewController:mail animated:YES];
    }else if(_libraryViewController&&mail!=nil){
     
        [_libraryViewController presentModalViewController:mail animated:YES];
    }
     //[mail release];
}
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [controller dismissModalViewControllerAnimated:YES];
}
/*-(void)message:(id)sender{
     MFMessageComposeViewController *message=[[MFMessageComposeViewController alloc]init];
    [message setBody:_stringLink];
    [message setMessageComposeDelegate:self];
    message.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
    if (_storeViewController) {
        [_storeViewController presentModalViewController:message animated:YES];
        
    }else if(_libraryViewController){
        [_libraryViewController presentModalViewController:message animated:YES];
    }
    [message release];
}*/
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [controller dismissModalViewControllerAnimated:YES];
}
/*-(BOOL)canBecomeFirstResponder{
    return YES;
}*/
/*-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    
    if (action==@selector(share:)) {
        return YES;
    }else if (action==@selector(DownloadBook:)){
        return YES;
    }else if(action==@selector(ViewBook:)){
        return YES;
    }else if(action==@selector(message:)){
       NSString *ver= [UIDevice currentDevice].systemVersion;
        if([ver floatValue]>5.1){
            return YES;
        }
        
    }
    return NO;
}*/
-(void)DownloadBook:(id)storeBookButton{
 
    [_storeViewController DownloadBook:storeBookButton];
}
-(void)ViewBook:(id)ViewBookButton{
  
//  
    [_libraryViewController showBookButton:ViewBookButton];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
/*-(void)dealloc{
    [super dealloc];
    _stringLink=nil;
}*/
@end
