//
//  FinishReadingViewController.m
//  MangoReader
//
//  Created by Harish on 1/15/15.
//
//

#import "FinishReadingViewController.h"
#import "AePubReaderAppDelegate.h"
#import "MangoGamesListViewController.h"
#import "HomePageViewController.h"
#import "PageNewBookTypeViewController.h"

@interface FinishReadingViewController ()

@end

@implementation FinishReadingViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withId :(NSString*)identity{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        _identity=identity;
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        _book= [delegate.dataModel getBookOfId:identity];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*if([_totalTime integerValue] > 60){
        int minutes = floor([_totalTime integerValue]/60);
        int seconds = round([_totalTime integerValue] - minutes * 60);
        _timeTakenValue.text = [NSString stringWithFormat:@"Welldone! you have completed the book in %d min and %d sec",minutes, seconds];
    }
    else{
        int seconds = [_totalTime integerValue];
        _timeTakenValue.text = [NSString stringWithFormat:@"Welldone! you have completed the book in %d sec", seconds];
    }*/
    _timeTakenValue.text = @"to be obtained";
    
    // Do any additional setup after loading the view from its nib.
}

- (IBAction) startReadingNewbook:(id)sender{
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"levelInfoMod" ofType:@"json"];
    NSString *myJSON = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    NSError *error =  nil;
    NSArray* allDisplayBooks = [NSJSONSerialization JSONObjectWithData:[myJSON dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int indexVal = [[prefs valueForKey:@"BOOKINDEX"]integerValue];
    if(indexVal+1 >= allDisplayBooks.count){
        indexVal = 0;
    }
    else{
        indexVal++;
    }
    [self readyBookToOpen:[[allDisplayBooks objectAtIndex:indexVal] valueForKey:@"id"]];
}

- (IBAction)readyBookToOpen:(NSString *)bookId{
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    Book *bk=[appDelegate.dataModel getBookOfEJDBId:bookId];
    
    //if (_delegate && [_delegate respondsToSelector:@selector(openBook:)]) {
    [self openBook:bk];
    //}
}

- (void)openBook:(Book *)bk {
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *identity=[NSString stringWithFormat:@"%@", bk.id];
    [appDelegate.dataModel displayAllData];
    
    PageNewBookTypeViewController *controller;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        controller=[[PageNewBookTypeViewController alloc]initWithNibName:@"PageNewBookTypeViewController_iPhone" bundle:nil WithOption:nil BookId:bk.id];
        
    }
    else{
        controller=[[PageNewBookTypeViewController alloc]initWithNibName:@"PageNewBookTypeViewController" bundle:nil WithOption:nil BookId:bk.id];
    }
    
    [self.navigationController pushViewController:controller animated:NO];
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

- (IBAction)dismissToHomePage:(id)sender{
    
        for(UIViewController *controller in self.navigationController.viewControllers){
    
            if([controller isKindOfClass:[HomePageViewController class]]){
    
                [self.navigationController popToViewController:controller animated:YES];
                break;
            }
        }
}



@end
