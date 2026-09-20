//
//  YDSplashViewController.m
//  FlowNet
//
//  Created by lee on 2025/12/17.
//

#import "SplashViewController.h"
#import "FLNDemoAdConfig.h"
#import <FLNAdSDK/FLNSplashAd.h>
 
#import <Masonry/Masonry.h>

@interface SplashViewController () <FLNSplashAdDelegate>

@property (nonatomic,strong) FLNSplashAd *splashAd;
@property (nonatomic,strong) UITextView *logTextView;
@property (nonatomic,strong) NSMutableArray<NSString *> *logLines;

@property (nonatomic, strong) UIButton *loadButton;
@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) UIButton *showButton;
@property (nonatomic, strong) UIView *logAreaView;
@property (nonatomic, strong) UILabel *logLabel;
 
@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"开屏广告";
 
    self.view.backgroundColor = UIColor.whiteColor;
    // Buttons
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

    // Log area
    self.logAreaView = [[UIView alloc] init];
    self.logAreaView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    [self.view addSubview:self.logAreaView];

    self.logLabel = [[UILabel alloc] init];
    self.logLabel.font = [UIFont systemFontOfSize:14];
    self.logLabel.textColor = [UIColor darkTextColor];
    self.logLabel.numberOfLines = 1;
    [self.logAreaView addSubview:self.logLabel];

    self.logTextView = [[UITextView alloc] init];
    self.logTextView.editable = NO;
    self.logTextView.selectable = YES;
    self.logTextView.backgroundColor = [UIColor clearColor];
    self.logTextView.textContainerInset = UIEdgeInsetsZero;
    self.logTextView.textContainer.lineFragmentPadding = 0;
    self.logTextView.font = [UIFont systemFontOfSize:16];
    [self.logAreaView addSubview:self.logTextView];


    // Button heights & spacing
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

    // logLabel at top of logArea, logTextView fills below
    [self.logLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.logAreaView).insets(UIEdgeInsetsMake(spacing, 8, 0, 8));
        make.height.mas_equalTo(20);
    }];
    [self.logTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logLabel.mas_bottom).offset(4);
        make.left.right.bottom.equalTo(self.logAreaView).insets(UIEdgeInsetsMake(0, 4, 4, 4));
    }];
    
    self.logLines = [NSMutableArray array];
    
    self.splashAd = [[FLNSplashAd alloc] initWithPosId:kFLNDemoPosIdSplash];
    self.splashAd.delegate = self;
    self.splashAd.timeout = 3;
}

- (void)loadAd {
    [self.splashAd loadAd];
}

- (void)checkAdReady {
    [self log:[NSString stringWithFormat:@"isReady:%@", [self.splashAd isReady] ? @"YES" : @"NO"]];
}

- (void)showAd {
    if ([self.splashAd isReady]) {
        UIWindow *window = [self activeWindow];
        if (window) {
            [self.splashAd showAdInWindow:window];
        } else {
            [self log:@"showAd failed: no active window"];
        }
    } else {
        [self log:@"isReady:NO"];
    }
}

// Resolve an active window in a multi-scene environment.
- (UIWindow *)activeWindow {
    if (self.view.window) {
        return self.view.window;
    }
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState != UISceneActivationStateForegroundActive) {
                continue;
            }
            if (![scene isKindOfClass:[UIWindowScene class]]) {
                continue;
            }
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            for (UIWindow *window in windowScene.windows) {
                if (window.isKeyWindow) {
                    return window;
                }
            }
            if (windowScene.windows.count > 0) {
                return windowScene.windows.firstObject;
            }
        }
    } else {
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            if (window.isKeyWindow) {
                return window;
            }
        }
        if ([UIApplication sharedApplication].windows.count > 0) {
            return [UIApplication sharedApplication].windows.firstObject;
        }
    }
    return nil;
}

// Enhanced log method: keeps history, timestamps, max 100 lines, scrolls to bottom.
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

- (void)splashAdDidLoad:(FLNSplashAd *)splashAd {
    [self log:[NSString stringWithFormat:@"%@ splashAd", NSStringFromSelector(_cmd)]];
    [self log:[NSString stringWithFormat:@"ecpm %ld 分", (long)splashAd.eCPM]];
    NSInteger price = splashAd.eCPM;
    [splashAd sendLossNotificationWithInfo:@{
        @"winner_price": @(price),
    }];
}


- (void)splashAdLoadFail:(FLNSplashAd *)splashAd error:(NSError *)error {
    [self log:[NSString stringWithFormat:@"%@ splashAderror:%@", NSStringFromSelector(_cmd), error]];
}


- (void)splashAdDidShow:(FLNSplashAd *)splashAd {
    [self log:[NSString stringWithFormat:@"%@ splashAd", NSStringFromSelector(_cmd)]];
}

 
- (void)splashAdShowFailed:(FLNSplashAd *)splashAd withError:(NSError *)error {
    [self log:[NSString stringWithFormat:@"%@ splashAd error:%@", NSStringFromSelector(_cmd), error]];
}


- (void)splashAdClicked:(FLNSplashAd *)splashAd {
    
    [self log:[NSString stringWithFormat:@"%@ splashAd", NSStringFromSelector(_cmd)]];

}


- (void)splashAdClosed:(FLNSplashAd *)splashAd {
     [self log:[NSString stringWithFormat:@"%@ splashAd", NSStringFromSelector(_cmd)]];

}


- (void)splashAdSkip:(FLNSplashAd *)splashAd time:(NSInteger)time{
    [self log:[NSString stringWithFormat:@"%@ splashAd time:%ld", NSStringFromSelector(_cmd), (long)time]];
}

 

@end
