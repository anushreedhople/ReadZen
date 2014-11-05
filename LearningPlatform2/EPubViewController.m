//
//  EPubViewController.m
//  LearningPlatform2
//
//  Created by Anushree Dhople on 7/27/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.//

#import "EPubViewController.h"
#import "ChapterListViewController.h"
#import "SearchResultsViewController.h"
#import "SearchResult.h"
#import "UIWebView+SearchWebView.h"
#import "Chapter.h"
#import "Parse/Parse.h"
#import "ReadingMetric.h"
#import "TFHpple.h"
#import "Tutorial.h"

@interface EPubViewController(){
    NSString *strHighlightedTextToBeSearched;
    ChapterListViewController* chapterListView;
}

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
    actualPagesCount = 0;
	searching = NO;
    epubLoaded = NO;
    self.loadedEpub = [[EPub alloc] initWithEPubPath:[epubURL path]];
    epubLoaded = YES;
	[self updatePagination];
    /*readingMetric = [[ReadingMetric alloc]init];
    [readingMetric setBookIndex:bookIndex];
    [readingMetric bookIsOpened:[NSDate date]];
    [readingMetric setTotalPages:[self getGlobalPageCount]];*/
}


-(void) loadBookSource:(NSString *)bookweblink {
    self.navigationController.navigationBarHidden=YES;
    booksource=bookweblink;
}

- (void) chapterDidFinishLoad:(Chapter *)chapter{
    totalPagesCount+=chapter.locationPageCount;
    actualPagesCount+=chapter.pageCount;
    

	if(chapter.chapterIndex + 1 < [loadedEpub.spineArray count]){
		[[loadedEpub.spineArray objectAtIndex:chapter.chapterIndex+1] setDelegate:self];
		[[loadedEpub.spineArray objectAtIndex:chapter.chapterIndex+1] loadChapterWithWindowSize:webView.bounds fontPercentSize:currentTextSize];
		[currentPageLabel setText:[NSString stringWithFormat:@"Page ? of %d   Loc ? of %d", actualPagesCount, totalPagesCount]];
	} else {
		[currentPageLabel setText:[NSString stringWithFormat:@"Page %d of %d   Loc %d of %d",[self getActualPageCount], actualPagesCount, [self getGlobalPageCount], totalPagesCount]];
		[pageSlider setValue:(float)100*(float)[self getGlobalPageCount]/(float)totalPagesCount animated:YES];
		paginating = NO;
        
        /*QuickFix - pages not getting loaded when book is opened first TODO*/
        [self gotoNextPage];
        [self gotoPrevPage];
        
        /*Finished loading the book. Check if page number exists in User db and load relevant page*/
         //NSLog(@"Book loaded... checking for last page");
         //NSArray *spineIndexes = [[PFUser currentUser] valueForKey:@"spineindex"];
         //NSArray *pageIndexes = [[PFUser currentUser] valueForKey:@"pageindex"];
         
         //int spineIndex = [[spineIndexes objectAtIndex:bookIndex]intValue];
         //int pageIndex = [[pageIndexes objectAtIndex:bookIndex]intValue];
         
         //if(spineIndex != 0 && pageIndex !=0) {
         //NSLog(@"Previous loaded page found... shifting to it");
         //[self loadSpine:spineIndex atPageIndex:pageIndex highlightSearchResult:nil];
         //}
         //NSLog(@"loadEpub spineIndex %d pageIndex %d",spineIndex,pageIndex);

	}
}

/*
-(void)storeCurrentPageNo {
    
    NSMutableArray *spineIndex = [[NSMutableArray alloc] init];
    NSMutableArray *pageIndex = [[NSMutableArray alloc]init];

    [spineIndex addObjectsFromArray:[[PFUser currentUser] valueForKey:@"spineindex"]];
    [pageIndex addObjectsFromArray:[[PFUser currentUser] valueForKey:@"pageindex"]];
    
    [spineIndex replaceObjectAtIndex:bookIndex withObject:[NSString stringWithFormat:@"%d",currentSpineIndex]];
    [pageIndex replaceObjectAtIndex:bookIndex withObject:[NSString stringWithFormat:@"%d", currentPageInSpineIndex]];
    
    //Add it to the Parse PFUser database
    PFUser *user = [PFUser currentUser];
    //user[@"spineindex"] = spineIndex;
    //user[@"pageindex"]=pageIndex;
    //[[PFUser currentUser] saveInBackground];

}
*/

/*
-(void)setBookIndex:(int)receivedBookIndex{
    bookIndex = receivedBookIndex;
}
*/

- (int) getGlobalPageCount{
	int pageCount = 0;
    
	for(int i=0; i<currentSpineIndex; i++){
		pageCount+= [[loadedEpub.spineArray objectAtIndex:i] locationPageCount];
    }
	pageCount+=currentPageInSpineIndex+1;
	return pageCount;
}

-(int) getActualPageCount {
    
    int actualPageCount = 0;
    for(int i=0; i<currentSpineIndex; i++){
        /*Get original page count from Chapters.m pageCount object*/
        actualPageCount+= [[loadedEpub.spineArray objectAtIndex:i] pageCount];
    }
    
    /*Get the actual page in current spine index without text increase*/
    double range = (float)[[loadedEpub.spineArray objectAtIndex:currentSpineIndex] pageCount] / (float)[[loadedEpub.spineArray objectAtIndex:currentSpineIndex] locationPageCount];
    double roundedRange = roundf(range*10)/10.0;
    
    double computedPageCount = (currentPageInSpineIndex+1)*roundedRange+0.9;
    actualPageCount+= (int)floor(computedPageCount);
    
    return actualPageCount;
}




