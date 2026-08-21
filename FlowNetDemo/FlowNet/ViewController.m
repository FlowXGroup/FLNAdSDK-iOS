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

static NSString * const kMenuCellId = @"menu";

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray<NSString *> *menuTitles;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.menuTitles = @[@"开屏广告",@"信息流 模版渲染",@"信息流 自渲染",@"插屏广告",@"激励视频"];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 8;
    }
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 0);
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kMenuCellId];
    [self.view addSubview:self.tableView];

    CGFloat initialW = CGRectGetWidth(self.view.bounds);
    if (initialW < 1) {
        initialW = CGRectGetWidth(UIScreen.mainScreen.bounds);
    }
    self.tableView.tableHeaderView = [self buildTableHeaderSizedForWidth:initialW];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIEdgeInsets safe = self.view.safeAreaInsets;
    CGRect b = self.view.bounds;
    self.tableView.frame = CGRectMake(CGRectGetMinX(b) + safe.left,
                                      CGRectGetMinY(b) + safe.top,
                                      CGRectGetWidth(b) - safe.left - safe.right,
                                      CGRectGetHeight(b) - safe.top - safe.bottom);
    [self relayoutTableHeaderIfNeeded];
}

- (void)relayoutTableHeaderIfNeeded {
    UIView *header = self.tableView.tableHeaderView;
    if (!header) {
        return;
    }
    CGFloat w = CGRectGetWidth(self.tableView.bounds);
    if (w < 1) {
        return;
    }
    UIView *newHeader = [self buildTableHeaderSizedForWidth:w];
    if (fabs(header.bounds.size.height - newHeader.bounds.size.height) > 0.5 || fabs(header.bounds.size.width - w) > 0.5) {
        self.tableView.tableHeaderView = newHeader;
    }
}

- (UIView *)buildTableHeaderSizedForWidth:(CGFloat)width {
    CGFloat layoutW = width >= 1.0 ? width : CGRectGetWidth(UIScreen.mainScreen.bounds);
    CGFloat side = 20.0;
    CGFloat top = 20.0;
    CGFloat gap = 6.0;
    CGFloat bottom = 16.0;
    CGFloat textW = MAX(layoutW - 2.0 * side, 0.0);

    UILabel *title = [[UILabel alloc] init];
    title.text = @"FlowNet Demo";
    title.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    title.textColor = [UIColor labelColor];
    title.numberOfLines = 1;
    CGSize titleFit = [title sizeThatFits:CGSizeMake(textW, CGFLOAT_MAX)];
    title.frame = CGRectMake(side, top, textW, titleFit.height);

    UILabel *sub = [[UILabel alloc] init];
    sub.text = @"选择广告类型进行联调";
    sub.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    sub.textColor = [UIColor secondaryLabelColor];
    sub.numberOfLines = 2;
    CGFloat subY = CGRectGetMaxY(title.frame) + gap;
    CGSize subFit = [sub sizeThatFits:CGSizeMake(textW, CGFLOAT_MAX)];
    sub.frame = CGRectMake(side, subY, textW, subFit.height);

    CGFloat totalH = CGRectGetMaxY(sub.frame) + bottom;
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, layoutW, totalH)];
    container.backgroundColor = [UIColor clearColor];
    [container addSubview:title];
    [container addSubview:sub];
    return container;
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
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
    return 80;
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
