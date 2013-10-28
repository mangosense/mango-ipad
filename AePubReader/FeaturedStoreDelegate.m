//
//  FeaturedStoreDelegate.m
//  MangoReader
//
//  Created by Nikhil Dhavale on 25/10/13.
//
//

#import "FeaturedStoreDelegate.h"
@implementation FeaturedStoreDelegate
-(id)initPrefixString:(NSString *)string{
    self=[super init];
    if (self) {
        _string=string;
        self.items = [NSMutableArray array];
        for (int i = 0; i < 100; i++)
        {
            [_items addObject:@(i)];
        }
    }
    return self;
}
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    NSLog(@"number of items %d %@",_items.count,_string);
    return [_items count];
}
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    if (index==1) {
        NSLog(@"viewforitem %@",_string);

    }
    //create new view if no view is available for recycling
    if (view == nil)
    {
        //don't do anything specific to the index within
        //this `if (view == nil) {...}` statement because the view will be
        //recycled and used with other index values later
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200.0f, 30.0f)];
        ((UIImageView *)view).image = [UIImage imageNamed:@"page.png"];
        view.contentMode = UIViewContentModeCenter;
        
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [label.font fontWithSize:20];
        label.tag = 1;
        [view addSubview:label];
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    label.text =[ NSString stringWithFormat:@"%@%@",_string,[_items[index] stringValue] ];
    
    return view;
}

@end
