// Copyright 2012 ESRI
//
// All rights reserved under the copyright laws of the United States
// and applicable international laws, treaties, and conventions.
//
// You may freely redistribute and use this sample code, with or
// without modification, provided you include the original copyright
// notice and use restrictions.
//
// See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
//

#import "WZPoverTableViewController.h"
#import "WZMainController.h"
#import "LayerModel.h"

#define kLocalTiledLayerViewControllerIdentifier @"WZPoverTableViewController"

@interface WZPoverTableViewController()

@end

@implementation WZPoverTableViewController
 
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

// in iOS7 this gets called and hides the status bar so the view does not go under the top iPhone status bar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *mypaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSLog(@"%@",mypaths);
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)updateLayerCheck:(NSMutableArray *)layerModels
{
    self.tilePackagesFromDocuments = layerModels;
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [self.tilePackagesFromDocuments count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if([self.tilePackagesFromDocuments count] > 0)
    {
        LayerModel *layer = self.tilePackagesFromDocuments[indexPath.row];
        cell.textLabel.text = layer.layerName;
        cell.accessoryType = layer.check ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone ;
    }   
    else
        cell.textLabel.text = @"暂无地图文件，请通过电脑添加！";
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if([self.tilePackagesFromDocuments count] > 0)
    {
        LayerModel *layer = self.tilePackagesFromDocuments[indexPath.row];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObject:layer forKey:@"layer"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeLayerNotification" object:self userInfo:dic];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
