//
//  InterstitialAdViewController.m
//  FlowNet
//

#import "InterstitialAdViewController.h"
#import "FLNDemoAdConfig.h"
#import <FLNAdSDK/FLNInterstitialAd.h>
#import <Masonry/Masonry.h>


@interface InterstitialAdViewController () <FLNInterstitialAdDelegate>

@property (nonatomic, strong) FLNInterstitialAd *interstitialAd;
@property (nonatomic, strong) UITextView *logTextView;
@property (nonatomic, strong) NSMutableArray<NSString *> *logLines;
@property (nonatomic, strong) UIButton *loadButton;
@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) UIButton *showButton;
@property (nonatomic, strong) UIView *logAreaView;
@property (nonatomic, strong) UILabel *logLabel;

@end

@implementation InterstitialAdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    self.logLabel.text = @"插屏回调日志";
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
    self.interstitialAd = [[FLNInterstitialAd alloc] initWithPosId:kFLNDemoPosIdInterstitial];
    self.interstitialAd.delegate = self;
}

- (void)loadAd {
    [self.interstitialAd loadAd];
}

- (void)checkAdReady {
    [self log:[NSString stringWithFormat:@"isReady:%@", [self.interstitialAd isReady] ? @"YES" : @"NO"]];
}

- (void)showAd {
    if (![self.interstitialAd isReady]) {
        [self log:@"isReady:NO"];
        return;
    }
    UIViewController *root = self.navigationController ?: self;
    [self.interstitialAd presentAdFromRootViewController:root];
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

#pragma mark - FLNInterstitialAdDelegate

- (void)interstitialAdDidLoad:(FLNInterstitialAd *)interstitialAd {
    [self log:[NSString stringWithFormat:@"%@ eCPM:%ld", NSStringFromSelector(_cmd), (long)interstitialAd.eCPM]];
    NSInteger price = interstitialAd.eCPM;
    [interstitialAd sendLossNotificationWithInfo:@{
        @"winner_price": @(price),
    }];
}

- (void)interstitialAd:(FLNInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    [self log:[NSString stringWithFormat:@"%@ %@", NSStringFromSelector(_cmd), error]];
}

- (void)interstitialAdDidShow:(FLNInterstitialAd *)interstitial {
    [self log:NSStringFromSelector(_cmd)];
}

- (void)interstitialAdShowFailed:(FLNInterstitialAd *)interstitialAd error:(NSError *)error {
    [self log:[NSString stringWithFormat:@"%@ %@", NSStringFromSelector(_cmd), error]];
}

- (void)interstitialAdDidClose:(FLNInterstitialAd *)interstitialAd {
    [self log:NSStringFromSelector(_cmd)];
}

- (void)interstitialAdDidClicked:(FLNInterstitialAd *)interstitialAd {
    [self log:NSStringFromSelector(_cmd)];
}

- (void)interstitialAdDidDismissScreen:(FLNInterstitialAd *)interstitialAd {
    [self log:NSStringFromSelector(_cmd)];
}

@end
