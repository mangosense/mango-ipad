//
//  MangoTextField.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 06/03/14.
//
//

#import "MangoTextField.h"
#import "Constants.h"


@implementation MangoTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        [self setEditable:NO];
        
        _highlightColor = [UIColor clearColor];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Highlighting Method

- (void)highlightWordAtIndex:(int)wordIndex AfterLength:(int)length {
    //self.scrollEnabled = YES;
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self.text];
     
    
    //NSLog(@"length %d", [string length]);

    NSMutableArray *words = [NSMutableArray arrayWithArray:[self.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];

    NSMutableArray *wordsToDelete = [NSMutableArray array];
    for (NSString *word in words) {
        if ([word length] == 0) {
            [wordsToDelete addObject:word];
        }
    }
    [words removeObjectsInArray:wordsToDelete];
    int cval = [wordsToDelete count]-1;
    if ([words count]) {
        //NSLog(@"Word index value as -- %d", wordIndex);
        NSString *word = [[words objectAtIndex:wordIndex] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSLog(@"check for end character %@",[word substringFromIndex: [word length] - 1]);
        
        NSRange range = [self.text rangeOfString:word options:NSLiteralSearch range:NSMakeRange(length, [self.text length] - length)];
        //NSRange range = [self.text rangeOfString:word options:NSBackwardsSearch range:NSMakeRange(0, length+cval+word.length)];
        
        [string addAttribute:NSBackgroundColorAttributeName value:_highlightColor range:range];
        
        _textRange = range;
        NSLog(@"range %i - %i", length, [self.text length] - length);
        //[self setContentOffset:CGPointMake(0, 100) animated:YES];
        
        //[self scrollRangeToVisible:_textRange];
       // [self performSelector:@selector(disableScroll) withObject:self afterDelay:0.05f];
        
        
        //[self scrollRangeToVisible:_textRange];
        //[self scrollRangeToVisible:_textRange];
        //self.contentSize = CGSizeZero;
        //[self setContentOffset:self.contentOffset animated:NO];
        
       // NSLog(@"current range location %d, location-- %i",[self visibleRangeOfTextView:self].location, range.location);
        //NSLog(@"visible range0 is %d -- %i",[self visibleRangeOfTextView:self].length,[self visibleRangeOfTextView:self].location);
        //NSLog(@"visible range1 is %d -- %i",range.length, range.location);
        //[self scrollRangeToVisible:NSMakeRange(length+10, 1)];
    /*    if(range.location > ([self visibleRangeOfTextView:self].length + [self visibleRangeOfTextView:self].location)*0.85){
         
            _textViewInsetValue = _textViewInsetValue+70;
            if(_textViewInsetValue > self.contentSize.height){
                //_textViewInsetValue = self.frame.size.height;
                //_textViewInsetValue = _textViewInsetValue;
            }
            NSLog(@"text inset value %d -- %f", _textViewInsetValue, self.frame.size.height);
            [self setContentInset:UIEdgeInsetsMake(-_textViewInsetValue, 0, 0, 0)];
        }*/
//        float rows = round( (self.contentSize.height - self.textContainerInset.top - self.textContainerInset.bottom) / self.font.lineHeight );
//        float rows1 = round( (self.frame.size.height - self.textContainerInset.top - self.textContainerInset.bottom) / self.font.lineHeight );
        //NSLog(@"original rows %f visible %f", rows, rows1);
        
        
       // if(((([self visibleRangeOfTextView:self].length)+([self visibleRangeOfTextView:self].location)) *.85) < range.location){
            

           // NSRange bottomRange = NSMakeRange(390, 1);
           // [self scrollRangeToVisible:bottomRange];
//            CGRect rect = CGRectMake(1, 590, self.frame.size.width, 590);
//            [self scrollRectToVisible:rect animated:YES];
//            [self setScrollEnabled:NO];
//            [self setScrollEnabled:YES];
           // [self scrollRectToVisible:rect animated:YES];
            /*int correctRow = rows * .70;
            if((_textViewInsetValue-currentScrolledHeight) < correctRow*70){
                
                 _textViewInsetValue = _textViewInsetValue + self.font.lineHeight;
                currentScrolledHeight+=self.font.lineHeight*2;
                [self setContentInset:UIEdgeInsetsMake( -_textViewInsetValue, 0.0, 0.0, 0.0)];
            }
            [self setContentInset:UIEdgeInsetsMake( -504, 0.0, 0.0, 0.0)];
            NSLog(@"Time to come down %d -- content height %d", _textViewInsetValue, range.location);*/
        //}
        
        UIFont *textFont = self.font;
        if (!textFont) {
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                
                textFont = [UIFont systemFontOfSize:15.0f];
            }
            else{
                textFont = [UIFont systemFontOfSize:25.0f];
            }
        }
        [string addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, [string length] - 1)];
        
        UIColor *textColor = self.textColor;
        
        if (!textColor) {
            textColor = [UIColor blackColor];
        }
        [string addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, [string length] - 1)];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init] ;
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        
        [string addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [string length])];
        //NSLog(@"Word index value as -- %d", wordIndex);
    }
    [self setAttributedText:string];
}

- (void) disableScroll {
    
    self.scrollEnabled = NO;
}

- (void) enableScroll {
    
    self.scrollEnabled = YES;
}

-(NSRange)visibleRangeOfTextView:(UITextView *)textView {
    CGRect bounds = textView.bounds;
    UITextPosition *start = [textView characterRangeAtPoint:bounds.origin].start;
    UITextPosition *end = [textView characterRangeAtPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds))].end;
    return NSMakeRange([textView offsetFromPosition:textView.beginningOfDocument toPosition:start],
                       [textView offsetFromPosition:start toPosition:end]);
}

@end
