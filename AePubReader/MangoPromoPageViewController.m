//
//  MangoPromoPageViewController.m
//  MangoReader
//
//  Created by Harish on 4/21/14.
//
//

#import "MangoPromoPageViewController.h"
#import "CoverViewControllerBetterBookType.h"
#import "MangoPromoTableViewCell.h"

@interface MangoPromoPageViewController ()

@end

@implementation MangoPromoPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
	return 5;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CustomCellIdentifier = @"CustomCellIdentifier";
	MangoPromoTableViewCell *cell = (MangoPromoTableViewCell *)[tableView
                                                dequeueReusableCellWithIdentifier: CustomCellIdentifier];
    if (cell == nil) {
        
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MangoPromoTableViewCell" owner:self options:nil];
		for (id oneObject in nib)
			if ([oneObject isKindOfClass:[MangoPromoTableViewCell class]])
				cell = (MangoPromoTableViewCell *)oneObject;
        
    }
    
    return cell;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backToBookCoverView:(id)sender{
    
     [self dismissViewControllerAnimated:YES completion:nil];
}

@end
