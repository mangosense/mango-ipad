//
//  ViewController.m
//  WebserviceTesting
//
//  Created by Nikhil Dhavale on 19/12/12.
//
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_prev release];
    [_next release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setPrev:nil];
    [self setNext:nil];
    [super viewDidUnload];
}
@end
