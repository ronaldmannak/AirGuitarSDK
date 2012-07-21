//
//  AGViewController.m
//  AirGuitarSDKDemo
//
//  Created by Ronald Mannak on 7/20/12.
//  Copyright (c) 2012 Yobble. All rights reserved.
//

#import "AGViewController.h"
#import "AirGuitarSDK.h"
#import "AGAccessoryManager.h"

@interface AGViewController ()

@end

@implementation AGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AGAccessoryManager *manager = [AGAccessoryManager sharedAccessoryManager];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
