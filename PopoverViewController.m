//
//  PopoveViewController.m
//  LearningPlatform2
//
//  Created by Anushree Dhople on 9/16/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import "PopoverViewController.h"

#define degreestoradians(x) (M_PI * x / 180)

@implementation PopoverViewController

@synthesize arrowDirection, arrow, popover;

-(void) updateArrowPosition
{
    if (arrowDirection & UIPopoverArrowDirectionUp)
    {
        arrow.frame = CGRectMake((popover.frame.origin.x) + (popover.frame.size.width / 2) - (arrow.frame.size.width / 2), popover.frame.origin.y - (arrow.frame.size.height), arrow.frame.size.width, arrow.frame.size.height);
        arrow.transform = CGAffineTransformMakeRotation(degreestoradians(180));
    }
    else if (arrowDirection & UIPopoverArrowDirectionLeft)
    {
        arrow.frame = CGRectMake((popover.frame.origin.x) - (arrow.frame.size.width), (popover.frame.origin.y) + (popover.frame.size.height / 2) -  (arrow.frame.size.height / 2), arrow.frame.size.width, arrow.frame.size.height);
        arrow.transform = CGAffineTransformMakeRotation(degreestoradians(90));
    }
    else if (arrowDirection & UIPopoverArrowDirectionRight)
    {
        arrow.frame = CGRectMake((popover.frame.origin.x) + (popover.frame.size.width), (popover.frame.origin.y) + (popover.frame.size.height / 2) - (arrow.frame.size.height / 2), arrow.frame.size.width, arrow.frame.size.height);
        arrow.transform = CGAffineTransformMakeRotation(degreestoradians(-90));
    }
    else if (arrowDirection & UIPopoverArrowDirectionDown)
    {
        arrow.frame = CGRectMake((popover.frame.origin.x) + (popover.frame.size.width / 2) - (arrow.frame.size.width / 2), popover.frame.origin.y + popover.frame.size.height, arrow.frame.size.width, arrow.frame.size.height);
    }
    else
    {
        NSLog(@"unknown direction %i", arrowDirection);
    }
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self updateArrowPosition];
}

-(void) dismiss
{
    [self dismissModallyFromViewController:parentViewController animated:YES];
}

-(void) presentModallyInViewController:(UIViewController *)controller animated:(BOOL)animated
{
    [controller.view addSubview:self.view];
    
    if (animated)
    {
        self.view.alpha = 0.0f;
        
        [UIView beginAnimations:@"Modal Entrance" context:nil];
        [UIView setAnimationDuration:0.25];
        
        self.view.alpha = 1.0f;
        
        [UIView commitAnimations];
    }
}

-(void) dismissModallyFromViewController:(UIViewController *)controller animated:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.view.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [controller dismissModalViewControllerAnimated:NO];
        }];
    }
    else
    {
        [controller dismissModalViewControllerAnimated:NO];
    }
}

-(id) init
{
    if (self = [super init])
    {
        popover = [PopOverView new];
        arrow   = [ArrowView new];
        
        popover.backgroundColor = [UIColor colorWithRed:50/255 green:50/255 blue:50/255 alpha:0.75];
        arrow.arrowColor        = [UIColor colorWithRed:50/255 green:50/255 blue:50/255 alpha:0.75];
        arrow.frame             = CGRectMake(0, 0, 20, 20);
        
        [self addObserver:self forKeyPath:@"arrowDirection" options:kNilOptions context:nil];
        [popover addObserver:self forKeyPath:@"frame"       options:kNilOptions context:nil];
        
        
        
        [self.view addSubview:popover];
        [self.view addSubview:arrow];
        
        arrowDirection = UIPopoverArrowDirectionRight;
    }
    
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismiss];
}


@end