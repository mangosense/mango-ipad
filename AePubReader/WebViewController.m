//
//  WebViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 04/10/12.
//
//

#import "WebViewController.h"
#import "Flurry.h"
@interface WebViewController ()

@end

@implementation WebViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil URL:(NSURL *)url{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _url=url;
     //   [_url retain];
    }
    return self;
}
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
    [self becomeFirstResponder];
    // Do any additional setup after loading the view from its nib.
    NSURLRequest *request=[[NSURLRequest alloc]initWithURL:_url];
  //  [_url release];
    if ([_url.absoluteString hasPrefix:@"http://"]) {
        _barButtonItem.title=@"Done";
    }else{
        _barButtonItem.title=@"Back to book";
    }
    [_webView loadRequest:request];
   // [request release];
    _alert =[[UIAlertView alloc]init];
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
        UIImage *image=[UIImage imageNamed:@"loading.png"];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-40, -160, 391, 320)];
        
        
        imageView.image=image;
        [_alert addSubview:imageView];
    //    [imageView release];
        UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(125, 25, 66.0f, 66.0f)];
        indicator.color=[UIColor blackColor];
        [indicator startAnimating];
        [_alert addSubview:indicator];
      //  [indicator release];
    }
    else{
    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(139.0f-18.0f, 40.0f, 37.0f, 37.0f)];
    [indicator startAnimating];
    [_alert addSubview:indicator];
  //  [indicator release];
        [_alert setTitle:@"Loading...."];}
    [_alert show];
  //  [_alert release];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];

}
-(void)viewWillAppear:(BOOL)animated{
    [Flurry logEvent:@"Game Center Entered/Promo VideoViewing"];

    [super viewWillAppear:YES];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];

}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];

    
}
-(void)viewWillDisappear:(BOOL)animated{
    [Flurry logEvent:@"Game Center Exited/Promo VideoViewing"];

    [super viewWillDisappear:YES];
}
-(BOOL)canBecomeFirstResponder{
    return YES;
}
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(copy:))
    {
        return NO;
    }
    if (action == @selector(cut:))
    {
        return NO;
    }
    if (action == @selector(paste:))
    {
        return NO;
    }
    if (action == @selector(select:))
    {
        return NO;
    }
    if (action == @selector(selectAll:))
    {
        return NO;
    }
    if (action == @selector(delete:))
    {
        return NO;
    }
    if (action == @selector(_setRtoLTextDirection:))
    {
        return NO;
    }
    if (action == @selector(_setLtoRTextDirection:))
    {
        return NO;
    }
    if (action == @selector(promptForReplace:))
    {
        return NO;
    }
    return NO;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [_alert dismissWithClickedButtonIndex:0 animated:YES];
    NSLog(@"error %@",error);
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
     [_alert dismissWithClickedButtonIndex:0 animated:YES];
}
-(void)webViewDidStartLoad:(UIWebView *)webView{
 

}
- (void)viewDidUnload {
    [self setWebView:nil];
    [self setBarButtonItem:nil];
    [super viewDidUnload];
}
- (IBAction)DismissViewControlller:(id)sender {
    NSURLRequest *request=[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:@"about:blank"]];
    
    [_webView loadRequest:request];
    [self dismissModalViewControllerAnimated:YES];
}
@end
