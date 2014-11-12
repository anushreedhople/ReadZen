//
//  LPDropViewController.m
//  LearningPlatform2
//
//  Created by Anil Kothari on 11/10/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import "LPDropViewController.h"
#import "Parse/Parse.h"

@interface LPDropViewController ()

@end

@implementation LPDropViewController

int bookid;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    /*Assign the table delegates*/
    [self.tableMetrics setDelegate:self];
    [self.tableMetrics setDataSource:self];
    
    self.m_vwBrightness.hidden=YES;
    self.m_vwTextSize.hidden=YES;
    self.m_vwMetrics.hidden=YES;
    
    
    /*Assign titles to the metrics*/
    NSLog(@"Going to assign metrics for display and bookid is %d", bookid);
    metricTitles = [[NSMutableArray alloc] initWithObjects:@"Pages Read",@"Secs per Page",@"Percentage Completed", @"Total Time Spent", nil];
    
    /*Initialize the reading metrics from Parse Db*/
    NSString *username = [[PFUser currentUser] valueForKey:@"username"];
    PFQuery *query = [PFQuery queryWithClassName:@"Metrics"];
    [query whereKey:@"userid" equalTo:username];
    NSArray *objects = [query findObjects];
    
    double timeInMin=0;
    
    for(PFObject *object in objects) {
        
        timeInMin =  (float)[[(NSArray *)[object valueForKey:@"completionmin"] objectAtIndex:bookid] intValue]/60;
        double roundedtimeInMin = (roundf)(timeInMin*10)/10.0;
        
        readingMetrics = [[NSMutableArray alloc] initWithObjects:
                          [NSString stringWithFormat:@"%@ pages",
                          [(NSArray *)[object valueForKey:@"pagesread"] objectAtIndex:bookid]],
                          [NSString stringWithFormat:@"%@ secs",
                          [(NSArray *)[object valueForKey:@"minperpage"] objectAtIndex:bookid]],
                          [NSString stringWithFormat:@"%@ %%",
                          [(NSArray *)[object valueForKey:@"completionpercent"] objectAtIndex:bookid]],
                          [NSString stringWithFormat:@"%.2f mins", roundedtimeInMin],
                           nil];
     }
 

    if (_iViewName == E_BrightNess) {
        self.view.frame=self.m_vwBrightness.frame;

        self.m_vwBrightness.hidden=NO;
        [self.view addSubview:self.m_vwBrightness];
        
        
        UIScreen *screen=[UIScreen mainScreen];
        CGFloat val=screen.brightness;

        _m_sliderBrightness.value=val;
        
     }else if (_iViewName == E_TextSize){
        self.view.frame=self.m_vwTextSize.frame;

        self.m_vwTextSize.hidden=NO;
        [self.view addSubview:self.m_vwTextSize];

    }
     else if(_iViewName == E_Metrics) {
         self.view.frame = self.m_vwMetrics.frame;
         
         self.m_vwMetrics.hidden = NO;
         [self.view addSubview:self.m_vwMetrics];
     }
    
    
    [self.increaseFont addTarget:self.delegate action:@selector(increaseFontSize) forControlEvents:UIControlEventTouchDown];
    [self.decreaseSize addTarget:self.delegate action:@selector(decreaseFontSize) forControlEvents:UIControlEventTouchDown];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)brightnessValueChanged:(id)sender {
    UISlider *slider=(UISlider *)sender;
    CGFloat sliderValue=slider.value;
    [[UIScreen mainScreen] setBrightness:sliderValue];
    
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];
    
    if (touch.view.tag > 0) {
        touch.view.center = location;
    }
    
    CGPoint locationPoint = [[touches anyObject] locationInView:self.view];
    UIView* viewYouWishToObtain = [self.view hitTest:locationPoint withEvent:event];

    
    if (viewYouWishToObtain.tag==100) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_DROP_VIEW" object:nil];
    }
    
//
}

- (IBAction)contrastValueChanged:(id)sender {
}

- (IBAction)contrast1:(id)sender {
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    /*Displays 3 metrics: No of pages read, Min spent per page, % of book completed*/
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleValue2
                reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell.
    /*Column-1*/
    UILabel * label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 312, 43)];
    [label1 setFont:[UIFont fontWithName:@"arial" size:18]];
    [label1 setTextColor:[UIColor blackColor]];
    label1.backgroundColor = [UIColor clearColor];
    label1.layer.borderColor=[[UIColor lightGrayColor]CGColor];
    label1.layer.borderWidth= 1.0f;
    label1.numberOfLines = 0;
    label1.text = [NSString stringWithFormat:@" %@",[metricTitles objectAtIndex:indexPath.row]];
    [cell.contentView addSubview:label1];
    
    /*Column-2*/
    UILabel * label2 = [[UILabel alloc]initWithFrame:CGRectMake(314, 0, 125, 43)];
    [label2 setFont:[UIFont fontWithName:@"arial" size:18]];
    [label2 setTextColor:[UIColor blackColor]];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.backgroundColor = [UIColor clearColor];
    label2.layer.borderColor=[[UIColor lightGrayColor]CGColor];
    label2.layer.borderWidth= 1.0f;
    label2.text = [NSString stringWithFormat:@"%@",[readingMetrics objectAtIndex:indexPath.row]];
    [cell.contentView addSubview:label2];

    return cell;
}

- (void) setBookIndex:(int)bookIndex {
    
    bookid = bookIndex;
    
}

@end
