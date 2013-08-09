//
//  EditorViewController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 08/08/13.
//
//

#import <UIKit/UIKit.h>
#import "MovableTextView.h"

@interface EditorViewController : UIViewController {
    
}

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) MovableTextView *mainTextView;
@property (nonatomic, strong) IBOutlet UIScrollView *pageScrollView;

@end
