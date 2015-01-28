//
//  AgeDetailsViewController.h
//  MangoReader
//
//  Created by Harish on 1/13/15.
//
//

#import <UIKit/UIKit.h>
#import "AePubReaderAppDelegate.h"

@interface AgeDetailsViewController : UIViewController{
    
}


@property (nonatomic, strong) IBOutlet UILabel *ageLabelValue;

- (IBAction) addAgeValue:(id)sender;

- (IBAction) moveToGameScreen:(id)sender;


- (IBAction)storeView:(id)sender;

@end
