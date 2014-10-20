//
//  ReadingMetric.h
//  LearningPlatform2
//
//  Created by Anushree Dhople on 10/13/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReadingMetric : NSObject {
    
    NSInteger bookindex;

    NSDate *bookopened;
    NSDate *bookclosed;
    NSInteger secspentreadingbook;
    
    NSDate *pageopened;
    NSDate *pageclosed;
    NSInteger secspentreadingpage;
    NSInteger avgsecspentreadingpage;
    
    NSInteger pagesread;
    NSInteger totalpages;
    
    NSInteger completedpercentage;

}

-(void) setBookIndex:(NSInteger)bookid;

-(void) bookIsOpened:(NSDate *)time;
-(void) bookIsClosed:(NSDate *)time;

-(void) pagescroll:(NSDate *)time;

-(void) setTotalPages:(NSInteger)pages;

-(void)updateDB;


@end
