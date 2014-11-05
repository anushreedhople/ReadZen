//
//  LPNotesViewController.m
//  LearningPlatform2
//
//  Created by Anil Kothari on 12/10/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import "LPNotesViewController.h"

@interface LPNotesViewController ()

@end

@implementation LPNotesViewController

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
    
    _m_vwScreen.layer.cornerRadius=5.0f;
    
    id lblDate=[self.m_vwScreen viewWithTag:102];
    if ([lblDate isKindOfClass:[UILabel class]]) {
        ((UILabel*)lblDate).text=[self setDateTime];
    }
    
    
    for (id view in self.m_lblFooter.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn=((UIButton *)view);
            if (btn.tag>=110 && btn.tag<=115) {
                btn.layer.cornerRadius=btn.frame.size.width/2;
                [btn addTarget:self action:@selector(changeColor:) forControlEvents:UIControlEventTouchDown];
            }
        }
    
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];

    
    
}
-(void)onKeyboardHide:(NSNotification *)notification
{
    
    
    
 }

-(void)saveTextInDefaults{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *marr=[[NSMutableArray alloc] init];
    
    NSDictionary *dictHighLightedTextInfo=[[NSDictionary alloc] initWithObjectsAndKeys:self.m_strBookName,@"bookName",self.m_strChapterName,@"chapterName",self.m_txtView.text,@"notesText",self.m_strAnchorNodeContent,@"anchorNode",self.m_strHighlighted,@"highlightedText", nil];

    if ([userDefaults objectForKey:@"notesTextData"]) {
        if ([[userDefaults objectForKey:@"notesTextData"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in [userDefaults objectForKey:@"notesTextData"]) {
                [marr addObject:dict];
                if (dict == dictHighLightedTextInfo) {
                    return;
                }
            }
        }
    }
    
    
    
    [marr addObject:dictHighLightedTextInfo];
    
    [userDefaults setObject:marr forKey:@"notesTextData"];
    
    
}


-(void) setCenter:(CGPoint)point{
    _m_vwScreen.center=point;
}

-(void)changeColor:(UIButton *)sender{
    UIColor *color=sender.backgroundColor;
    _m_vwScreen.backgroundColor=color;
    
    
}
-(NSString *)setDateTime{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd MMMM yyyy hh:mm a"];
    
    NSDate *now = [[NSDate alloc] init];
    
    NSString *theDate = [dateFormat stringFromDate:now];
    
    return theDate;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)trashTapped:(id)sender {
    
    id txtNoteView=[self.m_vwScreen viewWithTag:101];
    if ([txtNoteView isKindOfClass:[UITextView class]]) {
        ((UITextView*)txtNoteView).text=@"";
    }
}








-(void)dealloc{
 

}
- (IBAction)saveData:(id)sender {
    
    [self saveTextInDefaults];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_NOTES_VIEW" object:nil];
    

}
@end
