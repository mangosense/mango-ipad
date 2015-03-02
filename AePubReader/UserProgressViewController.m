//
//  UserProgressViewController.m
//  MangoReader
//
//  Created by Harish on 1/22/15.
//
//

#import "UserProgressViewController.h"
#import "AePubReaderAppDelegate.h"
#import "UserBookDownloadViewController.h"
#import "LevelViewController.h"
#import "ReadBook.h"

@interface UserProgressViewController ()

@end

@implementation UserProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
   //[self plotGaph];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    //NSArray *allLevelValue = [UserBookDownloadViewController returnAllAvailableLevels];
    //NSArray *userAgeObjects = [appDelegate.ejdbController getAllUserAgeValue];
//    NSString *baseLevel = [LevelViewController getLevelFromAge:appDelegate.userInfoAge.userAgeValue];
//    NSString *currentLevel = [prefs valueForKey:@"CURRENTUSERLEVEL"];
//    int startLevelIndex = [allLevelValue indexOfObject:baseLevel];
//    int toLevelIndex = [allLevelValue indexOfObject:currentLevel];
//    if(!(startLevelIndex == toLevelIndex)){
//        
//        for (int i = startLevelIndex; i <= toLevelIndex; ++i){
//            
//            
//        }
//        
//    }
    //get current level B and base A, find all elements in that gap ...
   // NSArray *result =[appDelegate.dataModel getAllUserReadBooks:currentLevel];
    
    _baseLevellabel.text =  [LevelViewController getLevelFromAge:appDelegate.userInfoAge.userAgeValue];
    _currentLevellabel.text = [prefs valueForKey:@"CURRENTUSERLEVEL"];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ReadBook" inManagedObjectContext:appDelegate.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSError *error;
    NSArray *array = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    ReadBook *readBook;
    int totalPoints = 0;
    for(ReadBook *info in array){
        readBook = info;
        totalPoints = totalPoints + [readBook.bookPoints intValue];
    }
    float ratingValue = totalPoints/100;
    _totalRatevalue.text = [NSString stringWithFormat:@"%d", totalPoints/100];
    _totalPoints.text = [NSString stringWithFormat:@"%d",totalPoints];
    
    //ReadBook *readBook = [array objectAtIndex:0];
    
    NSLog(@"Array: %@ ", array);
}


/*-(void)plotGaph
{
    
    // Create barChart from theme
    barChart = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [barChart applyTheme:theme];
    CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.view;
    hostingView.hostedGraph = barChart;
    
    // Border
    barChart.plotAreaFrame.borderLineStyle = nil;
    barChart.plotAreaFrame.cornerRadius    = 0.0f;
    
    // Paddings
    barChart.paddingLeft   = 0.0f;
    barChart.paddingRight  = 0.0f;
    barChart.paddingTop    = 0.0f;
    barChart.paddingBottom = 0.0f;
    
    barChart.plotAreaFrame.paddingLeft   = 70.0;
    barChart.plotAreaFrame.paddingTop    = 20.0;
    barChart.plotAreaFrame.paddingRight  = 20.0;
    barChart.plotAreaFrame.paddingBottom = 80.0;
    
    // Graph title
    barChart.title = @"Component Vs Percentage Plot";
    CPTMutableTextStyle *textStyle = [CPTTextStyle textStyle];
    textStyle.color                   = [CPTColor whiteColor];
    textStyle.fontSize                = 16.0f;
    textStyle.textAlignment           = CPTTextAlignmentCenter;
    barChart.titleTextStyle           = textStyle;
    barChart.titleDisplacement        = CGPointMake(0.0f, -20.0f);
    barChart.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    
    float val = _arrayLevel.count;
    NSLog(@"ary pcnt count %f", val);
    if(_arrayLevel.count < 4){
        val = 4.0;
    }
    
    // Add plot space for horizontal bar charts
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)barChart.defaultPlotSpace;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(120.0f)];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-0.10f) length:CPTDecimalFromFloat(val)];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)barChart.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.axisLineStyle               = nil;
    x.majorTickLineStyle          = nil;
    x.minorTickLineStyle          = nil;
    x.majorIntervalLength         = CPTDecimalFromString(@"25");
    x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    x.title                       = @"Component ->";
    x.titleLocation               = CPTDecimalFromFloat(val/2);
    x.titleOffset                 = 55.0f;
    
    // Define some custom labels for the data elements
    x.labelRotation  = M_PI / 4;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    
    NSMutableArray *customTickLocations = [[NSMutableArray alloc]init];
    
    for(int i =0; i< _arrayLevel.count; ++i){
        
        [customTickLocations addObject:[NSDecimalNumber numberWithInt:i]];
    }
    
    
    NSArray *xAxisLabels         = [NSArray arrayWithArray:_arrayComponent];
    NSUInteger labelLocation     = 0;
    NSMutableArray *customLabels = [NSMutableArray arrayWithCapacity:[xAxisLabels count]];
    CPTMutableTextStyle *style = [CPTMutableTextStyle textStyle];
    style.color = [[CPTColor whiteColor] colorWithAlphaComponent:1];
    style.fontName = @"Helvetica";
    style.fontSize = 12.0f;
    for ( NSNumber *tickLocation in customTickLocations ) {
        
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:[xAxisLabels objectAtIndex:labelLocation++] textStyle:style];
        newLabel.tickLocation = [tickLocation decimalValue];
        newLabel.offset       = x.labelOffset + x.majorTickLength;
        newLabel.rotation     = M_PI / 4;
        [customLabels addObject:newLabel];
    }
    
    x.axisLabels = [NSSet setWithArray:customLabels];
    
    CPTXYAxis *y = axisSet.yAxis;
    y.axisLineStyle               = nil;
    y.majorTickLineStyle          = nil;
    y.minorTickLineStyle          = nil;
    y.majorIntervalLength         = CPTDecimalFromString(@"25");
    y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"-.01");
    y.title                       = @"Percentage (%) ->";
    y.titleOffset                 = 45.0f;
    y.titleLocation               = CPTDecimalFromFloat(50.0f);
    
    
    // First bar plot
    CPTBarPlot *barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor redColor] horizontalBars:NO];
    barPlot.baseValue  = CPTDecimalFromString(@"0");
    
    barPlot.dataSource = self;
    barPlot.barOffset  = CPTDecimalFromFloat(0.25f);
    barPlot.identifier = @"Bar Plot 1";
    // barPlot.barWidth = CPTDecimalFromFloat(0.5f);
    [barChart addPlot:barPlot toPlotSpace:plotSpace];
    
}


-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return _arrayLevel.count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSDecimalNumber *num = nil;
    
    if ( [plot isKindOfClass:[CPTBarPlot class]] ) {
        switch ( fieldEnum ) {
            case CPTBarPlotFieldBarLocation:
                num = (NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInteger:index];
                break;
                
            case CPTBarPlotFieldBarTip:
                
                num = (NSDecimalNumber *)[NSDecimalNumber numberWithInteger:[[_arrayLevel objectAtIndex:index] integerValue]];
                
                break;
        }
    }
    
    return num;
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) backToHomePage:(id)sender{
    
    //[self.tabBarController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
