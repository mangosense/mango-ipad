//
//  MyBooksViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 03/12/12.
//
//

#import "MyBooksViewController.h"
#import "EpubReaderViewController.h"
#import "BookDownloaderIphone.h"
#import <Foundation/Foundation.h>
#import "ViewController.h"
@interface MyBooksViewController ()

@end

@implementation MyBooksViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.tabBarItem.title=@"My Books";
        self.tabBarItem.image=[UIImage imageNamed:@"library.png"];
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        NSArray *temp=[delegate.dataModel getDataDownloaded];
        _array=[[NSMutableArray alloc]initWithArray:temp];
        _downloadBook=NO;
        _deleted=NO;
        _bookOpen=NO;
    }
    return self;
}
-(void)downloadComplete:(NSInteger)index{
    _downloadBook=YES;
    
    _progress=[[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
    CGRect rect=CGRectMake(170, 150, 250, 12);
    _progress.frame=rect;
      [self.tabBarController setSelectedIndex:0];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSArray *temp=[delegate.dataModel getDataDownloaded];
   // [_array release];
    _array=[[NSMutableArray alloc]initWithArray:temp];
    [self.tableView reloadData];
    BookDownloaderIphone *bookDownload=[[BookDownloaderIphone alloc]initWithViewController:self];
   
    NSString *string=[[NSString alloc]initWithFormat:@"%d",index ];
    Book *book=[delegate.dataModel getBookOfId:string];
    bookDownload.book=book;
   // [string release];
     string=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *lastComp=[NSString stringWithFormat:@"%@.epub",book.id];
    string=[string stringByAppendingPathComponent:lastComp];

    bookDownload.loc=string;
    NSFileManager *manager=[NSFileManager defaultManager];
    if ([manager fileExistsAtPath:string]) {
        [manager removeItemAtPath:string error:nil];
    }
    [manager createFileAtPath:string contents:nil attributes:nil];
    NSError *error;
    NSURL *urlFile=[NSURL fileURLWithPath:string];
    [urlFile setResourceValue:[NSNumber numberWithBool: YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    bookDownload.handle=[NSFileHandle fileHandleForUpdatingAtPath:string];
  //  [bookDownload.handle retain];
    bookDownload.progress=_progress;
    bookDownload.value=[book.size floatValue];
    NSString *stirngValue=book.sourceFileUrl;
    NSURL *url=[NSURL URLWithString:stirngValue];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:url];
    
    NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:bookDownload];
    [connection start];
 /*   [request release];
    [bookDownload release];
    [connection autorelease];*/
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem.tintColor=[UIColor grayColor];
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mangoreader-logo.png"]];
    self.navigationItem.titleView=imageView;
  //  [imageView release];
//[self.navigationController.navigationBar setHidden:YES];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewDidAppear:(BOOL)animated{
     [super viewDidAppear:YES];
    if (_bookOpen) {
       _bookOpen=NO;  
    
        
        AePubReaderAppDelegate  *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;

    [self.tabBarController.tabBar setHidden:NO];
    [self.navigationController.navigationBar setHidden:NO];
    UIViewController *c=[[UIViewController alloc]init];

    [self presentViewController:c animated:NO completion:^(void){
        [self dismissViewControllerAnimated:NO completion:^(void){
            delegate.LandscapeOrientation=YES;
            delegate.PortraitOrientation=YES;}];
    }];
     //   [c release];
       
        }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return _array.count;
}
-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 180;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *CellIdentifier = @"Cell";
      NSString *ver= [UIDevice currentDevice].systemVersion;
    if ([ver floatValue]>=6.0) {
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    else{
        cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
   
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
       // [cell autorelease];
    }
    if (indexPath.row==0&&_downloadBook) {
      
        [cell addSubview:_progress];
        
    }
   
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    Book *book=[_array objectAtIndex:indexPath.row];
    cell.imageView.image=[[UIImage alloc]initWithContentsOfFile:book.localPathImageFile];
    cell.textLabel.text=book.title;

    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        _index=indexPath.row;
        if (_downloadBook) {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Message" message:@"This book is being downloaded. It can be deleted only after downloading is complete." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
         //   [alertView release];
            return;
        }
           Book *book=[_array objectAtIndex:indexPath.row];
         NSString *alertViewMessage=[NSString stringWithFormat:@"Do you wish to delete book titled %@ ?",book.title ];
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Delete Book" message:alertViewMessage delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        alertView.tag=300;
        [alertView show];
        //[alertView release];
        
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_downloadBook&&indexPath.row==0) {
        return;
    }
    // Navigation logic may go here. Create and push another view controller.
    _alertView =[[UIAlertView alloc]init];
//    CGRect rect=_alertView.frame;
//    
//    rect.size.height=190;
//    rect.size.width=160;
//    _alertView.frame=rect;
    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(139.0f-18.0f, 40.0f, 37.0f, 37.0f)];
    [indicator startAnimating];
    [_alertView addSubview:indicator];
   //[indicator release];
    [_alertView setTitle:@"Loading...."];
    [_alertView setDelegate:self];
//    UIImage *image=[UIImage imageNamed:@"loading.png"];
//    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, -50, 190, 160)];
//    
//    
//    imageView.image=image;
//    [_alertView addSubview:imageView];
//    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(125, 25, 66.0f, 66.0f)];
//    indicator.color=[UIColor blackColor];
//    [indicator startAnimating];
//    [_alertView addSubview:indicator];
//    [indicator release];
//
    [_alertView show];
//    UIImage *image=[UIImage imageNamed:@"pattern.png"];
//    UIColor *color=[UIColor colorWithPatternImage:image];
//    _alertView.backgroundColor=color;
    Book *iden=_array[indexPath.row];
    _identity=indexPath.row;
    [[NSUserDefaults standardUserDefaults] setInteger:[iden.id integerValue] forKey:@"bookid"];
   

 
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}
-(void)didPresentAlertView:(UIAlertView *)alertView{
    if (alertView.tag==300) {
        return;
    }
    NSString  *value=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    Book *bk=_array[_identity];
    NSString *epubString=[NSString stringWithFormat:@"%@.epub",bk.id];
    value=[value stringByAppendingPathComponent:epubString];
    NSLog(@"Path value: %@",value);
    
    ViewController *viewController;
         AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSLog(@"booktype %d",bk.textBook.integerValue);
     if (!bk.textBook) {
         delegate.LandscapeOrientation=YES;
         delegate.PortraitOrientation=NO;
         EpubReaderViewController *reader=[[EpubReaderViewController alloc]initWithNibName:@"EpubReaderViewController" bundle:nil];
         reader._strFileName=value;
         reader.url=bk.link;
         reader.imageLocation=bk.localPathImageFile;
         // reader.url=button.stringLink;
         self.tabBarController.hidesBottomBarWhenPushed=YES;
         reader.hidesBottomBarWhenPushed=YES;
         [self.navigationController pushViewController:reader animated:YES];
       //  [reader release];
         _bookOpen=YES;
     }
    EpubReaderViewController *reader;
    switch (bk.textBook.integerValue) {
        case 1://storyBooks
            delegate.LandscapeOrientation=YES;
            delegate.PortraitOrientation=NO;
            reader=[[EpubReaderViewController alloc]initWithNibName:@"EpubReaderViewController" bundle:nil];
            reader._strFileName=value;
            reader.url=bk.link;
            reader.imageLocation=bk.localPathImageFile;
            // reader.url=button.stringLink;
            self.tabBarController.hidesBottomBarWhenPushed=YES;
            reader.hidesBottomBarWhenPushed=YES;
            _bookOpen=YES;
            [self.navigationController pushViewController:reader animated:YES];
        //    [reader release];
            break;
        case 2://textbooks
            delegate.LandscapeOrientation=NO;
            delegate.PortraitOrientation=YES;
            value=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            _bookOpen=YES;
            epubString=[NSString stringWithFormat:@"%@.epub",bk.id];
            value=[value stringByAppendingPathComponent:epubString];
            NSLog(@"Path value: %@",value);
            viewController=[[ViewController alloc]initWithNibName:@"ViewControllerIphone" bundle:nil WithString:value];
            [self.navigationController pushViewController:viewController animated:YES];
        //    [viewController release];

            break;
    }

    [_alertView dismissWithClickedButtonIndex:0 animated:YES];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        Book *book=_array[_index];
        book.downloaded=@NO;
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate.dataModel saveData:book];
        NSString  *value=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
        NSString *epubString=[NSString stringWithFormat:@"%@",book.id];
        value=[value stringByAppendingPathComponent:epubString];
        NSLog(@"Delete value: %@",value);
        if ([[NSFileManager defaultManager] fileExistsAtPath:value]) {
              [[NSFileManager defaultManager]removeItemAtPath:value error:nil];
        }
        value=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        epubString=[NSString stringWithFormat:@"%@.epub",book.id];
        
      
        [_array removeObjectAtIndex:_index];
        NSIndexPath *path=[NSIndexPath indexPathForRow:_index inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
        _deleted=YES;
    }else{
        
    }
}
/*-(void)dealloc{
    _progress=nil;
    [super dealloc];
}*/
@end
