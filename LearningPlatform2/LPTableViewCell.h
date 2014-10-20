//
//  LPTableViewCell.h
//  LearningPlatform2
//
//  Created by Anushree Dhople on 10/13/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *lblauthor;
@property (weak, nonatomic) IBOutlet UILabel *lblGener;

@property (weak, nonatomic) IBOutlet UILabel *lblissue;

@end

