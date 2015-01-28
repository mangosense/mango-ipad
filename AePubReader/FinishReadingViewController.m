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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openNewBook) name:@"ReadNewBook" object:nil];
    if([_totalTime integerValue] > 60){
        int minutes = floor([_totalTime integerValue]/60);
        int seconds = round([_totalTime integerValue] - minutes * 60);
        _timeTakenValue.text = [NSString stringWithFormat:@"Welldone! you have completed the book in %d min and %d sec",minutes, seconds];
    }
    else{
        int seconds = [_totalTime integerValue];
        _timeTakenValue.text = [NSString stringWithFormat:@"Welldone! you have completed the book in %d sec", seconds];
    }
    
    // Do any additional setup after loading the view from its nib.
}

- (void) openNewBook{
    
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

- (void) viewDidAppear:(BOOL)animated{

//    HomePageViewController *moveToHomePageView;
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        
//        moveToHomePageView = [[HomePageViewController alloc] initWithNibName:@"HomePageViewController_iPhone" bundle:nil];
//    }
//    else{
//        moveToHomePageView = [[HomePageViewController alloc] initWithNibName:@"HomePageViewController" bundle:nil];
//    }
//    [self.navigationController popToViewController:moveToHomePageView animated:NO];
    
    
    
    
//    for(UIViewController *controller in self.navigationController.viewControllers){
//        
//        if([controller isKindOfClass:[HomePageViewController class]]){
//            
//            [self.navigationController popToViewController:controller animated:YES];
//            break;
//        }
//    }

}


- (IBAction)gameButtonTapped:(id)sender {
    
   
    
    NSDictionary *jsonDict = [self getJsonDictForBook];
    if ([[jsonDict objectForKey:NUMBER_OF_GAMES] intValue] == 0) {
        UIAlertView *noGamesAlert = [[UIAlertView alloc] initWithTitle:@"No Games" message:@"Sorry, this story does not have any games in it." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [noGamesAlert show];
    } else {
        
        MangoGamesListViewController *gamesListViewController;
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            gamesListViewController = [[MangoGamesListViewController alloc] initWithNibName:@"MangoGamesListViewController_iPhone" bundle:nil];
        }
        else{
            gamesListViewController = [[MangoGamesListViewController alloc] initWithNibName:@"MangoGamesListViewController" bundle:nil];
        }
        gamesListViewController.currentBookId = _book.id;
        gamesListViewController.currentBookTitle = _book.title;
        gamesListViewController.jsonString = [self getJsonContentForBook];
        
        NSString *jsonLocation = [AePubReaderAppDelegate returnBookJsonPath:_book];
        
        
        gamesListViewController.folderLocation = jsonLocation;
        NSMutableArray *gameNames = [[NSMutableArray alloc] init];
        for (NSDictionary *pageDict in [jsonDict objectForKey:PAGES]) {
            if ([[pageDict objectForKey:TYPE] isEqualToString:GAME]) {
                [gameNames addObject:[pageDict objectForKey:NAME]];
            }
        }
        gamesListViewController.gameNames = gameNames;
        
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:gamesListViewController];
        [navController.navigationBar setHidden:YES];
        
        [self.navigationController presentViewController:navController animated:YES completion:^{
            
        }];
    }
    
}

- (NSDictionary *)getJsonDictForBook {
    NSString *jsonContent = [self getJsonContentForBook];
    NSData *jsonData = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    
    return jsonDict;
}

- (NSString *)getJsonContentForBook {
    
    NSString *jsonLocation = [AePubReaderAppDelegate returnBookJsonPath:_book];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
    NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
    jsonLocation=     [jsonLocation stringByAppendingPathComponent:[onlyJson firstObject]];
    NSString *jsonContent=[[NSString alloc]initWithContentsOfFile:jsonLocation encoding:NSUTF8StringEncoding error:nil];
    return jsonContent;
}

@end
