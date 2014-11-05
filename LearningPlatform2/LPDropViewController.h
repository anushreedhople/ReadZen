//
//  LPDropViewController.h
//  LearningPlatform2
//
//  Created by Anil Kothari on 11/10/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol environmentChange <NSObject>

-(void) increaseFontSize;
-(void) decreaseFontSize;
-(void) restoreToDefault;


@end

@interface LPDropViewController : UIViewController {
    
    
    
}
@property (assign, nonatomic) id<environmentChange>  delegate;
@property (weak, nonatomic) IBOutlet UIButton *restoreToDefault;
@property (weak, nonatomic) IBOutlet UISlider *m_sliderBrightness;

@property (weak, nonatomic) IBOutlet UIButton *decreaseSize;
@property (assign, nonatomic) NSUInteger iViewName;
@property (strong, nonatomic) IBOutlet UIView *m_vwTextSize;
@property (weak, nonatomic) IBOutlet UIButton *increaseFont;

- (IBAction)brightnessValueChanged:(id)sender;
- (IBAction)contrastValueChanged:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *m_vwBrightness;
- (IBAction)contrast1:(id)sender;

@end
