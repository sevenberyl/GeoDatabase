
//  GisMap
//
//  Created by Mac on 15/4/17.
//
//

#import <Foundation/Foundation.h>
#import "CalloutCellData.h"

@interface CalloutCellFrame : NSObject

@property(nonatomic,strong) CalloutCellData *data;

@property(nonatomic,assign) CGRect titleFrame;

@property(nonatomic,assign) CGRect valueFrame;

@property(nonatomic,assign) CGFloat cellHeight;

@end
