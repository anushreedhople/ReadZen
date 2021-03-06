//
//  LPTableViewCell.h
//  LearningPlatform2
//
//  Created by Anushree Dhople on 10/13/14.
//  Copyright (c) 2014 ___IQRAEDUCATION___. All rights reserved.
//
#import <UIKit/UIKit.h>
@class LPTableViewCell;

@protocol LPTableViewCellDelegate <NSObject>

-(void)addItemViewController:(LPTableViewCell *)controller didFinishEnteringItem:(NSString *)item;

@end
@interface LPTableViewCell : UITableViewCell

@property (nonatomic, weak) id<LPTableViewCellDelegate> delegate;
@property (nonatomic, strong) NSString *bookid;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *lblauthor;
@property (weak, nonatomic) IBOutlet UILabel *lblGener;
@property (weak, nonatomic) IBOutlet UIButton *issuebtn;

- (IBAction)Issueclick:(id)sender;

@end


