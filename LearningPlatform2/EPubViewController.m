//
//  DetailViewController.m
//  AePubReader
//
//  Created by Federico Frappi on 04/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EPubViewController.h"
#import "ChapterListViewController.h"
#import "SearchResultsViewController.h"
#import "SearchResult.h"
#import "UIWebView+SearchWebView.h"
#import "Chapter.h"
#import "Parse/Parse.h"
#import "ReadingMetric.h"

@interface EPubViewController()


- (void) gotoNextSpine;
- (void) gotoPrevSpine;
- (void) gotoNextPage;
- (void) gotoPrevPage;

- (int) getGlobalPageCount;

- (void) gotoPageInCurrentSpine: (int)pageIndex;
- (void) updatePagination;

- (void) loadSpine:(int)spineIndex atPageIndex:(int)pageIndex;


@end

@implementation EPubViewController

int bookIndex;

@synthesize loadedEpub, toolbar, webView; 
@synthesize chapterListButton, decTextSizeButton, incTextSizeButton;
@synthesize currentPageLabel, pageSlider, searching;
@synthesize currentSearchResult;
@synthesize  weblink, websource;

#pragma mark -

- (void) loadEpub:(NSURL*) epubURL{
    currentSpineIndex = 0;
    currentPageInSpineIndex = 0;
    pagesInCurrentSpineCount = 0;
    totalPagesCount = 0;
	searching = NO;
    epubLoaded = NO;
    self.loadedEpub = [[EPub alloc] initWithEPubPath:[epubURL path]];
    epubLoaded = YES;
    NSLog(@"loadEpub");
	[self updatePagination];
    readingMetric = [[ReadingMetric alloc]init];
    [readingMetric setBookIndex:bookIndex];
    [readingMetric bookIsOpened:[NSDate date]];
    //NSLog(@"The global page count is %d",[self getGlobalPageCount]);
    [readingMetric setTotalPages:[self getGlobalPageCount]];
}

-(void) loadBookSource:(NSString *)bookweblink {
    booksource=bookweblink;
}

- (void) chapterDidFinishLoad:(Chapter *)chapter{
    totalPagesCount+=chapter.pageCount;

	if(chapter.chapterIndex + 1 < [loadedEpub.spineArray count]){
		[[loadedEpub.spineArray objectAtIndex:chapter.chapterIndex+1] setDelegate:self];
		[[loadedEpub.spineArray objectAtIndex:chapter.chapterIndex+1] loadChapterWithWindowSize:webView.bounds fontPercentSize:currentTextSize];
		[currentPageLabel setText:[NSString stringWithFormat:@"?/%d", totalPagesCount]];
	} else {
		[currentPageLabel setText:[NSString stringWithFormat:@"%d/%d",[self getGlobalPageCount], totalPagesCount]];
		[pageSlider setValue:(float)100*(float)[self getGlobalPageCount]/(float)totalPagesCount animated:YES];
		paginating = NO;
		//NSLog(@"Pagination Ended!");
        
        /*QuickFix - pages not getting loaded when book is opened first TODO*/
        [self gotoNextPage];
        [self gotoPrevPage];
        
        /*Finished loading the book. Check if page number exists in User db and load relevant page*/
         //NSLog(@"Book loaded... checking for last page");
         NSArray *spineIndexes = [[PFUser currentUser] valueForKey:@"spineindex"];
         NSArray *pageIndexes = [[PFUser currentUser] valueForKey:@"pageindex"];
         
         int spineIndex = [[spineIndexes objectAtIndex:bookIndex]intValue];
         int pageIndex = [[pageIndexes objectAtIndex:bookIndex]intValue];
         
         if(spineIndex != 0 && pageIndex !=0) {
         //NSLog(@"Previous loaded page found... shifting to it");
         [self loadSpine:spineIndex atPageIndex:pageIndex highlightSearchResult:nil];
         }
         //NSLog(@"loadEpub spineIndex %d pageIndex %d",spineIndex,pageIndex);

	}
}

-(void)storeCurrentPageNo {
    
    NSMutableArray *spineIndex = [[NSMutableArray alloc] init];
    NSMutableArray *pageIndex = [[NSMutableArray alloc]init];

    [spineIndex addObjectsFromArray:[[PFUser currentUser] valueForKey:@"spineindex"]];
    [pageIndex addObjectsFromArray:[[PFUser currentUser] valueForKey:@"pageindex"]];
    
    [spineIndex replaceObjectAtIndex:bookIndex withObject:[NSString stringWithFormat:@"%d",currentSpineIndex]];
    [pageIndex replaceObjectAtIndex:bookIndex withObject:[NSString stringWithFormat:@"%d", currentPageInSpineIndex]];
    
    /*Add it to the Parse PFUser database*/
    PFUser *user = [PFUser currentUser];
    user[@"spineindex"] = spineIndex;
    user[@"pageindex"]=pageIndex;
    [[PFUser currentUser] saveInBackground];

}

