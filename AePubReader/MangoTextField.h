//
//  MangoTextField.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 06/03/14.
//
//

#import <UIKit/UIKit.h>

@interface MangoTextField : UITextView

@property (nonatomic, strong) UIColor *highlightColor;

- (void)highlightWordAtIndex:(int)wordIndex AfterLength:(int)length;

@end
