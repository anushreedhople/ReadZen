//
//  PopOverView.h
//  LearningPlatform2
//
//  Created by Anushree Dhople on 9/16/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@interface PopOverView : UIView
{
    UIColor *backgroundColor;
    CGSize contentSize;
    UIViewController *contentViewController;
    CGSize borders;
}

@property(nonatomic, retain) UIColor *backgroundColor;
@property(readonly, assign) CGSize contentSize;
@property(nonatomic, retain) UIViewController *contentViewController;
@property(nonatomic, assign) CGSize borders;


@end
