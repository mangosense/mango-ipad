//
//  MyBooksViewControlleriPhone.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 07/11/13.
//
//

#import "MyBooksViewControlleriPhone.h"
#import "BookDownloaderIphone.h"
#import "RootViewController.h"
#import "NewStoreControlleriPhone.h"
#import "LandscapeTextBookViewController.h"
#import "EpubReaderViewController.h"
#import "ViewController.h"
@interface MyBooksViewControlleriPhone ()

@end

@implementation MyBooksViewControlleriPhone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        // Custom initialization
        self.tabBarItem.title=@"My Books";
        self.tabBarItem.image=[UIImage imageNamed:@"library.png"];
        _delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        NSArray *temp=[_delegate.dataModel getDataDownloaded];
        _array=[[NSMutableArray alloc]initWithArray:temp];
        _delegate.downloadBook=NO;
        _deleted=NO;
        _bookOpen=NO;
    }
    return self;
}
-(void)downloadComplete:(NSInteger)index{
    _delegate.downloadBook=YES;
    
    _progress=[[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
    CGRect rect=CGRectMake(170, 150, 250, 12);
    _progress.frame=rect;
    [self.tabBarController setSelectedIndex:0];
    NSArray *temp=[_delegate.dataModel getDataDownloaded];
    // [_array release];
    _array=[[NSMutableArray alloc]initWithArray:temp];
    [self.tableView reloadData];
    BookDownloaderIphone *bookDownload=[[BookDownloaderIphone alloc]initWithViewController:self];
    
    NSString *string=[[NSString alloc]initWithFormat:@"%d",index ];
    Book *book=[_delegate.dataModel getBookOfId:string];
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
    [urlFile setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
    bookDownload.handle=[NSFileHandle fileHandleForUpdatingAtPath:string];
    bookDownload.progress=_progress;
    bookDownload.value=[book.size floatValue];
    NSString *stirngValue=book.sourceFileUrl;
    NSURL *url=[NSURL URLWithString:stirngValue];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:url];
    
    NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:bookDownload];
    [connection start];
    
    
}
- (IBAction)showStore:(id)sender {
    NewStoreControlleriPhone *storeNew=[[NewStoreControlleriPhone alloc]initWithNibName:@"NewStoreControlleriPhone" bundle:nil];
    [UIView beginAnimations:@"View Flip" context:nil];
    [UIView setAnimationDuration:0.80];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                           forView:self.navigationController.view cache:NO];
    
    [self.navigationController pushViewController:storeNew animated:YES];
    [UIView commitAnimations];

}
- (IBAction)switchTabs:(id)sender {
    [self.tabBarController setSelectedIndex:1];
}
- (IBAction)feedback:(id)sender {
    MFMailComposeViewController *mail;
    mail=[[MFMailComposeViewController alloc]init];
    [mail setSubject:@"Feed back for the App"];
    mail.modalPresentationStyle=UIModalTransitionStyleCoverVertical;
    
    [mail setMailComposeDelegate:self];
    [mail setToRecipients:@[@"ios@mangosense.com"]];
    // [mail setMessageBody:body isHTML:NO];
    [self presentModalViewController:mail animated:YES];
}
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    [controller dismissModalViewControllerAnimated:YES];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if([UIDevice currentDevice].systemVersion.integerValue>=7)
    {
        // iOS 7 code here
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
 /*   self.navigationItem.leftBarButtonItem.tintColor=[UIColor grayColor];
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mangoreader-logo.png"]];
    self.navigationItem.titleView=imageView;
    
    UIBarButtonItem *barButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"Feedback" style:UIBarButtonItemStyleBordered target:self action:@selector(feedback:)];
    barButtonItem.tintColor=[UIColor grayColor];
    self.navigationItem.rightBarButtonItem=barButtonItem;*/
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"help"]) {
        NSArray *array=@[@"small_one.png",@"small_two.png",@"small_three.png", @"small_four"];
        RootViewController *rootViewController=[[RootViewController alloc]initWithNibName:@"PhoneContent" bundle:nil contentList:array] ;
        [self presentViewController:rootViewController animated:YES completion:nil];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"help"];
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        delegate.PortraitOrientation=NO;
        delegate.LandscapeOrientation=YES;
        
    }
    self.navigationController.navigationBarHidden=YES;
    self.navigationController.navigationController.navigationBarHidden=YES;
    self.tabBarController.tabBar.hidden=YES;

    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.PortraitOrientation=YES;
    delegate.LandscapeOrientation=YES;
    self.navigationController.navigationBarHidden=YES;
    self.navigationController.navigationController.navigationBarHidden=YES;
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    if (_bookOpen) {
        _bookOpen=NO;
        
        
        AePubReaderAppDelegate  *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        
      //  [self.tabBarController.tabBar setHidden:NO];
     //   [self.navigationController.navigationBar setHidden:NO];
        UIViewController *c=[[UIViewController alloc]init];
        
        [self presentViewController:c animated:NO completion:^(void){
            [self dismissViewControllerAnimated:NO completion:^(void){
                delegate.LandscapeOrientation=YES;
                delegate.PortraitOrientation=YES;}];
        }];
        
    }
    
  //  [Flurry logEvent:@"MyBooks entered iphone "];
    [self.tabBarController.tabBar setHidden:YES];
}
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
    }
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    if (indexPath.row==0&&delegate.downloadBook) {
        
        [cell addSubview:_progress];
        
    }else{
        
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    Book *book=_array[indexPath.row];
    //  NSLog(@"%@",book.localPathImageFile);
    cell.imageView.image=[[UIImage alloc]initWithContentsOfFile:book.localPathImageFile];
    cell.textLabel.text=book.title;
    
    
    return cell;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        _index=indexPath.row;
        if (delegate.downloadBook) {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Message" message:@"This book is being downloaded. It can be deleted only after downloading is complete." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            return;
        }
        Book *book=_array[indexPath.row];
        NSString *alertViewMessage=[NSString stringWithFormat:@"Do you wish to delete book titled %@ ?",book.title ];
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Delete Book" message:alertViewMessage delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        alertView.tag=300;
        [alertView show];
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate.downloadBook&&indexPath.row==0) {
        return;
    }
    // Navigation logic may go here. Create and push another view controller.
    /*  _alertView =[[UIAlertView alloc]init];
     
     UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(139.0f-18.0f, 40.0f, 37.0f, 37.0f)];
     [indicator startAnimating];
     [_alertView addSubview:indicator];
     [_alertView setTitle:@"Loading...."];
     [_alertView setDelegate:self];
     
     [_alertView show];*/
    [AePubReaderAppDelegate showAlertView];
    [[AePubReaderAppDelegate getAlertView] setDelegate:self];
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
    LandscapeTextBookViewController *landscapeViewController;
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
        reader.titleOfBook=bk.title;
        self.tabBarController.hidesBottomBarWhenPushed=YES;
        reader.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:reader animated:YES];
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
            reader.titleOfBook=bk.title;
            self.tabBarController.hidesBottomBarWhenPushed=YES;
            reader.hidesBottomBarWhenPushed=YES;
            _bookOpen=YES;
            [self.navigationController pushViewController:reader animated:YES];
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
            viewController.titleOfBook=bk.title;
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        case 3:
            delegate.LandscapeOrientation=YES;
            delegate.PortraitOrientation=NO;
            value=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            _bookOpen=YES;
            epubString=[NSString stringWithFormat:@"%@.epub",bk.id];
            value=[value stringByAppendingPathComponent:epubString];
            self.tabBarController.hidesBottomBarWhenPushed=YES;
            
            landscapeViewController=[[LandscapeTextBookViewController
                                      alloc]initWithNibName:@"LandscapeTextBookiPhone" bundle:nil WithString:value];
            landscapeViewController.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:landscapeViewController animated:YES];
            
            break;
    }
    [AePubReaderAppDelegate hideAlertView];
    // [_alertView dismissWithClickedButtonIndex:0 animated:YES];
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
@end
