//
//  ColoringToolsViewController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 06/12/13.
//
//

#import <UIKit/UIKit.h>
#import "DrawingToolsView.h"

@interface ColoringToolsViewController : UIViewController{
    
    NSString *userEmail;
    NSString *userDeviceID;
    NSString *ID;
}

@property (nonatomic, strong) NSString *bookId;
@property (nonatomic, assign) id <DrawingToolsDelegate> delegate;
- (IBAction)colorButtonTapped:(id)sender;
- (IBAction)sliderValueChanged:(id)sender;

@end
