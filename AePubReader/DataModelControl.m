//
//  DataModelControl.m
//  AePubReader
//
//  Created by Nikhil Dhavale on 25/09/12.
//
//

#import "DataModelControl.h"
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
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Book" inManagedObjectContext:_dataModelContext];
    [fetchRequest setEntity:entity];
NSArray *array= [_dataModelContext executeFetchRequest:fetchRequest error:nil];
    for (Book *bok in array) {
        NSLog(@"Book to be displayed %@,%@,%@ %@ %@",bok.id,bok.title,bok.downloaded,bok.bookId,bok.edited);
    }
    
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
-(NSArray *)getAllUserBooks{
    
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"Book" inManagedObjectContext:_dataModelContext];
        [fetchRequest setEntity:entity];
       // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"downloaded==%@",@YES];
       // [fetchRequest setPredicate:predicate];
        
        NSSortDescriptor *desc=[[NSSortDescriptor alloc] initWithKey:@"downloadedDate" ascending:NO];
        NSError *error;
        NSArray *array= [_dataModelContext executeFetchRequest:fetchRequest error:&error];
        NSArray *descp=@[desc];
        array=[array sortedArrayUsingDescriptors:descp];
        
        return array;

}
-(NSArray *)getOriginalBooks{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Book" inManagedObjectContext:_dataModelContext];
    [fetchRequest setEntity:entity];
     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"edited==%@",@NO];
     [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *desc=[[NSSortDescriptor alloc] initWithKey:@"downloadedDate" ascending:NO];
    NSError *error;
    NSArray *array= [_dataModelContext executeFetchRequest:fetchRequest error:&error];
    NSArray *descp=@[desc];
    array=[array sortedArrayUsingDescriptors:descp];
    
    return array;
}
-(void)insertNoteOFHighLight:(BOOL)highLight book:(NSInteger )bookid page:(NSInteger)pageNo string:(NSString *)text{
  //  [text retain];
    NoteHighlight *noteHighLight=[NSEntityDescription insertNewObjectForEntityForName:@"NoteHighlight" inManagedObjectContext:_dataModelContext];
    noteHighLight.highlight=@(highLight);
    noteHighLight.bookid=@(bookid);
    noteHighLight.pageNo=@(pageNo);
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"highlight==%@ && bookid=%d && pageNo=%d",@YES,bookid,pageNumber];
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
     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"highlight==%@ && bookid=%d",@NO,bookid];
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"highlight==%@ && bookid=%d ",@YES,bookid];
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"highlight==%@ && bookid=%d && pageNo=%d",@NO,bookid,pageNumber];

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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"downloaded==%@",@NO];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *array= [_dataModelContext executeFetchRequest:fetchRequest error:&error];
  //   NSLog(@"downloaded book count %d",array.count);
