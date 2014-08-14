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
@property (nonatomic, assign) int textViewInsetValue;
@property (nonatomic, assign) NSRange textRange;

- (void)highlightWordAtIndex:(int)wordIndex AfterLength:(int)length;

@end
