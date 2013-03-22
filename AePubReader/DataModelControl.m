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
#import "StoreBooks.h"
#import "NoteHighlight.h"
#import "NoteButton.h"

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
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription
//                                   entityForName:@"Book" inManagedObjectContext:_dataModelContext];
//    [fetchRequest setEntity:entity];
//NSArray *array= [_dataModelContext executeFetchRequest:fetchRequest error:nil];
////    for (Book *bok in array) {
////        NSLog(@"Book to be displayed %@,%@,%@",bok.id,bok.title,bok.downloaded);
////    }
//    
}
/*
 @property (nonatomic, retain) NSNumber * highlight;
 @property (nonatomic, retain) NSNumber * bookid;
 @property (nonatomic, retain) NSNumber * pageNo;
 @property (nonatomic, retain) NSString * text;

 */
-(void)showNotesAndHighlight{
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription
//                                   entityForName:@"NoteHighlight" inManagedObjectContext:_dataModelContext];
//    [fetchRequest setEntity:entity];
//    NSError *error;
//     NSArray *array= [_dataModelContext executeFetchRequest:fetchRequest error:&error];
//    [fetchRequest release];
//    NSLog(@"\n\n\n\n\n\n\n\n\n");
//    for (NoteHighlight *noteOrHighlight in array) {
//        NSLog(@"identity %@ text %@",noteOrHighlight.identity,noteOrHighlight.text);
//    }

}
-(void)insertNoteOFHighLight:(BOOL)highLight book:(NSInteger )bookid page:(NSInteger)pageNo string:(NSString *)text{
  //  [text retain];
    NoteHighlight *noteHighLight=[NSEntityDescription insertNewObjectForEntityForName:@"NoteHighlight" inManagedObjectContext:_dataModelContext];
    noteHighLight.highlight=[NSNumber numberWithBool:highLight];
    noteHighLight.bookid=[NSNumber numberWithInteger:bookid];
    noteHighLight.pageNo=[NSNumber numberWithInteger:pageNo];
    noteHighLight.text=text;
    noteHighLight.date_added=[NSDate date];
    noteHighLight.date_modified=[NSDate date];
    NSError *error;
    if (![_dataModelContext save:&error]) {
        NSLog(@"%@",error);
    }

    //[text release];
}
-(NSArray *)getHighlight:(NSInteger )bookid withPageNo:(NSInteger)pageNumber{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"NoteHighlight" inManagedObjectContext:_dataModelContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"highlight==%@ && bookid=%d && pageNo=%d",[NSNumber numberWithBool:YES],bookid,pageNumber];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *array= [_dataModelContext executeFetchRequest:fetchRequest error:&error];
   // [fetchRequest release];
    return array;
}
-(NSArray *)getHighlightorNotes:(NSInteger)bookid withPageNo:(NSInteger)pageNumber withSurroundingString:(NSString *)string{
//    [string retain];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"NoteHighlight" inManagedObjectContext:_dataModelContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookid=%d && pageNo=%d && surroundingtext==%@",bookid,pageNumber,string];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *array= [_dataModelContext executeFetchRequest:fetchRequest error:&error];
   // [fetchRequest autorelease];
   // [string release];
    return array;

    
}
-(NSArray *)getNoteWithBook:(NSInteger)bookid {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"NoteHighlight" inManagedObjectContext:_dataModelContext];
     [fetchRequest setEntity:entity];
     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"highlight==%@ && bookid=%d",[NSNumber numberWithBool:NO],bookid];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *array=[_dataModelContext executeFetchRequest:fetchRequest error:&error];
    NSSortDescriptor *desc=[[NSSortDescriptor alloc] initWithKey:@"pageNo" ascending:YES];
    array=[array sortedArrayUsingDescriptors:@[desc]];
  //  [desc release];
  //  [fetchRequest autorelease];
    return array;

}
-(NSArray *)getHighlightWithBook:(NSInteger)bookid{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"NoteHighlight" inManagedObjectContext:_dataModelContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"highlight==%@ && bookid=%d ",[NSNumber numberWithBool:YES],bookid];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *desc=[[NSSortDescriptor alloc] initWithKey:@"pageNo" ascending:YES];
    NSError *error;
    NSArray *array=[_dataModelContext executeFetchRequest:fetchRequest error:&error];
    array=[array sortedArrayUsingDescriptors:@[desc]];
 //   [desc release];
 //   [fetchRequest autorelease];
    return array;
}
-(NSArray *)getNoteOrHighlight:(NSInteger )bookid withPageNo:(NSInteger)pageNumber{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"NoteHighlight" inManagedObjectContext:_dataModelContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookid=%d && pageNo=%d",bookid,pageNumber];
    
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *array=[_dataModelContext executeFetchRequest:fetchRequest error:&error];
  //  [fetchRequest autorelease];
    return array;
}
-(NSArray *)getNotes:(NSInteger )bookid withPageNo:(NSInteger)pageNumber{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"NoteHighlight" inManagedObjectContext:_dataModelContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"highlight==%@ && bookid=%d && pageNo=%d",[NSNumber numberWithBool:NO],bookid,pageNumber];

    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *array= [_dataModelContext executeFetchRequest:fetchRequest error:&error];
   // [fetchRequest release];
    return array;
}
-(void)deleteNoteOrHighlight:(NoteHighlight *)hight{
    [_dataModelContext deleteObject:hight];
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
  //   NSLog(@"downloaded book count %d",array.count);
    for (Book *bk in array) {
        NSLog(@"book %@ %@",bk.id,bk.title);
        NSLog(@"book localimage Loc %@",bk.localPathImageFile);
    }
  //  [fetchRequest release];
    return array;
    
}
-(NSUInteger)getCount {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"NoteHighlight" inManagedObjectContext:_dataModelContext];
    [fetchRequest setEntity:entity];


    NSError *error;
 //   [fetchRequest autorelease];
    return [_dataModelContext countForFetchRequest:fetchRequest error:&error];

}
-(NoteHighlight*)getNoteOfIdentity:(NSInteger)identity{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"NoteHighlight" inManagedObjectContext:_dataModelContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identity==%d",identity];
    [fetchRequest setPredicate:predicate];
    NSError *error;
      NSArray *array= [_dataModelContext executeFetchRequest:fetchRequest error:&error];
 //   NSLog(@"note identity %d count %d",identity,array.count);
  //  [fetchRequest release];
    return [array lastObject];

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
  //  [desc release];
    array=[array sortedArrayUsingDescriptors:descp];
   // [fetchRequest release];
 //   NSLog(@"downloaded book count %d",array.count);
//    for (Book *book in array) {
//     //   NSDateFormatter *format=[[NSDateFormatter alloc]init];
//        
//      //  NSLog(@"%@",[format stringFromDate:book.date]);
//     //   [format release];
//    }
    return array;
    
}
-(Book *)getBookOfId:(NSString *)iden{
//    [iden retain];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Book" inManagedObjectContext:_dataModelContext];
 NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id==%@",[iden stringByDeletingPathExtension]];
    NSError *error;
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    NSArray *array= [_dataModelContext executeFetchRequest:fetchRequest error:&error];
  //  [fetchRequest release];
   // [iden release];
    return [array lastObject];
}
-(StoreBooks *)getStoreBookById:(NSString *)productId{
    //[productId retain];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"StoreBooks" inManagedObjectContext:_dataModelContext];

   NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productIdentity==%@",productId];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    NSError *error=nil;
    NSArray *array= [_dataModelContext executeFetchRequest:fetchRequest error:&error];
//    [fetchRequest release];
 //   [productId release];
    return [array lastObject];

}
-(BOOL)checkIfIdExists:(NSNumber *)iden{
 //   [iden retain];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Book" inManagedObjectContext:_dataModelContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id==%@",iden];
    NSError *error;
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    NSArray *array= [_dataModelContext executeFetchRequest:fetchRequest error:&error];
  //  [iden release];
  //  [fetchRequest release];
    if (array.count==0) {
       return NO;
    }
    else{
        return YES;
    }
    
}
-(Book*)getBookInstance{
    Book *book=[NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:_dataModelContext];
    return book;
}
-(void)saveData:(Book *)book{
    if ([book hasChanges]) {
        book.date=[NSDate date];
        [_dataModelContext save:nil];
    }
}
-(void)saveStoreBookData:(StoreBooks *)book{
    if ([book hasChanges]) {
        [_dataModelContext save:nil];
    }
}
-(BOOL)checkIfStoreId:(NSNumber *)identity{
  
   //     [identity retain];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"StoreBooks" inManagedObjectContext:_dataModelContext];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productIdentity==%@",identity];
        NSError *error;
        [fetchRequest setPredicate:predicate];
        [fetchRequest setEntity:entity];
        NSArray *array= [_dataModelContext executeFetchRequest:fetchRequest error:&error];
     //   [identity release];
   // [fetchRequest release];
        if (array.count==0) {
            return NO;
        }
        else{
            return YES;
        }
        

}
-(void)insertBookWithNo:(StoreBooks *)storeBooks {
 //   [storeBooks retain];
    if ([self checkIfIdExists:storeBooks.productIdentity]) {
     //   [storeBooks release];
        return;
    }
    Book *book=[NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:_dataModelContext];
    
    book.id=storeBooks.productIdentity;
    book.desc=storeBooks.desc;
    book.title=storeBooks.title;
   
    book.imageUrl=storeBooks.imageUrl;
    book.size=storeBooks.size;
    book.sourceFileUrl=storeBooks.book_url;
    book.link=storeBooks.bookLink;
    book.downloaded=@NO;
    book.date=[NSDate date];
    book.textBook=storeBooks.textBook;
    NSString *locationOfImage=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName=[NSString stringWithFormat:@"%@.jpg",storeBooks.productIdentity];
    locationOfImage=[locationOfImage stringByAppendingPathComponent:fileName];
    book.localPathImageFile=locationOfImage;
    NSError *error=nil;
    
    if (![_dataModelContext save:&error]) {
        NSLog(@"%@",error);
    }
    storeBooks.purchased=@YES;
    [self saveStoreBookData:storeBooks];
   // [storeBooks release];
}
-(void)insertBookWithYes:(StoreBooks *)storeBooks{
    //[storeBooks retain];
    if ([self checkIfIdExists:storeBooks.productIdentity]) {
      //  [storeBooks release];
        return;
    }
    Book *book=[NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:_dataModelContext];
    book.id=storeBooks.productIdentity;
    book.desc=storeBooks.desc;
    book.title=storeBooks.title;
  
    book.imageUrl=storeBooks.imageUrl;
    book.size=storeBooks.size;
    book.sourceFileUrl=storeBooks.book_url;
    book.link=storeBooks.bookLink;
    book.downloaded=@YES;
    book.downloadedDate=[NSDate date];
    book.date=[NSDate date];
    book.textBook=storeBooks.textBook;
    NSString *locationOfImage=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName=[NSString stringWithFormat:@"%@.jpg",storeBooks.productIdentity];
    locationOfImage=[locationOfImage stringByAppendingPathComponent:fileName];
    book.localPathImageFile=locationOfImage;
    NSError *error=nil;
    
    if (![_dataModelContext save:&error]) {
        NSLog(@"%@",error);
    }
    storeBooks.purchased=@YES;
    [self saveStoreBookData:storeBooks];
   // [storeBooks release];
    
}
-(StoreBooks *)getBookById:(NSNumber *)identity{
   // [identity retain];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"StoreBooks" inManagedObjectContext:_dataModelContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productIdentity==%@",identity];
    [fetchRequest setPredicate:predicate];
    NSError *error=nil;
    NSArray *bookArray=[_dataModelContext executeFetchRequest:fetchRequest error:&error];
    //[fetchRequest release];
    //[identity release];
    StoreBooks *bks=[bookArray lastObject];
    NSLog(@"Boook id and title %@ %@",identity,bks.title);
    return [bookArray lastObject];
}

