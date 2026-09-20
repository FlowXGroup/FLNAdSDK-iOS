//
//  UnifiedNativeAdViewController.m
//  FlowNet
//

#import "UnifiedNativeAdViewController.h"
#import "FLNDemoAdConfig.h"
#import "FLNDemoNativeVideoView.h"
#import <FLNAdSDK/FLNUnifiedNativeAd.h>
#import <FLNAdSDK/FLNUnifiedNativeAdView.h>
#import <FLNAdSDK/FLNUnifiedNativeAdDataObject.h>
#import <Masonry/Masonry.h>

@interface UnifiedNativeAdViewController () <FLNUnifiedNativeAdDelegate, FLNUnifiedNativeAdViewDelegate>

@property (nonatomic, strong) FLNUnifiedNativeAd *nativeAd;
@property (nonatomic, strong) NSMutableArray<FLNUnifiedNativeAdView *> *adViews;
@property (nonatomic, strong) NSMutableArray<NSString *> *logLines;

@property (nonatomic, strong) UIButton *loadButton;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) UITextView *logTextView;

@end

@implementation UnifiedNativeAdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"信息流自渲染";
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.adViews = [NSMutableArray array];
    self.logLines = [NSMutableArray array];

    self.loadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.loadButton setTitle:@"加载广告" forState:UIControlStateNormal];
    self.loadButton.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    [self.loadButton addTarget:self action:@selector(loadAd) forControlEvents:UIControlEventTouchUpInside];
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:self.scrollView];

    UIView *scrollContent = [[UIView alloc] init];
    [self.scrollView addSubview:scrollContent];

    self.stackView = [[UIStackView alloc] init];
    self.stackView.axis = UILayoutConstraintAxisVertical;
    self.stackView.spacing = 16;
    [scrollContent addSubview:self.stackView];

    self.logTextView = [[UITextView alloc] init];
    self.logTextView.editable = NO;
    self.logTextView.selectable = YES;
    self.logTextView.font = [UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightRegular];
    self.logTextView.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    self.logTextView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
    [self.view addSubview:self.logTextView];

    [self.view addSubview:self.loadButton];

    CGFloat inset = 16;
    CGFloat logH = 140;
    CGFloat gap = 12;
    [self.logTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(inset);
        make.right.equalTo(self.view).offset(-inset);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-12);
        make.height.mas_equalTo(logH);
    }];
    [self.loadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.logTextView);
        make.bottom.equalTo(self.logTextView.mas_top).offset(-gap);
        make.height.mas_equalTo(44);
    }];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(12);
        make.left.right.equalTo(self.logTextView);
        make.bottom.equalTo(self.loadButton.mas_top).offset(-gap);
    }];
    [scrollContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.width.equalTo(self.scrollView);
    }];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(scrollContent).insets(UIEdgeInsetsMake(0, inset, 16, inset));
        make.bottom.equalTo(scrollContent);
    }];

    self.nativeAd = [[FLNUnifiedNativeAd alloc] initWithPosId:kFLNDemoPosIdUnifiedNative];
    self.nativeAd.delegate = self;
}

- (void)dealloc {
    self.nativeAd.delegate = nil;
    [self clearAllAds];
}

- (void)appendLog:(NSString *)msg {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"HH:mm:ss";
    NSString *line = [NSString stringWithFormat:@"%@ %@\n", [fmt stringFromDate:[NSDate date]], msg];
    [self.logLines addObject:line];
    if (self.logLines.count > 80) {
        [self.logLines removeObjectsInRange:NSMakeRange(0, self.logLines.count - 80)];
    }
    self.logTextView.text = [self.logLines componentsJoinedByString:@""];
    if (self.logTextView.text.length > 0) {
        NSRange end = NSMakeRange(self.logTextView.text.length - 1, 1);
        [self.logTextView scrollRangeToVisible:end];
    }
}

- (void)loadAd {
    [self appendLog:@"请求 loadAd"];
    [self.nativeAd loadAd];
}

- (void)stopVideoPlayerInView:(UIView *)view {
    if (!view) {
        return;
    }
    if ([view isKindOfClass:[FLNDemoNativeVideoView class]]) {
        [(FLNDemoNativeVideoView *)view stop];
        return;
    }
    for (UIView *subview in view.subviews) {
        [self stopVideoPlayerInView:subview];
    }
}

- (void)clearAllAds {
    for (FLNUnifiedNativeAdView *v in [self.adViews copy]) {
        [self stopVideoPlayerInView:v];
        [v unregisterDataObject];
        v.delegate = nil;
        [v removeFromSuperview];
    }
    [self.adViews removeAllObjects];
    for (UIView *sub in [self.stackView.arrangedSubviews copy]) {
        [self.stackView removeArrangedSubview:sub];
        [sub removeFromSuperview];
    }
}

