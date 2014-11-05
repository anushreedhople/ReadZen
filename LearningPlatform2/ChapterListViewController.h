//
//  ChapterListViewController.h
//  LearningPlatform2
//
//  Created by Anushree Dhople on 7/27/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EPubViewController.h"
enum{
    TABLE_CHAPTER,
    TABLE_BOOKMARK,
    TABLE_HIGHLIGHT,
    TABLE_NOTES
};
@interface ChapterListViewController : UIViewController {
    EPubViewController* epubViewController;
    NSMutableArray *marrBookMarkData;
    NSMutableArray *marrHighlightData;
    NSMutableArray *marrNotesData;
    int iTableLoad;
    
}
@property(nonatomic, assign) NSString* strBookName;

@property(nonatomic, assign) EPubViewController* epubViewController;
@property (retain, nonatomic) IBOutlet UIView *m_vwTopView;
@property (retain, nonatomic) IBOutlet UILabel *m_lblBookName;
@property (retain, nonatomic) IBOutlet UIView *m_vwFooterView;
@property (retain, nonatomic) IBOutlet UIButton *btnContent;
@property (retain, nonatomic) IBOutlet UIButton *btnVocabulary;
@property (retain, nonatomic) IBOutlet UIButton *btnBookmarks;
@property (retain, nonatomic) IBOutlet UIButton *btnHighlights;
@property (retain, nonatomic) IBOutlet UITableView *m_tblChapterList;
- (IBAction)bookPressed:(id)sender;
- (IBAction)contentTapped:(id)sender;
- (IBAction)vocabularyTapped:(id)sender;
- (IBAction)bookmarksTapped:(id)sender;
- (IBAction)highlightsTapped:(id)sender;

@end

