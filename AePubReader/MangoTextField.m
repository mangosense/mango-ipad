//
//  MangoTextField.m
//  MangoReader
//
//  Created by Kedar Kulkarni on 06/03/14.
//
//

#import "MangoTextField.h"
#import "Constants.h"
static int lastlinepos=0;
@implementation MangoTextField
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        [self setEditable:NO];
        _highlightColor = [UIColor yellowColor];
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
    float rows = round( (self.contentSize.height - self.textContainerInset.top - self.textContainerInset.bottom) / self.font.lineHeight );
    int lastVisibleLine = round( (self.frame.size.height - self.textContainerInset.top - self.textContainerInset.bottom) / self.font.lineHeight );
    if (lastlinepos==0)
        lastlinepos = lastVisibleLine;
        
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
    
    if ([words count]) {
        //NSLog(@"Word index value as -- %d", wordIndex);
        NSString *word = [[words objectAtIndex:wordIndex] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSRange range = [self.text rangeOfString:word options:NSLiteralSearch range:NSMakeRange(length, [self.text length] - length)];
        [string addAttribute:NSBackgroundColorAttributeName value:_highlightColor range:range];
        
        //newRange = [self visibleRangeOfTextView:self];

        if (lastVisibleLine != lastlinepos){
            [self scrollRangeToVisible: NSMakeRange(0,range.location)];
            lastlinepos=lastVisibleLine;
        }
        self.scrollEnabled = NO;
        self.scrollEnabled = YES;
        NSLog(@"current range location %d, location-- %i",[self visibleRangeOfTextView:self].location, range.location);
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
        //float rows = round( (self.contentSize.height - self.textContainerInset.top - self.textContainerInset.bottom) / self.font.lineHeight );
        //float rows1 = round( (self.frame.size.height - self.textContainerInset.top - self.textContainerInset.bottom) / self.font.lineHeight );
        //NSLog(@"original rows %f visible %f", rows, rows1);
        
        /*if(((([self visibleRangeOfTextView:self].length)+([self visibleRangeOfTextView:self].location)) *.85) < range.location){
            
            _textViewInsetValue = _textViewInsetValue + 70;
            if((_textViewInsetValue +70) < 590){
            [self setContentInset:UIEdgeInsetsMake( -_textViewInsetValue, 0.0, 0.0, 0.0)];
            }
            NSLog(@"Time to come down %d -- content height %d", _textViewInsetValue, range.location);
        }*/
        
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


-(NSRange)visibleRangeOfTextView:(UITextView *)textView {
    CGRect bounds = textView.bounds;
    UITextPosition *start = [textView characterRangeAtPoint:bounds.origin].start;
    UITextPosition *end = [textView characterRangeAtPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds))].end;
    return NSMakeRange([textView offsetFromPosition:textView.beginningOfDocument toPosition:start],
                       [textView offsetFromPosition:start toPosition:end]);
}

@end
