
#import <UIKit/UIKit.h>
@class LPTableCell;
@protocol LPTableViewCellDelegate <NSObject>

-(void)addItemViewController:(LPTableCell *)controller didFinishEnteringItem:(NSString *)item;

@end
@interface LPTableCell : UITableViewCell
@property (nonatomic, weak) id<LPTableViewCellDelegate> delegate;
@property (nonatomic, strong) NSString *bookid;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *prepTimeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *lblgenr;
@property (weak, nonatomic) IBOutlet UIButton *issuebtn;
- (IBAction)isuuebtnclick:(id)sender;

@end
