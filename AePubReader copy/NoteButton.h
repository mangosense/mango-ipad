//
//  NoteButton.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 24/01/13.
//
//

#import <UIKit/UIKit.h>

@interface NoteButton : UIButton


@property(assign,nonatomic)NSInteger pageNo;
@property(assign,nonatomic)NSInteger bookId;
@property(retain,nonatomic)NSString *selectedText;
@property(retain,nonatomic)NSString *note;
@property(retain,nonatomic)NSString *surroundingtext;
- (id)initWithFrame:(CGRect)frame;
@end
