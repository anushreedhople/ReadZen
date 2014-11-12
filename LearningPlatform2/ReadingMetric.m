//
//  ReadingMetric.m
//  LearningPlatform2
//
//  Created by Anushree Dhople on 10/13/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import "ReadingMetric.h"
#import "Parse/Parse.h"

@implementation ReadingMetric

-(void) setBookIndex:(NSInteger)bookid {
    bookindex = bookid;
}

-(void) bookIsOpened:(NSDate *)time {
    bookopened = time;
    pageopened = time;
    pagesread = 1;
    secspentreadingpage = 0;
}

-(void) bookIsClosed:(NSDate *)time {
    
    /*First set the book closed time*/
    bookclosed = time;
    
    /*Now compute the time spent reading the book*/
    NSTimeInterval timebetweendates = [bookclosed timeIntervalSinceDate:bookopened];
    secspentreadingbook = timebetweendates;
    
    //NSLog(@"The time gap calculated in seconds is %ld", (long)secspentreadingbook);
    
    /*Now update all data in Parse db*/
    [self updateDB];
}

-(void) pagescroll:(NSDate *)time {
    
    /*First set the page closed time*/
    pageclosed = time;
    
    /*Now compute the time spent on that page*/
    NSTimeInterval timebetweendates = [pageclosed timeIntervalSinceDate:pageopened];
    NSInteger timespentreadingpage = timebetweendates;
    
    /*check is time spent in sec is more than 3 sec*/
    if(timespentreadingpage > 3){
        /*This is not scrolling. Consider it valid*/
        secspentreadingpage = secspentreadingpage + timespentreadingpage;
        avgsecspentreadingpage = secspentreadingpage/pagesread;
        
        //NSLog(@"The total time spent reading pages is %ld", (long)timespentreadingpage);
        //NSLog(@"Average time spent per page is %ld", avgsecspentreadingpage);
        
        pagesread++;
    }
    
    pageopened = pageclosed;
    
}


-(void) setTotalPages:(NSInteger)pages {
    totalpages = pages;
}

-(void) updateDB {
    
    /*Get username of current PFUser*/
    NSString *username = [PFUser currentUser].username;
    
    /*Create temporary arrays to store the 3 metric arrays*/
    NSMutableArray *completionmin = [[NSMutableArray alloc]init];
    NSMutableArray *completionpercent = [[NSMutableArray alloc]init];
    NSMutableArray *minperpage = [[NSMutableArray alloc]init];
    NSMutableArray *pagesalreadyread = [[NSMutableArray alloc]init];
    NSInteger totalpagesread=0;
    
    /*Create PFQuery to update Metrics class in Parse DB*/
    PFQuery *query=[PFQuery queryWithClassName:@"Metrics"];
    
    [query whereKey:@"userid" equalTo:username];
    NSArray *objects = [query findObjects];
    for(PFObject *object in objects) {
        
        /*First get the current data and store in temp arrays*/
        completionmin = [object valueForKey:@"completionmin"];
        completionpercent = [object valueForKey:@"completionpercent"];
        minperpage = [object valueForKey:@"minperpage"];
        pagesalreadyread = [object valueForKey:@"pagesread"];
       
        secspentreadingbook = secspentreadingbook + [[completionmin objectAtIndex:bookindex] integerValue];
        totalpagesread = pagesread + [[pagesalreadyread objectAtIndex:bookindex] integerValue];
        completedpercentage = totalpagesread/totalpages;
        
        /*Now update the arrays with current data*/
        [completionmin replaceObjectAtIndex:bookindex withObject:[NSString stringWithFormat:@"%ld",(long)secspentreadingbook]];
        [minperpage replaceObjectAtIndex:bookindex withObject:[NSString stringWithFormat:@"%ld",(long)avgsecspentreadingpage]];
        [completionpercent replaceObjectAtIndex:bookindex withObject:[NSString stringWithFormat:@"%ld", (long)completedpercentage]];
        [pagesalreadyread replaceObjectAtIndex:bookindex withObject:[NSString stringWithFormat:@"%ld", (long)totalpagesread]];
        
        object[@"completionmin"] = completionmin;
        object[@"minperpage"] = minperpage;
        object[@"completionpercent"] = completionpercent;
        object[@"pagesread"] = pagesalreadyread;
        [object saveInBackground];
    }
}



@end
