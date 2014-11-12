

#import "LPCLibraryTableViewController.h"
#import "LPTableCell.h"
#import "Parse/Parse.h"
#import "SearchDisplay.h"
@interface LPCLibraryTableViewController ()

@end

@implementation LPCLibraryTableViewController
NSArray *searchResults;
@synthesize bookarray,noOfRows;

BOOL searchstatus=NO;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.tableView.backgroundColor = [UIColor darkGrayColor];
    
    self.bookarray = [[NSMutableArray alloc] init];
    
    // self.bookid = [[NSMutableArray alloc] init];
    
    self.noOfRows = 0;
    
    
    self.booksids = [[NSMutableArray alloc]init];
    [self.booksids addObjectsFromArray:[[PFUser currentUser] valueForKey:@"bookids"]];
    
    PFQuery *query = [PFQuery queryWithClassName:@"BookRepository"];
    [query setLimit: 100];
    NSArray *objects = [query findObjects];
    
    noOfRows = objects.count;
    NSUInteger i = 0;
    for(PFObject *object in objects) {
        SearchDisplay *search = [SearchDisplay new];
        search.bookname=[object valueForKey:@"bookname"];
        search.bookcover=[object valueForKey:@"bookcover"];
        search.bookgenre=[object valueForKey:@"bookgenre"];
        search.authorname=[object valueForKey:@"authorname"];
        search.bookid=[object valueForKey:@"bookid"];
        [self.bookarray addObject:search];
        i++;
    }
    
    
    
    [super viewDidLoad];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [searchResults count];
        
    } else {
        return [bookarray count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 104;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomTableCell";
    LPTableCell *cell = (LPTableCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[LPTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    SearchDisplay *search = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        search = [searchResults objectAtIndex:indexPath.row];
        searchstatus=YES;
    } else {
        search = [bookarray objectAtIndex:indexPath.row];
        searchstatus=NO;
    }
    cell.delegate = self;
    cell.nameLabel.text = search.bookname;
    PFFile *theImage = search.bookcover;
    NSData *imageData = [theImage getData];
    cell.thumbnailImageView.image = [UIImage imageWithData:imageData];
    cell.lblgenr.text=search.bookgenre;
    cell.prepTimeLabel.text = search.authorname;
    cell.issuebtn.tag=indexPath.row;
    [cell.issuebtn setEnabled:NO];
    if([PFUser currentUser]) {
        
        if ([self.booksids containsObject: search.bookid])
        {
            cell.issuebtn.layer.cornerRadius=9;
            cell.issuebtn.layer.borderWidth=1.0f;
            [cell.issuebtn setTitle:@"Issued" forState:UIControlStateNormal];
            [cell.issuebtn sizeToFit];
        }
        else
        {
            
            [cell.issuebtn setTitle:@"Issue" forState:UIControlStateNormal];
            [cell.issuebtn setEnabled:YES];
            cell.issuebtn.layer.cornerRadius=9;
            cell.issuebtn.layer.borderWidth=1.0f;
            
        }
        
        
    }
    
    return cell;
}



- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSLog(@"Search is called ---------------");
    NSPredicate *p1 = [NSPredicate predicateWithFormat:@"bookname contains[c] %@", searchText];
    NSPredicate *p2 = [NSPredicate predicateWithFormat:@"authorname contains[c] %@", searchText];
    NSPredicate *p3 = [NSPredicate predicateWithFormat:@"bookgenre contains[c] %@", searchText];
    
    NSArray *subPredicates = [[NSArray alloc] initWithObjects:p1,p2,p3,nil];
    
    NSPredicate *resultPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:subPredicates];
    searchResults = [bookarray filteredArrayUsingPredicate:resultPredicate];
    
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}
- (void)addItemViewController:(LPTableCell *)controller didFinishEnteringItem:(NSString *)item
{
    
    
    NSLog(@"This was returned from ViewControllerB %@",item);
    
    int value = [item intValue];
    
    self.bookidloc =[self.bookid objectAtIndex:value];
    PFUser *currentUser = [PFUser currentUser];
    NSMutableArray *locbooksids = [currentUser valueForKey:@"bookids"];
    if(locbooksids)
    {
        if(locbooksids.count == 3)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Issue Alert!"
                                                            message:@"Your issue limit of 3 books is reached. Please return books to issue new books"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        else
        {
            [self alertduplicate];
            SearchDisplay *search = nil;
            if (searchstatus==YES)
            {
                search = [searchResults objectAtIndex:value];
            }
            else
            {
                search = [bookarray objectAtIndex:value];
            }
            [[PFUser currentUser] addUniqueObject: search.bookid forKey:@"bookids"];
            
            [[PFUser currentUser] saveInBackground];
        }
    }
    else
    {
        [self alertduplicate];
        SearchDisplay *search = nil;
        if (searchstatus==YES)
        {
            search = [searchResults objectAtIndex:value];
        }
        else
        {
            search = [bookarray objectAtIndex:value];
        }
        [[PFUser currentUser] addUniqueObject: search.bookid forKey:@"bookids"];
        
        [[PFUser currentUser] saveInBackground];
        
    }
    
    
    
    
}
- (void) alertduplicate
{
    NSMutableArray *books = [[NSMutableArray alloc]init];
    
    if([PFUser currentUser]) {
        [books addObjectsFromArray:[[PFUser currentUser] valueForKey:@"bookids"]];
        
        if ([books containsObject: self.bookidloc])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Issue Alert!"
                                                            message:@"Oops! This book has already been issued. Please check your library"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Book Issued"
                                                            message:@"Please go back to your library to read."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
            
        }
    }
}




@end