- (void)closeAd:(UIButton *)sender {
    UIView *host = sender.superview;
    if (![host isKindOfClass:[FLNUnifiedNativeAdView class]]) {
        return;
    }
    FLNUnifiedNativeAdView *adView = (FLNUnifiedNativeAdView *)host;
    [self stopVideoPlayerInView:adView];
    [adView unregisterDataObject];
    adView.delegate = nil;
    [adView removeFromSuperview];
    [self.adViews removeObject:adView];
    [self appendLog:@"已关闭一条广告"];
}

- (void)loadImageURLString:(NSString *)urlString imageView:(UIImageView *)iv {
    if (urlString.length == 0) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *d = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        UIImage *img = d.length ? [UIImage imageWithData:d] : nil;
        if (!img) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{ iv.image = img; });
    });
}

- (UIView *)buildMediaViewWithData:(FLNUnifiedNativeAdDataObject *)data {
    UIView *mediaView = [[UIView alloc] init];
    mediaView.clipsToBounds = YES;
    mediaView.backgroundColor = [UIColor tertiarySystemFillColor];

    if (data.videoUrl.length > 0) {
        if (data.videoImageUrl.length > 0) {
            UIImageView *coverImageView = [[UIImageView alloc] init];
            coverImageView.contentMode = UIViewContentModeScaleAspectFill;
            coverImageView.clipsToBounds = YES;
            [mediaView addSubview:coverImageView];
            [coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(mediaView);
            }];
            [self loadImageURLString:data.videoImageUrl imageView:coverImageView];
        }

        FLNDemoNativeVideoView *videoPlayerView = [[FLNDemoNativeVideoView alloc] initWithVideoURLString:data.videoUrl
                                                                                                  muted:YES];
        __weak typeof(self) weakSelf = self;
        videoPlayerView.onEvent = ^(NSString *message) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [strongSelf appendLog:message];
        };
        [mediaView addSubview:videoPlayerView];
        [videoPlayerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(mediaView);
        }];

        UILabel *videoBadge = [[UILabel alloc] init];
        videoBadge.font = [UIFont systemFontOfSize:11 weight:UIFontWeightSemibold];
        videoBadge.textColor = [UIColor whiteColor];
        videoBadge.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.55];
        videoBadge.textAlignment = NSTextAlignmentCenter;
        videoBadge.layer.cornerRadius = 4;
        videoBadge.clipsToBounds = YES;
        videoBadge.userInteractionEnabled = NO;
        videoBadge.text = @"视频";
        [mediaView addSubview:videoBadge];
        [videoBadge mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(mediaView).offset(6);
            make.height.mas_equalTo(20);
            make.width.mas_equalTo(40);
        }];

        if (data.videoDuration > 0) {
            UILabel *durationLabel = [[UILabel alloc] init];
            durationLabel.font = [UIFont monospacedDigitSystemFontOfSize:11 weight:UIFontWeightMedium];
            durationLabel.textColor = [UIColor whiteColor];
            durationLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.55];
            durationLabel.textAlignment = NSTextAlignmentCenter;
            durationLabel.layer.cornerRadius = 4;
            durationLabel.clipsToBounds = YES;
            durationLabel.userInteractionEnabled = NO;
            durationLabel.text = [NSString stringWithFormat:@" %ld\" ", (long)data.videoDuration];
            [mediaView addSubview:durationLabel];
            [durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.bottom.equalTo(mediaView).offset(-6);
                make.height.mas_equalTo(18);
            }];
        }
        return mediaView;
    }

    UIImageView *adImageView = [[UIImageView alloc] init];
    adImageView.contentMode = UIViewContentModeScaleAspectFill;
    adImageView.clipsToBounds = YES;
    adImageView.backgroundColor = [UIColor tertiarySystemFillColor];
    [mediaView addSubview:adImageView];
    [adImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(mediaView);
    }];
    id firstUrl = data.imageUrl.firstObject;
    NSString *mainUrl = [firstUrl isKindOfClass:[NSString class]] ? (NSString *)firstUrl : nil;
    [self loadImageURLString:mainUrl imageView:adImageView];
    return mediaView;
}