-(void)setBookIndex:(int)receivedBookIndex{
    bookIndex = receivedBookIndex;
}

- (int) getGlobalPageCount{
	int pageCounting = 0;
    
	for(int i=1; i<currentSpineIndex; i++){
		pageCounting+= [[loadedEpub.spineArray objectAtIndex:i] pageCount];
    }
	pageCounting+=currentPageInSpineIndex+1;
	return pageCounting;
}

- (void) loadSpine:(int)spineIndex atPageIndex:(int)pageIndex {
	[self loadSpine:spineIndex atPageIndex:pageIndex highlightSearchResult:nil];
}

- (void) loadSpine:(int)spineIndex atPageIndex:(int)pageIndex highlightSearchResult:(SearchResult*)theResult{
	
	webView.hidden = YES;
	
	self.currentSearchResult = theResult;

	[chaptersPopover dismissPopoverAnimated:YES];
	[searchResultsPopover dismissPopoverAnimated:YES];
	
	NSURL* url = [NSURL fileURLWithPath:[[loadedEpub.spineArray objectAtIndex:spineIndex] spinePath]];
    //NSLog(@"The url is %@",url);
	[webView loadRequest:[NSURLRequest requestWithURL:url]];
	currentPageInSpineIndex = pageIndex;
	currentSpineIndex = spineIndex;
    
    
	if(!paginating){
		[currentPageLabel setText:[NSString stringWithFormat:@"%d/%d",[self getGlobalPageCount], totalPagesCount]];
		[pageSlider setValue:(float)100*(float)[self getGlobalPageCount]/(float)totalPagesCount animated:YES];	
	}
    
    /*change pagesInCurrentSpineIndex variable also*/
	/*int totalWidth = [[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollWidth"] intValue];
	pagesInCurrentSpineCount = (int)((float)totalWidth/webView.bounds.size.width);
    NSLog(@"loadSpine totalWidth:%d webView width %f", totalWidth, webView.bounds.size.width);*/
    
    
    webView.hidden=NO;
}

- (void) gotoPageInCurrentSpine:(int)pageIndex{
	if(pageIndex>=pagesInCurrentSpineCount){
		pageIndex = pagesInCurrentSpineCount - 1;
		currentPageInSpineIndex = pagesInCurrentSpineCount - 1;	
	}
	
	float pageOffset = pageIndex*webView.bounds.size.width;

	NSString* goToOffsetFunc = [NSString stringWithFormat:@" function pageScroll(xOffset){ window.scroll(xOffset,0); } "];
	NSString* goTo =[NSString stringWithFormat:@"pageScroll(%f)", pageOffset];
	
	[webView stringByEvaluatingJavaScriptFromString:goToOffsetFunc];
	[webView stringByEvaluatingJavaScriptFromString:goTo];
	
	if(!paginating){
		[currentPageLabel setText:[NSString stringWithFormat:@"%d/%d",[self getGlobalPageCount], totalPagesCount]];
		[pageSlider setValue:(float)100*(float)[self getGlobalPageCount]/(float)totalPagesCount animated:YES];
	}
	
	webView.hidden = NO;
	
}

- (void) gotoNextSpine {
	if(!paginating){
		if(currentSpineIndex+1<[loadedEpub.spineArray count]){
			[self loadSpine:++currentSpineIndex atPageIndex:0];
		}	
	}
}

- (void) gotoPrevSpine {
	if(!paginating){
		if(currentSpineIndex-1>=0){
			[self loadSpine:--currentSpineIndex atPageIndex:0];
		}	
	}
}

- (void) gotoNextPage {
    
    [readingMetric pagescroll:[NSDate date]];
    
	if(!paginating){
		if(currentPageInSpineIndex+1<pagesInCurrentSpineCount){
            //NSLog(@"Going to next page");
			[self gotoPageInCurrentSpine:++currentPageInSpineIndex];
		} else {
            //NSLog(@"Going to next spine");
			[self gotoNextSpine];
		}		
	}
}

- (void) gotoPrevPage {
    
    [readingMetric pagescroll:[NSDate date]];
	if (!paginating) {
		if(currentPageInSpineIndex-1>=0){
			[self gotoPageInCurrentSpine:--currentPageInSpineIndex];
		} else {
			if(currentSpineIndex!=0){
				int targetPage = [[loadedEpub.spineArray objectAtIndex:(currentSpineIndex-1)] pageCount];
				[self loadSpine:--currentSpineIndex atPageIndex:targetPage-1];
			}
		}
	}
}


