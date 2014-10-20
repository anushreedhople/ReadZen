//
//  PopoveViewController.h
//  LearningPlatform2
//
//  Created by Anushree Dhople on 9/16/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopoverView.h"
#import "ArrowView.h"

@interface PopoverViewController : UIViewController
{
    PopOverView *popover;
    ArrowView *arrow;
    
    UIPopoverArrowDirection arrowDirection;
    
    UIViewController *parentViewController;
    
}

// for managing the content
@property(readonly, retain)  PopOverView *popover;

// the arrow
@property(readonly, retain) ArrowView *arrow;
@property(nonatomic, assign) UIPopoverArrowDirection arrowDirection;

-(void) presentModallyInViewController:(UIViewController *) controller animated:(BOOL) animated;
-(void) dismissModallyFromViewController:(UIViewController *) controller animated:(BOOL) animated;

-(void) dismiss;

@end