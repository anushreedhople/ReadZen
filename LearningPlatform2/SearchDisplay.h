//
//  SearchDisplay.h
//  LearningPlatform2
//
//  Created by Anushree Dhople on 8/18/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface SearchDisplay : NSObject

@property (nonatomic, strong) NSString *bookname;
@property (nonatomic, strong) NSString *authorname;
@property (nonatomic, strong) NSString *bookid;
@property (nonatomic, strong) PFFile *bookcover;
@property (nonatomic, strong) NSString *bookgenre;

@end