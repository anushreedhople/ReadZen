//
//  LPTableViewCell.m
//  LearningPlatform2
//
//  Created by Anushree Dhople on 10/13/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import "LPTableViewCell.h"
#import "Parse/Parse.h"
#import "LPLibraryTableViewController.h"
@implementation LPTableViewCell

@synthesize nameLabel,lblauthor,lblGener,issuebtn;
@synthesize delegate;
@synthesize thumbnailImageView;


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
    
}

-(IBAction)Issueclick:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    NSInteger row = button.tag;
    
    NSString *itemToPassBack = [NSString stringWithFormat:@"%ld", (long)row];
    [self.delegate addItemViewController:self didFinishEnteringItem:itemToPassBack];
    
    
}
@end
