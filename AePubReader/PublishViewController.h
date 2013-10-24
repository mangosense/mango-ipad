//
//  PublishViewController.h
//  MangoReader
//
//  Created by Kedar Kulkarni on 16/09/13.
//
//

#import <UIKit/UIKit.h>

@interface PublishViewController : UIViewController {
    
}

@property (nonatomic, strong) IBOutlet UITextField *titleTextField;
@property (nonatomic, strong) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, strong) IBOutlet UIPickerView *languagePickerView;
@property (nonatomic, strong) IBOutlet UIPickerView *ageGroupPickerView;
@property (nonatomic, strong) IBOutlet UITextField *categoryTextField;

@end
