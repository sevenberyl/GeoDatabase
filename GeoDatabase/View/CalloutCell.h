
//  GisMap
//
//  Created by Mac on 15/4/17.
//
//

#import <UIKit/UIKit.h>
#import "CalloutCellFrame.h"

@interface CalloutCell : UITableViewCell
+(instancetype)cellWithTableView:(UITableView *)tableView;

@property(nonatomic,strong) CalloutCellFrame *cellframe;

@end