-(NSInteger)insertStoreBooks:(NSMutableData *)data withPageNumber:(NSInteger )pageNumber{
    NSDictionary *diction=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSInteger totalBooks=[[diction objectForKey:@"total_no_of_books"] integerValue];
    
    NSString *string=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSArray *bookArray=[diction objectForKey:@"books"];
    
    for (int i=0;i<bookArray.count;i++) {
        NSDictionary *fromArray=[bookArray objectAtIndex:i];
       
        NSDictionary *key=[fromArray objectForKey:@"book"];
         NSLog(@"key %@",key);
        NSNumber *numberId=[key objectForKey:@"id"];
        if(numberId){
        NSLog(@"number id %@",numberId);
        }
        if(![self checkIfStoreId:numberId]&&[key objectForKey:@"title"]!=[NSNull null]){

            StoreBooks *storeBooks=[NSEntityDescription insertNewObjectForEntityForName:@"StoreBooks" inManagedObjectContext:_dataModelContext];
         //   NSArray *totalKeys=[key allKeys];
           
          //  NSLog(@"key title value %@",[key objectForKey:@"title"]);
          
            storeBooks.productIdentity=[key objectForKey:@"id"];
           
            storeBooks.title=[key objectForKey:@"title"];
            storeBooks.bookLink=[key objectForKey:@"book_link"];
            storeBooks.book_url=[key objectForKey:@"book_url"];
            storeBooks.imageUrl=[key objectForKey:@"cover_image_url"];
            storeBooks.size=[key objectForKey:@"source_file_size"];
            storeBooks.desc=[key objectForKey:@"description"];
            storeBooks.pageNumber=[NSNumber numberWithInteger:pageNumber];
           storeBooks.free=[key objectForKey:@"is_free"];
            storeBooks.purchased=@NO;
            NSNumber *numbr=[key objectForKey:@"booktype"];
           
                storeBooks.textBook=numbr;
           
            NSString *temp=[NSString stringWithFormat:@"%@.jpg",[key objectForKey:@"id"]];
            temp=[string stringByAppendingPathComponent:temp];
            NSURL *url=[NSURL URLWithString:storeBooks.imageUrl];
            
            ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
            storeBooks.localImage=temp;
            [request setDownloadDestinationPath:temp];
            [request setDelegate:self];
            
            [request setAllowResumeForFileDownloads:YES];
            [request startSynchronous];
            NSError *error=nil;
            if (![_dataModelContext save:&error]) {
                NSLog(@"%@",error);
            }
            NSLog(@"inserted id %@",[key objectForKey:@"id"]);
        }
        else{
            NSString *urlString=[key objectForKey:@"cover_image_url"];
            NSURL *url=[NSURL URLWithString:urlString];
            NSString *temp=[NSString stringWithFormat:@"%@.jpg",[key objectForKey:@"id"]];
            temp=[string stringByAppendingPathComponent:temp];
            if (![[NSFileManager defaultManager] fileExistsAtPath:temp]) {
                 ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
                [request setDownloadDestinationPath:temp];
                [request setDelegate:self];
                [request setAllowResumeForFileDownloads:YES];
                [request startSynchronous];
            }
            NSString *val=[NSString stringWithFormat:@"%@",numberId ];
            StoreBooks *books=[self getStoreBookById:val];
            books.desc=[key objectForKey:@"description"];
            NSNumber *numbr=[key objectForKey:@"booktype"];
            
                    books.textBook=numbr;
               NSLog(@"update id %@",[key objectForKey:@"id"]);
        
            [self saveStoreBookData:books];
        }
    }
    
    return totalBooks;
}
-(NSArray *)getStoreBooksPurchased{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"StoreBooks" inManagedObjectContext:_dataModelContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"purchased==%@",[NSNumber numberWithBool:YES]];
    [fetchRequest setPredicate:predicate];
    NSArray *arr=[_dataModelContext executeFetchRequest:fetchRequest error:nil];
    
   // [fetchRequest release];
    return arr;
}
-(NSArray *)getForPage:(NSInteger )pageNumber{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"StoreBooks" inManagedObjectContext:_dataModelContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pageNumber==%@",[NSNumber numberWithInteger:pageNumber]];
    [fetchRequest setPredicate:predicate];
    
        NSError *error;
    NSArray *array= [_dataModelContext executeFetchRequest:fetchRequest error:&error];
 
  //  [fetchRequest release];
    NSLog(@"per page book count %d",array.count);
       return array;
    
}
-(BOOL)insertIfNew:(NSMutableData *)data{
    NSArray *array=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

    NSString *string=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //NSFileManager *manager=[NSFileManager defaultManager];
  //  NSLog(@"diction count %d",diction.count);
    NSInteger count=0;
    _downloadedImage=0;
    
    for (int i=0;i<array.count;i++) {
        NSDictionary *fromDict=[array objectAtIndex:i];
        NSDictionary *key=[fromDict objectForKey:@"book"];

           NSString *temp=[NSString stringWithFormat:@"%@.jpg",[key objectForKey:@"id"]];
           
           
           NSNumber *numberId=[key objectForKey:@"id"];
           
           temp=[string stringByAppendingPathComponent:temp];
           NSURL *url=[NSURL URLWithString:[key objectForKey:@"cover_image_url"]];
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
                 NSLog(@"id %@",book.id);
               NSNumber *num=[key objectForKey:@"booktype"];
              
                   book.textBook=num;
              
               NSNumber *numb=[key objectForKey:@"source_file_size"];
              // NSLog(@" %@ %f",book.id,[numb floatValue]);
          //     if(numb!=[NSNull null]){
               book.size=[NSNumber numberWithFloat:[numb floatValue]];
               NSLog(@"%@",book.title);
              
            //   }
//              url=[NSURL URLWithString:book.imageUrl];
//               NSURLRequest *nsRequest=[[NSURLRequest alloc]initWithURL:url];
//               [NSURLConnection sendAsynchronousRequest:nsRequest queue:nil completionHandler:^(NSURLResponse * response, NSData * dataRecieved , NSError *error) {
//                   [dataRecieved writeToFile:temp atomically:NO];
//               
//                   _downloadedImage++;               }];
//           
//            
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
           //    [str release];
             //  if(num!=[NSNull null]){
                   book.size=[NSNumber numberWithFloat:[num floatValue]];
               book.desc=[key objectForKey:@"description"];
               //}
                NSLog(@"id %@",iden );
                 NSNumber *type=[key objectForKey:@"booktype"];
             
                   book.textBook=type;
               NSLog(@"id %@",iden );
               [self saveData:book];
           }
           if (![[NSFileManager defaultManager] fileExistsAtPath:temp]) {
               NSLog(@"File downloading %@",temp);
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
