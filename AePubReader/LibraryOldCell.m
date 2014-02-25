//
//  LibraryOldCell.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 01/08/13.
//
//

#import "LibraryOldCell.h"

@implementation LibraryOldCell
-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.button=[ShadowButton buttonWithType:UIButtonTypeCustom];
        self.button.frame=CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
        UIImage *image=[UIImage imageNamed:@"actions.png"];
        self.shareButton=[[ShareButton alloc]init];
        
        
        self.shareButton.frame=CGRectMake(40, 70, 72, 72);
        [self.shareButton setImage:image forState:UIControlStateNormal];
        [self.shareButton setHidden:YES];
        self.showRecording=[[UIButton alloc]initWithFrame:CGRectMake(40, 70, 66, 66)];
        image=[UIImage imageNamed:@"record-control.png"];
        [self.showRecording setImage:image forState:UIControlStateNormal];
        [self.showRecording setHidden:YES];
        // self.showRecording.tag=[book.id integerValue];
        
        
        [self.contentView addSubview:self.button];
        [self.contentView addSubview:self.shareButton];
        [self.contentView addSubview:self.showRecording];
        self.buttonDelete=[[UIButton alloc]init];
        self.buttonDelete.frame=CGRectMake(-10, -10, 48, 48);
        self.buttonDelete.hidden=YES;
        
        [self.buttonDelete setImage:[UIImage imageNamed:@"closebutton.png"] forState:UIControlStateNormal];
        [self.contentView addSubview:self.buttonDelete];

    }
    return self;
}
@end
