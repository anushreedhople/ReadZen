//
//  LPViewController.h
//  LearningPlatform2
//
//  Created by Anushree Dhople on 7/21/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPAppDelegate.h"
#import "GoogleOAuth.h"
#import "LPLibraryViewController.h"

@interface LPViewController : UIViewController <GoogleOAuthDelegate, CustomMethodDelegate>

@property (nonatomic, strong) GoogleOAuth *googleOAuth;

- (void)showProfile;
- (void)revokeAccess;


/*@property (strong, nonatomic) IBOutlet UILabel *status;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UITextField *name;
@property (strong, nonatomic) IBOutlet UIButton *login;
@property (strong, nonatomic) IBOutlet UIButton *signup;

-(IBAction)signInUser:(id)sender;
-(IBAction)registerUser:(id)sender;
*/

-(BOOL)signInUser:(NSString *)emailid;
-(void)createUser:(NSString *)emailid;

@end