- (void) loadSpine:(int)spineIndex atPageIndex:(int)pageIndex {
	[self loadSpine:spineIndex atPageIndex:pageIndex highlightSearchResult:nil];
}

- (void) loadSpineWithTitle:(NSString *)strTitle andSpineIndex:(int) iSpineIndex{
    
    self.navigationController.navigationBarHidden=YES;
    
    [chaptersPopover dismissPopoverAnimated:YES];
    [searchResultsPopover dismissPopoverAnimated:YES];
    
    for (Chapter *chapter in loadedEpub.spineArray) {
        //NSLog(@"chapter title %@",chapter.title);
        //NSLog(@"strTitle %@",strTitle);
        
        if ([[chapter.title lowercaseString] isEqualToString:[strTitle lowercaseString]]) {
            //NSLog(@"chapter-----------------------");
            
            NSURL* url = [NSURL fileURLWithPath:[[loadedEpub.spineArray objectAtIndex:iSpineIndex++] spinePath]];
            //NSLog(@"The url is %@",url);
            NSString *str=[[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
            
            NSString *loadString = [NSString stringWithFormat:@"<html><head><style>body {background:#F2EBE4} p {color:black;}</style></head><body><p>%@<p></body></html>", str];
            
            [webView loadHTMLString:loadString baseURL:nil];
            
            //	[webView loadRequest:[NSURLRequest requestWithURL:url]];
            currentPageInSpineIndex = 0;
            currentSpineIndex = 0;
            
            if(!paginating){
                [currentPageLabel setText:[NSString stringWithFormat:@"Page %d of %d   Loc %d of %d",[self getActualPageCount], actualPagesCount, [self getGlobalPageCount], totalPagesCount]];
                [pageSlider setValue:(float)100*(float)[self getGlobalPageCount]/(float)totalPagesCount animated:YES];
            }
            
            /*change pagesInCurrentSpineIndex variable also*/
            /*int totalWidth = [[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollWidth"] intValue];
            pagesInCurrentSpineCount = (int)((float)totalWidth/webView.bounds.size.width);
            NSLog(@"loadSpine totalWidth:%d webView width %f", totalWidth, webView.bounds.size.width);*/
            
            
            webView.hidden=NO;
            
            if (chapterListView) {
                [chapterListView dismissViewControllerAnimated:YES completion:^{
                }];
            }
        }
    }
}

- (void) loadSpine:(int)spineIndex atPageIndex:(int)pageIndex highlightSearchResult:(SearchResult*)theResult{
	
	webView.hidden = YES;
	
	self.currentSearchResult = theResult;

	[chaptersPopover dismissPopoverAnimated:YES];
	[searchResultsPopover dismissPopoverAnimated:YES];
	
	NSURL* url = [NSURL fileURLWithPath:[[loadedEpub.spineArray objectAtIndex:spineIndex] spinePath]];
    //NSLog(@"The url is %@",url);
    NSString *str=[[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    NSString *loadString = [NSString stringWithFormat:@"<html><head><style>body {background:#F2EBE4} p {color:black;}</style></head><body><p>%@<p></body></html>", str];
    
    [webView loadHTMLString:loadString baseURL:nil];
    
    //	[webView loadRequest:[NSURLRequest requestWithURL:url]];
	currentPageInSpineIndex = pageIndex;
	currentSpineIndex = spineIndex;
    
    
	if(!paginating){
		[currentPageLabel setText:[NSString stringWithFormat:@"Page %d of %d   Loc %d of %d",[self getActualPageCount], actualPagesCount, [self getGlobalPageCount], totalPagesCount]];
		[pageSlider setValue:(float)100*(float)[self getGlobalPageCount]/(float)totalPagesCount animated:YES];	
	}
    
    /*change pagesInCurrentSpineIndex variable also*/
	/*int totalWidth = [[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollWidth"] intValue];
	pagesInCurrentSpineCount = (int)((float)totalWidth/webView.bounds.size.width);
    */

    webView.hidden=NO;
    
    if ([theResult isKindOfClass:[NSString class]]) {
        NSString *strHighlight=(NSString *)theResult;
        [self.webView highlightString:strHighlight];
        
    }else{
        NSString *strHighlight=theResult.originatingQuery;
        [self.webView highlightAllOccurencesOfString:strHighlight];
        
    }
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
		[currentPageLabel setText:[NSString stringWithFormat:@"Page %d of %d   Loc %d of %d",[self getActualPageCount], actualPagesCount, [self getGlobalPageCount], totalPagesCount]];
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
    
    //[readingMetric pagescroll:[NSDate date]];
    
	if(!paginating){
		if(currentPageInSpineIndex+1<pagesInCurrentSpineCount){
			[self gotoPageInCurrentSpine:++currentPageInSpineIndex];
		} else {
			[self gotoNextSpine];
		}
        [self checkForBookMarkAndShowIcon:2];
	}
}

- (void) gotoPrevPage {
    
    //[readingMetric pagescroll:[NSDate date]];
	if (!paginating) {
		if(currentPageInSpineIndex-1>=0){
			[self gotoPageInCurrentSpine:--currentPageInSpineIndex];
		} else {
			if(currentSpineIndex!=0){
				int targetPage = [[loadedEpub.spineArray objectAtIndex:(currentSpineIndex-1)] locationPageCount];
				[self loadSpine:--currentSpineIndex atPageIndex:targetPage-1];
			}
		}
        [self checkForBookMarkAndShowIcon:1];
	}
}

- (void) highLightBookMark:(BOOL) bIsYes{
    
    if (bIsYes){
        [_btnBookMark setImage:[UIImage imageNamed:@"bookmark12"] forState:UIControlStateNormal];
    }
    else{
        [_btnBookMark setImage:[UIImage imageNamed:@"bookmark"] forState:UIControlStateNormal];
    }
    
}


-(int)getIndexOfChapter:(NSString *)chapter{
    
    int jCounter=0;
    for (Chapter *chap in self.loadedEpub.spineArray) {
        if ([chap.title isEqualToString:chapter]) {
            return jCounter;
        }
        jCounter++;
    }
    
    return 0;
    
}


-(void)checkForBookMarkAndShowIcon:(int) isCallFromPrevPage{
    
    /*TODO - Check behavior in model App and replicate for magnification*/
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.m_vwBookMark.hidden=YES;
    
    if ([userDefaults objectForKey:@"bookMark"]) {
        if ([[userDefaults objectForKey:@"bookMark"] isKindOfClass:[NSArray class]]) {
            
            for (NSDictionary *dict in [userDefaults objectForKey:@"bookMark"]) {
                
                //NSLog(@"'%@' '%@'",[dict objectForKey:@"bookName"],self.strBookName);
                //NSLog(@"'%@' '%@'",[dict objectForKey:@"chapterName"],[self getChapterNameOfBook]);
                
                if (isCallFromPrevPage==3) {
                    if ([[dict objectForKey:@"bookName"] isEqualToString:self.strBookName]){
                        
                        NSString *strPage=[self.currentPageLabel.text componentsSeparatedByString:@"/"][0];
                        
                        if ([[dict objectForKey:@"pageNumber"] intValue] == [strPage intValue]) {
                            [_btnBookMark setImage:[UIImage imageNamed:@"bookmark12"] forState:UIControlStateNormal];
                            break;
                        }else{
                            [_btnBookMark setImage:[UIImage imageNamed:@"bookmark"] forState:UIControlStateNormal];
                        }
                        
                    }
                    
                    
                }else if (isCallFromPrevPage==2){
                    if (currentPageInSpineIndex==0) {
                        //                        int iIndex=[self getIndexOfChapter:[self getChapterNameOfBook]];
                        //                        NSString *strChapter=[[self.loadedEpub.spineArray objectAtIndex:++iIndex] title] ;
                        
                        NSString *strChapter=[self getChapterNameOfBook];
                        
                        if ([[dict objectForKey:@"bookName"] isEqualToString:self.strBookName] && [[dict objectForKey:@"chapterName"] isEqualToString:strChapter] ){
                            
                            NSString *strPage=[self.currentPageLabel.text componentsSeparatedByString:@"/"][0];
                            
                            if ([[dict objectForKey:@"pageNumber"] intValue] == [strPage intValue]) {
                                [_btnBookMark setImage:[UIImage imageNamed:@"bookmark12"] forState:UIControlStateNormal];
                                break;
                            }else{
                                [_btnBookMark setImage:[UIImage imageNamed:@"bookmark"] forState:UIControlStateNormal];
                            }
                        }else{
                            
                            //chapter 21 to chapter22 move
                            //chap 21 0 pageindex is book mark so that chapter 22 page 0 will not be bookmark
                            [_btnBookMark setImage:[UIImage imageNamed:@"bookmark"] forState:UIControlStateNormal];
                        }
                    }
                    
                    else{
                        
                        if ([[dict objectForKey:@"bookName"] isEqualToString:self.strBookName] && [[dict objectForKey:@"chapterName"] isEqualToString:[self getChapterNameOfBook]]) {
                            
                            NSString *strPage=[self.currentPageLabel.text componentsSeparatedByString:@"/"][0];
                            
                            if ([[dict objectForKey:@"pageNumber"] intValue] == [strPage intValue]) {
                                [_btnBookMark setImage:[UIImage imageNamed:@"bookmark12"] forState:UIControlStateNormal];
                                break;
                            }else{
                                [_btnBookMark setImage:[UIImage imageNamed:@"bookmark"] forState:UIControlStateNormal];
                            }
                        }
                    }
                }
                
                
                
                
                else{
                    //chapter 22 to 21 move
                    //chap 21 final pageindex is book mark so that chapter 22 page 0 will not be bookmark
                    //                    if (pagesInCurrentSpineCount+1==currentPageInSpineIndex-1 || pagesInCurrentSpineCount == currentPageInSpineIndex|| pagesInCurrentSpineCount+1== currentPageInSpineIndex) {
                    //
                    //                            int iIndex=[self getIndexOfChapter:[self getChapterNameOfBook]];
                    //                            NSString *strChapter=[[self.loadedEpub.spineArray objectAtIndex:--iIndex] title] ;
                    //
                    //                            if ([[dict objectForKey:@"bookName"] isEqualToString:self.strBookName] && [[dict objectForKey:@"chapterName"] isEqualToString:strChapter] ){
                    //                                NSString *strPage=[self.currentPageLabel.text componentsSeparatedByString:@"/"][0];
                    //
                    //                                if ([[dict objectForKey:@"pageNumber"] intValue] == [strPage intValue]) {
                    //                                    [_btnBookMark setImage:[UIImage imageNamed:@"bookmark12"] forState:UIControlStateNormal];
                    //                                    break;
                    //                                }else{
                    //                                    [_btnBookMark setImage:[UIImage imageNamed:@"bookmark"] forState:UIControlStateNormal];
                    //                                }
                    //
                    //                            }
                    //
                    //
                    //                    }
                    //                    else
                    //
                    //                    {
                    if ([[dict objectForKey:@"bookName"] isEqualToString:self.strBookName] && [[dict objectForKey:@"chapterName"] isEqualToString:[self getChapterNameOfBook]]) {
                        
                        NSString *strPage=[self.currentPageLabel.text componentsSeparatedByString:@"/"][0];
                        
                        if ([[dict objectForKey:@"pageNumber"] intValue] == [strPage intValue]) {
                            [_btnBookMark setImage:[UIImage imageNamed:@"bookmark12"] forState:UIControlStateNormal];
                            break;
                        }else{
                            [_btnBookMark setImage:[UIImage imageNamed:@"bookmark"] forState:UIControlStateNormal];
                        }
                    }else{
                        [_btnBookMark setImage:[UIImage imageNamed:@"bookmark"] forState:UIControlStateNormal];
                    }
                }
            }
        }else{
            [_btnBookMark setImage:[UIImage imageNamed:@"bookmark"] forState:UIControlStateNormal];
        }
    }
}


- (IBAction) increaseTextSizeClicked:(id)sender{
	if(!paginating){
		if(currentTextSize+25<=200){
            totalPagesCount=0;
            actualPagesCount=0;
			currentTextSize+=25;
			[self updatePagination];
            [self updateTextFontSizeWithValue:currentTextSize];
            
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
            totalPagesCount=0;
            actualPagesCount=0;
			currentTextSize-=25;
			[self updatePagination];
            [self updateTextFontSizeWithValue:currentTextSize];
            
			if(currentTextSize==50){
				[decTextSizeButton setEnabled:NO];
			}
			[incTextSizeButton setEnabled:YES];
		}
	}
}

-(void)updateTextFontSizeWithValue:(int) iTextSize{
    
    //    NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'",
    //                          iTextSize];
    //    [webView stringByEvaluatingJavaScriptFromString:jsString];
    
    
}

- (IBAction) doneClicked:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction) slidingStarted:(id)sender{
    int targetPage = ((pageSlider.value/(float)100)*(float)totalPagesCount);
    if (targetPage==0) {
        targetPage++;
    }
	//[currentPageLabel setText:[NSString stringWithFormat:@"%d/%d", targetPage, totalPagesCount]];
}

- (IBAction) slidingEnded:(id)sender{
	int targetPage = (int)((pageSlider.value/(float)100)*(float)totalPagesCount);
    if (targetPage==0) {
        targetPage++;
    }
	int pageSum = 0;
	int chapterIndex = 0;
	int pageIndex = 0;
	for(chapterIndex=0; chapterIndex<[loadedEpub.spineArray count]; chapterIndex++){
		pageSum+=[[loadedEpub.spineArray objectAtIndex:chapterIndex] locationPageCount];
		if(pageSum>=targetPage){
			pageIndex = [[loadedEpub.spineArray objectAtIndex:chapterIndex] locationPageCount] - 1 - pageSum + targetPage;
			break;
		}
	}
	[self loadSpine:chapterIndex atPageIndex:pageIndex];
    [self checkForBookMarkAndShowIcon:3];
}

- (IBAction) showChapterIndex:(id)sender{
    //	if(chaptersPopover==nil){
    chapterListView = [[ChapterListViewController alloc] initWithNibName:@"ChapterListViewController" bundle:[NSBundle mainBundle]];
    [chapterListView setEpubViewController:self];
    chapterListView.strBookName=self.strBookName;
    
    [self presentViewController:chapterListView animated:YES completion:^{
        
    }];
    //		chaptersPopover = [[UIPopoverController alloc] initWithContentViewController:chapterListView];
    //		[chaptersPopover setPopoverContentSize:CGSizeMake(400, 600)];
    //		[chapterListView release];
    //	}
    //	if ([chaptersPopover isPopoverVisible]) {
    //		[chaptersPopover dismissPopoverAnimated:YES];
    //	}else{
    //		[chaptersPopover presentPopoverFromBarButtonItem:chapterListButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    //	}
}


- (void)webViewDidFinishLoad:(UIWebView *)theWebView{
    
    NSString *strHighlightedSpan=[NSString stringWithFormat:@"document.getElementById('selc').style.color = yellow"];
	
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
        [webView highlightAllOccurencesOfString:currentSearchResult.originatingQuery];
	}
	
	
	int totalWidth = [[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollWidth"] intValue];
	pagesInCurrentSpineCount = (int)((float)totalWidth/webView.bounds.size.width);

	[self gotoPageInCurrentSpine:currentPageInSpineIndex];
    
    webView.backgroundColor=[UIColor clearColor];
    
    //check if the book name is found in nsuserdefault
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    for (NSDictionary *dict in [userDefaults objectForKey:@"highlightedTextData"]) {
        if ([dict objectForKey:@"bookName"]) {
            if ([[dict objectForKey:@"bookName"]isEqualToString:self.strBookName]) {
                NSString *strCurrentChapterName=[self getChapterNameOfBook];
                if ([strCurrentChapterName isEqualToString:[dict objectForKey:@"chapterName"]]) {
                    
                    //search for the string and then highlight
                    [theWebView highlightAllOccurencesOfString:[dict objectForKey:@"highlightedText"]];
                    
                }
            }
        }
    }
}

- (void) updatePagination{
	if(epubLoaded){
        if(!paginating){
            paginating = YES;
            totalPagesCount=0;
            [self loadSpine:currentSpineIndex atPageIndex:currentPageInSpineIndex];
            /*QuickFix - Initialize the webView programatically... not done for first load and bounds were 0*/
            self.webView=[[UIWebView alloc]initWithFrame:CGRectMake(20, 142, 728,811)];
            self.webView.backgroundColor=UIColorFromRGB(MACRO_CODE_FOR_BG);
            [[loadedEpub.spineArray objectAtIndex:0] setDelegate:self];
            [[loadedEpub.spineArray objectAtIndex:0] loadChapterWithWindowSize:webView.bounds fontPercentSize:currentTextSize];
            //[currentPageLabel setText:@"?/?"];
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
    [self updatePagination];
	return YES;
}


- (IBAction) openWebLink:(id)sender{
    
    //Get the weblink from Parse
    NSString *urlString= booksource;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}


-(void)saveAction:(id)sender
{
    [self.webView copy:[UIApplication sharedApplication]];
    NSString *text = [UIPasteboard generalPasteboard].string;
    
    [[UIApplication sharedApplication] sendAction:@selector(copy:) to:nil from:self forEvent:nil];
    NSString *sampleText =  [UIPasteboard generalPasteboard].string;
    
    NSString *newText = [self.webView stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
    NSLog(@"Save button is selected and string selected is text: %@ and newText %@ and sampleText %@", text, newText, sampleText);
    
}


- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
    _searchView.hidden=!_searchView.hidden;
    [self.view endEditing:YES];
}


-(void)hideDropView{
    
    //NSLog(@"Tap guester");
    if (m_objDropViewController!=nil) {
        [m_objDropViewController.view removeFromSuperview];
        m_objDropViewController.delegate=nil;
        m_objDropViewController=nil;
    }
}

-(void)hideNotesView{
    
    //NSLog(@"Tap guester");
    
    if (m_objNotesViewController!=nil) {
        [m_objNotesViewController.view removeFromSuperview];
        m_objNotesViewController=nil;
    }
}


-(void) searchHighLightedText{
    
    NSString *currentColor = [webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('backColor')"];
    BOOL isBlue = [currentColor isEqualToString:@"rgb(0, 0, 255)"];
    
    if (isBlue) {
        
    }
}


#pragma mark -
#pragma mark View lifecycle
#pragma mark -

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action
              withSender:(id)sender
{
    if (action == @selector(saveAction:) ||
        action == @selector(highLightAction:) ||
        action == @selector(mailAction:)||
        action == @selector(searchAction:) ||
        action == @selector(addNotesAction:) ||
        action == @selector(goToSafari:)
        )
        return YES;
    
    return [super canPerformAction:action withSender:sender];
}


- (void)loadView
{
    [super loadView];
    
    UIMenuItem *menuitem = [[UIMenuItem alloc] initWithTitle:@"Save" action:@selector(saveAction:)];
    [menuitem cxa_setImage:[UIImage imageNamed:@"save"]];
    
    UIMenuItem *menuitem1 = [[UIMenuItem alloc] initWithTitle:@"HighLight" action:@selector(highLightAction:)];
    [menuitem1 cxa_setImage:[UIImage imageNamed:@"highlight"]];
    
    UIMenuItem *menuitem2 = [[UIMenuItem alloc] initWithTitle:@"Mail" action:@selector(mailAction:)];
    [menuitem2 cxa_setImage:[UIImage imageNamed:@"mail"]];
    
    UIMenuItem *menuitem3 = [[UIMenuItem alloc] initWithTitle:@"Search" action:@selector(searchAction:)  ];
    [menuitem3 cxa_setImage:[UIImage imageNamed:@"searchAct"]];
    
    UIMenuItem *menuitem4 = [[UIMenuItem alloc] initWithTitle:@"Notes" action:@selector(addNotesAction:)];
    [menuitem4 cxa_setImage:[UIImage imageNamed:@"notes"]];
    
    UIMenuItem *menuitem5 = [[UIMenuItem alloc] initWithTitle:@"Safari" action:@selector(goToSafari:) ];
    CXAMenuItemSettings *settings = [CXAMenuItemSettings new];
    settings.image = [UIImage imageNamed:@"safari"];
    settings.shadowDisabled = YES;
    settings.shrinkWidth = 16;
    [menuitem5 cxa_setSettings:settings];
    
    [[UIMenuController sharedMenuController]setMenuItems:@[menuitem,menuitem1,menuitem2,menuitem3,menuitem4,menuitem5]];
}


 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    [super viewDidLoad];
    strHighlightedTextToBeSearched=@"";
    /*setup UIMenuController */
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideNotesView) name:@"HIDE_NOTES_VIEW" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideDropView) name:@"HIDE_DROP_VIEW" object:nil];
    
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [_searchView addGestureRecognizer:tapGesture];
    
    [_searchView setHidden:YES];
    
    self.view.backgroundColor=UIColorFromRGB(MACRO_CODE_FOR_BG);
    
    
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
    
    //self.navigationController.navigationBarHidden=YES;
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

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    self.navigationController.navigationBar.hidden=YES;
}

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
        /*Back button is pressed. Save the current page number */
        //[self storeCurrentPageNo];
        //[readingMetric bookIsClosed:[NSDate date]];
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
        [webView highlightAllOccurencesOfString:currentSearchResult.originatingQuery];
    }
    
    
    int totalWidth = [[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollWidth"] intValue];
    pagesInCurrentSpineCount = (int)((float)totalWidth/webView.bounds.size.width);
    
    [self gotoPageInCurrentSpine:currentPageInSpineIndex];
    
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)takeToHomeScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)showChapterList:(id)sender {
}
- (IBAction)showReadingMetric:(id)sender {
}
- (IBAction)takeToBookMarkPage:(id)sender {
}

- (IBAction)fontSizeChanged:(id)sender {
    
    if (m_objDropViewController!=nil) {
        [m_objDropViewController.view removeFromSuperview];
        m_objDropViewController.delegate=nil;
        m_objDropViewController=nil;
    }
    
    
    
    if (m_objDropViewController==nil) {
        m_objDropViewController=[[LPDropViewController alloc] initWithNibName:NSStringFromClass([LPDropViewController class]) bundle:nil];
        m_objDropViewController.delegate=self;
    }
    
    
    m_objDropViewController.iViewName=E_TextSize;
    m_objDropViewController.view.frame=CGRectMake(0, self.view.frame.size.height*-1, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:m_objDropViewController.view];
    
    
    
    
    
    
    [UIView animateWithDuration:0.3 animations:^{
        m_objDropViewController.view.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        m_objDropViewController.view.alpha=0.5;
    } completion:^(BOOL finished) {
        m_objDropViewController.view.alpha=1.0;
        
    }];
    
    
    
    
    
    
    if (m_objDropViewController.iViewName == E_TextSize) {
        //Do nothing as it is already done
        //        CGRect frame=CGRectMake(self.view.center.x - m_objDropViewController.view.frame.size.width/2, self.view.frame.origin.y - m_objDropViewController.view.frame.size.height, m_objDropViewController.view.frame.size.width, m_objDropViewController.view.frame.size.height);
        
        
        //        if (m_objDropViewController.view.frame.origin.y==frame.origin.y) {
        //
        //            frame=CGRectMake(self.view.center.x - m_objDropViewController.view.frame.size.width/2, self.view.frame.origin.y, m_objDropViewController.view.frame.size.width, m_objDropViewController.view.frame.size.height);
        //
        //            [UIView animateWithDuration:0.3 animations:^{
        //                m_objDropViewController.view.frame=frame;
        //                m_objDropViewController.view.alpha=0.5;
        //            } completion:^(BOOL finished) {
        //                m_objDropViewController.view.alpha=1.0;
        //
        //            }];
        //
        //        }else{
        //
        //
        //            [UIView animateWithDuration:0.3 animations:^{
        //                m_objDropViewController.view.frame=frame;
        //            } completion:^(BOOL finished) {
        //                m_objDropViewController.view.alpha=1.0;
        //
        //            }];
        //        }
        //
        
        
    }else{
        
        
        m_objDropViewController.view.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        
        //        m_objDropViewController.view.frame=m_objDropViewController.m_vwTextSize.frame;
        
        //
        //        CGRect frame=CGRectMake(self.view.center.x - m_objDropViewController.view.frame.size.width/2, self.view.frame.origin.y - m_objDropViewController.view.frame.size.height, m_objDropViewController.view.frame.size.width, m_objDropViewController.view.frame.size.height);
        //        m_objDropViewController.view.frame=frame;
        //        m_objDropViewController.view.alpha=0.5;
        //
        //        [self.view addSubview:m_objDropViewController.view];
        //
        //
        //        frame=CGRectMake(self.view.center.x - m_objDropViewController.view.frame.size.width/2, self.view.frame.origin.y, m_objDropViewController.view.frame.size.width, m_objDropViewController.view.frame.size.height);
        //
        //        [UIView animateWithDuration:0.3 animations:^{
        //            m_objDropViewController.view.frame=frame;
        //            m_objDropViewController.view.alpha=0.5;
        //        } completion:^(BOOL finished) {
        //            m_objDropViewController.view.alpha=1.0;
        //
        //        }];
    }
    
}
- (IBAction)openSearchPanel:(id)sender{
    
    _searchView.hidden=! _searchView.hidden;
    _searchBar.hidden=NO;
    if (_searchView.hidden) {
        
    }else{
        _searchBar.text=@"";
        [_searchBar becomeFirstResponder];
        
    }
    
    
    
    
}


- (IBAction)adjustBrightness:(id)sender{
    
    [m_objDropViewController.view removeFromSuperview];
    m_objDropViewController.delegate=nil;
    
    m_objDropViewController=nil;
    
    if (m_objDropViewController==nil) {
        m_objDropViewController=[[LPDropViewController alloc] initWithNibName:NSStringFromClass([LPDropViewController class]) bundle:nil];
        m_objDropViewController.delegate=self;
    }
    
    
    m_objDropViewController.iViewName=E_BrightNess;
    m_objDropViewController.view.frame=CGRectMake(0, self.view.frame.size.height*-1, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:m_objDropViewController.view];
    
    
    
    
    
    
    [UIView animateWithDuration:0.3 animations:^{
        m_objDropViewController.view.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        m_objDropViewController.view.alpha=0.5;
    } completion:^(BOOL finished) {
        m_objDropViewController.view.alpha=1.0;
        
    }];
    
    
    
    
    //    if (m_objDropViewController.iViewName == E_BrightNess) {
    //Do nothing as it is already done
    //        CGRect frame=CGRectMake(self.view.center.x - m_objDropViewController.view.frame.size.width/2, self.view.frame.origin.y - m_objDropViewController.view.frame.size.height, m_objDropViewController.view.frame.size.width, m_objDropViewController.view.frame.size.height);
    
    
    //        if (m_objDropViewController.view.frame.origin.y==frame.origin.y) {
    //
    //            frame=CGRectMake(self.view.center.x - m_objDropViewController.view.frame.size.width/2, self.view.frame.origin.y, m_objDropViewController.view.frame.size.width, m_objDropViewController.view.frame.size.height);
    //
    //            [UIView animateWithDuration:0.3 animations:^{
    //                m_objDropViewController.view.frame=frame;
    //                m_objDropViewController.view.alpha=0.5;
    //            } completion:^(BOOL finished) {
    //                m_objDropViewController.view.alpha=1.0;
    //
    //            }];
    //
    //        }else{
    //
    //
    //            [UIView animateWithDuration:0.3 animations:^{
    //                m_objDropViewController.view.frame=frame;
    //            } completion:^(BOOL finished) {
    //                m_objDropViewController.view.alpha=1.0;
    //
    //            }];
    //        }
    //
    //
    //
    //    }else{
    //
    //        m_objDropViewController.iViewName=E_BrightNess;
    //
    //        CGRect frame=CGRectMake(self.view.center.x - m_objDropViewController.view.frame.size.width/2, self.view.frame.origin.y - m_objDropViewController.view.frame.size.height, m_objDropViewController.view.frame.size.width, m_objDropViewController.view.frame.size.height);
    //        m_objDropViewController.view.frame=frame;
    //        m_objDropViewController.view.alpha=0.5;
    //
    //        [self.view addSubview:m_objDropViewController.view];
    //
    //
    //        frame=CGRectMake(self.view.center.x - m_objDropViewController.view.frame.size.width/2, self.view.frame.origin.y, m_objDropViewController.view.frame.size.width, m_objDropViewController.view.frame.size.height);
    //
    //        [UIView animateWithDuration:0.3 animations:^{
    //            m_objDropViewController.view.frame=frame;
    //            m_objDropViewController.view.alpha=0.5;
    //        } completion:^(BOOL finished) {
    //            m_objDropViewController.view.alpha=1.0;
    //
    //        }];
    //    }
    
}


-(void)tapOnWebView{
    if (m_objDropViewController) {
        
        CGRect frame=CGRectMake(self.view.center.x - m_objDropViewController.view.frame.size.width/2, self.view.frame.origin.y - m_objDropViewController.view.frame.size.height, m_objDropViewController.view.frame.size.width, m_objDropViewController.view.frame.size.height);
        
        [UIView animateWithDuration:0.3 animations:^{
            m_objDropViewController.view.frame=frame;
        } completion:^(BOOL finished) {
            m_objDropViewController.view.alpha=1.0;
            
        }];
        
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}




#pragma mark TextSize increment

-(void) increaseFontSize{
    [self increaseTextSizeClicked:nil];
}
-(void) decreaseFontSize{
    [self decreaseTextSizeClicked:nil];
    
}

-(void) restoreToDefault{
    
}


#pragma mark HighLighting

-(void)highLightAction:(id)sender{
    NSString *newText = [self.webView stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
    
    //    NSLog(@"htmlString %@",[self.webView getHTML]);
    //
    //    NSLog(@"%@",[self.webView stringByEvaluatingJavaScriptFromString:@"(window.getSelection()).anchorNode.nextSibling.textContent"]);
    //
    //    NSLog(@"%@",[webView stringByEvaluatingJavaScriptFromString:@"(window.getSelection()).anchorNode.textContent"]);
    //
    //    NSLog(@"%@",[webView stringByEvaluatingJavaScriptFromString:@"(window.getSelection()).anchorNode.anchorNode.textContent"]);
    
    
    
    NSString *strAnchorNodeContent=[webView stringByEvaluatingJavaScriptFromString:@"(window.getSelection()).anchorNode.textContent"];
    
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *marr=[[NSMutableArray alloc] init];
    
    if ([userDefaults objectForKey:@"highlightedTextData"]) {
        if ([[userDefaults objectForKey:@"highlightedTextData"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in [userDefaults objectForKey:@"highlightedTextData"]) {
                [marr addObject:dict];
            }
        }
    }
    
    
    
    
    NSString *strPage=[self.currentPageLabel.text componentsSeparatedByString:@"/"][0];
    
    int targetPage=[strPage intValue];
    NSNumber *pageNumber=[NSNumber numberWithInt:targetPage];
    
    
    NSDictionary *dictHighLightedTextInfo=[[NSDictionary alloc] initWithObjectsAndKeys:self.strBookName,@"bookName",[self getChapterNameOfBook],@"chapterName",strAnchorNodeContent,@"anchorNode",newText,@"highlightedText",[NSNumber numberWithInteger:currentPageInSpineIndex],@"PageIndexInSpine",[NSNumber numberWithInteger:currentSpineIndex],@"spineIndex",pageNumber, @"pageNumber", nil];
    
    [marr addObject:dictHighLightedTextInfo];
    
    [userDefaults setObject:marr forKey:@"highlightedTextData"];
    
    
    [self.webView highlightButtonString:newText withColor:@"yellow"];
    //    [self.webView highlightString:newText];
    
}


- (IBAction)showBookMarks:(id)sender{
    
    
    //    self.m_vwBookMark.hidden=NO;
    //
    //    [UIView animateWithDuration:0.2 animations:^{
    //        self.m_vwBookMark.frame=CGRectMake(self.m_vwBookMark.frame.origin.x, 50, self.m_vwBookMark.frame.size.width, 100);
    //
    //    } completion:^(BOOL finished) {
    //
    //    }];
    //
    //    NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerText"];//may be `"document.body.innerText;"`
    
    NSString *body = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByClassName('calibre1')"];
    
    NSString *strTextContent = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
    
    
    NSArray *arr=[strTextContent componentsSeparatedByString:@"<p class=\"calibre1\">"];
    
    /*
     //HTML PARSER
     
     TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:[strTextContent dataUsingEncoding:NSUTF8StringEncoding]];
     
     NSString *tutorialsXpathQueryString = @"//p[@class='calibre1']";
     NSArray *tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
     
     NSMutableArray *newTutorials = [[NSMutableArray alloc] initWithCapacity:0];
     for (TFHppleElement *element in tutorialsNodes) {
     Tutorial *tutorial = [[Tutorial alloc] init];
     [newTutorials addObject:tutorial];
     tutorial.title = [[element firstChild] content];
     tutorial.url = [element objectForKey:@"calibre1"];
     }
     
     */
    
    [_btnBookMark setImage:[UIImage imageNamed:@"bookmark12"] forState:UIControlStateNormal];
    
    
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *marr=[[NSMutableArray alloc] init];
    
    
    
    if ([userDefaults objectForKey:@"bookMark"]) {
        if ([[userDefaults objectForKey:@"bookMark"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in [userDefaults objectForKey:@"bookMark"]) {
                [marr addObject:dict];
            }
        }
    }
    
    
    UIScrollView* sv = nil;
    for (UIView* v in  webView.subviews) {
        if([v isKindOfClass:[UIScrollView class]]){
            sv = (UIScrollView*) v;
            sv.scrollEnabled = NO;
            sv.bounces = NO;
            
            NSString *strContent=@"";
            if (arr){
                if (arr.count>=2) {
                    strContent=arr[2];
                    
                    if(strContent.length>=4){
                        //                        NSString *trimmedString=[strContent substringFromIndex:MAX((int)[strContent length]-5, 0)];
                        //                        if ([trimmedString isEqualToString:@"</p>"]) {
                        strContent=[strContent substringToIndex:MAX((int)[strContent length]-5, 0)];
                        //                        }
                    }
                    
                }
            }
            
            
            NSString *strPage=[self.currentPageLabel.text componentsSeparatedByString:@"/"][0];
            
            int targetPage=[strPage intValue];
            NSNumber *pageNumber=[NSNumber numberWithInt:targetPage];
            
            
            NSDictionary *dictHighLightedTextInfo=[[NSDictionary alloc] initWithObjectsAndKeys:self.strBookName,@"bookName",[self getChapterNameOfBook],@"chapterName",[NSNumber numberWithInteger:currentPageInSpineIndex],@"PageIndexInSpine",[NSNumber numberWithInteger:currentSpineIndex],@"spineIndex",strContent,@"pageContent",pageNumber, @"pageNumber",nil];
            [marr addObject:dictHighLightedTextInfo];
            [userDefaults setObject:marr forKey:@"bookMark"];
            
        }
    }
    
    
}




-(NSString *)getChapterNameOfBook{
    //    NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerText"];
    //
    //
    //    NSArray *arr=[html componentsSeparatedByString:@"\n"];
    //
    //    NSString *chapterName=@"";
    //    if (arr.count>0) {
    //        chapterName=arr[0];
    //    }
    
    return [[loadedEpub.spineArray objectAtIndex:currentSpineIndex] title];
}


-(void)goToSafari:(id)sender{
    NSString *strMessageToBeSend = [self.webView stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
    
    NSURL *url= [NSURL URLWithString:[NSString stringWithFormat:@"https://www.google.co.in/webhp?sourceid=chrome-instant&ion=1&espv=2&ie=UTF-8#q=%@",strMessageToBeSend]];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}
#pragma mark Mail Composer

-(void)mailAction:(id)sender{
    NSString *strMessageToBeSend = [self.webView stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setToRecipients:@[@"abc@gmail.com"]];
        [composeViewController setSubject:[NSString stringWithFormat:@"Text from %@",self.strBookName]];
        [composeViewController setMessageBody:strMessageToBeSend isHTML:NO];
        
        [self presentViewController:composeViewController animated:YES completion:nil];
    }
}


-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if(error)
    {
        UIAlertView *alrt=[[UIAlertView alloc]initWithTitle:@"" message:@"" delegate:nil cancelButtonTitle:@"" otherButtonTitles:nil, nil];
        [alrt show];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
}


#pragma mark Search Action


-(void)searchAction:(id)sender{
    NSString *strSearch = [self.webView stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
    strHighlightedTextToBeSearched=strSearch;
    
    [self openSearch];
}
- (void) hideSearchView{
    _searchView.hidden=YES;
    
}
-(void) openSearch{
    _searchView.hidden=NO;
    if (_searchView.hidden) {
        [self.view endEditing:YES];
    }else{
        _searchBar.hidden=NO;
        [_searchBar becomeFirstResponder];
        _searchBar.text=strHighlightedTextToBeSearched;
    }
}


#pragma mark Notes action
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    if (m_popOverNotes == popoverController) {
        NSLog(@"Same");
    }
}
-(void)addNotesAction:(id)sender{
    NSString *strTextToBeSelected = [self.webView stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
    
    
    [self.webView highlightButtonString:strTextToBeSelected withColor:@"yellow"];
    //    [self.webView highlightString:strTextToBeSelected withColor:@"pink"];
    
    m_objNotesViewController=[[LPNotesViewController alloc] initWithNibName:NSStringFromClass([LPNotesViewController class]) bundle:nil];
    m_objNotesViewController.m_strBookName=[NSString stringWithFormat:@"%@",self.strBookName];
    m_objNotesViewController.m_strChapterName=[NSString stringWithFormat:@"%@",[self getChapterNameOfBook]];
    
    
    m_objNotesViewController.m_strHighlighted = strTextToBeSelected;
    
    m_objNotesViewController.m_strAnchorNodeContent=[webView stringByEvaluatingJavaScriptFromString:@"(window.getSelection()).anchorNode.textContent"];
    
    
    
    [self.view addSubview:m_objNotesViewController.view];
    
    [m_objNotesViewController.m_txtView becomeFirstResponder];
    [m_objNotesViewController setCenter:CGPointMake(self.view.center.x, self.view.center.y-150)];
    
}

-(void) removeAllHighLights{
    [self.webView removeAllHighlights];
}


@end
