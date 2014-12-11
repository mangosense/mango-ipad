//
//  DataModelControl.h
//  AePubReader
//
//  Created by Nikhil Dhavale on 25/09/12.
//
//

#import <Foundation/Foundation.h>
#import "Book.h"
#import "StoreBooks.h"
#import "NoteHighlight.h"
@interface DataModelControl : NSObject
@property (nonatomic, retain)NSManagedObjectContext* dataModelContext;
-(id)initWithContext:(NSManagedObjectContext *)context;
-(NSInteger)insertStoreBooks:(NSMutableData *)data withPageNumber:(NSInteger )pageNumber;
-(BOOL)checkIfStoreId:(NSNumber *)identity;
-(NSArray *)getDataNotDownloaded;
-(void)saveData:(Book *)book;
-(void)saveStoreBookData:(StoreBooks *)book;
-(Book *)getBookOfId:(NSString *)iden;
- (Book *)getBookOfEJDBId:(NSString *)ejdbId;
-(NSArray *)getDataDownloaded;
-(BOOL)insertIfNew:(NSMutableData *)data;
-(NSArray *)getForPage:(NSInteger )pageNumber;
-(void)displayAllData;
-(StoreBooks *)getBookById:(NSNumber *)identity;
-(BOOL)checkIfIdExists:(NSString *)iden;
-(StoreBooks *)getStoreBookById:(NSString *)productId;
-(void)insertNoteOFHighLight:(BOOL)highLight book:(NSInteger )bookid page:(NSInteger)pageNo string:(NSString *)text;
-(Book*)getBookInstance;
-(void)insertBookWithNo:(StoreBooks *)storeBooks;
-(void)insertBookWithYes:(StoreBooks *)storeBooks;
-(NSArray *)getHighlight:(NSInteger )bookid withPageNo:(NSInteger)pageNumber;
-(NSArray *)getNotes:(NSInteger )bookid withPageNo:(NSInteger)pageNumber;
-(NSArray *)getStoreBooksPurchased;
-(NSArray *)getHighlightorNotes:(NSInteger)bookid withPageNo:(NSInteger)pageNumber withSurroundingString:(NSString *)string;
@property(nonatomic,assign)   NSInteger  downloadedImage;
-(NSArray *)getNoteOrHighlight:(NSInteger )bookid withPageNo:(NSInteger)pageNumber;
-(NSArray *)getNoteWithBook:(NSInteger)bookid ;
-(NSArray *)getHighlightWithBook:(NSInteger)bookid;
-(void)deleteNoteOrHighlight:(NoteHighlight *)hight;
-(NSUInteger)getCount;
-(NoteHighlight *) getNoteOfIdentity:(NSInteger )identity;
-(void)showNotesAndHighlight;
-(NSArray *)getAllUserBooks;
-(NSArray *)getEditedBooks;
@end
