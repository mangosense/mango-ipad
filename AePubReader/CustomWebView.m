//
//  CustomWebView.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 09/01/13.
//
//

#import "CustomWebView.h"

@implementation CustomWebView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
   
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    UIMenuController *menuController=[UIMenuController sharedMenuController];
    UIMenuItem *itemHightlight=[[UIMenuItem alloc]initWithTitle:@"Highlight" action:@selector(highlight:)];
    UIMenuItem *itemNotes=[[UIMenuItem alloc]initWithTitle:@"Notes" action:@selector(notes:)];
    NSArray *array=@[itemHightlight,itemNotes];
    menuController.menuItems=array;
   // [itemHightlight release];
   // [itemNotes release];
    [menuController setMenuVisible:YES];
}
-(void)highlight:(id)sender{
    
  
    
}
-(void)notes:(id)sender{
    
}
@end
