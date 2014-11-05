//
//  LPDropViewController.m
//  LearningPlatform2
//
//  Created by Anil Kothari on 11/10/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import "LPDropViewController.h"

@interface LPDropViewController ()

@end

@implementation LPDropViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.m_vwBrightness.hidden=YES;
    self.m_vwTextSize.hidden=YES;
    
 

    if (_iViewName == E_BrightNess) {
        self.view.frame=self.m_vwBrightness.frame;

        self.m_vwBrightness.hidden=NO;
        [self.view addSubview:self.m_vwBrightness];
        
        
        UIScreen *screen=[UIScreen mainScreen];
        CGFloat val=screen.brightness;

        _m_sliderBrightness.value=val;
        
     }else if (_iViewName == E_TextSize){
        self.view.frame=self.m_vwTextSize.frame;

        self.m_vwTextSize.hidden=NO;
        [self.view addSubview:self.m_vwTextSize];

    }
    
    
    [self.increaseFont addTarget:self.delegate action:@selector(increaseFontSize) forControlEvents:UIControlEventTouchDown];
    [self.decreaseSize addTarget:self.delegate action:@selector(decreaseFontSize) forControlEvents:UIControlEventTouchDown];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)brightnessValueChanged:(id)sender {
    UISlider *slider=(UISlider *)sender;
    CGFloat sliderValue=slider.value;
    [[UIScreen mainScreen] setBrightness:sliderValue];
    
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];
    
    if (touch.view.tag > 0) {
        touch.view.center = location;
    }
    
    CGPoint locationPoint = [[touches anyObject] locationInView:self.view];
    UIView* viewYouWishToObtain = [self.view hitTest:locationPoint withEvent:event];

    
    if (viewYouWishToObtain.tag==100) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_DROP_VIEW" object:nil];
    }
    
//
}

- (IBAction)contrastValueChanged:(id)sender {
}

- (IBAction)contrast1:(id)sender {
}
@end
