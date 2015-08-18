//
//  CalloutTableViewController.m
//  LocalTiledLayerSample
//
//  Created by Mac on 15/3/6.
//
//

#import "WZCalloutTableViewController.h"
#import "CalloutHeaderView.h"
#import "NSString+Extension.h"

#import "CalloutCell.h"
#import "CalloutCellData.h"


@interface WZCalloutTableViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSArray *tableDatas;

@property(nonatomic,strong) NSDictionary *sizeAttributes;

@property(nonatomic,strong) NSDictionary *configDic;

@property(nonatomic,strong) NSDictionary *kgDic;
@property(nonatomic,strong) NSDictionary *gxDic;
@end

@implementation WZCalloutTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

-(void)viewDidLayoutSubviews {
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [CalloutHeaderView headerView];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setDicDatas:(NSDictionary *)dicDatas
{
    _dicDatas = dicDatas;
    NSArray *arr = [self arraryWithDictionary:dicDatas];
    self.tableDatas = [self calloutCellFramesWithStatuses:arr];
    [self.tableView reloadData];
}

-(NSArray *)arraryWithDictionary:(NSDictionary *)dic
{
    if(dic == nil)
        return nil;
    NSString *type;
    if ([dic objectForKey:@"DKBH"]) {
        type = @"kg";
    }else{
        type = @"gx";
    }
    NSMutableArray *arrary = [NSMutableArray array];
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        
        NSString *objstr = [obj description];
        if ([objstr isEqualToString:@"Null"] || [objstr isEqualToString:@""]||objstr == nil || [objstr isEqualToString:@"<null>"]||[objstr isEqualToString:@" "])
            obj = @"暂无数据";
        NSString *name = [self keyToName:[key description] type:type];


        if(name && ![[name lowercaseString] isEqualToString:@"shape"])
        {
//            NSString *textStr = [NSString stringWithFormat:@"%@ : %@",name,obj];
            CalloutCellData *data = [[CalloutCellData alloc]init];
            
            NSString *title = [NSString stringWithFormat:@"%@ : ",name];
            NSString *value = [obj description];
//            NSLog(@"title--%@,value--%@",title,value);
            if ([title isEqualToString:@"入库时间 : "]) {
                value = [value substringToIndex:10];
            }
            
            if ([title isEqualToString:@"起点高程 : "] || [title isEqualToString:@"终点高程 : "]) {
                value = [value substringToIndex:5];
            }

            data.title = title;
            data.value = value;
            [arrary addObject:data];
        }
        
    }];
    return arrary;
}

- (NSArray *)calloutCellFramesWithStatuses:(NSArray *)datas
{
    NSMutableArray *frames = [NSMutableArray array];
    for (CalloutCellData *data in datas) {
        CalloutCellFrame *f = [[CalloutCellFrame alloc] init];
        f.data = data;
        [frames addObject:f];
    }
    return frames;
}


-(NSString *)keyToName:(NSString *)key type:(NSString *)type
{
    NSString *name;
  
    if ([type isEqualToString:@"kg"]) {
        name = [self.kgDic objectForKey:key];
//        NSLog(@"key--->%@,name---->%@",key,name);
    }else
    {
        name =[self.gxDic objectForKey:key];
//        NSLog(@"key--->%@,name---->%@",key,name);
    }
    return name;
}

-(NSDictionary *)kgDic
{
    if (_kgDic == nil) {
        NSDictionary *kgdic =[self.configDic objectForKey:@"kg"];
        _kgDic = kgdic;
    }
    return _kgDic;
}

-(NSDictionary *)gxDic
{
    if (_gxDic == nil) {
        NSDictionary *gxdic =[self.configDic objectForKey:@"gx"];
        _gxDic = gxdic;
    }
    return _gxDic;
}

-(NSDictionary *)configDic
{
    if (_configDic == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *fileD = [documentsDirectory stringByAppendingPathComponent:@"config.json"];
        NSData *data = [NSData dataWithContentsOfFile:fileD];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        _configDic = dic;
    }
    return _configDic;
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableDatas.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *ID = @"cellID";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
//    }
//    cell.textLabel.text = self.tableDatas[indexPath.row];
////    cell.textLabel.numberOfLines = 0;
////    cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
////    cell.textLabel.font = [UIFont systemFontOfSize:18.0];
//    return cell;
    
    CalloutCell *cell = [CalloutCell cellWithTableView:tableView];
    cell.cellframe = self.tableDatas[indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *text = self.tableDatas[indexPath.row];
//    CGFloat h = [text sizeWithFont:[UIFont systemFontOfSize:18.0]].height;
//    NSLog(@"%f",h);
//    return h;
//    return 32;
    CalloutCellFrame *frame = self.tableDatas[indexPath.row];
    return frame.cellHeight;
}


@end
