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
#import "ImageDownloader.h"
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
-(void)displayAllData{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Book" inManagedObjectContext:_dataModelContext];
    [fetchRequest setEntity:entity];
NSArray *array= [_dataModelContext executeFetchRequest:fetchRequest error:nil];
    for (Book *bok in array) {
        NSLog(@"Book to be displayed %@,%@,%@",bok.id,bok.title,bok.downloaded);
    }
          
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
    
    NSSortDescriptor *desc=[[NSSortDescriptor alloc] initWithKey:@"downloadedDate" ascending:NO];
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
        [format release];
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
-(BOOL)checkIfIdExists:(NSNumber *)iden{
    [iden retain];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Book" inManagedObjectContext:_dataModelContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id==%@",iden];
    NSError *error;
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    NSArray *array= [_dataModelContext executeFetchRequest:fetchRequest error:&error];
    if (array.count==0) {
       return NO;
    }
    else{
        return YES;
    }
    [iden release];
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
    //NSFileManager *manager=[NSFileManager defaultManager];
  //  NSLog(@"diction count %d",diction.count);
    NSInteger count=0;
    _downloadedImage=0;
       for (NSDictionary *key in diction) {
           key=[key objectForKey:@"book"];

           NSString *temp=[NSString stringWithFormat:@"%@.jpg",[key objectForKey:@"id"]];
           
           
           NSNumber *numberId=[key objectForKey:@"id"];
           
           temp=[string stringByAppendingPathComponent:temp];
           NSURL *url;
           if (![self checkIfIdExists:numberId]) {
               count++;
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
              url=[NSURL URLWithString:book.imageUrl];
//               NSURLRequest *nsRequest=[[NSURLRequest alloc]initWithURL:url];
//               [NSURLConnection sendAsynchronousRequest:nsRequest queue:nil completionHandler:^(NSURLResponse * response, NSData * dataRecieved , NSError *error) {
//                   [dataRecieved writeToFile:temp atomically:NO];
//               
//                   _downloadedImage++;
//               }];
           
            
               ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
               book.localPathImageFile=temp;
               [request setDownloadDestinationPath:temp];
               [request setDelegate:self];
               
               [request setAllowResumeForFileDownloads:YES];
               [request startSynchronous];
//               NSData *data=[NSData dataWithContentsOfURL:url];
//               [data writeToFile:temp atomically:NO];
               NSError *error=nil;
               if (![_dataModelContext save:&error]) {
                   NSLog(@"%@",error);
               }
              
           }else{
               NSNumber *num=[key objectForKey:@"source_file_size"];
               NSNumber *iden=[key objectForKey:@"id"];
               NSString *str=[[NSString alloc ]initWithFormat:@"%@.epub",iden];
               Book *book=[self getBookOfId:str];
               [str release];
               book.size=num;
               [self saveData:book];
           }
           if (![[NSFileManager defaultManager] fileExistsAtPath:temp]) {
               
               ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
               [request setDownloadDestinationPath:temp];
               [request setDelegate:self];
               
               [request setAllowResumeForFileDownloads:YES];
               [request startSynchronous];

           }
           
           
    }//end for
NSLog(@"books inserted %d",count);
    NSLog(@"books downloaded %d",_downloadedImage);
    return YES;
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{

}
@end
