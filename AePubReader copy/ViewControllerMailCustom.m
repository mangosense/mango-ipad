//
//  ViewControllerMailCustom.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 29/11/12.
//
//

#import "ViewControllerMailCustom.h"

@interface ViewControllerMailCustom ()

@end

@implementation ViewControllerMailCustom

- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskLandscape;
    
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
            (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}
- (BOOL)shouldAutorotate {
    
    return YES;
}

@end
