//
//  LPRegisterViewController.h
//  LearningPlatform2
//
//  Created by Anushree Dhople on 7/24/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPRegisterViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *name;
@property (strong, nonatomic) IBOutlet UITextField *email;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UITextField *grade;
@property (strong, nonatomic) IBOutlet UITextField *schoolname;
@property (strong, nonatomic) IBOutlet UILabel *status;
@property (strong, nonatomic) IBOutlet UIButton *signup;
@property (strong, nonatomic) IBOutlet UIButton *cancel;

-(IBAction)createUser:(id)sender;
-(IBAction)cancel:(id)sender;

@end
