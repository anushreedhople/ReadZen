//
//  LPLibraryViewController.m
//  LearningPlatform2
//
//  Created by Anushree Dhople on 7/22/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import "LPLibraryViewController.h"
#import "Parse/Parse.h"
#import "LPLibraryTableViewController.h"
#import "EPubViewController.h"

const int THUMBNAIL_WIDTH = 150;
const int THUMBNAIL_HEIGHT = 250;
const int THUMBNAILS_COLS = 3;
const int PADDING = 50;
const int PADDING_TOP = 100;


@interface LPLibraryViewController ()

@end

@implementation LPLibraryViewController

@synthesize bookids;

int buttonid=0;

- (BOOL)connectedToInternet
{
    NSURL *url=[NSURL URLWithString:@"http://www.google.com"];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"HEAD"];
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: NULL];
    
    return ([response statusCode]==200)?YES:NO;
}


-(void)gotoCentralLibrary:(UIBarButtonItem *)sender {
    
    /*Check if internet connection exists first*/
    if([self connectedToInternet]) {
        NSLog(@"Internet connection exists");
        UIStoryboard *storyboard = self.storyboard;
        LPLibraryViewController *libTableView = [storyboard instantiateViewControllerWithIdentifier:@"CentralLibrary"];
        [self.navigationController pushViewController:libTableView animated:YES];
    }
    else {
        /*Display UIAlertView*/
        NSLog(@"Internet connection is not there... cannot open central library");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Check your Internet connection"
                                                        message:@"Your device seems to be offline. Please check your Internet connection and try again."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


/*
 Function Name:loading function
 Input Param: sender
 Output Param: void
 Description:1. we have created a array (bookids)
 2.we have to take current user books details from DB(its strored in booksids) and assign to array.
 3.then select books from bookrepository using bookid.
 4.we have to create button and select button image from bookcover.
 
 
 **/


-(void)viewWillAppear {
    
    //First clear all button subviews to avoid overlap
    for(UIView *subview in self.view.subviews){
        if([subview isKindOfClass:[UIButton class]]) {
            //if(subview.tag) { /*to remove only book buttons and not goto library and logout buttons*/
            [subview removeFromSuperview];
            //}
            //else {
            //    NSLog(@"This is not a tagged button. Do not remove");
            //}
        }
        else {
            NSLog(@"This is not a button. Do not remove");
        }
    }
    
    self.bookids = [[NSMutableArray alloc]init];
    
    if([PFUser currentUser]) {
        [self.bookids addObjectsFromArray:[[PFUser currentUser] valueForKey:@"bookids"]];
        NSLog(@"The bookid count is %lu", (unsigned long)self.bookids.count);
        for(int i=0; i<self.bookids.count; i++) {
            NSString *bookid = [self.bookids objectAtIndex:i];
            PFQuery *query = [PFQuery queryWithClassName:@"BookRepository"];
            query.cachePolicy = kPFCachePolicyCacheElseNetwork;
            [query whereKey:@"bookid" equalTo:bookid];
            NSArray *objects = [query findObjects];
            UIButton *button;
            for(PFObject *object in objects) {
                PFFile *theImage = [object valueForKey:@"bookcover"];
                NSData *imageData = [theImage getData];
                UIImage *thumbnail = [UIImage imageWithData:imageData];
                if(thumbnail){
                    button = [UIButton buttonWithType:UIButtonTypeCustom];
                    [button setImage:thumbnail forState:UIControlStateNormal];
                    button.showsTouchWhenHighlighted;
                    button.tag = i;
                    [button addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
                    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(buttonPressed:)];
                    [button addGestureRecognizer:longPress];
                    button.frame = CGRectMake(THUMBNAIL_WIDTH * (i % THUMBNAILS_COLS) + PADDING * (i % THUMBNAILS_COLS) + PADDING,
                                              THUMBNAIL_HEIGHT * (i / THUMBNAILS_COLS) + PADDING * (i / THUMBNAILS_COLS) + PADDING + PADDING_TOP,
                                              THUMBNAIL_WIDTH,
                                              THUMBNAIL_HEIGHT);
                    button.imageView.contentMode = UIViewContentModeScaleAspectFill;
                    [self.view addSubview:button];
                    
                    //Retrieve the book and store in App /Library directory with user domain mask
                    //TODO - Check NSUserDomainMask if working
                    PFFile *book = [object valueForKey:@"book"];
                    NSData *bookData = [book getData];
                    NSString *path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    NSString *filePath = [NSString stringWithFormat:@"%@/book%d.epub", path, i];
                    [bookData writeToFile:filePath atomically:YES];
                }
            }
            
            
             /*int rows = images.count / THUMBNAIL_COLS;
             if (((float)images.count / THUMBNAIL_COLS) - rows != 0) {
             rows++;
             }
             
             int height = THUMBNAIL_HEIGHT * rows + PADDING * rows + PADDING + PADDING_TOP;
             
             photoScrollView.contentSize = CGSizeMake(self.view.frame.size.width, height);
             photoScrollView.clipsToBounds = YES;*/
             
        }
    }
    else NSLog(@"Current user does not exist");
    
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController viewWillAppear:animated];
    [self viewWillAppear];
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController viewDidAppear:animated];

}



