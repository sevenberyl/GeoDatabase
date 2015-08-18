
//  LocalTiledLayerSample
//
//  Created by Mac on 15/3/6.
//
//

#import "CalloutHeaderView.h"

@implementation CalloutHeaderView


- (IBAction)closeMe:(id)sender {
    NSLog(@"close");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeCalloutView" object:nil];
}

+(instancetype)headerView
{
   return  [[[NSBundle mainBundle]loadNibNamed:@"CalloutHeaderView" owner:nil options:nil]lastObject];
}

@end
