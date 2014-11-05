//
//  LPNotesViewController.h
//  LearningPlatform2
//
//  Created by Anil Kothari on 12/10/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPNotesViewController : UIViewController
- (IBAction)trashTapped:(id)sender;
@property (retain, nonatomic) IBOutlet UIView *m_lblFooter;
@property (weak, nonatomic) IBOutlet UITextView *m_txtView;
@property (retain, nonatomic) IBOutlet UIView *m_vwScreen;

- (IBAction)saveData:(id)sender;

@property (nonatomic, strong) NSString *m_strChapterName;
@property (nonatomic, strong) NSString *m_strBookName;
@property (nonatomic, strong) NSString *m_strAnchorNodeContent;
@property (nonatomic, strong) NSString *m_strHighlighted;
-(void) setCenter:(CGPoint)point;
@end
