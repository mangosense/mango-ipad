//
//  TextViewViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 17/01/13.
//
//

#import "TextViewViewController.h"

@interface TextViewViewController ()

@end

@implementation TextViewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil With:(NSString *)note withUpdate:(BOOL)update withInteger:(NSInteger) identity
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if (note) {
          _note=[[NSString alloc]initWithString:note];
            
        }else{
            _note=nil;
        }
        _identity=identity;
        _update=update;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.contentSizeForViewInPopover=CGSizeMake(200, 200);
    // Do any additional setup after loading the view from its nib.
    NSString *html;
    if (_update) {
        html=[NSString stringWithFormat:@"<div id=\"content\" contenteditable=\"true\" style=\"font-family: Helvetica\">%@</div>",_note];
    }else{
        html =@"<div id=\"content\" contenteditable=\"true\" style=\"font-family: Helvetica\">Notes:</div>";
    }
    [_webview loadHTMLString:html baseURL:nil];
    [_webview becomeFirstResponder];
}
-(void)viewDidAppear:(BOOL)animated{
    [_webview becomeFirstResponder];
    [super viewDidAppear:animated];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    NSString *notes=[_webview stringByEvaluatingJavaScriptFromString:@"document.getElementById('content').innerHTML"];
    NSLog(@"Typed %@",notes);
    if (_update) {
        if (![notes isEqualToString:_note]) {
            [self.delegate updateNotes:notes withIdentity:_identity];
        }
    }else{// if update flag is gone then
        [self.delegate sendNotes:notes];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*- (void)dealloc {
    [_textView release];
    [_webview release];
    [_note release];
    [super dealloc];
}*/
- (void)viewDidUnload {
    [self setTextView:nil];
    [self setWebview:nil];
    [super viewDidUnload];
}
@end
