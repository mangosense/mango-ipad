//
//  CoverViewControllerBetterBookType.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 21/11/13.
//
//

#import "CoverViewControllerBetterBookType.h"
#import "LanguageChoiceViewController.h"
#import "AePubReaderAppDelegate.h"
#import "DataModelControl.h"
#import "PageNewBookTypeViewController.h"
#import "MangoEditorViewController.h"
#import "MangoGamesListViewController.h"

@interface CoverViewControllerBetterBookType ()

@end

@implementation CoverViewControllerBetterBookType

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil WithId:(NSString *)identity
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _identity=identity;
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
       _book= [delegate.dataModel getBookOfId:identity];
        NSLog(@"%@",_book.edited);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _titleLabel.text=_book.title;
    NSString *jsonLocation=_book.localPathFile;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
    NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
    jsonLocation=     [jsonLocation stringByAppendingPathComponent:[onlyJson firstObject]];
  //  NSLog(@"json location %@",jsonLocation);
    NSString *jsonContents=[[NSString alloc]initWithContentsOfFile:jsonLocation encoding:NSUTF8StringEncoding error:nil];
  //  NSLog(@"json contents %@",jsonContents);
    UIImage *image=[MangoEditorViewController coverPageImageForStory:jsonContents WithFolderLocation:_book.localPathFile];

    _coverImageView.image=image;
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)multipleLanguage:(id)sender {
    UIButton *button=(UIButton *)sender;
    LanguageChoiceViewController *choiceViewController=[[LanguageChoiceViewController alloc]initWithStyle:UITableViewStyleGrouped];
    choiceViewController.delegate=self;
    _popOverController=[[UIPopoverController alloc]initWithContentViewController:choiceViewController];
    CGSize size=_popOverController.popoverContentSize;
    size.height=size.height-300;
    _popOverController.popoverContentSize=size;

    NSString *jsonLocation=_book.localPathFile;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
    NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
    jsonLocation=     [jsonLocation stringByAppendingPathComponent:[onlyJson firstObject]];
    //  NSLog(@"json location %@",jsonLocation);
    NSString *jsonContent=[[NSString alloc]initWithContentsOfFile:jsonLocation encoding:NSUTF8StringEncoding error:nil];
    
    NSData *jsonData = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    choiceViewController.array = [jsonDict objectForKey:@"available_languages"];
    choiceViewController.bookDict = jsonDict;
    
    [_popOverController presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)optionsToReader:(id)sender {
    UIButton *button=(UIButton *)sender;
    PageNewBookTypeViewController *controller=[[PageNewBookTypeViewController alloc]initWithNibName:@"PageNewBookTypeViewController" bundle:nil WithOption:button.tag BookId:_identity];
      
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)libraryButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void) dismissPopOver{
    [_popOverController dismissPopoverAnimated:YES];
}

- (NSString *)getJsonContentForBook {
    NSString *jsonLocation=_book.localPathFile;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:jsonLocation error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
    NSArray *onlyJson = [dirContents filteredArrayUsingPredicate:fltr];
    jsonLocation=     [jsonLocation stringByAppendingPathComponent:[onlyJson firstObject]];
    //  NSLog(@"json location %@",jsonLocation);
    NSString *jsonContent=[[NSString alloc]initWithContentsOfFile:jsonLocation encoding:NSUTF8StringEncoding error:nil];
    return jsonContent;
}

- (void)showOrHideGameButton {
    NSDictionary *jsonDict = [self getJsonDictForBook];
    if ([[jsonDict objectForKey:NUMBER_OF_GAMES] intValue] == 0) {
        _games.hidden = YES;
    } else {
        _games.hidden = NO;
    }
}

- (NSDictionary *)getJsonDictForBook {
    NSString *jsonContent = [self getJsonContentForBook];
    NSData *jsonData = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
    NSLog(@"%@", jsonDict);
    return jsonDict;
}

- (IBAction)gameButtonTapped:(id)sender {
    NSDictionary *jsonDict = [self getJsonDictForBook];
    if ([[jsonDict objectForKey:NUMBER_OF_GAMES] intValue] == 0) {
        UIAlertView *noGamesAlert = [[UIAlertView alloc] initWithTitle:@"No Games" message:@"Sorry, this story does not have any games in it." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [noGamesAlert show];
    } else {
        MangoGamesListViewController *gamesListViewController = [[MangoGamesListViewController alloc] initWithNibName:@"MangoGamesListViewController" bundle:nil];
        gamesListViewController.jsonString = [self getJsonContentForBook];
        gamesListViewController.folderLocation = _book.localPathFile;
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

@end
