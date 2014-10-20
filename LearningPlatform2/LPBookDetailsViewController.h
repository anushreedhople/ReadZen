//
//  LPBookDetailsViewController.h
//  LearningPlatform2
//
//  Created by Anushree Dhople on 7/28/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPBookDetailsViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *issueBook;
@property (strong, nonatomic) IBOutlet UILabel *titleText;
@property (strong, nonatomic) IBOutlet UILabel *authorText;
@property (strong, nonatomic) IBOutlet UITextView *bookDescription;
@property (strong, nonatomic) IBOutlet UIImageView *bookcoverView;

@property (nonatomic, strong) NSString *bookname;
@property (nonatomic, strong) NSString *authorname;
@property (nonatomic, strong) NSString *bookid;
@property (nonatomic, strong) UIImage *bookcover;
@property (nonatomic, strong) NSString *bookdescription;

-(IBAction)issueBook:(id)sender;

@end
