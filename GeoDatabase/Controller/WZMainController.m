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


//github test 

#import <ArcGIS/ArcGIS.h>
#import "WZMainController.h"
#import "WZPoverTableViewController.h"
#import "LayerModel.h"
#import "WZCalloutTableViewController.h"
#import "MBProgressHUD+MJ.h"
#import "DACircularProgressView.h"

#define DynamicMapServiceURL_KG @"http://192.1.1.223:6080/arcgis/rest/services/nnkg_yd_v4/MapServer"
#define DynamicMapServiceURL_GX @"http://192.1.1.224:8399/arcgis/rest/services/GXLine/MapServer"

//定义查询的图层id
#define layerID_kg 1
//#define layerID_gx 1

@interface WZMainController()<AGSLayerDelegate,AGSCalloutDelegate,AGSMapViewTouchDelegate,CLLocationManagerDelegate,UIAlertViewDelegate,NSURLConnectionDataDelegate>

@property (nonatomic,strong) NSMutableArray *layerModels;
@property (nonatomic, strong) IBOutlet AGSMapView *mapView;
@property (nonatomic,strong) CLLocationManager *clManager;
@property (nonatomic,strong) UIPopoverController *popoverView;
@property (nonatomic,strong) WZPoverTableViewController  *popoverVC;

@property (nonatomic, strong) AGSGraphic *selectedGraphic;
@property (nonatomic, strong) AGSGraphicsLayer *graphicsLayer;
@property (nonatomic, strong) AGSIdentifyTask *identifyTask;
@property (nonatomic, strong) AGSIdentifyParameters *identifyParams;
@property (nonatomic, strong) AGSPoint* mappoint;

@property (nonatomic,strong) UIPinchGestureRecognizer *pin;
@property (nonatomic,strong) UITapGestureRecognizer *tap;
@property (nonatomic,strong) UIPanGestureRecognizer *pan;

@property (nonatomic,strong) WZCalloutTableViewController *calloutVC;

@property (nonatomic,assign) BOOL isPopover;

@property (nonatomic,assign) BOOL isTask;

@property (nonatomic,assign) int layerQueryID;

@property (strong, nonatomic) IBOutlet UISlider *slider;

/**
 *  用来写数据的文件句柄对象
 */
@property (nonatomic, strong) NSFileHandle *writeHandle;
/**
 *  文件的总大小
 */
@property (nonatomic, assign) long long totalLength;
/**
 *  当前已经写入的文件大小
 */
@property (nonatomic, assign) long long currentLength;

@property (nonatomic, weak) DACircularProgressView *circleView;

@property(nonatomic,strong) MBProgressHUD *mbHud;

@end

@implementation WZMainController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.backgroundColor = [UIColor whiteColor];
    self.mapView.gridSize = 0;
    
//    可见范围 476597 2492659 588731 2543403
    //    AGSEnvelope *nanningEnv = [AGSEnvelope envelopeWithXmin:476597
    //                                                       ymin:2492659
    //                                                       xmax:588731
    //                                                       ymax:2543403
    //                                           spatialReference:self.mapView.spatialReference];
    //    [self.mapView zoomToEnvelope:nanningEnv animated:YES];
    
    [self loadBaseMap];

}

-(void)loadBaseMap
{
    //    加载底图-》电子地图
    AGSLocalTiledLayer *layer = [AGSLocalTiledLayer localTiledLayerWithName:@"电子地图"];
    
    if(layer != nil && !layer.error){
        [self.mapView addMapLayer:layer withName:@"电子地图"];
        
        //        进入后定位
        [self performSelector:@selector(localMyMapView) withObject:nil afterDelay:0.5];
        
        //        监听更换图层事件
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLayer:) name:@"changeLayerNotification" object:nil];
    }else{
        [[[UIAlertView alloc]initWithTitle:@"读取底图失败！" message:@"可以连接至电脑然后通过iTunes导入底图或者直接通过局内网下载底图，是否立即下载底图？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"下载", nil] show];
    }
}

#pragma marks -- UIAlertViewDelegate --
//根据被点击按钮的索引处理点击事件
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            NSLog(@"cancel");
            break;
        }
        case 1:
        {
            [self performSelector:@selector(downloadMapDatafile) withObject:nil afterDelay:0.5];
            break;
        }
    }

}

