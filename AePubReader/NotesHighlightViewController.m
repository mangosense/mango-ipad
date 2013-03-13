//
//  NotesHighlightViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 18/12/12.
//
//

#import "NotesHighlightViewController.h"
#import "AePubReaderAppDelegate.h"
#import "DataModelControl.h"
#import "NoteHighlight.h"
#import "DetailHighlightViewController.h"
#import "NSString+HTML.h"
@interface NotesHighlightViewController ()

@end

@implementation NotesHighlightViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
          }
    return self;
}
- (id)initWithStyle:(UITableViewStyle)style With:(NSInteger)bookid withPageNo:(NSInteger)pageNumber{
    self = [super initWithStyle:style];
    if (self) {
        // ustom initialization
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
           // NSInteger iden=[[NSUserDefaults standardUserDefaults] integerForKey:@"bookid"];
        NSArray *notes= [delegate.dataModel getNoteWithBook:bookid];
        _array=[[NSMutableArray alloc]init];//traversing is needed since pages may not have notes
        _arraySection=[[NSMutableArray alloc]init];
        NSNumber *number=[NSNumber numberWithInt:-1];

        NSMutableArray *arrayPerPage=[[NSMutableArray alloc]init];
   //     [arrayPerPage addObject:noteHighlight];
        for (NoteHighlight *high in notes) {
           // NSLog(@"note %@ relevantHighlight %@ page number %@",high.note,high.text,high.pageNo);
            if (number.integerValue!=high.pageNo.integerValue&&[notes indexOfObject:high]!=0) {
                number=high.pageNo;
                 [_arraySection addObject:high.pageNo];
               
                [_array addObject:arrayPerPage];
                
                [arrayPerPage release];
                arrayPerPage=[[NSMutableArray alloc]init];
                 [arrayPerPage addObject:high];
                NSLog(@"new page");
            }else{
                NSLog(@"same page");
                number=high.pageNo;
                [arrayPerPage addObject:high];
            }
            if ([notes indexOfObject:high]==0) {
                [_arraySection addObject:high.pageNo];
            }
            
        }
        if(arrayPerPage.count!=0){
            [_array addObject:arrayPerPage];
        }
//        for (NSMutableArray *array in _array) {
//            NSLog(@"total notes :%d",array.count );
//            for (NoteHighlight *highlight in array) {
//                NSLog(@"%@ pageNumber---%@ location--%@ top ----%@ identity---%@",highlight.note,highlight.pageNo,highlight.left,highlight.top,highlight.identity);
//            }
//            
//        }
        [delegate.dataModel showNotesAndHighlight];
        [arrayPerPage autorelease];
        _bookId=bookid;
        _pageNumber=pageNumber;
        _highlight=NO;
        
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray *array =[NSArray arrayWithObjects:@"Notes",@"Highlight" ,nil];
    UISegmentedControl *segmentedControl=[[UISegmentedControl alloc]initWithItems:array];
    segmentedControl.segmentedControlStyle=UISegmentedControlStyleBar;
    self.navigationItem.titleView=segmentedControl;
    [segmentedControl addTarget:self action:@selector(notesOrHighLight:) forControlEvents:UIControlEventValueChanged];
    [segmentedControl setSelectedSegmentIndex:0];
    [segmentedControl release];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)notesOrHighLight:(id)sender{
    UISegmentedControl *seg=(UISegmentedControl *)sender;
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSArray *arrayNotesOrHighlight=nil;
    [_array release];
    [_arraySection release];
   

    switch (seg.selectedSegmentIndex) {
        case 0:
            NSLog(@"index 0");
            _highlight=NO;
            arrayNotesOrHighlight= [delegate.dataModel getNoteWithBook:_bookId];
           
           
           
            break;
        case 1:
            NSLog(@"index 1");
          _highlight=YES;
           arrayNotesOrHighlight= [delegate.dataModel getHighlightWithBook:_bookId];

       
        
            break;
        default:
            break;
    }
  
    
    _array=[[NSMutableArray alloc]init];//traversing is needed since pages may not have notes
    _arraySection=[[NSMutableArray alloc]init];
    NSNumber *number=[NSNumber numberWithInt:-1];
    
    NSMutableArray *arrayPerPage=[[NSMutableArray alloc]init];
    //     [arrayPerPage addObject:noteHighlight];
    for (NoteHighlight *high in arrayNotesOrHighlight) {
      //  NSLog(@"note %@ relevantHighlight %@ page  identity %@ ",high.note,high.text,high.identity);
        if (number.integerValue!=high.pageNo.integerValue&&[arrayNotesOrHighlight indexOfObject:high]!=0) {
            number=high.pageNo;
            [_arraySection addObject:high.pageNo];
            
            [_array addObject:arrayPerPage];
            
            [arrayPerPage release];
            arrayPerPage=[[NSMutableArray alloc]init];
            [arrayPerPage addObject:high];
       //     NSLog(@"new page");
        }else{
       //     NSLog(@"same page");
             number=high.pageNo;
            [arrayPerPage addObject:high];
        }
        if ([arrayNotesOrHighlight indexOfObject:high]==0) {
            [_arraySection addObject:high.pageNo];
        }
        
    }
    if(arrayPerPage.count!=0){
        [_array addObject:arrayPerPage];
    
    }
      [arrayPerPage release];
 [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"Low memory");
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return _array.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    NSMutableArray *arrayPerPage=[_array objectAtIndex:section];
    return arrayPerPage.count;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *title=[NSString stringWithFormat:@"%@",[_arraySection objectAtIndex:section] ];
    return  title;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
//     = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString *ver= [UIDevice currentDevice].systemVersion;

    if ([ver floatValue]>6.0) {
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    else{
        cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    if (cell==nil) {
            cell=[[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        
    }
     NSMutableArray *arrayPerPage=[_array objectAtIndex:indexPath.section];
    NoteHighlight *notesOrHighlight=[arrayPerPage objectAtIndex:indexPath.row];
    cell.textLabel.text=notesOrHighlight.text;
    if (notesOrHighlight.note) {
            cell.detailTextLabel.text=[notesOrHighlight.note stringByConvertingHTMLToPlainText];
    }
    else{
        cell.detailTextLabel.text=@"";
    }
    // Configure the cell...
    
    return cell;
}
-(void)viewWillAppear:(BOOL)animated{
  
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
     
    [self.navigationController.navigationBar setHidden:NO];
}
-(void)viewWillDisappear:(BOOL)animated{
  
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
    [self.navigationController.navigationBar setHidden:YES];
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
        NSMutableArray *arrayPerPage=[_array objectAtIndex:indexPath.section];
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        
        NoteHighlight *high=[arrayPerPage objectAtIndex:indexPath.row];
   
        [arrayPerPage removeObjectAtIndex:indexPath.row];
   
        [_delegateAction deleted:high.pageNo.integerValue];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
             [delegate.dataModel deleteNoteOrHighlight:high];
        
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
    NSNumber *pagNumber=[_arraySection objectAtIndex:indexPath.section];
    [_delegate loadSpine:pagNumber.integerValue  atPageIndex:pagNumber.integerValue highlightSearchResult:nil];
    
}
-(void)dealloc{
    
    [_array release];
    [_arraySection release];
    [super dealloc];
}
@end