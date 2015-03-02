//
//  LevelViewController.m
//  MangoReader
//
//  Created by Harish on 1/26/15.
//
//

#import "LevelViewController.h"

@interface LevelViewController ()

@end

@implementation LevelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

+ (NSString *)getLevelFromAge :(NSString *)value{
    
    NSString *level;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"LevelAgeValue" ofType:@"plist"];
    NSArray *dict = [[NSArray alloc]
                          initWithContentsOfFile:path];
    
    for(NSDictionary *val in dict){
        if([[val objectForKey:@"Age"] isEqualToString:value])
            level = [val objectForKey:@"Level"];
    }
    
    if(!level){
        level = @"K";
    }
    
    return level;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
