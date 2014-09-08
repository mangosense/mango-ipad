//
//  UINavigationController+KeyboardDismiss.h
//  comparestructuredproducts
//
//  Created by Paul Morris on 31/07/2013.
//  Copyright (c) 2013 Little Red Door Ltd. All rights reserved.
//

/******
 This is a little category to allow the iPad keyboard to dismiss
 when presenting a view controller modally with type UIModalPresentationFormSheet
 within a navigation controller. Apple's intended behaviour means that the
 keyboard can occassionally remain on screen even if there is no first
 responder.
 *******/

#import <UIKit/UIKit.h>

@interface UINavigationController (KeyboardDismiss)

- (BOOL)disablesAutomaticKeyboardDismissal;

@end
