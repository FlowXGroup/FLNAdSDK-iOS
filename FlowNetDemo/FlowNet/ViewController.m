//
//  ViewController.m
//  FlowNet
//

#import "ViewController.h"
#import "SplashViewController.h"
#import "NativeExpressAdViewController.h"
#import "InterstitialAdViewController.h"
#import "RewardAdViewController.h"
#import "UnifiedNativeAdViewController.h"
#import <FLNAdSDK/FLNAdSDKManager.h>
#import <Masonry/Masonry.h>

static NSString * const kMenuCellId = @"menu";
static const CGFloat kMenuRowHeight = 80.0;

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *sdkVersionLabel;
@property (nonatomic, copy) NSArray<NSString *> *menuTitles;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"FlowNet Demo";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.menuTitles = @[@"开屏广告",@"信息流 模版渲染",@"信息流 自渲染",@"插屏广告",@"激励视频"];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 0);
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kMenuCellId];
    [self.view addSubview:self.tableView];

    self.sdkVersionLabel = [[UILabel alloc] init];
    self.sdkVersionLabel.textAlignment = NSTextAlignmentCenter;
    self.sdkVersionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.sdkVersionLabel.textColor = [UIColor secondaryLabelColor];
    self.sdkVersionLabel.numberOfLines = 1;
    NSString *sdkVersion = [FLNAdSDKManager sdkVersion];
    self.sdkVersionLabel.text = sdkVersion.length > 0 ? sdkVersion : @"";
    [self.view addSubview:self.sdkVersionLabel];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(self.menuTitles.count * kMenuRowHeight);
    }];
    [self.sdkVersionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tableView.mas_bottom).offset(8);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.height.mas_equalTo(22);
        make.bottom.lessThanOrEqualTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-8);
    }];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMenuCellId forIndexPath:indexPath];
    cell.textLabel.text = self.menuTitles[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
    cell.textLabel.textColor = [UIColor labelColor];
    cell.textLabel.numberOfLines = 2;
    cell.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kMenuRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIViewController *target = nil;
    switch (indexPath.row) {
        case 0:
            target = [[SplashViewController alloc] init];
            break;
        case 1:
            target = [[NativeExpressAdViewController alloc] init];
            break;
        case 2:
            target = [[UnifiedNativeAdViewController alloc] init];
            break;
        case 3:
            target = [[InterstitialAdViewController alloc] init];
            break;
        case 4:
            target = [[RewardAdViewController alloc] init];
            break;
        default:
            break;
    }
    if (target) {
        target.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:target animated:YES];
    }
}

@end
