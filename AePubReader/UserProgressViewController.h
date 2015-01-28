//
//  UserProgressViewController.h
//  MangoReader
//
//  Created by Harish on 1/22/15.
//
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface UserProgressViewController : UIViewController<CPTPlotDataSource>{
    
    CPTXYGraph *barChart;
}

//@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) NSArray *dataArray;
@property (nonatomic, retain) NSMutableArray *arrayComponent;
@property (nonatomic, retain) NSMutableArray *arrayLevel;


-(void)plotGaph;

- (IBAction) backToHomePage:(id)sender;

@end
