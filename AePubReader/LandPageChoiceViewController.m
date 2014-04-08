//
//  LandPageChoiceViewController.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 19/11/13.
//
//

#import "LandPageChoiceViewController.h"
#import "CustomNavViewController.h"
#import "CategoriesViewController.h"
#import "BooksFromCategoryViewController.h"
#import "MangoStoreViewController.h"
#import "MyStoriesBooksViewController.h"
#import "CategoriesFlexibleViewController.h"
#import "BooksCollectionViewController.h"

@interface LandPageChoiceViewController ()

@end

@implementation LandPageChoiceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
        userEmail = delegate.loggedInUserInfo.email;
        userDeviceID = delegate.deviceId;
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    viewName = @"Home page";
    if(!userEmail){
        ID = userDeviceID;
    }
    else{
        ID = userEmail;
    }
    // Do any additional setup after loading the view from its nib.
    
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.controller=self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)creatAStory:(id)sender {
    /*MyStoriesBooksViewController *myStoriesBooksViewController = [[MyStoriesBooksViewController alloc] initWithNibName:@"MyStoriesBooksViewController" bundle:nil];
    myStoriesBooksViewController.toEdit = YES;
    
    [self.navigationController pushViewController:myStoriesBooksViewController animated:YES];*/

    /// -----
    /*BooksFromCategoryViewController *booksCategoryViewController=[[BooksFromCategoryViewController alloc]initWithNibName:@"BooksFromCategoryViewController" bundle:nil withInitialIndex:0];
    booksCategoryViewController.toEdit=YES;
    [self.navigationController pushViewController:booksCategoryViewController animated:YES];*/
    
    /// -----
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSDictionary *dimensions = @{
                                 PARAMETER_USER_ID : ID,
                                 PARAMETER_DEVICE: IOS
                                 
                                 };
    [delegate trackEvent:[HOME_CREATE_STORY valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[HOME_CREATE_STORY valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [HOME_CREATE_STORY valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    if(userEmail){
        [userObject setObject:userEmail forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];
    
    BooksCollectionViewController *booksCollectionViewController = [[BooksCollectionViewController alloc] initWithNibName:@"BooksCollectionViewController" bundle:nil];
    booksCollectionViewController.fromCreateStoryView = 1;
    booksCollectionViewController.toEdit = YES;
    [self.navigationController pushViewController:booksCollectionViewController animated:YES];
    
}

- (IBAction)openFreeStories:(id)sender {
    [self store:nil];
}

- (IBAction)store:(id)sender {
    //NewStoreCoverViewController *controller=[[NewStoreCoverViewController alloc]initWithNibName:@"NewStoreCoverViewController" bundle:nil shouldShowLibraryButton:NO];
    //[self.navigationController pushViewController:controller animated:YES];
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *dimensions = @{
                                 PARAMETER_USER_ID : ID,
                                 PARAMETER_DEVICE: IOS
                                 
                                 };
    [delegate trackEvent:[HOME_STORE_VIEW valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[HOME_STORE_VIEW valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [HOME_STORE_VIEW valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    if(userEmail){
        [userObject setObject:userEmail forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];
    
    
    MangoStoreViewController *storeViewController;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        storeViewController = [[MangoStoreViewController alloc] initWithNibName:@"MangoStoreViewController_iPhone" bundle:nil];
    }
    else{
        storeViewController = [[MangoStoreViewController alloc] initWithNibName:@"MangoStoreViewController" bundle:nil];
    }
    
        [self.navigationController pushViewController:storeViewController animated:YES];
    
}

- (IBAction)myStories:(id)sender {
    AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *dimensions = @{
                                 PARAMETER_USER_ID : ID,
                                 PARAMETER_DEVICE: IOS
                                 
                                 };
    [delegate trackEvent:[HOME_MY_STORIES valueForKey:@"description"] dimensions:dimensions];
    PFObject *userObject = [PFObject objectWithClassName:@"Event_Analytics"];
    [userObject setObject:[HOME_STORE_VIEW valueForKey:@"value"] forKey:@"eventName"];
    [userObject setObject: [HOME_STORE_VIEW valueForKey:@"description"] forKey:@"eventDescription"];
    [userObject setObject:viewName forKey:@"viewName"];
    [userObject setObject:delegate.deviceId forKey:@"deviceIDValue"];
    [userObject setObject:delegate.country forKey:@"deviceCountry"];
    [userObject setObject:delegate.language forKey:@"deviceLanguage"];
    if(userEmail){
        [userObject setObject:userEmail forKey:@"emailID"];
    }
    [userObject setObject:IOS forKey:@"device"];
    [userObject saveInBackground];
    
    CategoriesFlexibleViewController *categoryFlexible;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        categoryFlexible=[[CategoriesFlexibleViewController alloc]initWithNibName:@"CategoriesFlexibleViewController_iPhone" bundle:nil];
    }
    else{
        categoryFlexible=[[CategoriesFlexibleViewController alloc]initWithNibName:@"CategoriesFlexibleViewController" bundle:nil];
    }
    
    categoryFlexible.pageNumber = 0;
    [self.navigationController pushViewController:categoryFlexible animated:YES];
}
@end
