//
//  CalloutCell.m
//  GisMap
//
//  Created by Mac on 15/4/17.
//
//

#import "CalloutCell.h"

@interface CalloutCell()

@property(nonatomic,weak) UILabel *titleLabel;
@property(nonatomic,weak) UILabel *valueLabel;

@end

@implementation CalloutCell

+(instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"calloutCellID";
    CalloutCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[CalloutCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:18.0];
        titleLabel.numberOfLines = 0;
        titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UILabel *valueLabel = [[UILabel alloc]init];
        valueLabel.font = [UIFont systemFontOfSize:18.0];
        valueLabel.numberOfLines = 0;
        valueLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [self.contentView addSubview:valueLabel];
        self.valueLabel = valueLabel;
    }
    return self;
}

-(void)setCellframe:(CalloutCellFrame *)cellframe
{
    _cellframe = cellframe;
    
    CalloutCellData *data = cellframe.data;
    
    self.titleLabel.frame = cellframe.titleFrame;
    self.titleLabel.text = data.title;
    
    self.valueLabel.frame = cellframe.valueFrame;
    self.valueLabel.text = data.value;
    
}
@end
