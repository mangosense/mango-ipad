//
//  DataModelControl.m
//  AePubReader
//
//  Created by Nikhil Dhavale on 25/09/12.
//
//

#import "DataModelControl.h"
#import "ASIHTTPRequest.h"
#import <CoreData/CoreData.h>
#import "Book.h"
 #import <objc/runtime.h>
@implementation DataModelControl
-(id)initWithContext:(NSManagedObjectContext *)context{
    self = [super init];
    
    if (self)
    {
        self.dataModelContext = context;
        return self;
    }
    
    return self
    ;

}
-(NSArray *)getDataNotDownloaded{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Book" inManagedObjectContext:_dataModelContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"downloaded==%@",[NSNumber numberWithBool:NO]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *array= [_dataModelContext executeFetchRequest:fetchRequest error:&error];
     NSLog(@"downloaded book count %d",array.count);
//    for (Book *bk in array) {
//        NSLog(@"book %@ %@",bk.id,bk.title);
//    }
    [fetchRequest release];
    return array;
    
}
-(NSArray *)getDataDownloaded{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Book" inManagedObjectContext:_dataModelContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"downloaded==%@",[NSNumber numberWithBool:YES]];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *desc=[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSError *error;
    NSArray *array= [_dataModelContext executeFetchRequest:fetchRequest error:&error];
    NSArray *descp=@[desc];
    [desc release];
    array=[array sortedArrayUsingDescriptors:descp];
    [fetchRequest release];
    NSLog(@"downloaded book count %d",array.count);
    for (Book *book in array) {
        NSDateFormatter *format=[[NSDateFormatter alloc]init];
        
        NSLog(@"%@",[format stringFromDate:book.date]);
    }
    return array;
    
}
-(Book *)getBookOfId:(NSString *)iden{
    [iden retain];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Book" inManagedObjectContext:_dataModelContext];
 NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id==%@",[iden stringByDeletingPathExtension]];
    NSError *error;
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    NSArray *array= [_dataModelContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    [iden release];
    return [array lastObject];
}

-(void)saveData:(Book *)book{
    if ([book hasChanges]) {
        book.date=[NSDate date];
        [_dataModelContext save:nil];
    }
}
-(BOOL)insertIfNew:(NSMutableData *)data{
    NSArray *diction=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

    NSString *string=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSFileManager *manager=[NSFileManager defaultManager];
  //  NSLog(@"diction count %d",diction.count);
       for (NSDictionary *key in diction) {
           key=[key objectForKey:@"book"];

           NSString *temp=[NSString stringWithFormat:@"%@.jpg",[key objectForKey:@"id"]];
//          const char *val=class_getName([[key objectForKey:@"id"] class]);
//           NSLog(@"%s",val);
           
           
           
           temp=[string stringByAppendingPathComponent:temp];
           
           if (![manager fileExistsAtPath:temp]) {
               Book *book=[NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:_dataModelContext];
               book.id=[key objectForKey:@"id"];
               book.desc=[key objectForKey:@"description"];
               book.sourceFileUrl=[key objectForKey:@"book_url"];
               book.imageUrl=[key objectForKey:@"cover_image_url"];
               book.title=[key objectForKey:@"title"];
               book.downloaded=[NSNumber numberWithBool:NO];
               book.link=[key objectForKey:@"book_link"];
               NSNumber *numb=[key objectForKey:@"source_file_size"];
              // NSLog(@" %@ %f",book.id,[numb floatValue]);
               book.size=[NSNumber numberWithFloat:[numb floatValue]];
               NSURL *url=[NSURL URLWithString:book.imageUrl];
//               NSURLRequest *nsRequest=[[NSURLRequest alloc]initWithURL:url];
//               
//               NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:nsRequest delegate:self];
//               [connection autorelease];
               ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
               book.localPathImageFile=temp;
               [request setDownloadDestinationPath:temp];
               [request setDelegate:self];
               
               [request setAllowResumeForFileDownloads:YES];
               [request startSynchronous];
               NSError *error=nil;
               if (![_dataModelContext save:&error]) {
                   NSLog(@"%@",error);
               }
              
//               @property (nonatomic, retain) NSString * desc;
//               @property (nonatomic, retain) NSString * sourceFileUrl;
//               @property (nonatomic, retain) NSString * imageUrl;
//               @property (nonatomic, retain) NSString * title;
//               @property (nonatomic, retain) NSNumber * downloaded;
//               @property (nonatomic, retain) NSString * localPathFile;
//               @property (nonatomic, retain) NSString * localPathImageFile;
           }else{
               NSNumber *num=[key objectForKey:@"source_file_size"];
               NSNumber *iden=[key objectForKey:@"id"];
               NSString *str=[[NSString alloc ]initWithFormat:@"%@.epub",iden];
               Book *book=[self getBookOfId:str];
               [str release];
               book.size=num;
               [self saveData:book];
           }
           
           
    }

    return YES;
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{

}

@end
