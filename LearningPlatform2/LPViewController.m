//
//  LPViewController.m
//  LearningPlatform2
//
//  Created by Anushree Dhople on 7/21/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import "LPViewController.h"
#import "LPAppDelegate.h"
#import "LPLibraryViewController.h"
#import "LPRegisterViewController.h"
#import "Parse/Parse.h"

@interface LPViewController ()

@end

@implementation LPViewController


/*
 Function Name:signInUser
 Input Param: sender
 Output Param: void
 Description:It is a login function.we have to pass a query with username for user availability checking. table name is user and cell name is username.
 If user is available then go to library view else dislpay error.
 
 **/
-(BOOL)signInUser:(NSString *)emailid{


    NSLog(@"Sign in the user with email id %@", emailid);

    __block BOOL userFound = NO;
    
    PFQuery *query = [PFQuery queryWithClassName:[PFUser parseClassName]];
    NSArray *pfUsers = [query findObjects];

    for(PFObject *object in pfUsers) {
        NSString *retrievedEmail = [object valueForKey:@"email"];
        NSLog(@"The retrieved email id is %@",retrievedEmail);
        if([retrievedEmail isEqualToString:emailid]) {
            userFound=YES;
            NSLog(@"User is found");
            [PFUser logInWithUsernameInBackground:emailid password:@"test123" block:^(PFUser *user, NSError *error){
                if(user) {
                    NSLog(@"Existing user login successful");
                    //User login successfull.. open the library of the user
                    UIStoryboard *storyboard = self.storyboard;
                    UINavigationController *libViewNav = [storyboard instantiateViewControllerWithIdentifier:@"LibViewNavigator"];
                    LPLibraryViewController *controller = [libViewNav.viewControllers objectAtIndex:0];
                    controller.delegate=self;
                    
                    [self presentViewController:libViewNav animated:YES completion:nil];
                }
                else {
                    //Login not successful.Stay at login screen for now
                    //TODO - Display error msg
                    NSLog(@"Existing user login is not successfull. Please try again");
                }
            }];
        }
    }
    
    return userFound;
}

/*
 Function Name:registerUser
 Input Param: sender
 Output Param: void
 Description:It is a signup function.its redirect to register view.
 
 
 **/
/*-(IBAction)registerUser:(id)sender {
    
    UIStoryboard *storyboard = self.storyboard;
    LPRegisterViewController *registerView = [storyboard instantiateViewControllerWithIdentifier:@"RegisterView"];
    [self presentViewController:registerView animated:YES completion:nil];
    
}*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    /*Clear all field*/
    /*self.name.text = @"";
    self.password.text=@"";
    self.status.text=@"";
    self.name.delegate=self;
    self.password.delegate=self;*/
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard
        
        
        [textField resignFirstResponder];
        return NO;
        
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

- (void)showProfile{
    NSLog(@"showProfile is invoked");
    [_googleOAuth authorizeUserWithClienID:@"1097792518857-6mpummir0l7tlm9dn8b5sl92h0oenmva.apps.googleusercontent.com"
                           andClientSecret:@"-HRAFU56KptnZ1YEeeMC2pPn"
                             andParentView:self.view
                                 andScopes:[NSArray arrayWithObjects:@"https://www.googleapis.com/auth/userinfo.email", nil]
     ];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (![parent isEqual:self.parentViewController]) {
        NSLog(@"Came back to parent screen");
    }
}

#pragma mark - CustomMethodDelegate
-(void)doSomething {
    NSLog(@"Logging out of gmail login too...");
    
    [self revokeAccess];
    [self logoutUser];
    
    [self showProfile];
    
}

- (void)revokeAccess{
    [_googleOAuth revokeAccessToken];
}

-(void)logoutUser {
    [_googleOAuth removeAccessTokenInfoFile];
}

-(void)authorizationWasSuccessful{
    [_googleOAuth callAPI:@"https://www.googleapis.com/oauth2/v1/userinfo"
           withHttpMethod:httpMethod_GET
       postParameterNames:nil postParameterValues:nil];
}