- (void)viewDidLoad
{
    /*Create Image Views for all books issued to User and load the gifs from the database */
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    
    /*Put library button on right side of navigation bar*/
    
    UIBarButtonItem *libraryButton = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Library"
                                      style:UIBarButtonItemStyleBordered
                                      target:self
                                      action:@selector(gotoCentralLibrary:)];
    
    self.navigationItem.rightBarButtonItem = libraryButton;
    //[libraryButton release];
    
    [self.navigationController setDelegate:self];
    
    [self viewWillAppear];
    
    [super viewDidLoad];
    // Do any additional setup after loadig the view from its nib.
    //Check if any docs associated with the user are already loaded in iPAD. Then display the front page
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buttonTouched:(id)sender {
    /*Button was pressed. Open up new UIViewController with the chosen book*/
    NSLog(@"Button was pressed to view book");
    
    /*Retrieve book from Apps /Library and pass onto epubview*/
    int i = (int)[sender tag];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/book%d.epub", path, i];
    
    EPubViewController *epubViewController = [[EPubViewController alloc]initWithNibName:@"EPubView" bundle:nil];
    [self.navigationController pushViewController:epubViewController animated:YES];

    /*Get web link from Parse*/
    NSString *bookid = [self.bookids objectAtIndex:i];
    PFQuery *query = [PFQuery queryWithClassName:@"BookRepository"];
    [query whereKey:@"bookid" equalTo:bookid];
    NSArray *objects = [query findObjects];
    NSString *weblink;
    NSString *strBookname;
    for(PFObject *object in objects) {
        weblink = [object valueForKey:@"booksource"];
        strBookname= [object valueForKey:@"bookname"];
    }
    
    /*Set the book name*/
    [epubViewController setStrBookName:strBookname];
    /*Set the tag of the book*/
    [epubViewController setBookIndex:i];
    /*Set the weblink book source for copyright reasons*/
    [epubViewController loadBookSource:weblink];
    /*Open the book in Web View*/
    [epubViewController loadEpub:[NSURL fileURLWithPath:filePath]];
    
    
}
/*
 Function Name:buttonpressed
 Input Param: sender
 Output Param: void
 Description:We will get some event on button press
 
 
 **/

-(void)buttonPressed:(id)sender {
    
    UILongPressGestureRecognizer *gest = (UILongPressGestureRecognizer *)sender;
    UIButton *button = (UIButton*)[gest view];
    //NSLog(@"The button tag is %d",[button tag]);
    buttonid = [button tag];
    
    switch(gest.state) {
        case UIGestureRecognizerStateBegan:
            //NSLog(@"State Began");
            [[[UIAlertView alloc] initWithTitle:@"Delete Book" message:@"Do you want to return this book?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil] show];
            break;
        case UIGestureRecognizerStateChanged:
            //NSLog(@"State changed");
            break;
        case UIGestureRecognizerStateEnded:
            //NSLog(@"State End");
            break;
        default:
            break;
    }

    
}


/*
 Function Name:alertview
 Input Param: button index
 Output Param: void
 Description:Here we can get some event from popup messege button.
 If user clicked Ok then user removed one book from his book list.
 
 
 **/

-(void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    /*The user clicked OK */
    if(buttonIndex == 0){
        NSLog(@"User wants to remove book from library at index %d", buttonid);
        PFUser *currentUser = [PFUser currentUser];
        NSMutableArray *booksids = [currentUser valueForKey:@"bookids"];
        if(booksids){
            NSLog(@"Array of issued books retrieved");
            [booksids removeObjectAtIndex:buttonid];
            currentUser[@"bookids"] = booksids;
            [currentUser save];
            //[self.view
            //[self refreshSubViews:buttonIndex];
            [self viewWillAppear];
        }
        
    }
}

-(void)refreshSubViews:(NSInteger)buttonIndex {
    NSArray *subviews = [self.view subviews];
    NSInteger i=0;
    BOOL foundButton = NO;
    
    for(UIView *subview in subviews) {
        if(buttonIndex == i) {
            /*Found the button... remove it from the view*/
            [subview removeFromSuperview];
            foundButton=YES;
            continue;
        }
        if(foundButton) {
            /*Button has been removed... change the tag of remaining button*/
            subview.tag = subview.tag--;
        }
        i++;
    }
    
    
}

/*
-(IBAction)sort:(id)sender {
    
    NSLog(@"Sort button is pressed");
    UIBarButtonItem *barButton = (UIBarButtonItem *)sender;
    CGRect rect = barButton.customView.bounds;
    NSLog(@"x %f y %f", rect.origin.x, rect.origin.y);
    
    PopoverViewController *popController = [[PopoverViewController alloc] init];
    
    UIButton *contentView = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [contentView setTitle:@"Hello World!" forState:UIControlStateNormal];
    
    UIViewController *controller = [[UIViewController alloc] init];
    controller.view = contentView;
    
    //popController.popover.contentViewController = controller;
    //popController.popover.frame = CGRectMake(100, 100, 200, 100);
    
    //[popController.popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    //[popController presentModallyInViewController:self animated:YES];
    //[popController pr]
    
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:popController];
    [popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}*/


@end
