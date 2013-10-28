//
//  NewStoreCoverViewController.h
//  MangoReader
//
//  Created by Nikhil Dhavale on 25/10/13.
//
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
@interface NewStoreCoverViewController : UIViewController<UISearchBarDelegate,iCarouselDelegate>
- (IBAction)changeCategory:(id)sender;
@property (weak, nonatomic) IBOutlet iCarousel *featured;
@property (weak, nonatomic) IBOutlet iCarousel *newarrivals;
@property (weak, nonatomic) IBOutlet iCarousel *mangopacks;
@property (weak, nonatomic) IBOutlet iCarousel *popularBooks;

@end