-(void)accessTokenWasRevoked{
    /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Your access was revoked!"
                                                   delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];*/
    /*No need to show popup here-commented*/
    
    /*do we need to logout user here - TODO.. check*/
}

-(void)errorOccuredWithShortDescription:(NSString *)errorShortDescription andErrorDetails:(NSString *)errorDetails{
    NSLog(@"%@", errorShortDescription);
    NSLog(@"%@", errorDetails);
}


-(void)errorInResponseWithBody:(NSString *)errorMessage{
    NSLog(@"%@", errorMessage);
}

-(void)responseFromServiceWasReceived:(NSString *)responseJSONAsString andResponseJSONAsData:(NSData *)responseJSONAsData{
    if ([responseJSONAsString rangeOfString:@"family_name"].location != NSNotFound) {
        NSError *error;
        NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseJSONAsData
                                                                          options:NSJSONReadingMutableContainers
                                                                            error:&error];
        if (error) {
            NSLog(@"Google - An error occured while converting JSON data to dictionary.");
            return;
        }
        else{
            NSLog(@"Google Login successfull");
            /*Get the email id of the user*/
            NSString *emailid = [dictionary objectForKey:@"email"];
            NSLog(@"The user email id is %@",emailid);
            
            /*Check if user exists in my db. Login PFUser if exists*/
            BOOL userExists = [self signInUser:emailid];
            if(userExists){
                NSLog(@"User is found");
                /*User is found and library displayed. Do nothing for now */
            }else {
                /*User does not exist. Create new user and login him*/
                NSLog(@"Going to create new Parse user");
                [self createUser:emailid];
                NSLog(@"Created new Parse user");
            }
            
            
            

        }
    }
}

/*
 Function Name:registerUser
 Input Param: sender
 Output Param: void
 Description:It is a user creation function.here we passing user details to DB.
 if user created successfully then redirect to library view else error.
 
 
 **/

-(void)createUser:(NSString *)emailid {
    
    /*routine to register new user in Parse db*/
    PFUser *user = [PFUser user];
    user.username = emailid;
    user.password = @"test123";
    user.email = emailid;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error) {
           NSLog(@"User created successfully");
            /*Log In user to account */
            [PFUser logInWithUsernameInBackground:emailid password:@"test123" block:^(PFUser *user, NSError *error) {
                if(user){
                    /*User login successfull. Open the eLibrary of user*/
                    UIStoryboard *storyboard = self.storyboard;
                    LPLibraryViewController *libView = [storyboard instantiateViewControllerWithIdentifier:@"LibraryView"];
                    libView.delegate=self;
                    [self presentViewController:libView animated:YES completion:nil];
                }
                else {
                    /*Login failed. Open the login screen */
                    NSLog(@"Login failed");
                    /*TODO - What action to be taken*/
                }
            }];
        }
        else {
            NSLog(@"Create user failed! Please try again");
        }
    }];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _googleOAuth = [[GoogleOAuth alloc] initWithFrame:self.view.frame];
    [_googleOAuth setGOAuthDelegate:self];
    
    self.showProfile;
    
    
    
    /*Customize the buttons*/
    //self.login.layer.borderWidth =1.0f;
    //self.login.layer.borderColor = [[UIColor grayColor] CGColor];
    //self.login.layer.cornerRadius=9;
    //self.signup.layer.cornerRadius=9;
    //self.signup.layer.borderWidth=1.0f;
    //self.signup.layer.borderColor = [[UIColor grayColor] CGColor];
    
    //PFUser *currentUser = [PFUser currentUser];
    //if(currentUser) {
        /*User is already logged in. Goto library view*/
        //UIStoryboard *storyboard = self.storyboard;
        //UINavigationController *libViewNav = [storyboard instantiateViewControllerWithIdentifier:@"LibViewNavigator"];
        //[self presentViewController:libViewNav animated:YES completion:nil];


    //}
    
    // Do any additional setup after loading the view.
    self.title = @"ReadZen";
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

@end