- (IBAction) increaseTextSizeClicked:(id)sender{
    NSLog(@"Increase text size is clicked");
	if(!paginating){
        NSLog(@"inside first if loop");
		if(currentTextSize+25<=200){
            NSLog(@"inside second if loop");
			currentTextSize+=25;
			[self updatePagination];
			if(currentTextSize == 200){
				[incTextSizeButton setEnabled:NO];
			}
			[decTextSizeButton setEnabled:YES];
		}
	}
}
- (IBAction) decreaseTextSizeClicked:(id)sender{
	if(!paginating){
		if(currentTextSize-25>=50){
			currentTextSize-=25;
			[self updatePagination];
			if(currentTextSize==50){
				[decTextSizeButton setEnabled:NO];
			}
			[incTextSizeButton setEnabled:YES];
		}
	}
}

- (IBAction) doneClicked:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction) slidingStarted:(id)sender{
    int targetPage = ((pageSlider.value/(float)100)*(float)totalPagesCount);
    if (targetPage==0) {
        targetPage++;
    }
	[currentPageLabel setText:[NSString stringWithFormat:@"%d/%d", targetPage, totalPagesCount]];
}

- (IBAction) slidingEnded:(id)sender{
	int targetPage = (int)((pageSlider.value/(float)100)*(float)totalPagesCount);
    if (targetPage==0) {
        targetPage++;
    }
	int pageSum = 0;
	int chapterIndex = 0;
	int pageIndex = 0;
	for(chapterIndex=1; chapterIndex<[loadedEpub.spineArray count]; chapterIndex++){
		pageSum+=[[loadedEpub.spineArray objectAtIndex:chapterIndex] pageCount];
//		NSLog(@"Chapter %d, targetPage: %d, pageSum: %d, pageIndex: %d", chapterIndex, targetPage, pageSum, (pageSum-targetPage));
		if(pageSum>=targetPage){
			pageIndex = [[loadedEpub.spineArray objectAtIndex:chapterIndex] pageCount] - 1 - pageSum + targetPage;
			break;
		}
	}
	[self loadSpine:chapterIndex atPageIndex:pageIndex];
}

- (IBAction) showChapterIndex:(id)sender{
	if(chaptersPopover==nil){
		ChapterListViewController* chapterListView = [[ChapterListViewController alloc] initWithNibName:@"ChapterListViewController" bundle:[NSBundle mainBundle]];
		[chapterListView setEpubViewController:self];
		chaptersPopover = [[UIPopoverController alloc] initWithContentViewController:chapterListView];
		[chaptersPopover setPopoverContentSize:CGSizeMake(400, 600)];
		[chapterListView release];
	}
	if ([chaptersPopover isPopoverVisible]) {
		[chaptersPopover dismissPopoverAnimated:YES];
	}else{
		[chaptersPopover presentPopoverFromBarButtonItem:chapterListButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];		
	}
}


