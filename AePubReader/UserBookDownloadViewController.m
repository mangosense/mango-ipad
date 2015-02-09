//
//  UserBookDownloadViewController.m
//  MangoReader
//
//  Created by Harish on 1/24/15.
//
//

#import "UserBookDownloadViewController.h"
#import "AePubReaderAppDelegate.h"

@interface UserBookDownloadViewController ()

@end

@implementation UserBookDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

+ (NSArray *) returnAllAvailableLevels{
    
    NSMutableArray *booksArray = [[NSMutableArray alloc] init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"levelInfoMod" ofType:@"json"];
    NSString *myJSON = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    NSError *error =  nil;
    booksArray = [NSJSONSerialization JSONObjectWithData:[myJSON dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    NSMutableArray *levelsArray=[[NSMutableArray alloc]init];
    for(NSDictionary *element in booksArray){
        if(![levelsArray count]){
            [levelsArray addObject:[element objectForKey:@"level"]];
        }
        else{
            if(![levelsArray containsObject:[element objectForKey:@"level"]]){
                [levelsArray addObject:[element objectForKey:@"level"]];
            }
        }
    }
    return levelsArray;
}

- (void) returnArrayElementa{
    
    NSMutableArray *booksArray = [[NSMutableArray alloc] init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"levelInfoMod" ofType:@"json"];
    NSString *myJSON = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    NSError *error =  nil;
    booksArray = [NSJSONSerialization JSONObjectWithData:[myJSON dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];

    [_delegate getJsonIntoArray:booksArray];
}

- (void) downloadBook :(NSString *)bookId{
    
    //check if books are already available .....
    
    AePubReaderAppDelegate *appDelegate = (AePubReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    Book *bk=[appDelegate.dataModel getBookOfEJDBId:bookId];
    
    //int isDownloaded = [bk.downloaded integerValue];
    
    if(bk.localPathFile){
        [_delegate finishBookDownlaod];
    }
    
    else{
        MangoApiController *apiController = [MangoApiController sharedApiController];
        [apiController downloadBookWithId:bookId withDelegate:self ForTransaction:nil];
    }
    
}

- (void)updateBookProgress:(int)progress {
    if(progress <0){
        progress = 0;
    }
    NSLog(@"progress %d",progress);
}

- (void)bookDownloaded:(NSString *)bookId {
    
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Complete" message:@"Your book is downloaded, go to my stories view" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    //[alert show];
    [_delegate finishBookDownlaod];
}

- (void) bookDownloadAborted:(NSString *)bookId{
    
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
