//
//  LPLibraryViewController.h
//  LearningPlatform2
//
//  Created by Anushree Dhople on 7/22/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EPubViewController.h"

@protocol CustomMethodDelegate
-(void)doSomething;
@end

@interface LPLibraryViewController : UIViewController <UINavigationControllerDelegate>

@property (strong,nonatomic) id<CustomMethodDelegate> delegate;

@property (retain, nonatomic) IBOutlet UIButton *gotoLibrary;
@property (strong, nonatomic) NSMutableArray *bookids;

-(void)gotoCentralLibrary:(UIBarButtonItem *)sender;

-(void)buttonTouched:(id)sender;
-(void)buttonPressed:(id)sender;
-(void)viewDidAppearCustomized;
- (BOOL)connectedToInternet;

-(IBAction)sort:(id)sender;

@end