//    for (Book *bk in array) {
//        NSLog(@"book %@ %@",bk.id,bk.title);
//        NSLog(@"book localimage Loc %@",bk.localPathImageFile);
//    }
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"downloaded==%@",@YES];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *desc=[[NSSortDescriptor alloc] initWithKey:@"downloadedDate" ascending:NO];
    NSError *error;
    NSArray *array= [_dataModelContext executeFetchRequest:fetchRequest error:&error];
    NSArray *descp=@[desc];
    array=[array sortedArrayUsingDescriptors:descp];

    return array;
    
}
-(Book *)getBookOfId:(NSString *)iden{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Book" inManagedObjectContext:_dataModelContext];
 NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id==%@",[iden stringByDeletingPathExtension]];
    NSError *error;
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    NSArray *array= [_dataModelContext executeFetchRequest:fetchRequest error:&error];

    return [array lastObject];
}
-(StoreBooks *)getStoreBookById:(NSString *)productId{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"StoreBooks" inManagedObjectContext:_dataModelContext];

   NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productIdentity==%@",productId];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    NSError *error=nil;
    NSArray *array= [_dataModelContext executeFetchRequest:fetchRequest error:&error];

    return [array lastObject];

}
-(BOOL)checkIfIdExists:(NSNumber *)iden{
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
  
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"StoreBooks" inManagedObjectContext:_dataModelContext];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productIdentity==%@",identity];
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
        

}
-(void)insertBookWithNo:(StoreBooks *)storeBooks {
    if ([self checkIfIdExists:storeBooks.productIdentity]) {
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
}
-(void)insertBookWithYes:(StoreBooks *)storeBooks{
    if ([self checkIfIdExists:storeBooks.productIdentity]) {
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
    
}
-(StoreBooks *)getBookById:(NSNumber *)identity{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"StoreBooks" inManagedObjectContext:_dataModelContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productIdentity==%@",identity];
    [fetchRequest setPredicate:predicate];
    NSError *error=nil;
    NSArray *bookArray=[_dataModelContext executeFetchRequest:fetchRequest error:&error];

    return [bookArray lastObject];
}

-(NSInteger)insertStoreBooks:(NSMutableData *)data withPageNumber:(NSInteger )pageNumber{
    NSDictionary *diction=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSInteger totalBooks=[diction[@"total_no_of_books"] integerValue];
    
    NSString *string=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSArray *bookArray=diction[@"books"];
    
    for (int i=0;i<bookArray.count;i++) {
        NSDictionary *fromArray=bookArray[i];
       
        NSDictionary *key=fromArray[@"book"];
      //   NSLog(@"key %@",key);
        NSNumber *numberId=key[@"id"];
        if(numberId){
        NSLog(@"number id %@",numberId);
        }
        if(![self checkIfStoreId:numberId]&&key[@"title"]!=[NSNull null]&&[NSNull null]!=(NSNull *)numberId){

            StoreBooks *storeBooks=[NSEntityDescription insertNewObjectForEntityForName:@"StoreBooks" inManagedObjectContext:_dataModelContext];
  
            storeBooks.productIdentity=key[@"id"];
           
            storeBooks.title=key[@"title"];
            storeBooks.bookLink=key[@"book_link"];
            storeBooks.book_url=key[@"book_url"];
            storeBooks.imageUrl=key[@"cover_image_url"];
            storeBooks.size=key[@"source_file_size"];
            storeBooks.desc=key[@"description"];
            storeBooks.pageNumber=@(pageNumber);
           storeBooks.free=key[@"is_free"];
            storeBooks.purchased=@NO;
            NSNumber *numbr=key[@"booktype"];
            if (![[NSNull null] isEqual:numbr]) {
                storeBooks.textBook=numbr;

            }
            NSURLResponse *response;
            NSError *error;
            NSString *temp=[NSString stringWithFormat:@"%@.jpg",key[@"id"]];
            temp=[string stringByAppendingPathComponent:temp];
            NSURL *url=[NSURL URLWithString:storeBooks.imageUrl];
            NSURLRequest *request=[[NSURLRequest alloc]initWithURL:url];
            NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            [data writeToFile:temp atomically:YES];
            storeBooks.localImage=temp;
            if (![_dataModelContext save:&error]) {
                NSLog(@"%@",error);
            }
            NSLog(@"inserted id %@",key[@"id"]);
        }
        else{
            NSString *urlString=key[@"cover_image_url"];
            NSURL *url=[NSURL URLWithString:urlString];
            NSString *temp=[NSString stringWithFormat:@"%@.jpg",key[@"id"]];
            temp=[string stringByAppendingPathComponent:temp];
            NSURLResponse *response;
            NSError *erro;
            NSURLRequest *request;
//            if ([[NSFileManager defaultManager] fileExistsAtPath:temp]) {
//                [[NSFileManager defaultManager] removeItemAtPath:temp error:&erro];
//                if (erro) {
//                    NSLog(@"%@",erro);
//                }
//            }
            if (![[NSFileManager defaultManager] fileExistsAtPath:temp]) {
                request=[NSURLRequest requestWithURL:url];
                NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&erro];
                NSLog(@"url %@ local %@",url.absoluteString,temp);
                [data writeToFile:temp atomically:YES];
            }
            NSString *val=[NSString stringWithFormat:@"%@",numberId ];
            StoreBooks *books=[self getStoreBookById:val];
            books.desc=key[@"description"];
            books.localImage=temp;

            NSNumber *numbr=key[@"booktype"];
            if (![[NSNull null] isEqual:numbr]) {
                books.textBook=numbr;

            }
               NSLog(@"update id %@",key[@"id"]);
            if (key[@"id"]!=[NSNull null]) {
                [self saveStoreBookData:books];

            }
        }
    }
    
    return totalBooks;
}
-(NSArray *)getStoreBooksPurchased{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"StoreBooks" inManagedObjectContext:_dataModelContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"purchased==%@",@YES];
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pageNumber==%@",@(pageNumber)];
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

    NSInteger count=0;
    _downloadedImage=0;
    
    for (int i=0;i<array.count;i++) {
        NSDictionary *fromDict=array[i];
        NSDictionary *key=fromDict[@"book"];

           NSString *temp=[NSString stringWithFormat:@"%@.jpg",key[@"id"]];
           
           
           NSNumber *numberId=key[@"id"];
           
           temp=[string stringByAppendingPathComponent:temp];
           NSURL *url=[NSURL URLWithString:key[@"cover_image_url"]];
           if (![self checkIfIdExists:numberId]) {
               count++;
               Book *book=[NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:_dataModelContext];
               book.id=key[@"id"];
               if ([NSNull null] !=key[@"description"]) {
               book.desc=key[@"description"];    
               }else{
                   book.desc=@"";
               }
               NSString *tempUrl=key[@"book_url"];
               tempUrl=[tempUrl stringByReplacingOccurrencesOfString:@"localhost" withString:@"192.168.2.28"];
               book.sourceFileUrl=tempUrl;
               tempUrl=key[@"cover_image_url"];
               tempUrl=[tempUrl stringByReplacingOccurrencesOfString:@"localhost" withString:@"192.168.2.28"];
               book.imageUrl=tempUrl;
               if ([NSNull null] !=key[@"title"]) {
               book.title=key[@"title"];
               }else{
                   book.title=@"";
               }
               book.downloaded=@NO;
               book.link=key[@"book_link"];
                 NSLog(@"id %@",book.id);
               NSNumber *num=key[@"booktype"];
               if (num !=(id)[NSNull null]) {
                   book.textBook=num;

               }
               book.downloadedDate=[NSDate dateWithTimeIntervalSinceNow:NSTimeIntervalSince1970];
               NSNumber *numb=key[@"source_file_size"];
             if((id)[NSNull null]!=numb){
               book.size=@([numb floatValue]);
               NSLog(@"%@",book.title);
              
               }
               NSError *error=nil;
               NSURLResponse *response;
//
               NSURLRequest *request=[NSURLRequest requestWithURL:url];
               NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
               book.localPathImageFile=temp;
               [data writeToFile:temp atomically:YES];
NSLog(@"mime type %@",response.MIMEType);
               if (![_dataModelContext save:&error]) {
                   NSLog(@"%@",error);
               }
              
           }else{
               NSNumber *num=key[@"source_file_size"];
               NSNumber *iden=key[@"id"];
               NSString *str=[[NSString alloc ]initWithFormat:@"%@.epub",iden];
               Book *book=[self getBookOfId:str];
               if(num!=(id)[NSNull null]){
                   book.size=@([num floatValue]);
               book.desc=key[@"description"];
               }
                NSLog(@"id %@",iden );
                 NSNumber *type=key[@"booktype"];
               if (type!=(id)[NSNull null]) {
                   book.textBook=type;

               }
                                  NSLog(@"id %@",iden );
                   book.sourceFileUrl=key[@"book_url"];
                      book.imageUrl=key[@"cover_image_url"];
               book.localPathImageFile=temp;

               [self saveData:book];
           }
      //  if ([[NSFileManager defaultManager] fileExistsAtPath:temp]) {
       //     [[NSFileManager defaultManager] removeItemAtPath:temp error:nil];
        //}
           if (![[NSFileManager defaultManager] fileExistsAtPath:temp]) {
               NSURLResponse *response;
               NSError *error;
               NSURLRequest *request=[NSURLRequest requestWithURL:url];
               NSLog(@"locallocation %@ %@",temp,url.absoluteString);
               NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
               NSLog(@"mime type %@",response.MIMEType);
               [data writeToFile:temp atomically:YES];
           }
           
           
    }//end for
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"changed"];

    return YES;
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{

}
@end
