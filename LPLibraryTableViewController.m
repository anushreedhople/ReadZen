//
//  LPLibraryTableViewController.m
//  LearningPlatform2
//
//  Created by Anushree Dhople on 7/27/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import "LPLibraryTableViewController.h"
#import "Parse/Parse.h"
#import "LPTableViewController.h"
#import "LPBookDetailsViewController.h"
#import "LPTableViewCell.h"

@interface LPLibraryTableViewController ()

@end

@implementation LPLibraryTableViewController


@synthesize booknames, authornames, bookid, bookcover, bookdescriptions;
@synthesize noOfRows;
@synthesize searchresult;
@synthesize searchbar;
@synthesize booksids,bookgeneric;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    self.tableView.backgroundColor = [UIColor darkGrayColor];
    
    self.booknames = [[NSMutableArray alloc] init];
    self.authornames = [[NSMutableArray alloc] init];
    self.bookid = [[NSMutableArray alloc] init];
    self.bookcover = [[NSMutableArray alloc]init];
    self.bookdescriptions = [[NSMutableArray alloc] init];
    self.noOfRows = 0;

    self.bookgeneric = [[NSMutableArray alloc] init];
    self.booksids = [[NSMutableArray alloc]init];
    [self.booksids addObjectsFromArray:[[PFUser currentUser] valueForKey:@"bookids"]];
    
    /*Get Parse data using PFQuery*/
    PFQuery *query = [PFQuery queryWithClassName:@"BookRepository"];
    NSArray *objects = [query findObjects];
   
    noOfRows = objects.count;
    NSUInteger i = 0;
    for(PFObject *object in objects) {
        if([object valueForKey:@"bookdescription"]){
        [self.bookdescriptions addObject:[object valueForKey:@"bookdescription"]];}
        [self.booknames addObject:[object valueForKey:@"bookname"]];
        [self.authornames addObject:[object valueForKey:@"authorname"]];
        [self.bookid addObject:[object valueForKey:@"bookid"]];
        [self.bookcover addObject:[object valueForKey:@"bookcover"]];
        [self.bookgeneric addObject:[object valueForKey:@"bookgenre"]];

        i++;
    }
    
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}


- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (![parent isEqual:self.parentViewController]) {
        NSLog(@"Back pressed from here");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    cell.backgroundColor = [UIColor whiteColor];
    /*Code to alternate color of cells between dark gray and white */
    /*if ((indexPath.row % 2) == 1) {
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    else
    {
        cell.backgroundColor = [UIColor darkGrayColor];
        cell.textLabel.backgroundColor = [UIColor darkGrayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }*/
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView==self.tableView)
    {
        return noOfRows;
    }
    else
    {
        [self searchthroughdata];
        return  self.searchresult.count;
    
    }
    
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText

{   
    [self searchthroughdata];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    LPTableViewCell *cell = (LPTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SimpleTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    
    cell.nameLabel.text = [self.booknames objectAtIndex:indexPath.row];
    
    PFFile *theImage = [self.bookcover objectAtIndex:indexPath.row];
    NSData *imageData = [theImage getData];
    cell.thumbnailImageView.image = [UIImage imageWithData:imageData];
    
    cell.lblauthor.text=[self.authornames objectAtIndex:indexPath.row];
    cell.lblGener.text=[self.bookgeneric objectAtIndex:indexPath.row];
    if([PFUser currentUser]) {
        
        if ([self.booksids containsObject: [self.bookid objectAtIndex:indexPath.row]])
        {
            
            cell.lblissue.text=@"Issued";
            
        }
        else
        {
            cell.lblissue.text=@"Issue";
            
        }
        
    }
    
    return cell;}



-(void)searchthroughdata{
    self.searchresult=nil;
    NSPredicate *resultPredicate = [NSPredicate
                                        predicateWithFormat:@"SELF contains[search] %@",
                                    self.searchbar.text];
    self.searchresult=[[self.booknames filteredArrayUsingPredicate:resultPredicate]mutableCopy];
    [self.searchresult addObjectsFromArray:[[self.authornames filteredArrayUsingPredicate:resultPredicate] mutableCopy]];
    
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==self.tableView) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        LPBookDetailsViewController *bookdetails = [self.storyboard instantiateViewControllerWithIdentifier:@"BookDetailsViewController"];
        [self.navigationController pushViewController:bookdetails animated:YES];
        bookdetails.bookname = cell.textLabel.text;
        bookdetails.authorname = cell.detailTextLabel.text;
        bookdetails.bookid = [self.bookid objectAtIndex:indexPath.row];
        bookdetails.bookdescription = [self.bookdescriptions objectAtIndex:indexPath.row];
        
        PFFile *theImage = [self.bookcover objectAtIndex:indexPath.row];
        NSData *imageData = [theImage getData];
        bookdetails.bookcover = [UIImage imageWithData:imageData];
        if(bookdetails.bookcover) {NSLog(@"Some image data is added");}

    }
    else
    {
        
        
        indexPath=[[self.searchDisplayController searchResultsTableView]indexPathForSelectedRow];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        LPBookDetailsViewController *bookdetails = [self.storyboard instantiateViewControllerWithIdentifier:@"BookDetailsViewController"];
        [self.navigationController pushViewController:bookdetails animated:YES];
     
        
        bookdetails.bookname = cell.textLabel.text;
        
        PFQuery *query=[PFQuery queryWithClassName:@"BookRepository"];
        
        [query whereKey:@"bookname" equalTo:bookdetails.bookname];
         NSArray *objects = [query findObjects];
        for(PFObject *object in objects) {
          
        bookdetails.authorname =[object valueForKey:@"authorname"];
        bookdetails.bookid = [object valueForKey:@"bookid"];
        bookdetails.bookdescription =[object valueForKey:@"bookdescription"];
        
        PFFile *theImage = [object valueForKey:@"bookcover"];
        NSData *imageData = [theImage getData];
        bookdetails.bookcover = [UIImage imageWithData:imageData];
                
                
        }
        
        
    }
    
}
@end
