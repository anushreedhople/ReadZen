//
//  ArrowView.m
//  LearningPlatform2
//
//  Created by Anushree Dhople on 9/16/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import "ArrowView.h"

#define CGRectCenter(rect) CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
#define CGSizeDiv(size, div) CGSizeMake(size.width / div, size.height / div)

@implementation ArrowView

@synthesize arrowColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = NO;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(currentContext, arrowColor.CGColor);
    
    CGPoint arrowLocation =  CGRectCenter(self.bounds);
    CGSize arrowSize = CGSizeDiv(self.frame.size, 1);
    
    CGPoint arrowTip = CGPointMake(arrowLocation.x, arrowLocation.y + (arrowSize.height / 2));
    CGPoint arrowLeftFoot = CGPointMake(arrowLocation.x - (arrowSize.width / 2), arrowLocation.y - (arrowSize.height / 2));
    CGPoint arrowRightFoot = CGPointMake(arrowLocation.x + (arrowSize.width / 2), arrowLocation.y - (arrowSize.height / 2));
    
    // now we draw the triangle
    CGContextMoveToPoint(currentContext, arrowTip.x, arrowTip.y);
    CGContextAddLineToPoint(currentContext, arrowLeftFoot.x, arrowLeftFoot.y);
    CGContextAddLineToPoint(currentContext, arrowRightFoot.x, arrowRightFoot.y);
    
    CGContextClosePath(currentContext);
    CGContextDrawPath(currentContext, kCGPathFill);
}

@end