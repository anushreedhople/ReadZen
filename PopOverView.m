//
//  PopOverView.m
//  LearningPlatform2
//
//  Created by Anushree Dhople on 9/16/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import "PopOverView.h"

@implementation PopOverView

@synthesize backgroundColor, borders, contentSize, contentViewController;

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"] || [keyPath isEqualToString:@"borders"])
    {
        contentSize = CGRectInset(self.frame, borders.width, borders.height).size;
        contentViewController.view.frame = CGRectMake(borders.width, borders.height, contentSize.width, contentSize.height);
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = NO;
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor colorWithRed:50/256 green:50/256 blue:50/256 alpha:0.75f];
        self.borders = CGSizeMake(25, 25);
        contentSize = CGRectInset(frame, borders.width * 2, borders.height * 2).size;
        self.userInteractionEnabled = YES;
        
        [self addObserver:self forKeyPath:@"frame"      options:kNilOptions context:nil];
        [self addObserver:self forKeyPath:@"borders"    options:kNilOptions context:nil];
    }
    
    return self;
}

-(void) setContentViewController:(UIViewController *)contentViewController_
{
    if (contentViewController_ != self->contentViewController)
    {
        [self->contentViewController.view removeFromSuperview];
        
        self->contentViewController = contentViewController_;
        [self addSubview:contentViewController_.view];
        contentViewController_.view.frame = CGRectMake(borders.width, borders.height, contentSize.width, contentSize.height);
    }
}

void CGContextDrawRoundedRect(CGContextRef context, CGColorRef color, CGRect bounds, CGFloat radius);

void CGContextDrawRoundedRect(CGContextRef context, CGColorRef color, CGRect bounds, CGFloat radius)
{
    CGContextSetFillColorWithColor(context, color);
    
    // If you were making this as a routine, you would probably accept a rectangle
    // that defines its bounds, and a radius reflecting the "rounded-ness" of the rectangle.
    CGRect rrect = bounds;
    
    // NOTE: At this point you may want to verify that your radius is no more than half
    // the width and height of your rectangle, as this technique degenerates for those cases.
    
    // In order to draw a rounded rectangle, we will take advantage of the fact that
    // CGContextAddArcToPoint will draw straight lines past the start and end of the arc
    // in order to create the path from the current position and the destination position.
    
    // In order to create the 4 arcs correctly, we need to know the min, mid and max positions
    // on the x and y lengths of the given rectangle.
    CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
    
    // Next, we will go around the rectangle in the order given by the figure below.
    //       minx    midx    maxx
    // miny    2       3       4
    // midy   1 9              5
    // maxy    8       7       6
    // Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't
    // form a closed path, so we still need to close the path to connect the ends correctly.
    // Thus we start by moving to point 1, then adding arcs through each pair of points that follows.
    // You could use a similar tecgnique to create any shape with rounded corners.
    
    // Start at 1
    CGContextMoveToPoint(context, minx, midy);
    // Add an arc through 2 to 3
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    // Add an arc through 4 to 5
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    // Add an arc through 6 to 7
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    // Add an arc through 8 to 9
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    // Close the path
    CGContextClosePath(context);
    // Fill the path
    CGContextDrawPath(context, kCGPathFill);
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGColorRef color = [backgroundColor CGColor];
    
    CGContextDrawRoundedRect(currentContext, color, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height), 10);
}


@end