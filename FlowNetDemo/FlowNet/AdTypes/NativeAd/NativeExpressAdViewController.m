//
//  YDNativeExpressAdViewController.m
//  FlowNet
//
//  Created by lee on 2025/12/17.
//

#import "NativeExpressAdViewController.h"
#import "FLNDemoAdConfig.h"
#import <FLNAdSDK/FLNNativeExpressAd.h>
#import <FLNAdSDK/FLNNativeExpressAdView.h>
 
@interface NativeExpressAdViewController ()<FLNNativeExpressAdDelegate,UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong) FLNNativeExpressAd *nativeExpressAd;
@property (nonatomic,strong) NSMutableArray<FLNNativeExpressAdView *> *adPool; // 多广告池
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *data; // 普通内容 + 广告占位

@end

@implementation NativeExpressAdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"信息流模版";
    
    self.data = [NSMutableArray array];
    for (int i = 0; i < 50; i++) {
        [self.data addObject:[NSString stringWithFormat:@"内容 %d", i]];
    }
    
    // 插入广告占位
    [self.data insertObject:@"__ad__" atIndex:5];
 
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"text"];
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"ad"];
    
    self.adPool = [NSMutableArray array];
    
    CGFloat w = CGRectGetWidth(self.view.bounds);
    if (w < 1) {
        w = CGRectGetWidth(UIScreen.mainScreen.bounds);
    }
    // 初始化广告
    self.nativeExpressAd = [[FLNNativeExpressAd alloc] initWithPosId:kFLNDemoPosIdNativeExpress width:w];
    self.nativeExpressAd.delegate = self;
    [self.nativeExpressAd loadAd:1]; // 一次请求多条广告
    
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id obj = self.data[indexPath.row];
    
    if ([obj isEqual:@"__ad__"]) {
        FLNNativeExpressAdView *v = self.adPool.firstObject;
        if (v && v.frame.size.height > 1) {
            return MAX(120, v.frame.size.height);
        }
        return 56;
    }
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id obj = self.data[indexPath.row];
    
    if ([obj isEqual:@"__ad__"]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ad" forIndexPath:indexPath];
        for (UIView *sub in [cell.contentView.subviews copy]) {
            if ([sub isKindOfClass:[FLNNativeExpressAdView class]]) {
                [sub removeFromSuperview];
            }
        }
        cell.textLabel.text = nil;

        FLNNativeExpressAdView *nativeExpressAdView = self.adPool.firstObject;
        if (nativeExpressAdView) {
            nativeExpressAdView.frame = CGRectMake(0, 0, nativeExpressAdView.frame.size.width, nativeExpressAdView.frame.size.height);
            [cell.contentView addSubview:nativeExpressAdView];
        } else {
            cell.textLabel.text = @"广告加载中…";
        }
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"text" forIndexPath:indexPath];
    cell.textLabel.text = obj;
    return cell;
}

 
 
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    // 回收广告，放回广告池
//    for (UIView *v in cell.contentView.subviews) {
//        if ([v isKindOfClass:FLNNativeExpressAdView.class]) {
//            [self.adPool addObject:(FLNNativeExpressAdView *)v];
//            [v removeFromSuperview];
//        }
//    }
}

#pragma mark - FLNNativeExpressAdDelegate

- (void)nativeExpressAdDidLoad:(nonnull FLNNativeExpressAd *)nativeExpressAd {
    NSLog(@" 广告Load");

}

- (void)nativeExpressAdFailToLoad:(FLNNativeExpressAd *)nativeExpressAd error:(NSError *)error {
    NSLog(@"广告加载失败: %@", error);
}

- (void)nativeExpressAdViewRenderSuccess:(nonnull FLNNativeExpressAd *)nativeExpressAd nativeExpressAdView:(nonnull NSArray<__kindof FLNNativeExpressAdView *> *)nativeExpressAdViews {
    
    NSLog(@" 广告 RenderSuccess");
    
    for (FLNNativeExpressAdView *adView in nativeExpressAdViews) {
        [self.adPool addObject:adView];
        
        NSInteger price = adView.eCPM;
        [nativeExpressAd sendLossNotificationWithInfo:@{
            @"winner_price": @(price),
        }];
    }
    
    [self.tableView reloadData];
}

 
- (void)nativeExpressAdViewRenderFail:(nonnull FLNNativeExpressAd *)nativeExpressAd error:(nonnull NSError *)error {
    NSLog(@" 广告 RenderFail");
}


- (void)nativeExpressAdViewClicked:(FLNNativeExpressAd *)nativeExpressAd
                 nativeExpressAdView:(FLNNativeExpressAdView *)nativeExpressAdView {
    NSLog(@"💰 广告点击");
}

- (void)nativeExpressAdViewClosed:(FLNNativeExpressAd *)nativeExpressAd
               nativeExpressAdView:(FLNNativeExpressAdView *)nativeExpressAdView {
    NSLog(@"❌ 广告关闭");
    [self.adPool removeObject:nativeExpressAdView];
    [self.tableView reloadData];

}

- (void)nativeExpressAdViewDidShow:(FLNNativeExpressAd *)nativeExpressAd
                nativeExpressAdView:(FLNNativeExpressAdView *)nativeExpressAdView {
    NSLog(@"📈 广告曝光");
}


@end
