//
//  RewardAdViewController.m
//  FlowNet
//

#import "RewardAdViewController.h"
#import "FLNDemoAdConfig.h"
#import <FLNAdSDK/FLNRewardAd.h>
#import <Masonry/Masonry.h>



@interface RewardAdViewController () <FLNRewardAdDelegate>

@property (nonatomic, strong) FLNRewardAd *rewardAd;
@property (nonatomic, strong) UITextView *logTextView;
@property (nonatomic, strong) NSMutableArray<NSString *> *logLines;
@property (nonatomic, strong) UIButton *loadButton;
@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) UIButton *showButton;
@property (nonatomic, strong) UIView *logAreaView;
@property (nonatomic, strong) UILabel *logLabel;

@end

@implementation RewardAdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"激励视频";
    self.view.backgroundColor = UIColor.whiteColor;

    self.loadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.loadButton setTitle:@"Load" forState:UIControlStateNormal];
    [self.loadButton addTarget:self action:@selector(loadAd) forControlEvents:UIControlEventTouchUpInside];
    self.loadButton.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    [self.view addSubview:self.loadButton];

    self.checkButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.checkButton setTitle:@"Check" forState:UIControlStateNormal];
    [self.checkButton addTarget:self action:@selector(checkAdReady) forControlEvents:UIControlEventTouchUpInside];
    self.checkButton.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    [self.view addSubview:self.checkButton];

    self.showButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.showButton setTitle:@"Show" forState:UIControlStateNormal];
    [self.showButton addTarget:self action:@selector(showAd) forControlEvents:UIControlEventTouchUpInside];
    self.showButton.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    [self.view addSubview:self.showButton];

    self.logAreaView = [[UIView alloc] init];
    self.logAreaView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    [self.view addSubview:self.logAreaView];

    self.logLabel = [[UILabel alloc] init];
    self.logLabel.font = [UIFont systemFontOfSize:14];
    self.logLabel.textColor = [UIColor darkTextColor];
    self.logLabel.numberOfLines = 1;
    self.logLabel.text = @"激励视频回调日志";
    [self.logAreaView addSubview:self.logLabel];

    self.logTextView = [[UITextView alloc] init];
    self.logTextView.editable = NO;
    self.logTextView.selectable = YES;
    self.logTextView.backgroundColor = [UIColor clearColor];
    self.logTextView.textContainerInset = UIEdgeInsetsZero;
    self.logTextView.textContainer.lineFragmentPadding = 0;
    self.logTextView.font = [UIFont systemFontOfSize:14];
    [self.logAreaView addSubview:self.logTextView];

    CGFloat btnH = 44;
    CGFloat spacing = 12;
    CGFloat side = 24;

    [self.loadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(spacing);
        make.left.equalTo(self.view.mas_left).offset(side);
        make.right.equalTo(self.view.mas_right).offset(-side);
        make.height.mas_equalTo(btnH);
    }];
    [self.checkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loadButton.mas_bottom).offset(spacing);
        make.left.right.height.equalTo(self.loadButton);
    }];
    [self.showButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.checkButton.mas_bottom).offset(spacing);
        make.left.right.height.equalTo(self.loadButton);
    }];
    [self.logAreaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.showButton.mas_bottom).offset(spacing);
        make.left.right.equalTo(self.loadButton);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-spacing);
    }];
    [self.logLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.logAreaView).insets(UIEdgeInsetsMake(spacing, 8, 0, 8));
        make.height.mas_equalTo(20);
    }];
    [self.logTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logLabel.mas_bottom).offset(4);
        make.left.right.bottom.equalTo(self.logAreaView).insets(UIEdgeInsetsMake(0, 4, 4, 4));
    }];

    self.logLines = [NSMutableArray array];
    self.rewardAd = [[FLNRewardAd alloc] initWithPosId:kFLNDemoPosIdReward];
    self.rewardAd.delegate = self;
    self.rewardAd.timeout = 5;
    self.rewardAd.videoMuted = YES;
}

- (void)loadAd {
    [self.rewardAd loadAd];
}

- (void)checkAdReady {
    [self log:[NSString stringWithFormat:@"isReady:%@", [self.rewardAd isReady] ? @"YES" : @"NO"]];
}

- (void)showAd {
    if (![self.rewardAd isReady]) {
        [self log:@"isReady:NO"];
        return;
    }
    UIViewController *root = self.navigationController ?: self;
    [self.rewardAd presentAdFromRootViewController:root];
}

- (void)log:(NSString *)log {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *timestamp = [formatter stringFromDate:[NSDate date]];
    NSString *logLine = [NSString stringWithFormat:@"%@ %@", timestamp, log];
    [self.logLines addObject:[logLine stringByAppendingString:@"\n"]];
    if (self.logLines.count > 100) {
        [self.logLines removeObjectsInRange:NSMakeRange(0, self.logLines.count - 100)];
    }
    NSMutableString *all = [NSMutableString string];
    for (NSString *line in self.logLines) {
        [all appendString:line];
    }
    self.logTextView.text = all;
    if (self.logTextView.text.length > 0) {
        NSRange bottom = NSMakeRange(self.logTextView.text.length - 1, 1);
        [self.logTextView scrollRangeToVisible:bottom];
    }
}

#pragma mark - FLNRewardAdDelegate

- (void)rewardVideoAdDidLoad:(FLNRewardAd *)rewardedAd {
    [self log:[NSString stringWithFormat:@"%@ eCPM:%ld", NSStringFromSelector(_cmd), (long)rewardedAd.eCPM]];
    NSInteger price = rewardedAd.eCPM;
    [rewardedAd sendLossNotificationWithInfo:@{
        @"winner_price": @(price),
    }];
}

- (void)rewardVideoAd:(FLNRewardAd *)rewardedAd didFailWithError:(NSError *)error {
    [self log:[NSString stringWithFormat:@"%@ %@", NSStringFromSelector(_cmd), error]];
}

- (void)rewardVideoAdReadyToPlay:(FLNRewardAd *)rewardedAd {
    [self log:NSStringFromSelector(_cmd)];
}

- (void)rewardVideoAdDidPlayStart:(FLNRewardAd *)rewardedAd {
    [self log:NSStringFromSelector(_cmd)];
}

- (void)rewardVideoAdDidPlayFinish:(FLNRewardAd *)rewardedAd {
    [self log:NSStringFromSelector(_cmd)];
}

- (void)rewardVideoAdDidShow:(FLNRewardAd *)rewardedAd {
    [self log:NSStringFromSelector(_cmd)];
}

- (void)rewardVideoAdShowFailed:(FLNRewardAd *)rewardedAd error:(NSError *)error {
    [self log:[NSString stringWithFormat:@"%@ %@", NSStringFromSelector(_cmd), error]];
}

- (void)rewardVideoAdDidClose:(FLNRewardAd *)rewardedAd {
    [self log:NSStringFromSelector(_cmd)];
}

- (void)rewardVideoAdDidClicked:(FLNRewardAd *)rewardedAd {
    [self log:NSStringFromSelector(_cmd)];
}

- (void)rewardVideoAdDidRewardEffective:(FLNRewardAd *)rewardedAd info:(NSDictionary *)info {
    [self log:[NSString stringWithFormat:@"%@ info:%@", NSStringFromSelector(_cmd), info]];
}

@end
