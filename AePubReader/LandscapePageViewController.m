//
//  LandscapePageViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 26/05/13.
//
//

#import "LandscapePageViewController.h"
#import "Flurry.h"
#import "AePubReaderAppDelegate.h"
#import "NoteButton.h"
@interface LandscapePageViewController ()

@end

@implementation LandscapePageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(Chapter *)chapter
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        NSString *encodedString=[chapter.spinePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        _url=[[NSURL alloc]initWithString:encodedString];
        _val=[[NSString alloc]initWithString:encodedString];
        _chapter=chapter;
        //   [_chapter retain];
        _query=nil;
    }
    return self;
}
- (IBAction)onBack:(id)sender {
    NSString *string=@"exited at textbook";
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    [dictionary setValue:@(_chapter.pageCount) forKey:@"pageCount"];
    [dictionary setValue:@(_bookId) forKey:@"identity"];
    [dictionary setValue:_titleOfBook forKey:@"book title"];
    
    [Flurry logEvent:string withParameters:dictionary];
    self.navigationController.navigationBarHidden=NO;
    
    [self.navigationController popViewControllerAnimated:YES];
    [self.parentViewController.parentViewController.navigationController popViewControllerAnimated:YES];
    NSNotificationCenter *defaultCenter=[NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self];
    if (_searchResultsPopover) {
        if([_searchResultsPopover isPopoverVisible]){
            [_searchResultsPopover dismissPopoverAnimated:YES];
        }
    }
    
}
-(void)setQuery:(NSString *)query{
    _query=[[NSString alloc]initWithString:query];
}
-(BOOL)shouldAutorotate{
    return YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURLRequest *request=[[NSURLRequest alloc]initWithURL:_url];
    _webView.delegate=self;
    _simpleView.webview=_webView;
    [_webView loadRequest:request];
    _webView.scrollView.bounces=NO;
    //   // [request release];
    //        _webView.scrollView.scrollEnabled=NO;
    
    _hide=YES;
    for(UIView *wview in [[_webView subviews][0] subviews]) {
        if([wview isKindOfClass:[UIImageView class]]) { wview.hidden = YES; }
    }
    _topView.backgroundColor=[UIColor blackColor];
    
    _tap=NO;
    
    ////
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector( show: ) ];
    //  gr.delegate=self;
    [self.webView.scrollView addGestureRecognizer: gr];
    // [gr release];
    //    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(show:)];
    //    [self.webView addGestureRecognizer:pan];
    //    [pan release];
    _leftSideView.backgroundColor=[UIColor blackColor];
    _highlight.backgroundColor=[UIColor clearColor];
    _notesButton.backgroundColor=[UIColor clearColor];
    _highlightAsNotes.backgroundColor=[UIColor clearColor];
    _showNotesOrHighlight.backgroundColor=[UIColor clearColor];
    _hideTouchUpInsider.backgroundColor=[UIColor clearColor];
    _searchViewController=[[SearchResultsViewController alloc]initWithNibName:@"SearchResultsViewController" bundle:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuShown) name:UIMenuControllerDidShowMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowMenu) name:UIMenuControllerWillShowMenuNotification object:nil];
    //ios 5
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    UIImage *image=[UIImage imageNamed:@"srbar.png"];
    _searchBar.backgroundImage=image;
    // Do any additional setup after loading the view from its nib.
}
- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskLandscape;
    
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"%@",error);
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    if (_alertView) {
        [_alertView dismissWithClickedButtonIndex:0 animated:YES];
        _alertView =nil;
    }
    NSString *jsCode=@"var hLink=document.getElementsByTagName('a');for (i=0;i<hLink.length;i++) {if (hLink[i].getAttribute('href')=='#') {hLink[i].setAttribute('href','javascript:void(0)');}}";
    [_webView stringByEvaluatingJavaScriptFromString:jsCode];
    
    NSString *filePath  = [[NSBundle mainBundle] pathForResource:@"UIWebViewSearch" ofType:@"js" inDirectory:@""];
    NSData *fileData    = [NSData dataWithContentsOfFile:filePath];
    NSMutableString *jsString  = [[NSMutableString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    //   NSLog(@"Val %@",jsString);
    //    //
    [_webView stringByEvaluatingJavaScriptFromString:jsString];
    if (_query) {
        NSString *format=[NSString stringWithFormat:@"uiWebview_HighlightAllOccurencesOfString('%@')",_query ];
        [_webView stringByEvaluatingJavaScriptFromString:format];
        
    }
    // [jsString autorelease];
    //HighlightedStringOld
    filePath  = [[NSBundle mainBundle] pathForResource:@"HighlightedStringOld" ofType:@"js" inDirectory:@""];
    fileData    = [NSData dataWithContentsOfFile:filePath];
    jsString  = [[NSMutableString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    //   NSLog(@"Val %@",jsString);
    //    //
    //    [jsString autorelease];
    [_webView stringByEvaluatingJavaScriptFromString:jsString];
    
    //    jsCode=@"function touchEnd(event){window.location = 'touchEnded'}";
    //    jsCode=@"document.addEventListener(\"touchend\",touchEnd,false)";
    //    [_webView stringByEvaluatingJavaScriptFromString:jsCode];
    //   jsCode=   [_webView stringByEvaluatingJavaScriptFromString:@"function tryout(){ alert('hi'); return true;} tryout()"];
    //    NSLog(@"jsCode %@",jsCode);
    /*
     myDiv = document.getElementById(“myDiv”);
     selection = window.getSelection();
     selection.setPosition(myDiv, 0);
     */
    _webView.scrollView.scrollEnabled=YES;
    NSString *width=[_webView stringByEvaluatingJavaScriptFromString:@"document.body.clientWidth"];
    NSString *height=[_webView stringByEvaluatingJavaScriptFromString:@"document.body.clientHeight"];
    NSLog(@"width %@ height %@",width,height);

    

        
        
        [self selection:nil];
        

    //    CGRect frame=_webView.frame;
    //    frame.size.height=actualHeight;
    //    frame.size.width=actualWidth;
    //    _webView.frame=frame;
}
-(void)webViewDidStartLoad:(UIWebView *)webView{
    
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if ([[[request URL]absoluteString]hasPrefix:@"selection"]) {
        NSLog(@"%@",[request URL].absoluteString);
        return NO;
    }
    
    //    if ([[[request URL]absoluteString]hasPrefix:@"touchEnded"]) {
    //        [self show:nil];
    //        return NO;
    //    }
    return YES;
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    
    // [jsString autorelease];
    
    //   [_webView stringByEvaluatingJavaScriptFromString:@"alert('hi')"];
    if (_searchResultsPopover==nil) {
        _searchResultsPopover=[[UIPopoverController alloc]initWithContentViewController:_searchViewController];
        [_searchResultsPopover setPopoverContentSize:CGSizeMake(400, 600)];
        
    }
    if(![_searchResultsPopover isPopoverVisible]){
        [_searchResultsPopover presentPopoverFromRect:searchBar.bounds inView:searchBar permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    }
    LandscapeTextBookViewController *controller=(LandscapeTextBookViewController *)self.parentViewController.parentViewController;
    if(!controller.searching){
        controller.searching=YES;
        LandscapeTextBookViewController *controller=(LandscapeTextBookViewController *)self.parentViewController.parentViewController;
        _searchViewController.epubViewController=controller;
        _searchViewController.array=controller.array;
        [_searchViewController searchString:[searchBar text]];
        [searchBar resignFirstResponder];
    }
    
}
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? paths[0] : nil;
    return basePath;
}
-(void)willShowMenu{
    NSLog(@"menu will notification");
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
        
        
        UIMenuController *menuController=[UIMenuController sharedMenuController];
        UIMenuItem *itemHightlight=[[UIMenuItem alloc]initWithTitle:@"Highlight" action:@selector(highlight:)];
        //            UIMenuItem *removeHighlight=[[UIMenuItem alloc]initWithTitle:@"Remove Highlight" action:@selector(removeAllHighlight:)];
        UIMenuItem *itemNotes=[[UIMenuItem alloc]initWithTitle:@"Notes" action:@selector(notes:)];
        
        NSArray *array=@[itemHightlight,itemNotes];
        menuController.menuItems=array;
        // [itemHightlight release];
        // [itemNotes release];
        //    [removeHighlight release];
        //   [self becomeFirstResponder];
    }
}
-(void)menuShown{
    NSLog(@"menu shown notification");
    NSString *json=[_webView stringByEvaluatingJavaScriptFromString:@"function getRectForSelectedWord() {var selection = window.getSelection();var range = selection.getRangeAt(0);var rect = range.getBoundingClientRect();return JSON.stringify(rect)}getRectForSelectedWord()"];
    
    //    NSLog(@"x=%f y=%f w=%f h=%f", [UIMenuController sharedMenuController].menuFrame.origin.x,[UIMenuController sharedMenuController].menuFrame.origin.y,[UIMenuController sharedMenuController].menuFrame.size.width,[UIMenuController sharedMenuController].menuFrame.size.height);
    if (json.length>0) {
        NSLog(@"JSON %@",json);
        
        NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]options:NSJSONReadingAllowFragments error:nil];
        
        NSNumber *left=dict[@"left"];
        NSNumber *top=dict[@"top"];
        NSNumber *width=dict[@"width"];
        NSNumber *height=dict[@"height"];
        
        _frame=CGRectMake(left.floatValue, top.floatValue, width.floatValue, height.floatValue);
        _left=left.doubleValue;
        _top=top.doubleValue;
        
    }    
    
    
}
-(void)show:(id)sender{
    NSLog(@"Menu shown");
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad)
    {
        UIGestureRecognizer *gest=(UIGestureRecognizer *)sender;
        
        UIMenuController *menuController=[UIMenuController sharedMenuController];
        if (menuController.isMenuVisible==NO&& [[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad ) {
            
            
            UIMenuItem *itemHightlight=[[UIMenuItem alloc]initWithTitle:@"Highlight" action:@selector(highlight:)];
            //       UIMenuItem *removeHighlight=[[UIMenuItem alloc]initWithTitle:@"Remove Highlight" action:@selector(removeAllHighlight:)];
            UIMenuItem *itemNotes=[[UIMenuItem alloc]initWithTitle:@"Notes" action:@selector(notes:)];
            
            NSArray *array=@[itemHightlight,itemNotes];
            menuController.menuItems=array;
            //   [itemHightlight release];
            //  [itemNotes release];
            //      [removeHighlight release];
            [menuController setTargetRect:  gest.accessibilityFrame inView:self.webView];
            [menuController setMenuVisible:YES];
            _tap=YES;
        }
    }
    
    
}
-(BOOL)canBecomeFirstResponder{
    
    return YES;
}
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action==@selector(highlight:)) {
        return YES;
    }
    if (action==@selector(notes:)) {
        return YES;
    }
    return  [super canPerformAction:action withSender:sender];
}
-(void)highlight:(id)sender{
    
    //window.getSelection().getRangeAt(0).startContainer
    //window.getSelection().getRangeAt(0).endContainer
    //window.getSelection().getRangeAt(0).toString()
    
    
    
    NSString *selectedText=[_webView stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
    if (selectedText.length==0) {
        return;
    }
    NSString *startContainer=[_webView stringByEvaluatingJavaScriptFromString:@"window.getSelection().baseNode.wholeText"];
    //window.getSelection().getRangeAt(0).startContainer
    NSString *endContainer=[_webView stringByEvaluatingJavaScriptFromString:@"window.getSelection().extentNode.wholeText"];
    
    
    
    NSString *surroundingText=[_webView stringByEvaluatingJavaScriptFromString:@"window.getSelection().extentNode.wholeText"];
    NSString *currentstartOffset=[_webView stringByEvaluatingJavaScriptFromString:@"window.getSelection().getRangeAt(0).startOffset"];
    NSLog(@"new surrounding text %@",surroundingText);
    if (![startContainer isEqualToString:endContainer]) {
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        NSInteger bookId= [[NSUserDefaults standardUserDefaults]integerForKey:@"bookid"];
        NSArray *array=[delegate.dataModel getNoteOrHighlight:bookId withPageNo:_chapter.chapterIndex];
        array=[[NSArray alloc]initWithArray:array];
        int i;
        for (i=0;i<array.count;i++) {
            @try {
                NoteHighlight *noteOrHighlight=array[i];
                NSRange range= [noteOrHighlight.surroundingtext rangeOfString:selectedText];
                surroundingText=noteOrHighlight.surroundingtext;
                if (range.location!=NSNotFound)// if valid range
                {
                    currentstartOffset=[NSString stringWithFormat:@"%d",range.location ];
                    NSInteger endTempOffset=currentstartOffset.integerValue+selectedText.length;
                    
                    NSLog(@"surrounding text %@",surroundingText);
                    NSInteger startoldOffset=noteOrHighlight.srno.integerValue;
                    NSInteger endOldOffset=noteOrHighlight.srno.integerValue+noteOrHighlight.text.length;
                    BOOL val=endTempOffset<startoldOffset;
                    
                    val=val|(currentstartOffset.integerValue>endOldOffset);
                    if (!val) {
                        break;
                    }
                    
                    
                }
                
            }
            @catch (NSException *exception) {
                NSLog(@"exception %@",exception);
            }
            @finally {
                
            }
        }
        if (i==array.count) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Cannot" message:@"Cannot highlight more than one paragraph" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            //  [alert release];
            //  [array release];
            return;
            
        }
        //[array release];
    }
    
    
    
    NSUInteger currentendIndex=currentstartOffset.integerValue+selectedText.length;
    
    
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    //check for overlapps
    NSInteger bookId= [[NSUserDefaults standardUserDefaults]integerForKey:@"bookid"];
    
    NSArray *array=[delegate.dataModel getHighlightorNotes:bookId withPageNo:_chapter.chapterIndex withSurroundingString:surroundingText];
    array=[[NSArray alloc]initWithArray:array];
    if (array.count>0) {
        
        NSString *tempText;
        NSError *erro=nil;
        for (NoteHighlight *highlight in array) {
            NSInteger indexStart= highlight.srno.intValue;
            NSInteger indexEnd=highlight.text.length+indexStart;
            //currentstart---oldstart-----currentend<---->oldend
            if (currentstartOffset.intValue<indexStart&&currentendIndex<=indexEnd) {
                NSLog(@"\n\n\noldselection ----%@",highlight.text);
                NSLog(@"newselection ----%@",selectedText);
                tempText=[selectedText substringToIndex:(indexStart-currentstartOffset.intValue)];
                
                NSLog(@"\nfragment-----%@",tempText);
                tempText=[NSString stringWithFormat:@"%@%@",tempText,highlight.text];
                highlight.text=tempText;
                highlight.srno=@(currentstartOffset.integerValue);
                highlight.highlight=@YES;
                if ([highlight hasChanges]) {
                    [delegate.dataModel.dataModelContext save:&erro];
                    if (erro) {
                        NSLog(@"%@",erro);
                    }
                }
                [self removeAllHighlight:nil];
                [self selection:nil];
                //    [array release];
                return;
            }
            //oldstart<-->currentstart------oldend-----currentend
            else if (currentstartOffset.intValue>=indexStart&&indexEnd<currentendIndex){
                NSLog(@"\n\n\noldselection ----%@",highlight.text);
                NSLog(@"newselection ----%@",selectedText);
                //transform the older text
                tempText=[highlight.text substringToIndex:(currentstartOffset.intValue-indexStart)];
                
                NSLog(@"\nfragment-----%@",tempText);
                tempText=[NSString stringWithFormat:@"%@%@",tempText,selectedText];
                NSLog(@"actual new string %@",tempText);
                highlight.text=tempText;
                if ([highlight hasChanges]) {
                    [delegate.dataModel.dataModelContext save:&erro];
                    if (erro) {
                        NSLog(@"%@",erro);
                    }
                }
                [self removeAllHighlight:nil];
                [self selection:nil];
                //    [array release];
                return;
            }
            //oldstart---currentstart---currentend---oldend
            else if(indexStart>currentstartOffset.intValue&&currentendIndex<indexEnd){
                //   [array release];
                return;
            }
            else if(currentstartOffset.intValue==indexStart&&currentendIndex==indexEnd){
                //    [array release];
                return;
            }//currentstart---oldstart-----oldend--currentend
            else if(currentstartOffset.intValue<indexStart&&currentendIndex>indexEnd){
                highlight.text=selectedText;
                highlight.srno=@(currentstartOffset.intValue);
                if ([highlight hasChanges]) {
                    [delegate.dataModel.dataModelContext save:&erro];
                    if (erro) {
                        NSLog(@"%@",erro);
                    }
                }
                [self removeAllHighlight:nil];
                [self selection:nil];
                //   [array release];
                return;
            }
        }
        
        
    }
    // [array release];
    NSRange range=[surroundingText rangeOfString:selectedText];
    if (range.location==NSNotFound) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Cannot" message:@"Cannot highlight more than one paragraph" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        //   [alert release];
        return;
    }
    //    NSString *newSurroundingText=[[NSString alloc]initWithFormat:@"%@<span xmlns=\"http://www.w3.org/1999/xhtml\" class=\"uiWebviewHighlight\" style=\"background-color: yellow; color: black; \">%@</span>%@",before,selectedText,after ];
    //
    //    NSString *jsCode=[NSString stringWithFormat:@"document.body.innerHTML=document.body.innerHTML.replace('%@','%@')",surroundingText,newSurroundingText];
    //    NSLog(@"code for highlight%@",jsCode);
    //    [_webView stringByEvaluatingJavaScriptFromString:jsCode];
    //    [newSurroundingText release];
    NoteHighlight *noteHighlight=[NSEntityDescription insertNewObjectForEntityForName:@"NoteHighlight" inManagedObjectContext:delegate.managedObjectContext];
    noteHighlight.text=selectedText;
    noteHighlight.surroundingtext=surroundingText;
    noteHighlight.srno=@(currentstartOffset.integerValue);// srno is startoffset
    
    noteHighlight.identity=[NSNumber numberWithInteger:[delegate.dataModel getCount]];
    NSLog(@"identity %@",noteHighlight.identity);
    noteHighlight.bookid=@(bookId);
    NSInteger pageNumber=  _chapter.chapterIndex;
    noteHighlight.pageNo=@(pageNumber);
    noteHighlight.date_added=[NSDate date];
    noteHighlight.date_modified=[NSDate date];
    noteHighlight.highlight=@YES;
    NSError *error;
    if (![delegate.managedObjectContext save:&error]) {
        NSLog(@"%@",error);
    }
    [self selection:nil];
}
-(void)sendNotes:(NSString *)string{
    // [string retain];
    
    
    NSString *newSurrounding,*newCurrentOffset;
    if (![_startContainerNote isEqualToString:_endContainerNote]) {
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        NSInteger bookId= [[NSUserDefaults standardUserDefaults]integerForKey:@"bookid"];
        NSArray *array=[delegate.dataModel getNoteOrHighlight:bookId withPageNo:_chapter.chapterIndex];
        array=[[NSArray alloc]initWithArray:array];
        int i;
        for (i=0;i<array.count;i++) {
            NoteHighlight *noteOrHighlight=array[i];
            NSRange range= [noteOrHighlight.surroundingtext rangeOfString:_selectedStringNote];
            newSurrounding=noteOrHighlight.surroundingtext;
            if (range.location!=NSNotFound) {
                newCurrentOffset=[NSString stringWithFormat:@"%d",range.location ];
                NSInteger endTempOffset=newCurrentOffset.integerValue+_selectedStringNote.length;
                
                NSLog(@"surrounding text %@",newSurrounding);
                NSInteger startoldOffset=noteOrHighlight.srno.integerValue;
                NSInteger endOldOffset=noteOrHighlight.srno.integerValue+noteOrHighlight.text.length;
                BOOL val=endTempOffset<startoldOffset;
                
                val=val|(newCurrentOffset.integerValue>endOldOffset);
                if (!val) {
                    //    [_currentstartOffsetNote release];
                    _currentstartOffsetNote =[[NSString alloc ]initWithString:newCurrentOffset];
                    //  [_surroundingTextNote release];
                    _surroundingTextNote=[[NSString alloc]initWithString:newSurrounding];
                    break;
                }
                
                
                
            }
        }// this in case if notes or highlight already exist handle those distortion
        if (i==array.count) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Cannot" message:@"Cannot highlight more than one paragraph" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            //            [alert release];
            //            [array release];
            //            [_selectedStringNote release];
            //            [_startContainerNote release];
            //            [_endContainerNote release];
            //            [_surroundingTextNote release];
            //            [_currentstartOffsetNote release];
            //            [string release];
            return;
            
        }
        //   [array release];
    }
    NSUInteger currentendIndex=_currentstartOffsetNote.integerValue+_selectedStringNote.length;
    
    
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    //check for overlapps
    NSInteger bookId= [[NSUserDefaults standardUserDefaults]integerForKey:@"bookid"];
    
    NSArray *array=[delegate.dataModel getHighlightorNotes:bookId withPageNo:_chapter.chapterIndex withSurroundingString:_surroundingTextNote];
    array=[[NSArray alloc]initWithArray:array];
    if (array.count>0) {
        NSString *tempText;
        NSError *erro=nil;
        for (NoteHighlight *highlightOrNote in array) {
            NSInteger indexStart= highlightOrNote.srno.intValue;
            NSInteger indexEnd=highlightOrNote.text.length+indexStart;
            //currentstart---oldstart-----currentend<---->oldend
            if (_currentstartOffsetNote.intValue<indexStart&&currentendIndex<=indexEnd) {
                NSLog(@"\n\n\noldselection ----%@",highlightOrNote.text);
                NSLog(@"newselection ----%@",_selectedStringNote);
                tempText=[_selectedStringNote substringToIndex:(indexStart-_currentstartOffsetNote.intValue)];
                
                NSLog(@"\nfragment-----%@",tempText);
                tempText=[NSString stringWithFormat:@"%@%@",tempText,highlightOrNote.text];
                highlightOrNote.text=tempText;
                highlightOrNote.srno=@(_currentstartOffsetNote.intValue);
                if (highlightOrNote.highlight.boolValue==NO) {
                    highlightOrNote.note=[highlightOrNote.note stringByAppendingFormat:@"<div><br></div>%@",string];
                }else{
                    
                    highlightOrNote.note=string;
                    highlightOrNote.highlight=@NO;
                }
                highlightOrNote.left=@(_left);
                highlightOrNote.top=@(_top);
                if ([highlightOrNote hasChanges]) {
                    [delegate.dataModel.dataModelContext save:&erro];
                    if (erro) {
                        NSLog(@"%@",erro);
                    }
                }
                [self removeAllHighlight:nil];
                [self selection:nil];
                //                [array release];
                //                [_selectedStringNote release];
                //                [_startContainerNote release];
                //                [_endContainerNote release];
                //                [_surroundingTextNote release];
                //                [_currentstartOffsetNote release];
                //                [string release];
                return;
            }
            //oldstart<-->currentstart------oldend-----currentend
            else if (_currentstartOffsetNote.intValue>=indexStart&&indexEnd<currentendIndex){
                NSLog(@"\n\n\noldselection ----%@",highlightOrNote.text);
                NSLog(@"newselection ----%@",_selectedStringNote);
                //transform the older text
                tempText=[highlightOrNote.text substringToIndex:(_currentstartOffsetNote.intValue-indexStart)];
                
                NSLog(@"\nfragment-----%@",tempText);
                tempText=[NSString stringWithFormat:@"%@%@",tempText,_selectedStringNote];
                NSLog(@"actual new string %@",tempText);
                highlightOrNote.text=tempText;
                
                if (highlightOrNote.highlight.boolValue==NO) {
                    highlightOrNote.note=[highlightOrNote.note stringByAppendingFormat:@"<div><br></div>%@",string];
                }else{
                    highlightOrNote.note=string;
                    highlightOrNote.highlight=@NO;
                }
                highlightOrNote.left=@(_left);
                highlightOrNote.top=@(_top);
                if ([highlightOrNote hasChanges]) {
                    [delegate.dataModel.dataModelContext save:&erro];
                    if (erro) {
                        NSLog(@"%@",erro);
                    }
                }
                
                [self removeAllHighlight:nil];
                [self selection:nil];
                //                [array release];
                //                [_selectedStringNote release];
                //                [_startContainerNote release];
                //                [_endContainerNote release];
                //                [_surroundingTextNote release];
                //                [_currentstartOffsetNote release];
                //                [string release];
                return;
            }
            //oldstart---currentstart---currentend---oldend
            else if(indexStart>_currentstartOffsetNote.intValue&&currentendIndex<indexEnd){
                if (highlightOrNote.highlight.boolValue==NO) {
                    highlightOrNote.note=[highlightOrNote.note stringByAppendingFormat:@"<div><br></div>%@",string];
                }else{
                    highlightOrNote.note=string;
                    highlightOrNote.highlight=@NO;
                }
                highlightOrNote.left=@(_left);
                highlightOrNote.top=@(_top);
                if ([highlightOrNote hasChanges]) {
                    [delegate.dataModel.dataModelContext save:&erro];
                    if (erro) {
                        NSLog(@"%@",erro);
                    }
                }
                
                //                [_selectedStringNote release];
                //                [_startContainerNote release];
                //                [_endContainerNote release];
                //                [_surroundingTextNote release];
                //                [_currentstartOffsetNote release];
                //                [string release];
                //                [array release];
                return;
            }
            else if(_currentstartOffsetNote.intValue==indexStart&&currentendIndex==indexEnd){
                if (highlightOrNote.highlight.boolValue==NO) {
                    highlightOrNote.note=[highlightOrNote.note stringByAppendingFormat:@"<div><br></div>%@",string];
                }else{
                    highlightOrNote.note=string;
                    highlightOrNote.highlight=@NO;
                }
                highlightOrNote.left=@(_left);
                highlightOrNote.top=@(_top);
                if ([highlightOrNote hasChanges]) {
                    [delegate.dataModel.dataModelContext save:&erro];
                    if (erro) {
                        NSLog(@"%@",erro);
                    }
                }
                
                //                [_selectedStringNote release];
                //                [_startContainerNote release];
                //                [_endContainerNote release];
                //                [_surroundingTextNote release];
                //                [_currentstartOffsetNote release];
                //                [string release];
                //                [array release];
                return;
            }//currentstart---oldstart-----oldend--currentend
            else if(_currentstartOffsetNote.intValue<indexStart&&currentendIndex>indexEnd){
                highlightOrNote.text=_selectedStringNote;
                highlightOrNote.srno=@(_currentstartOffsetNote.intValue);
                if (highlightOrNote.highlight.boolValue==NO) {
                    highlightOrNote.note=[highlightOrNote.note stringByAppendingFormat:@"<div><br></div>%@",string];
                }else{
                    highlightOrNote.note=string;
                    highlightOrNote.highlight=@NO;
                }
                highlightOrNote.left=@(_left);
                highlightOrNote.top=@(_top);
                if ([highlightOrNote hasChanges]) {
                    [delegate.dataModel.dataModelContext save:&erro];
                    if (erro) {
                        NSLog(@"%@",erro);
                    }
                }
                [self removeAllHighlight:nil];
                [self selection:nil];
                //                [_selectedStringNote release];
                //                [_startContainerNote release];
                //                [_endContainerNote release];
                //                [_surroundingTextNote release];
                //                [_currentstartOffsetNote release];
                //                [string release];
                //                [array release];
                return;
            }
        }
        
    }
    NoteHighlight *noteHighlight=[NSEntityDescription insertNewObjectForEntityForName:@"NoteHighlight" inManagedObjectContext:delegate.managedObjectContext];
    noteHighlight.text=_selectedStringNote;
    noteHighlight.surroundingtext=_surroundingTextNote;
    noteHighlight.identity=[NSNumber numberWithInteger:[delegate.dataModel getCount]];// srno is startoffset
    NSLog(@"identity %@",noteHighlight.identity);
    noteHighlight.srno=@(_currentstartOffsetNote.integerValue);
    noteHighlight.bookid=@(bookId);
    NSInteger pageNumber=  _chapter.chapterIndex;
    noteHighlight.pageNo=@(pageNumber);
    noteHighlight.date_added=[NSDate date];
    noteHighlight.date_modified=[NSDate date];
    noteHighlight.highlight=@NO;
    noteHighlight.note=string;
    noteHighlight.left=@(_left);
    noteHighlight.top=@(_top);
    NSError *error;
    if (![delegate.managedObjectContext save:&error]) {
        NSLog(@"%@",error);
    }
    [self selection:nil];
    //    [array release];
    //    [_selectedStringNote release];
    //    [_startContainerNote release];
    //    [_endContainerNote release];
    //    [_surroundingTextNote release];
    //    [_currentstartOffsetNote release];
    //    [string release];
}
-(IBAction)notes:(id)sender{
    
    TextViewViewController *textViewController;
    NSString *temp=[_webView stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
    _selectedStringNote=[[NSString alloc]initWithString:temp];
    temp=[_webView stringByEvaluatingJavaScriptFromString:@"window.getSelection().baseNode.wholeText"];
    _startContainerNote=[[NSString alloc]initWithString:temp];
    //window.getSelection().getRangeAt(0).startContainer
    temp=[_webView stringByEvaluatingJavaScriptFromString:@"window.getSelection().extentNode.wholeText"];
    _endContainerNote=[[NSString alloc]initWithString:temp];
    temp=[_webView stringByEvaluatingJavaScriptFromString:@"window.getSelection().extentNode.wholeText"];
    _surroundingTextNote=[[NSString alloc]initWithString:temp];
    temp=[_webView stringByEvaluatingJavaScriptFromString:@"window.getSelection().getRangeAt(0).startOffset"];
    _currentstartOffsetNote=[[NSString alloc]initWithString:temp];
    if (_selectedStringNote.length==0) {
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        NSInteger bookId= [[NSUserDefaults standardUserDefaults]integerForKey:@"bookid"];
        NSArray *array= [delegate.dataModel getNoteOrHighlight:bookId withPageNo:_chapter.chapterIndex];
        //  [array retain];
        int i;
        NoteHighlight *notes=nil;
        for (i=0;i<array.count;i++) {
            notes=array[i];
            if (notes.text.length==0) {
                
                
                break;
            }
        }
        //        [array release];
        
        
        _frame=CGRectMake(30, 70, 100, 100);
        TextViewViewController *textViewController;
        
        if (notes==nil) {
            textViewController=    [[TextViewViewController alloc]initWithNibName:@"TextViewViewController" bundle: nil With:nil withUpdate:NO withInteger:[delegate.dataModel getCount]];
            
            textViewController.update=NO;
        }else{
            textViewController=    [[TextViewViewController alloc]initWithNibName:@"TextViewViewController" bundle: nil With:notes.note withUpdate:YES withInteger:notes.identity.integerValue];
            
        }
        
        textViewController.delegate=self;
        _pop=[[UIPopoverController alloc]initWithContentViewController:textViewController];
        //   [textViewController release];
        [_pop setPopoverContentSize:CGSizeMake(300.0f, 300.0f)];
        [_pop presentPopoverFromRect:_frame inView:self.webView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        return;
    }
    if(!CGRectIsEmpty(_frame))
    {
        
        
        textViewController=[[TextViewViewController alloc]initWithNibName:@"TextViewViewController" bundle: nil With:nil withUpdate:NO withInteger:0];
        textViewController.delegate=self;
        textViewController.update=NO;
        
        _pop=[[UIPopoverController alloc]initWithContentViewController:textViewController];
        //  [textViewController release];
        [_pop setPopoverContentSize:CGSizeMake(300.0f, 300.0f)];
        [_pop presentPopoverFromRect:_frame inView:self.webView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }    
    
}
- (void)viewDidUnload {
    [self setWebView:nil];
    [self setHideOrShow:nil];
    [self setTopView:nil];
    [self setSimpleView:nil];
    [self setHighlight:nil];
    [self setLeftSideView:nil];
    [self setNotesButton:nil];
    [self setShowNotesOrHighlight:nil];
    [self setHighlightAsNotes:nil];
    [self setHideTouchUpInsider:nil];
    [self setTocButton:nil];
    [self setSearchBar:nil];
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerDidShowMenuNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillShowMenuNotification
                                                  object:nil];
    
}
- (IBAction)removeAllHighlight:(id)sender {
    [_webView stringByEvaluatingJavaScriptFromString:@"uiWebview_RemoveAllHighlights()"];
    //  [_webView reload];
}
-(void)deleted:(NSInteger)page{
    //
    if (page==_chapter.chapterIndex) {
        [self.webView reload];
        _alertView =[[UIAlertView alloc]init];
        UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(139.0f-18.0f, 40.0f, 37.0f, 37.0f)];
        [indicator startAnimating];
        [_alertView addSubview:indicator];
        //        [indicator release];
        [_alertView setTitle:@"Deleting...."];
        [_alertView show];
    }
}
- (IBAction)selection:(id)sender {
    //[self removeAllHighlight:nil];
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[NoteButton class]]) {
            [view removeFromSuperview];
        }
    }
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSInteger bookId= [[NSUserDefaults standardUserDefaults]integerForKey:@"bookid"];
    NSInteger pageNumber=_chapter.chapterIndex;
    NSArray *array=[delegate.dataModel getNoteOrHighlight:bookId withPageNo:pageNumber];
    for (NoteHighlight *noteHighlight in array) {
        NSString *selectedText=noteHighlight.text;
        NSString *surroundingText=noteHighlight.surroundingtext;
        //        NSLog(@" selected string ---%@",selectedText);
        //        NSLog(@"outer text ----%@",surroundingText);
        //        NSLog(@"surrounding endindex %d",surroundingText.length);
        //        NSLog(@"selected endindex %d",selectedText.length);
        NSNumber *startOffset=noteHighlight.srno;
        NSString *before=[surroundingText substringToIndex:startOffset.integerValue];
        NSUInteger endIndex=startOffset.integerValue+selectedText.length;
        NSString *after=[surroundingText substringFromIndex:endIndex];
        
        if (noteHighlight.highlight.boolValue==YES) {
            NSString *newSurroundingText=[[NSString alloc]initWithFormat:@"%@<span xmlns=\"http://www.w3.org/1999/xhtml\" class=\"uiWebviewHighlight\" style=\"background-color: yellow; color: black; \">%@</span>%@",before,selectedText,after ];
            NSString *jsCode=[NSString stringWithFormat:@"document.body.innerHTML=document.body.innerHTML.replace('%@','%@')",surroundingText,newSurroundingText];
            [_webView stringByEvaluatingJavaScriptFromString:jsCode];
            //           [newSurroundingText release];
        }
        else{
            CGRect frame;
            NSInteger left;
            double top;
            if (selectedText.length!=0) {
                NSString *newSurroundingText=[[NSString alloc]initWithFormat:@"%@<span xmlns=\"http://www.w3.org/1999/xhtml\" class=\"uiWebviewHighlight\" style=\"background-color: red; color: black; \">%@</span>%@",before,selectedText,after ];
                NSString *jsCode=[NSString stringWithFormat:@"document.body.innerHTML=document.body.innerHTML.replace('%@','%@')",surroundingText,newSurroundingText];
                [_webView stringByEvaluatingJavaScriptFromString:jsCode];
                //           [newSurroundingText release];
                left=noteHighlight.left.integerValue;
                top=noteHighlight.top.doubleValue;
            }
            else{
                top=60;
                left=100;
            }
            
            
            NSLog(@"%@",noteHighlight.top);
            double newTop=top;
            if (_webView.frame.size.height!=1024) {
                newTop=top;
                newTop=newTop/1024;
                newTop=newTop*_webView.frame.size.height;
                
            }
            
            if (left>512) {
                left=1004;
            }else{
                left=20;
            }
            frame=CGRectMake(left, newTop, 16, 18);
            NoteButton *button=[[NoteButton alloc]initWithFrame:frame];
            NSLog(@"noteidentity %d",noteHighlight.identity.integerValue);
            button.tag=noteHighlight.identity.integerValue;
            UIImage *image=[UIImage imageNamed:@"not.png"];
            [button addTarget:self action:@selector(editNote:) forControlEvents:UIControlEventTouchUpInside];
            [button setImage:image forState:UIControlStateNormal];
            [self.view addSubview:button];
            [self.view bringSubviewToFront:button];
            //       [button release];
            
        }
        
    }
    
}
-(void)editNote:(id)sender{
    NoteButton *button=(NoteButton *)sender;
    NSLog(@"identity %d",button.tag);
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NoteHighlight *notOrHiglight=[delegate.dataModel getNoteOfIdentity:button.tag];
    NSLog(@"%@",notOrHiglight.text);
    
    TextViewViewController *textViewController=[[TextViewViewController alloc]initWithNibName:@"TextViewViewController" bundle:nil With:notOrHiglight.note withUpdate:YES withInteger:button.tag];
    textViewController.delegate=self;
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:textViewController];
    //   [textViewController release];
    _showNotes=[[UIPopoverController alloc]initWithContentViewController:nav];
    //   [nav release];
    [_showNotes setPopoverContentSize:CGSizeMake(300.0f, 300.0f)];
    [_showNotes presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    
    
}
- (IBAction)highlightfromButton:(id)sender {
    [self highlight:nil];
}
-(void)updateNotes:(NSString *)string withIdentity:(NSInteger)identity{
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NoteHighlight *notOrHiglight=[delegate.dataModel getNoteOfIdentity:identity];
    notOrHiglight.note=string;
    NSError *error;
    if ([notOrHiglight hasChanges]) {
        [delegate.dataModel.dataModelContext save:&error];
        if (error) {
            NSLog(@"%@",error);
        }
    }
    
}
- (IBAction)showList:(id)sender {
    UIButton *button=(UIButton *)sender;
    NSInteger bookId= [[NSUserDefaults standardUserDefaults]integerForKey:@"bookid"];
    NotesHighlightViewController *notesHighlight=[[NotesHighlightViewController alloc]initWithStyle:UITableViewStyleGrouped With:bookId withPageNo:_chapter.chapterIndex];
    LandscapeTextBookViewController *controller=(LandscapeTextBookViewController *)self.parentViewController.parentViewController;
    notesHighlight.delegate=controller;
    notesHighlight.delegateAction=self;
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:notesHighlight];
    //   [notesHighlight release];
    _listNotesHighlight=[[UIPopoverController alloc]initWithContentViewController:nav];
    //   [nav release];
    controller.pop=_listNotesHighlight;
    [_listNotesHighlight presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    
    
}
- (IBAction)tableOfContents:(id)sender {
    
    NSFileManager *manager=[NSFileManager defaultManager];
    LandscapeTextBookViewController *controller=(LandscapeTextBookViewController *)self.parentViewController.parentViewController;
    NSArray *files=[manager contentsOfDirectoryAtPath:controller.rootPath error:nil];
    files=[files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.ncx'"]];
    if (files.count!=0) {
        TableOfContentsHandler *handler=[[TableOfContentsHandler alloc]init];
        handler.delegate=self;
        NSString *loc=[files lastObject];
        loc=[controller.rootPath stringByAppendingPathComponent:loc];
        [handler allocate];
        [handler parseFileAt:loc];
    }
    
}
-(void)listOfTOC:(NSMutableArray *)array{
    TableOfContentsViewController *contentViewController=[[TableOfContentsViewController alloc]initWithStyle:UITableViewStyleGrouped array:array];

    LandscapeTextBookViewController *controller=(LandscapeTextBookViewController *)self.parentViewController.parentViewController;
    contentViewController.delegate=controller;
    _tableOfContentsPop=[[UIPopoverController alloc]initWithContentViewController:contentViewController];

    [_tableOfContentsPop presentPopoverFromRect:_tocButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

@end
