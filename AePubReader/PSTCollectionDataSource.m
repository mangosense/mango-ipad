//
//  PSTCollectionDataSource.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 31/07/13.
//
//

#import "PSTCollectionDataSource.h"
#import "OldCell.h"
#import "Book.h"
#import "StoreBooks.h"
#import "LiveViewController.h"
#import "LibraryOldCell.h"
#import "AePubReaderAppDelegate.h"
#import "LibraryViewController.h"
@implementation PSTCollectionDataSource
- (NSInteger)numberOfSectionsInCollectionView:(PSUICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(PSUICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _array.count;
}
- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OldCell *cell;
    LibraryOldCell *cellLibrary;
    Book *book;
    StoreBooks *bookStore;
    UIImage *image;
    LibraryViewController *library;
     AePubReaderAppDelegate *delegate=(AePubReaderAppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *title;
    NSString  *value;
    NSString *path;
      switch (_controllerCount) {
        case 0:
              library=(LibraryViewController *)_controller;
              cellLibrary=(LibraryOldCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell"forIndexPath:indexPath];
              book=_array[indexPath.row];
          //    NSLog(@"title %@",book.title);
              cellLibrary.button.storeViewController=nil;
              cellLibrary.button.libraryViewController=library;
              cellLibrary.button.stringLink=book.link;
              cellLibrary.shareButton.hidden=YES;
              cellLibrary.buttonDelete.hidden=YES;

              
              if (indexPath==0&&delegate.addControlEvents) {
                  cellLibrary.button.downloading=YES;
              }
             title=[NSString stringWithFormat:@"%@.jpg",book.id];
              value=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
              
              
              title=[value stringByAppendingPathComponent:title];
              image=[UIImage imageWithContentsOfFile:title];
              cellLibrary.button.imageLocalLocation=title;
              cellLibrary.button.tag=indexPath.row;
              [cellLibrary.button setImage:image forState:UIControlStateNormal];
              [cellLibrary.button addTarget:_controller action:@selector(showBookButton:) forControlEvents:UIControlEventTouchUpInside];
              
              if (!library.allowOptions) {
                  
                  cellLibrary.shareButton.imageLocalLocation=title;
                  cellLibrary.shareButton.tag=indexPath.row;
                  
                  
                  
                  cellLibrary.shareButton.stringLink=book.link;
                  [cellLibrary.shareButton addTarget:_controller action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                  [cellLibrary.shareButton setHidden:NO];
                  
                  
                  
              }else if(library.allowOptions){
                  cellLibrary.shareButton.hidden=YES;
              }
              
            [cellLibrary.button addTarget:_controller action:@selector(showBookButton:) forControlEvents:UIControlEventTouchUpInside];
              if (library.recordButton) {
                  
                  
                  if (library.recordButtonShow) {
                      path=[[NSUserDefaults standardUserDefaults] objectForKey:@"recordingDirectory"];
                      
                      NSLog(@"%@",path);
                      
                      path =[path stringByAppendingFormat:@"/%@",book.id];
                      /*
                       Check if recording exists
                       */
                      if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                          
                          
                          cellLibrary.showRecording.tag=[book.id integerValue];
                          [cellLibrary.showRecording addTarget:_controller action:@selector(RecordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                          cellLibrary.showRecording.hidden=NO;}
                  }else{
                      cellLibrary.showRecording.hidden=YES;
                  }
                  
              }
              if(library.deleteButton){
                  if(library.showDeleteButton){
                      cellLibrary.buttonDelete.tag=indexPath.row;
                      [cellLibrary.buttonDelete addTarget:_controller action:@selector(DeleteBook:) forControlEvents:UIControlEventTouchUpInside];
                      cellLibrary.buttonDelete.hidden=NO;
                  }else{
                      cellLibrary.buttonDelete.hidden=YES;
                      
                  }
              }
              if (_array.count-1==indexPath.row) {
                  library.recordButton=NO;
                  library.deleteButton=NO;
              }
              return cellLibrary;
            break;
        case 1:
            cell=(OldCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
           book=_array[indexPath.row];
            cell.button.storeViewController=(DownloadViewControlleriPad *)_controller;
            cell.button.stringLink=book.link;
            cell.button.tag=[book.id integerValue];
            image=[UIImage imageWithContentsOfFile:book.localPathImageFile];
            cell.button.imageLocalLocation=book.localPathImageFile;
            [ cell.button setImage:image forState:UIControlStateNormal];
            [ cell.button setAlpha:0.7];

            [cell.button addTarget:_controller action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
            cell.button.storeViewController=(DownloadViewControlleriPad *)_controller;
            break;
        case 2:
            cell=(OldCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
            bookStore=_array[indexPath.row];
            cell.button.stringLink=bookStore.bookLink;
            cell.button.tag=[bookStore.productIdentity integerValue];
            image=[UIImage imageWithContentsOfFile:bookStore.localImage];
            cell.button.imageLocalLocation=bookStore.localImage;
            [cell.button setImage:image forState:UIControlStateNormal];
            [cell.button setAlpha:0.7];
            [cell.button addTarget:_controller action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
            break;
    }

    return cell;
}
- (PSUICollectionReusableView *)collectionView:(PSUICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if(_controllerCount==2){
    LiveViewController *controller=(LiveViewController *)_controller;
	 if ([kind isEqualToString:PSTCollectionElementKindSectionFooter]) {
		
	}
    controller.oldFootView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"Footer" forIndexPath:indexPath];
	[controller.oldFootView setTarget:_controller];
    // TODO Setup view
	
    return controller.oldFootView;
    }
    return nil;
}

@end
