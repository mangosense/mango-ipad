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
        NSString *word = [[words objectAtIndex:wordIndex] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSRange range = [self.text rangeOfString:word options:NSLiteralSearch range:NSMakeRange(length, [self.text length] - length)];
        [string addAttribute:NSBackgroundColorAttributeName value:_highlightColor range:range];
        
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
    }
    [self setAttributedText:string];
}

@end