- (void)buildAdViewWithData:(FLNUnifiedNativeAdDataObject *)data {
    if (!data.isAdValid) {
        [self appendLog:@"跳过无效广告数据 isAdValid=NO"];
        return;
    }

    FLNUnifiedNativeAdView *adView = [[FLNUnifiedNativeAdView alloc] init];
    adView.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    adView.layer.cornerRadius = 12;
    adView.clipsToBounds = YES;
    adView.viewController = self;
    adView.delegate = self;

    [self.stackView addArrangedSubview:adView];
    [adView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_greaterThanOrEqualTo(200);
    }];
    [self.adViews addObject:adView];

    UIView *mediaView = [self buildMediaViewWithData:data];
    [adView addSubview:mediaView];

    UIImageView *iconImageView = [[UIImageView alloc] init];
    iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    iconImageView.backgroundColor = [UIColor tertiarySystemFillColor];
    iconImageView.layer.cornerRadius = 4;
    iconImageView.clipsToBounds = YES;
    [adView addSubview:iconImageView];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    titleLabel.numberOfLines = 2;
    titleLabel.text = data.title.length ? data.title : @"广告";
    [adView addSubview:titleLabel];

    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    descLabel.textColor = [UIColor secondaryLabelColor];
    descLabel.numberOfLines = 3;
    descLabel.text = data.desc.length ? data.desc : @"";
    [adView addSubview:descLabel];

    UIButton *ctaButton = [UIButton buttonWithType:UIButtonTypeSystem];
    NSString *ctaTitle = data.buttonText.length ? data.buttonText : (data.callToAction.length ? data.callToAction : @"查看详情");
    [ctaButton setTitle:ctaTitle forState:UIControlStateNormal];
    ctaButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    [adView addSubview:ctaButton];

    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeClose];
    [closeButton addTarget:self action:@selector(closeAd:) forControlEvents:UIControlEventTouchUpInside];
    [adView addSubview:closeButton];

    [self loadImageURLString:data.iconUrl imageView:iconImageView];

    [mediaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(adView);
        make.height.mas_equalTo(160);
    }];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(adView).offset(6);
        make.right.equalTo(adView).offset(-6);
    }];
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(adView).offset(12);
        make.top.equalTo(mediaView.mas_bottom).offset(12);
        make.width.height.mas_equalTo(40);
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconImageView.mas_right).offset(10);
        make.right.equalTo(adView).offset(-12);
        make.top.equalTo(mediaView.mas_bottom).offset(10);
    }];
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(titleLabel);
        make.top.equalTo(titleLabel.mas_bottom).offset(4);
    }];
    [ctaButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(adView).offset(12);
        make.right.equalTo(adView).offset(-12);
        make.top.equalTo(iconImageView.mas_bottom).offset(12);
        make.bottom.equalTo(adView).offset(-12);
        make.height.mas_equalTo(40);
    }];

    [adView layoutIfNeeded];
    [adView registerDataObject:data clickableViews:@[ mediaView, iconImageView, titleLabel, descLabel, ctaButton ]];
    [self appendLog:[NSString stringWithFormat:@"已绑定广告 eCPM:%ld 标题:%@", (long)data.eCPM, data.title ?: @""]];
}

#pragma mark - FLNUnifiedNativeAdDelegate

- (void)fln_unifiedNativeAdLoaded:(NSArray<FLNUnifiedNativeAdDataObject *> *)unifiedNativeAdDataObjects error:(NSError *)error {
    if (error) {
        [self appendLog:[NSString stringWithFormat:@"加载失败 %@", error.localizedDescription]];
        return;
    }
    NSUInteger n = unifiedNativeAdDataObjects.count;
    [self appendLog:[NSString stringWithFormat:@"加载成功，条数 %lu", (unsigned long)n]];
    [self clearAllAds];
    if (n == 0) {
        [self appendLog:@"无广告数据"];
        return;
    }
    for (FLNUnifiedNativeAdDataObject *obj in unifiedNativeAdDataObjects) {
        if (obj.videoUrl.length > 0) {
            NSString *durationText = obj.videoDuration > 0
                ? [NSString stringWithFormat:@"，时长 %ld 秒", (long)obj.videoDuration]
                : @"";
            [self appendLog:[NSString stringWithFormat:@"检测到视频素材%@", durationText]];
        } else {
            [self appendLog:@"检测到图片素材"];
        }
        [self buildAdViewWithData:obj];
        NSInteger price = obj.eCPM;
        [obj sendLossNotificationWithInfo:@{
            @"winner_price": @(price),
        }];
    }
}

#pragma mark - FLNUnifiedNativeAdViewDelegate

- (void)fln_unifiedNativeAdViewDidExpose:(FLNUnifiedNativeAdView *)unifiedNativeAdView {
    [self appendLog:@"曝光"];
}

- (void)fln_unifiedNativeAdViewDidClick:(FLNUnifiedNativeAdView *)unifiedNativeAdView {
    [self appendLog:@"点击"];
}

- (void)fln_unifiedNativeAdDetailViewClosed:(FLNUnifiedNativeAdView *)unifiedNativeAdView {
    [self appendLog:@"详情页关闭"];
}

- (void)fln_unifiedNativeAdDetailViewWillPresentScreen:(FLNUnifiedNativeAdView *)unifiedNativeAdView {
    [self appendLog:@"详情页将展示"];
}

@end
