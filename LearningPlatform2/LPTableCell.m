
#import "LPTableCell.h"

@implementation LPTableCell
@synthesize delegate;
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

- (IBAction)isuuebtnclick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger row = button.tag;
    
    NSString *itemToPassBack = [NSString stringWithFormat:@"%ld", (long)row];
    [self.delegate addItemViewController:self didFinishEnteringItem:itemToPassBack];
    
    
}
@end
