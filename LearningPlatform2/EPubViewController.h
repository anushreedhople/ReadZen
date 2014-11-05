//
//  DetailViewController.h
//  LearningPlatform2
//
//  Created by Anushree Dhople on 7/27/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZipArchive.h"
#import "EPub.h"
#import "Chapter.h"
#import "ReadingMetric.h"
#import "LPDropViewController.h"
#import "LPNotesViewController.h"

@class SearchResultsViewController;
@class SearchResult;
#import <MessageUI/MessageUI.h>

@interface EPubViewController : UIViewController <MFMailComposeViewControllerDelegate,UIWebViewDelegate, ChapterDelegate, UISearchBarDelegate,environmentChange,UIPopoverControllerDelegate> {
    
    UIToolbar *toolbar;
        
	UIWebView *webView;
    
    UIBarButtonItem* chapterListButton;
	
	UIBarButtonItem* decTextSizeButton;
	UIBarButtonItem* incTextSizeButton;
    
    UISlider* pageSlider;
    UILabel* currentPageLabel;
			
	EPub* loadedEpub;
	int currentSpineIndex;
	int currentPageInSpineIndex;
	int pagesInCurrentSpineCount;
	int currentTextSize;
	int totalPagesCount;
    int actualPagesCount;
    
    BOOL epubLoaded;
    BOOL paginating;
    BOOL searching;
    
    UIPopoverController* chaptersPopover;
    UIPopoverController* searchResultsPopover;

    SearchResultsViewController* searchResViewController;
    SearchResult* currentSearchResult;
    LPDropViewController *m_objDropViewController;
    UIPopoverController *m_popOverNotes;
    
    LPNotesViewController *m_objNotesViewController;
    NSString *booksource;
    
    ReadingMetric* readingMetric;
}

- (IBAction) showChapterIndex:(id)sender;
- (IBAction) increaseTextSizeClicked:(id)sender;
- (IBAction) decreaseTextSizeClicked:(id)sender;
- (IBAction) slidingStarted:(id)sender;
- (IBAction) slidingEnded:(id)sender;
- (IBAction) doneClicked:(id)sender;
- (IBAction) openWebLink:(id)sender;

@property (retain, nonatomic) IBOutlet UIView *searchView;
- (void) loadSpine:(int)spineIndex atPageIndex:(int)pageIndex highlightSearchResult:(SearchResult*)theResult;
- (void) hideSearchView;
- (void) loadEpub:(NSURL*) epubURL;
-(void) loadBookSource:(NSString *)bookweblink;
- (void) storeCurrentPageNo;
- (void) setBookIndex:(int)bookIndex;
-(void) removeAllHighLights;

- (void) loadSpineWithTitle:(NSString *)strTitle andSpineIndex:(int) iSpineIndex;

- (void)showPopover:(id)sender;
- (void) highLightBookMark:(BOOL) bIsYes;

@property (nonatomic, retain) EPub* loadedEpub;
@property (nonatomic, retain) NSString* strBookName;

@property (nonatomic, retain) SearchResult* currentSearchResult;

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *chapterListButton;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *decTextSizeButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *incTextSizeButton;

@property (nonatomic, retain) IBOutlet UISlider *pageSlider;
@property (nonatomic, retain) IBOutlet UILabel *currentPageLabel;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *websource;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *weblink;
@property BOOL searching;
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) UIPopoverController *popController;

@property (nonatomic, retain) IBOutlet UIButton *btnHome;
- (IBAction)takeToHomeScreen:(id)sender;

@property (nonatomic, retain) IBOutlet UIButton *chapter;
- (IBAction)showChapterList:(id)sender;

@property (nonatomic, retain) IBOutlet UIButton *readingMetric;
- (IBAction)showReadingMetric:(id)sender;

@property (nonatomic, retain) IBOutlet UIButton *btnBookMarkPage;
- (IBAction)takeToBookMarkPage:(id)sender;


@property (retain, nonatomic) IBOutlet UIView *m_vwBookMark;
- (IBAction)fontSizeChanged:(id)sender;



@property (nonatomic, retain) IBOutlet UIButton *btnSearch;
- (IBAction)openSearchPanel:(id)sender;


@property (nonatomic, retain) IBOutlet UIButton *btnBrightness;
- (IBAction)adjustBrightness:(id)sender;


@property (nonatomic, retain) IBOutlet UIButton *btnBookMark;
- (IBAction)showBookMarks:(id)sender;

-(void) removeAllHighLights;

@end