-(void)downloadMapDatafile
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.mbHud = hud;
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"正在下载...";
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;

    // 1.URL
//    NSURL *url = [[NSURL alloc]initFileURLWithPath:@"/Volumes/Seven/平板地图app及数据/电子地图.tpk"];
    
    NSURL *url = [NSURL URLWithString:@"/Volumes/Seven/平板地图app及数据/电子地图.tpk"];
    
    // 2.请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 3.下载(创建完conn对象后，会自动发起一个异步请求)
    [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - NSURLConnectionDataDelegate代理方法
/**
 *  请求失败时调用（请求超时、网络异常）
 *
 *  @param error      错误原因
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.mbHud hide:YES afterDelay:0.1 ];
    [[[UIAlertView alloc]initWithTitle:@"下载底图失败！" message:@"请使用wifi连接至局内网，然后重新下载。" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil] show];
}

/**
 *  1.接收到服务器的响应就会调用
 *
 *  @param response   响应
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
//    [MBProgressHUD showMessage:self.loadingString];
    // 文件路径
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filepath = [caches stringByAppendingPathComponent:@"电子地图.tpk"];
    
    // 创建一个空的文件 到 沙盒中
    NSFileManager *mgr = [NSFileManager defaultManager];
    [mgr createFileAtPath:filepath contents:nil attributes:nil];
    
    // 创建一个用来写数据的文件句柄
    self.writeHandle = [NSFileHandle fileHandleForWritingAtPath:filepath];
    
    // 获得文件的总大小
    self.totalLength = response.expectedContentLength;
}

/**
 *  2.当接收到服务器返回的实体数据时调用（具体内容，这个方法可能会被调用多次）
 *
 *  @param data       这次返回的数据
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // 移动到文件的最后面
    [self.writeHandle seekToEndOfFile];
    
    // 将数据写入沙盒
    [self.writeHandle writeData:data];
    
    // 累计文件的长度
    self.currentLength += data.length;
    
    self.mbHud.labelText =[NSString stringWithFormat:@"已完成:%0.2f%%",(double)self.currentLength/ self.totalLength * 100];
    
}

/**
 *  3.加载完毕后调用（服务器的数据已经完全返回后）
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.currentLength = 0;
    self.totalLength = 0;
    
    // 关闭文件
    [self.writeHandle closeFile];
    self.writeHandle = nil;
    [self.mbHud hide:YES afterDelay:0.5 ];
     [self loadBaseMap];
}


-(UITableViewController *)popoverVC
{
    if (_popoverVC == nil) {
        _popoverVC = [[WZPoverTableViewController alloc]init];
        _popoverVC.tilePackagesFromDocuments = self.layerModels;
    }
    return _popoverVC;
}

-(void)addGeodatabaseWithName:(NSString *)name
{
    NSLog(@"添加Geo图层：%@",name);
    NSError *error;
    AGSGDBGeodatabase *gdb = [AGSGDBGeodatabase geodatabaseWithName:name  error:&error];
    
    while (error) {
        NSLog(@"读取%@文件错误--->%@",name,error);
        break;
    }
    
    NSArray *tables = [gdb featureTables];

    for (int i = tables.count - 1; i >= 0; i--) {
        
        AGSGDBFeatureTable *table = [tables objectAtIndex:i];
        AGSFeatureTableLayer *layer = [[AGSFeatureTableLayer alloc] initWithFeatureTable:table];
        NSString *name = [NSString stringWithFormat:@"localFeatureTableLayer%d",i];
        [self.mapView addMapLayer:layer withName:name];
        self.slider.hidden = NO;
    }
    
    self.mapView.callout.delegate = self;
    self.mapView.touchDelegate = self;
    
    
    if (self.graphicsLayer == nil) {
        self.graphicsLayer = [AGSGraphicsLayer graphicsLayer];
        [self.mapView addMapLayer:self.graphicsLayer withName:@"graphice Layer"];
    }
}

#pragma mark -touch的代理方法
-(void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint features:(NSDictionary *)features
{
    
//    for (int i = 0; i < [[features allKeys] count]; i++) {
//    
//        NSString *key = [features allKeys][i];
//        NSMutableArray *reulsts = features[key];
////        NSLog(@"reulsts--->%@------%@",key,reulsts);
//    }

    
    
    [self closeCalloutView];
    
    NSString *key = [[features allKeys] firstObject];
    NSMutableArray *reulsts = features[key];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeCalloutView) name:@"closeCalloutView" object:nil];
    
    for (int i = 0; i < reulsts.count; i++) {
        
        AGSGDBFeature *feature = reulsts[i];
        NSDictionary *dic = [feature allAttributes];
//        NSLog(@"reulsts--->%@",dic);
        
        
        AGSSymbol* symbol = [AGSSimpleFillSymbol simpleFillSymbol];
        symbol.color = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.8];
        AGSGraphic *graphic = [AGSGraphic graphicWithFeature:feature];
        graphic.symbol = symbol;

        [self.graphicsLayer addGraphic:graphic];
        
        self.calloutVC = [[WZCalloutTableViewController alloc]init];
        self.calloutVC.view.frame = CGRectMake(0, 0, cellWith, 300);
        self.calloutVC.dicDatas = dic;
        self.mapView.callout.customView = self.calloutVC.view;
        [self.mapView.callout showCalloutAtPoint:mappoint forFeature:feature layer:nil animated:YES];
    }

}

-(NSMutableArray *)layerModels
{
    if (_layerModels == nil) {
        NSMutableArray *datas = [[NSMutableArray alloc] init];
        
        NSString *extension = @"geodatabase";
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
        NSEnumerator *e = [contents objectEnumerator];
        NSString *filename;
        
        while ((filename = [e nextObject])) {
            if ([[filename pathExtension] isEqualToString:extension]) {
                filename = [filename stringByDeletingPathExtension];
                LayerModel *layer = [[LayerModel alloc]init];
                layer.layerName = filename;
                layer.check = false;
                [datas addObject:layer];
            }
        }
        
        
        LayerModel *offlineLayer = [[LayerModel alloc]init];
        offlineLayer.check = NO;
        offlineLayer.layerName = @"离线影像";
        [datas addObject:offlineLayer];
        _layerModels = datas;
    }
    return _layerModels;
}

- (IBAction)localButton:(id)sender {
    [self localMyMapView];
}
- (IBAction)chooseButton:(id)sender {
    [self chooseLayer];
}

-(void)closeCalloutView
{
    [self.graphicsLayer removeAllGraphics];
    [self.mapView.callout dismiss];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"closeCalloutView" object:nil];
}

//选择图层
-(void)chooseLayer
{
    //ipad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.popoverView = [[UIPopoverController alloc]initWithContentViewController:self.popoverVC];
        
        //让popover弹出时，依然相应屏幕的事件
        self.popoverView.passthroughViews = [NSArray arrayWithObjects:self.view, nil];
        
        self.popoverView.popoverContentSize = CGSizeMake(250, 280);
        
        [self.popoverView presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
   //iphone
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController pushViewController:self.popoverVC animated:YES];
    }
    
//    添加手势监听，以便隐藏popover
    self.pin = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(dissMissPopoverView)];
    self.tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dissMissPopoverView)];
    self.pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dissMissPopoverView)];
    [self.view addGestureRecognizer:self.pin];
    [self.view addGestureRecognizer:self.tap];
    [self.view addGestureRecognizer:self.pan];
    
    [self closeCalloutView];
}

//隐藏呼出框
-(void)dissMissPopoverView
{
    if (self.popoverView) {
        [self.view removeGestureRecognizer:self.pin];
        [self.view removeGestureRecognizer:self.tap];
        [self.view removeGestureRecognizer:self.pan];
        [self.popoverView dismissPopoverAnimated:YES];
    }
}

//修改图层
-(void)changeLayer:(NSNotification *)notification
{
    NSDictionary *dic = [notification userInfo];
    LayerModel *layermodel = dic[@"layer"];
    NSString *mapName = layermodel.layerName;
    
    if ([mapName isEqualToString:@"离线影像"]) {
        if (layermodel.check) {
            [self.mapView removeMapLayerWithName:mapName];
            //刷新列表状态
            for (LayerModel *layer in self.layerModels) {
                if([layer.layerName isEqualToString:mapName])
                    layer.check = NO;
            }
        }else
        {
            AGSLocalTiledLayer *layer = [AGSLocalTiledLayer localTiledLayerWithName:@"离线影像"];
            [self.mapView addMapLayer:layer withName:@"离线影像"];
            
            //刷新列表状态
            for (LayerModel *layer in self.layerModels) {
                if([layer.layerName isEqualToString:mapName])
                    layer.check = YES;
            }
            
        }
        [self.popoverVC updateLayerCheck:self.layerModels];
        
        return;
    }
    
    //先移除所有图层
    NSArray *maps = [self.mapView mapLayers];
    for (AGSLayer *layer in maps) {
        if ([layer.name isEqualToString:@"电子地图"])
        {
        }else if([layer.name isEqualToString:@"离线影像"])
        {
        }else
        {
            [self.mapView removeMapLayer:layer];
            self.slider.hidden = YES;
        }
    }
    
    
    
    //添加选中的图层
    if (!layermodel.check)
        [self addGeodatabaseWithName:mapName];
    
    
    //刷新列表状态
    for (LayerModel *layer in self.layerModels) {
        if ([layer.layerName isEqualToString:mapName]) {
            layer.check = !layer.check;
        }else
        {
            if (![layer.layerName isEqualToString:@"离线影像"]) {
                layer.check = NO;
            }
        }
    }
    
    [self.popoverVC updateLayerCheck:self.layerModels];
    
    
    
    
//    //iphone
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
//        [self.navigationController popToRootViewControllerAnimated:YES];
//    }
    
}

//定位
-(void)localMyMapView
{
    
    NSLog(@"定位...");
    if (!self.clManager)
        self.clManager = [[CLLocationManager alloc] init];
    
    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
    NSLog(@"系统版本==》%f",version);
    if (version >= 8.0)
    {
        [self.clManager requestWhenInUseAuthorization];
        
    }else
    {
        NSLog( @"开始执行ios7定位服务" );
        // 如果定位服务可用
        if([CLLocationManager locationServicesEnabled])
        {
            NSLog( @"开始执行定位服务" );
            // 设置定位精度最佳精度
            self.clManager.desiredAccuracy = kCLLocationAccuracyBest;
            // 设置距离过滤器为50米表示每移动50米更新一次位置
            self.clManager.distanceFilter = 50;
            // 将视图控制器自身设置为CLLocationManager的delegate
            // 因此该视图控制器需要实现CLLocationManagerDelegate协议
            self.clManager.delegate = self;
            // 开始监听定位信息
            [self.clManager startUpdatingLocation];
        }
        else
        {
            NSLog( @"无法使用定位服务" );
        }
    }
    
    if(!self.mapView.locationDisplay.dataSourceStarted)
        [self.mapView.locationDisplay startDataSource];

    self.mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
    self.mapView.locationDisplay.wanderExtentFactor = 0.75;
}

// 成功获取定位数据后将会激发该方法
-(void)locationManager:(CLLocationManager *)manager
    didUpdateLocations:(NSArray *)locations
{
    // 获取最后一个定位数据
//    CLLocation* location = [locations lastObject];
    // 依次获取CLLocation中封装的经度、纬度、高度、速度、方向等信息
    NSLog(@"定位成功");
}
// 定位失败时激发的方法
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"定位失败: %@",error);
}


- (IBAction)sliderChange:(id)sender {
    NSArray *maps = [self.mapView mapLayers];
    for (AGSLayer *layer in maps) {
        if ([layer.name isEqualToString:@"电子地图"])
        {
        }else if([layer.name isEqualToString:@"离线影像"])
        {
        }else
        {
            layer.opacity  = self.slider.value;
        }
    }
    
}


- (void)viewDidUnload 
{
  	self.mapView = nil;
    self.tilePackage = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
