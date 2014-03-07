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
        [self setUserInteractionEnabled:NO];
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
    
    NSArray *words = [self.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *word = [[words objectAtIndex:wordIndex] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSRange range = [self.text rangeOfString:word options:NSLiteralSearch range:NSMakeRange(length, [self.text length] - length)];
    [string addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:range];
    [string addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, [string length] - 1)];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init] ;
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [string addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [string length] - 1)];

    [self setAttributedText:string];
}

@end
