//
//  CalloutCellFrame.m
//  GisMap
//
//  Created by Mac on 15/4/17.
//
//

#import "CalloutCellFrame.h"

@implementation CalloutCellFrame

- (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxW:(CGFloat)maxW
{
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = font;
    CGSize maxSize = CGSizeMake(maxW, MAXFLOAT);
    return [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

- (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font
{
    return [self sizeWithText:text font:font maxW:MAXFLOAT];
}

-(void)setData:(CalloutCellData *)data
{
    _data = data;
    
    CGFloat titleX = 2;
    CGFloat titleY = 2;
    CGSize titleSize = [self sizeWithText:data.title font:[UIFont systemFontOfSize:18.0]];
    self.titleFrame = CGRectMake(titleX, titleY, titleSize.width, titleSize.height);
    
    CGFloat valueX = CGRectGetMaxX(self.titleFrame);
    CGFloat valueY = 2;
    CGSize valueSize = [self sizeWithText:data.value font:[UIFont systemFontOfSize:18.0] maxW:(cellWith - titleSize.width-10)];
    self.valueFrame = CGRectMake(valueX, valueY, valueSize.width, valueSize.height);
    self.cellHeight = fmaxf(titleSize.height, valueSize.height)+ 5;
}

@end
