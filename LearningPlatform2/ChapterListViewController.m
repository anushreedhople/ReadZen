//
//  ChapterListViewController.m
//  AePubReader
//
//  Created by Federico Frappi on 04/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChapterListViewController.h"


@implementation ChapterListViewController

@synthesize epubViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:@"ChapterListViewController"  bundle:nil];
    if (self != nil) {
        // further initialization needed
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=UIColorFromRGB(MACRO_CODE_FOR_BG);
    self.m_tblChapterList.backgroundColor=[UIColor clearColor];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.m_lblBookName.text=_strBookName;
    
    iTableLoad=TABLE_CHAPTER;
    
    
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    marrBookMarkData=[[NSMutableArray alloc] init];
    
    marrHighlightData=[[NSMutableArray alloc] init];
    
    marrNotesData=[[NSMutableArray alloc] init];
    
    
    if ([userDefaults objectForKey:@"bookMark"]) {
        if ([[userDefaults objectForKey:@"bookMark"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in [userDefaults objectForKey:@"bookMark"]) {
                
                
                if ([[dict objectForKey:@"bookName"]isEqualToString:self.m_lblBookName.text]) {
                    [marrBookMarkData addObject:dict];
                    
                }
                
                
            }
        }
    }
    
    
    
    
    
    if ([userDefaults objectForKey:@"notesTextData"]) {
        if ([[userDefaults objectForKey:@"notesTextData"] isKindOfClass:[NSArray class]]) {
            
            for (NSDictionary *dict in [userDefaults objectForKey:@"notesTextData"]) {
                if ([[dict objectForKey:@"bookName"]isEqualToString:self.m_lblBookName.text]) {
                    [marrNotesData addObject:dict];
                }
            }
        }
    }
    
    
    
    
    
    
    
    if ([userDefaults objectForKey:@"highlightedTextData"]) {
        if ([[userDefaults objectForKey:@"highlightedTextData"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in [userDefaults objectForKey:@"highlightedTextData"]) {
                if ([[dict objectForKey:@"bookName"]isEqualToString:self.m_lblBookName.text]) {
                    [marrHighlightData addObject:dict];
                    
                }
                
                
            }
        }
    }
    
    
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
    


-(void)deleteAllHighLights{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *marr=[[NSMutableArray alloc] init];
    
    if ( iTableLoad==TABLE_HIGHLIGHT) {
        [userDefaults setObject:marr forKey:@"highlightedTextData"];
        [marrHighlightData removeAllObjects];
        
        [self.m_tblChapterList reloadData];
        [epubViewController removeAllHighLights];
        
        
    }else if ( iTableLoad==TABLE_BOOKMARK){
        [userDefaults setObject:marr forKey:@"bookMark"];
        [marrBookMarkData removeAllObjects];
        
        [self.m_tblChapterList reloadData];
        [epubViewController highLightBookMark :NO];
        
    }else if ( iTableLoad==TABLE_NOTES){
        [userDefaults setObject:marr forKey:@"notesTextData"];
        [marrNotesData removeAllObjects];
        
        [self.m_tblChapterList reloadData];
        [epubViewController removeAllHighLights];
        
        
    }
    
    
    
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag==TABLE_HIGHLIGHT ) {
        return 60;
    }else{
        return 50;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (iTableLoad==TABLE_CHAPTER){
        
        return [epubViewController.loadedEpub.spineArray count];
    }
    else if (iTableLoad==TABLE_BOOKMARK){
        return marrBookMarkData.count;
    }    else if (iTableLoad==TABLE_HIGHLIGHT){
        return marrHighlightData.count;
        
    }else if (iTableLoad==TABLE_NOTES){
        return marrNotesData.count;
        
    }else{
        return 1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *vw=[[UIView alloc]initWithFrame:CGRectMake(tableView.frame.origin.x, 0, tableView.frame.size.width, 30)];
    [vw setBackgroundColor:UIColorFromRGB(MACRO_CODE_FOR_BG)];
    
    UILabel *lbl=[[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.origin.x, 0, tableView.frame.size.width, 40)];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    lbl.font=[UIFont fontWithName:@"Helvetica" size:14.0f];
    
    if (iTableLoad==TABLE_CHAPTER){
        lbl.text=[NSString stringWithFormat:@"%d items (selection list)",[epubViewController.loadedEpub.spineArray count]];
    }
    else if (iTableLoad==TABLE_BOOKMARK){
        lbl.text=[NSString stringWithFormat:@"%d items (selection list)", marrBookMarkData.count];
    }    else if (iTableLoad==TABLE_HIGHLIGHT){
        lbl.text=[NSString stringWithFormat:@"%d items (selection list)", marrHighlightData.count];
        
    } else if (iTableLoad==TABLE_NOTES){
        lbl.text=[NSString stringWithFormat:@"%d items (selection list)", marrNotesData.count];
        
    }
    
    
    [lbl setBackgroundColor:[UIColor clearColor]];
    [vw addSubview:lbl];
    
    UIView *vw1=[[UIView alloc]initWithFrame:CGRectMake(tableView.frame.origin.x, 0, tableView.frame.size.width, 0.3)];
    [vw1 setBackgroundColor:UIColorFromRGB(0xCFCDD0)];
    
    
    
    if (iTableLoad==TABLE_HIGHLIGHT || iTableLoad == TABLE_BOOKMARK ||iTableLoad==TABLE_NOTES){
        
        
        //        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        //        btn.frame=CGRectMake(10, 0, 135, 44);
        //        [btn setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        //        [btn addTarget:self action:@selector(deleteAllHighLights) forControlEvents:UIControlEventTouchDown];
        //        [vw addSubview:btn];
        
        
        
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(10, 0, 135, 44);
        //        [btn setBackgroundColor:[UIColor whiteColor]];
        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        
        [btn setTitle:@"Delete All" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(deleteAllHighLights) forControlEvents:UIControlEventTouchDown];
        [vw addSubview:btn];
        
        
        if (iTableLoad==TABLE_HIGHLIGHT) {
            if (marrHighlightData.count==0) {
                btn.hidden=YES;
            }else{
                btn.hidden=NO;
                
            }
        }
        
        
        if (iTableLoad==TABLE_BOOKMARK) {
            if (marrBookMarkData.count==0) {
                btn.hidden=YES;
            }else{
                btn.hidden=NO;
            }
        }
        
        
        if (iTableLoad==TABLE_NOTES) {
            if (marrNotesData.count==0) {
                btn.hidden=YES;
            }else{
                btn.hidden=NO;
            }
        }
        
    }
    vw.backgroundColor=UIColorFromRGB(0xECE4DA);
    
    [vw addSubview:vw1];
    
    
    
    
    return vw;
}


-(int)getIndexOfChapter:(NSString *)chapter{
    int jCounter=0;
    
    for (jCounter=0; jCounter<[epubViewController.loadedEpub.spineArray count]; jCounter++) {
        NSString *chapterName= [[epubViewController.loadedEpub.spineArray objectAtIndex:jCounter] title];
        if ([chapterName isEqualToString:chapter]) {
            return jCounter;
        }
        
    }
    return jCounter;
    
    //    for (Chapter *chap in epubViewController.loadedEpub.spineArray) {
    //        if ([chap.title isEqualToString:chapter]) {
    //            return jCounter;
    //        }
    //        jCounter++;
    //    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    
    
    if (iTableLoad==TABLE_CHAPTER){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
        cell.backgroundColor=[UIColor clearColor];
        
        cell.contentView.backgroundColor=[UIColor clearColor];
        cell.textLabel.backgroundColor=[UIColor clearColor];
        cell.textLabel.text = [[epubViewController.loadedEpub.spineArray objectAtIndex:[indexPath row]] title];
        return cell;
        
    }else if (iTableLoad==TABLE_BOOKMARK){
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
        cell.backgroundColor=[UIColor clearColor];
        
        cell.contentView.backgroundColor=[UIColor clearColor];
        cell.textLabel.backgroundColor=[UIColor clearColor];
        NSDictionary *dict=marrBookMarkData[indexPath.row];
        
        NSString *strPageContent=[dict objectForKey:@"pageContent"];
        
        cell.textLabel.text = [NSString stringWithFormat:@"Chapter Name: %@ ",[dict objectForKey:@"chapterName"] ];
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%@ ",strPageContent ];
        return cell;
        
    }else if (iTableLoad == TABLE_HIGHLIGHT){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
        cell.backgroundColor=[UIColor clearColor];
        
        cell.contentView.backgroundColor=[UIColor clearColor];
        cell.textLabel.backgroundColor=[UIColor clearColor];
        
        NSDictionary *dict=marrHighlightData[indexPath.row];
        
        
        
        
        
        //        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
        //
        //        [attributedString addAttribute:NSForegroundColorAttributeName
        //                                 value:UIColorFromRGB(0xff0000)
        //                                 range:NSMakeRange(strChap.length+19, [attributedString length]-19-strChap.length )];
        //
        //        [attributedString addAttribute:NSBackgroundColorAttributeName
        //                                 value:UIColorFromRGB(0x00ffff)
        //                                 range:NSMakeRange(strChap.length+19, [attributedString length]-19-strChap.length)];
        
        cell.detailTextLabel.text = dict[@"chapterName"];
        cell.textLabel.text = dict[@"highlightedText"];
        
        return cell;
        
    }else if (iTableLoad == TABLE_NOTES){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
        cell.backgroundColor=[UIColor clearColor];
        
        cell.contentView.backgroundColor=[UIColor clearColor];
        cell.textLabel.backgroundColor=[UIColor clearColor];
        
        NSDictionary *dict=marrNotesData[indexPath.row];
        
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ HighLight Text: %@",dict[@"chapterName"],dict[@"highlightedText"]];
        cell.textLabel.text = [NSString stringWithFormat:@"%@",dict[@"notesText"]];
        
        return cell;
        
    }
    return nil;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    NSDictionary *dict;
    
    if (iTableLoad==TABLE_CHAPTER){
        
        [epubViewController loadSpine:[indexPath row] atPageIndex:0 highlightSearchResult:nil];
        
        
    }
    else if (iTableLoad==TABLE_BOOKMARK){
        
        dict=marrBookMarkData[indexPath.row];
        NSNumber *numPageIndex=[dict objectForKey:@"PageIndexInSpine"];
        NSString *str1=[dict objectForKey:@"chapterName"];
        
        int IChap=[self getIndexOfChapter:str1];
        [epubViewController loadSpine:IChap atPageIndex:[numPageIndex intValue] highlightSearchResult:nil];
        
        [epubViewController highLightBookMark :YES];
    }
    
    
    else if (iTableLoad==TABLE_HIGHLIGHT){
        
        dict=marrHighlightData[indexPath.row];
        NSNumber *numPageIndex=[dict objectForKey:@"PageIndexInSpine"];
        NSString *str1=[dict objectForKey:@"chapterName"];
        //        NSString *str=[str1 stringByReplacingOccurrencesOfString:@"Chapter" withString:@""];
        
        int IChap=[self getIndexOfChapter:str1];
        [epubViewController loadSpine:IChap atPageIndex:[numPageIndex intValue] highlightSearchResult:nil];
        
        
        NSString *strHighLight=dict[@"highlightedText"];
        
        if (strHighLight) {
            if (![strHighLight isKindOfClass:[NSNull class]]) {
                [epubViewController loadSpine:IChap atPageIndex:[numPageIndex intValue]highlightSearchResult:dict[@"highlightedText"]];
                
                //                [epubViewController.webView highlightAllOccurencesOfStringInBlue:dict[@"highlightedText"]];
            }else{
                [epubViewController loadSpine:IChap atPageIndex:[numPageIndex intValue] highlightSearchResult:nil];
                
            }
        }else{
            [epubViewController loadSpine:IChap atPageIndex:[numPageIndex intValue] highlightSearchResult:nil];
            
        }
        
        
    }
    
    else if (iTableLoad==TABLE_NOTES){
        
        dict=marrNotesData[indexPath.row];
        NSNumber *numPageIndex=[dict objectForKey:@"PageIndexInSpine"];
        NSString *strChapName=[dict objectForKey:@"chapterName"];
        
        
        NSString *str=[strChapName stringByReplacingOccurrencesOfString:@"Chapter" withString:@""];
        
        int spineIndex=[self getIndexOfChapter:strChapName];
        NSString *strHighLight=dict[@"notesText"];
        
        if (strHighLight) {
            if (![strHighLight isKindOfClass:[NSNull class]]) {
                [epubViewController loadSpine:spineIndex atPageIndex:[numPageIndex intValue] highlightSearchResult:dict[@"notesText"]];
                
                
            }else{
                [epubViewController loadSpine:spineIndex atPageIndex:[numPageIndex intValue] highlightSearchResult:nil];
                
            }
        }else{
            [epubViewController loadSpine:spineIndex atPageIndex:[numPageIndex intValue] highlightSearchResult:nil];
            
        }
        
        
    }
    
    if (iTableLoad!=TABLE_CHAPTER) {
        [self dismissViewControllerAnimated:YES completion:^{
            
            [epubViewController.webView highlightAllOccurencesOfStringInBlue:dict[@"notesText"]];
        }];
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }
    
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
- (IBAction)bookPressed:(id)sender {
    if (iTableLoad==TABLE_HIGHLIGHT) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
}

- (IBAction)contentTapped:(id)sender {
    
    
    iTableLoad=TABLE_CHAPTER;
    
    [self.m_tblChapterList reloadData];
}

- (IBAction)vocabularyTapped:(id)sender {
    
    
    iTableLoad=TABLE_NOTES;
    
    [self.m_tblChapterList reloadData];
}

- (IBAction)bookmarksTapped:(id)sender {
    
    
    iTableLoad=TABLE_BOOKMARK;
    
    [self.m_tblChapterList reloadData];
}

- (IBAction)highlightsTapped:(id)sender {
    
    iTableLoad=TABLE_HIGHLIGHT;
    [self.m_tblChapterList reloadData];
    
    
}
@end