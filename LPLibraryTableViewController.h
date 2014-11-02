//
//  LPLibraryTableViewController.h
//  LearningPlatform2
//
//  Created by Anushree Dhople on 7/27/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LPLibraryTableViewController : UITableViewController<UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray *booknames;
@property (nonatomic, strong) NSMutableArray *authornames;
@property (nonatomic, strong) NSMutableArray *bookid;
@property (nonatomic, strong) NSMutableArray *bookcover;
@property (nonatomic, strong) NSMutableArray *bookdescriptions;
@property NSUInteger noOfRows;


@property (nonatomic, strong) NSMutableArray *searchresult;
//@property (nonatomic, strong) NSArray *bookname;
@property (nonatomic, strong) IBOutlet UISearchBar *searchbar;

@property (nonatomic, strong) NSMutableArray *booksids;
@property (nonatomic, strong) NSMutableArray *bookgeneric;
@property (nonatomic, strong) NSString *bookidloc;

@end