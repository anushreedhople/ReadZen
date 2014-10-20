//
//  LPBookDetailsViewController.m
//  LearningPlatform2
//
//  Created by Anushree Dhople on 7/28/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import "LPBookDetailsViewController.h"
#import "Parse/Parse.h"

@interface LPBookDetailsViewController ()

@end

@implementation LPBookDetailsViewController

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
    // Do any additional setup after loading the view.
    [self.titleText setText:self.bookname];
    [self.authorText setText:self.authorname];
    self.bookcoverView.image = self.bookcover;
    self.bookDescription.text = self.bookdescription;
    
    /*Customize the button */
    self.issueBook.layer.cornerRadius=9;
    self.issueBook.layer.borderWidth=1.0f;
    self.issueBook.layer.borderColor=[[UIColor blackColor]CGColor];
    //self.bookDescription.layer.backgroundColor = [[UIColor whiteColor]CGColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)issueBook:(id)sender{
    
    NSLog(@"Issue book is called and book id is %@", self.bookid);
    /*The book id is to be added to the logged user's database*/

    /*Check if it is less than 3 books first */
    PFUser *currentUser = [PFUser currentUser];
    NSMutableArray *booksids = [currentUser valueForKey:@"bookids"];
    if(booksids){
        if(booksids.count == 3){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Issue Alert!"
                                                            message:@"Your issue limit of 3 books is reached. Please return books to issue new books"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        else {
            [self alertduplicate];
            [[PFUser currentUser] addUniqueObject:self.bookid forKey:@"bookids"];
            [[PFUser currentUser] saveInBackground];
        }
    }
 
}

- (void) alertduplicate
{
    NSMutableArray *books = [[NSMutableArray alloc]init];
    
    if([PFUser currentUser]) {
        [books addObjectsFromArray:[[PFUser currentUser] valueForKey:@"bookids"]];
        
        if ([books containsObject: self.bookid])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Issue Alert!"
                                                            message:@"Oops! This book has already been issued. Please check your library"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Issue Alert!"
                                                            message:@"Book is issued. Please go to your library to read."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

@end
