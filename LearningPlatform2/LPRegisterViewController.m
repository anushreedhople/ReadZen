//
//  LPRegisterViewController.m
//  LearningPlatform2
//
//  Created by Anushree Dhople on 7/24/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import "LPRegisterViewController.h"
#import "Parse/Parse.h"
#import "LPLibraryViewController.h"

@interface LPRegisterViewController ()

@end

@implementation LPRegisterViewController

@synthesize name,email, password, grade, schoolname;
@synthesize status;

/*
 Function Name:registerUser
 Input Param: sender
 Output Param: void
 Description:It is a user creation function.here we passing user details to DB.
 if user created successfully then redirect to library view else error.
 
 
 **/

-(IBAction)createUser:(id)sender {
    
    /*routine to register new user in Parse db*/
    PFUser *user = [PFUser user];
    user.username = name.text;
    user.password = password.text;
    user.email = email.text;
    user[@"grade"] = grade.text;
    user[@"schoolname"] = schoolname.text;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error) {
            status.text = @"User created successfully";
            /*Log In user to account */
            [PFUser logInWithUsernameInBackground:name.text password:password.text block:^(PFUser *user, NSError *error) {
                if(user){
                    /*User login successfull. Open the eLibrary of user*/
                    UIStoryboard *storyboard = self.storyboard;
                    LPLibraryViewController *libView = [storyboard instantiateViewControllerWithIdentifier:@"LibraryView"];
                    [self presentViewController:libView animated:YES completion:nil];
                }
                else {
                    /*Login failed. Open the login screen */
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }];
        }
        else {
            status.text = @"Create user failed! Please try again";
        }
    }];
}

/*
 Function Name:cancel
 Input Param: sender
 Output Param: void
 Description:It is a cancel function.its redirect to login view.
 
 
 **/
-(IBAction)cancel:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

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
    
    /*Customize the buttons */
    self.signup.layer.cornerRadius=9;
    self.signup.layer.borderColor=[[UIColor blackColor] CGColor];
    self.signup.layer.borderWidth=1.0f;
    self.cancel.layer.cornerRadius=9;
    self.cancel.layer.borderColor=[[UIColor blackColor] CGColor];
    self.cancel.layer.borderWidth=1.0f;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