- (void)webViewDidFinishLoad:(UIWebView *)theWebView{
    
    NSLog(@"WebViewDidFinshLoad is called");
	
	NSString *varMySheet = @"var mySheet = document.styleSheets[0];";
	
	NSString *addCSSRule =  @"function addCSSRule(selector, newRule) {"
	"if (mySheet.addRule) {"
	"mySheet.addRule(selector, newRule);"								// For Internet Explorer
	"} else {"
	"ruleIndex = mySheet.cssRules.length;"
	"mySheet.insertRule(selector + '{' + newRule + ';}', ruleIndex);"   // For Firefox, Chrome, etc.
	"}"
	"}";
	
	NSString *insertRule1 = [NSString stringWithFormat:@"addCSSRule('html', 'padding: 0px; height: %fpx; -webkit-column-gap: 0px; -webkit-column-width: %fpx;')", webView.frame.size.height, webView.frame.size.width];
	NSString *insertRule2 = [NSString stringWithFormat:@"addCSSRule('p', 'text-align: justify;')"];
	NSString *setTextSizeRule = [NSString stringWithFormat:@"addCSSRule('body', '-webkit-text-size-adjust: %d%%;')", currentTextSize];
	NSString *setHighlightColorRule = [NSString stringWithFormat:@"addCSSRule('highlight', 'background-color: yellow;')"];

	
	[webView stringByEvaluatingJavaScriptFromString:varMySheet];
	
	[webView stringByEvaluatingJavaScriptFromString:addCSSRule];
		
	[webView stringByEvaluatingJavaScriptFromString:insertRule1];
	
	[webView stringByEvaluatingJavaScriptFromString:insertRule2];
	
	[webView stringByEvaluatingJavaScriptFromString:setTextSizeRule];
	
	[webView stringByEvaluatingJavaScriptFromString:setHighlightColorRule];
	
	if(currentSearchResult!=nil){
	//	NSLog(@"Highlighting %@", currentSearchResult.originatingQuery);
        [webView highlightAllOccurencesOfString:currentSearchResult.originatingQuery];
	}
	
	
	int totalWidth = [[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollWidth"] intValue];
	pagesInCurrentSpineCount = (int)((float)totalWidth/webView.bounds.size.width);

	[self gotoPageInCurrentSpine:currentPageInSpineIndex];
}

- (void) updatePagination{
	if(epubLoaded){
        if(!paginating){
            NSLog(@"Pagination Started!");
            paginating = YES;
            totalPagesCount=0;
            [self loadSpine:currentSpineIndex atPageIndex:currentPageInSpineIndex];
            /*QuickFix - Initialize the webView programatically... not done for first load and bounds were 0*/
            self.webView=[[UIWebView alloc]initWithFrame:CGRectMake(20, 142, 728,811)];
            [[loadedEpub.spineArray objectAtIndex:0] setDelegate:self];
            [[loadedEpub.spineArray objectAtIndex:0] loadChapterWithWindowSize:webView.bounds fontPercentSize:currentTextSize];
            [currentPageLabel setText:@"?/?"];
        }
	}
    self.webView.hidden=NO;
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
	if(searchResultsPopover==nil){
		searchResultsPopover = [[UIPopoverController alloc] initWithContentViewController:searchResViewController];
		[searchResultsPopover setPopoverContentSize:CGSizeMake(400, 600)];
	}
	if (![searchResultsPopover isPopoverVisible]) {
		[searchResultsPopover presentPopoverFromRect:searchBar.bounds inView:searchBar permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
//	NSLog(@"Searching for %@", [searchBar text]);
	if(!searching){
		searching = YES;
		[searchResViewController searchString:[searchBar text]];
        [searchBar resignFirstResponder];
	}
}


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    NSLog(@"shouldAutorotate");
    [self updatePagination];
	return YES;
}

- (IBAction) openWebLink:(id)sender{
    
    /*Get the weblink from Parse*/
    NSString *urlString= booksource;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

-(void)saveAction:(id)sender
{
    /*   NSRange selectedRange = [webView selectedRange];
     
     NSDictionary *currentAttributesDict = [_textView.textStorage attributesAtIndex:selectedRange.location effectiveRange:nil];
     
     if ([currentAttributesDict objectForKey:NSForegroundColorAttributeName] == nil ||
     [currentAttributesDict objectForKey:NSForegroundColorAttributeName] != [UIColor redColor]) {
     
     NSDictionary *dict = @{NSForegroundColorAttributeName: [UIColor redColor]};
             [_textView.textStorage beginEditing];
             [_textView.textStorage setAttributes:dict range:selectedRange];
             [_textView.textStorage endEditing];
         }
         */
    [self.webView copy:[UIApplication sharedApplication]];
    NSString *text = [UIPasteboard generalPasteboard].string;
    
    [[UIApplication sharedApplication] sendAction:@selector(copy:) to:nil from:self forEvent:nil];
    NSString *sampleText =  [UIPasteboard generalPasteboard].string;
    
    NSString *newText = [self.webView stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
    NSLog(@"Save button is selected and string selected is text: %@ and newText %@ and sampleText %@", text, newText, sampleText);
    
}

/*
- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
    
    NSLog(@"Tap guester");
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
    
}*/

#pragma mark -
#pragma mark View lifecycle

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*setup UIMenuController */
    /*CGRect targetregangle=CGRectMake(200, 200, 100, 100);
    [[UIMenuController sharedMenuController] setTargetRect:targetregangle inView:self.view];
    
    UIMenuItem *menuitem=[[UIMenuItem alloc] initWithTitle:@"Save" action:@selector(saveAction:)];
    
    [[UIMenuController sharedMenuController]setMenuItems:@[menuitem]];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.view addGestureRecognizer:tapGesture];*/
    
    self.websource.title = @"Book Source:";
    NSUInteger size=15;
    UIFont *font = [UIFont boldSystemFontOfSize:size];
    NSDictionary *attributes = @{NSFontAttributeName: font};
    [self.websource setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    self.weblink.title = @"Click here to view book source";
    font = [UIFont fontWithName:@"Optima-BoldItalic" size:size];
    attributes = @{NSFontAttributeName: font};
    [self.weblink setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
	[webView setDelegate:self];
		
	UIScrollView* sv = nil;
	for (UIView* v in  webView.subviews) {
		if([v isKindOfClass:[UIScrollView class]]){
			sv = (UIScrollView*) v;
			sv.scrollEnabled = NO;
			sv.bounces = NO;
		}
	}
	currentTextSize = 100;	 
	
	UISwipeGestureRecognizer* rightSwipeRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoNextPage)] autorelease];
	[rightSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
	
	UISwipeGestureRecognizer* leftSwipeRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPrevPage)] autorelease];
	[leftSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
	
	[webView addGestureRecognizer:rightSwipeRecognizer];
	[webView addGestureRecognizer:leftSwipeRecognizer];
	
	[pageSlider setThumbImage:[UIImage imageNamed:@"slider_ball.png"] forState:UIControlStateNormal];
	[pageSlider setMinimumTrackImage:[[UIImage imageNamed:@"orangeSlide.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
	[pageSlider setMaximumTrackImage:[[UIImage imageNamed:@"yellowSlide.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
    
	searchResViewController = [[SearchResultsViewController alloc] initWithNibName:@"SearchResultsViewController" bundle:[NSBundle mainBundle]];
	searchResViewController.epubViewController = self;
}

- (void)viewDidUnload {
	self.toolbar = nil;
	self.webView = nil;
	self.chapterListButton = nil;
	self.decTextSizeButton = nil;
	self.incTextSizeButton = nil;
	self.pageSlider = nil;
	self.currentPageLabel = nil;	
}


#pragma mark -
#pragma mark Memory management

/*
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
*/

- (void)dealloc {
    self.toolbar = nil;
	self.webView = nil;
	self.chapterListButton = nil;
	self.decTextSizeButton = nil;
	self.incTextSizeButton = nil;
	self.pageSlider = nil;
	self.currentPageLabel = nil;
	[loadedEpub release];
	[chaptersPopover release];
	[searchResultsPopover release];
	[searchResViewController release];
	[currentSearchResult release];
    [super dealloc];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (![parent isEqual:self.parentViewController]) {
        //NSLog(@"Book is being closed now");
        /*Back button is pressed. Save the current page number */
        [self storeCurrentPageNo];
        [readingMetric bookIsClosed:[NSDate date]];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSString *varMySheet = @"var mySheet = document.styleSheets[0];";
    
    NSString *addCSSRule =  @"function addCSSRule(selector, newRule) {"
    "if (mySheet.addRule) {"
    "mySheet.addRule(selector, newRule);" // For Internet Explorer
    "} else {"
    "ruleIndex = mySheet.cssRules.length;"
    "mySheet.insertRule(selector + '{' + newRule + ';}', ruleIndex);"   // For Firefox, Chrome, etc.
    "}"
    "}";
    
    NSString *insertRule1 = [NSString stringWithFormat:@"addCSSRule('html', 'padding: 0px; height: %fpx; -webkit-column-gap: 0px; -webkit-column-width: %fpx;')", webView.frame.size.height, webView.frame.size.width];
    NSString *insertRule2 = [NSString stringWithFormat:@"addCSSRule('p', 'text-align: justify;')"];
    NSString *setTextSizeRule = [NSString stringWithFormat:@"addCSSRule('body', '-webkit-text-size-adjust: %d%%;')", currentTextSize];
    NSString *setHighlightColorRule = [NSString stringWithFormat:@"addCSSRule('highlight', 'background-color: white;')"];
    
    
    [webView stringByEvaluatingJavaScriptFromString:varMySheet];
    
    [webView stringByEvaluatingJavaScriptFromString:addCSSRule];
    
    [webView stringByEvaluatingJavaScriptFromString:insertRule1];
    
    [webView stringByEvaluatingJavaScriptFromString:insertRule2];
    
    [webView stringByEvaluatingJavaScriptFromString:setTextSizeRule];
    
    [webView stringByEvaluatingJavaScriptFromString:setHighlightColorRule];
    
    if(currentSearchResult!=nil){
        // NSLog(@"Highlighting %@", currentSearchResult.originatingQuery);
        [webView highlightAllOccurencesOfString:currentSearchResult.originatingQuery];
    }
    
    
    int totalWidth = [[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollWidth"] intValue];
    pagesInCurrentSpineCount = (int)((float)totalWidth/webView.bounds.size.width);
    
    [self gotoPageInCurrentSpine:currentPageInSpineIndex];
    
    
}


@end
