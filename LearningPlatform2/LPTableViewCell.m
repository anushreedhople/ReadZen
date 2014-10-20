//
//  LPTableViewCell.m
//  LearningPlatform2
//
//  Created by Anushree Dhople on 10/13/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import "LPTableViewCell.h"

@implementation LPTableViewCell
@synthesize nameLabel,lblauthor,lblGener,lblissue;

@synthesize thumbnailImageView;


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
