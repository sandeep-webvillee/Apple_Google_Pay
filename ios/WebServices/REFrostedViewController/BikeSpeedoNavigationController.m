//
//  DEMONavigationController.m
//  REFrostedViewControllerStoryboards
//
//  Created by Roman Efimov on 10/9/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import "BikeSpeedoNavigationController.h"

@interface BikeSpeedoNavigationController ()

@end

@implementation BikeSpeedoNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBarHidden = YES;
}

#pragma mark -
#pragma mark Gesture recognizer

//- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
//{
//    // Dismiss keyboard (optional)
//    //
//    [self.view endEditing:YES];
//    [self.frostedViewController.view endEditing:YES];
//    
//    // Present the view controller
//    //
//    [self.frostedViewController panGestureRecognized:sender];
//}

@end
