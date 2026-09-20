//
//  FLNDemoNativeVideoView.m
//  FlowNet
//

#import "FLNDemoNativeVideoView.h"
#import <AVFoundation/AVFoundation.h>

@interface FLNDemoNativeVideoView ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, copy) NSString *videoURLString;

@end

@implementation FLNDemoNativeVideoView

- (instancetype)initWithVideoURLString:(NSString *)videoURLString muted:(BOOL)muted {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _videoURLString = [videoURLString copy];
        self.backgroundColor = [UIColor blackColor];
        self.clipsToBounds = YES;
        self.userInteractionEnabled = NO;

        NSURL *videoURL = [NSURL URLWithString:videoURLString];
        if (!videoURL || videoURL.scheme.length == 0) {
            [self notifyEvent:@"自渲染视频 URL 无效"];
            return self;
        }

        _playerItem = [AVPlayerItem playerItemWithURL:videoURL];
        _player = [AVPlayer playerWithPlayerItem:_playerItem];
        _player.muted = muted;

        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.layer addSublayer:_playerLayer];

        [_playerItem addObserver:self
                      forKeyPath:@"status"
                         options:NSKeyValueObservingOptionNew
                         context:NULL];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerDidFinishPlaying:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:_playerItem];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window && self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
        [self play];
        [self notifyEvent:@"自渲染视频开始播放"];
        return;
    }
    if (!self.window) {
        [self.player pause];
    }
}

- (void)play {
    if (!self.player || !self.window) {
        return;
    }
    [self.player play];
}

- (void)stop {
    if (!self.player && !self.playerItem && !self.playerLayer) {
        return;
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    @try {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
    } @catch (__unused NSException *exception) {
    }

    [self.player pause];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    [self.playerLayer removeFromSuperlayer];

    self.player = nil;
    self.playerItem = nil;
    self.playerLayer = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if (object != self.playerItem || ![keyPath isEqualToString:@"status"]) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.playerItem) {
            return;
        }
        switch (self.playerItem.status) {
            case AVPlayerItemStatusReadyToPlay:
                [self notifyEvent:@"自渲染视频准备完成"];
                if (self.window) {
                    [self play];
                    [self notifyEvent:@"自渲染视频开始播放"];
                }
                break;
            case AVPlayerItemStatusFailed:
                [self notifyEvent:[NSString stringWithFormat:@"自渲染视频播放失败：%@",
                                    self.playerItem.error.localizedDescription ?: @"未知错误"]];
                break;
            default:
                break;
        }
    });
}

- (void)playerDidFinishPlaying:(NSNotification *)notification {
    if (notification.object != self.playerItem) {
        return;
    }
    [self notifyEvent:@"自渲染视频播放完成"];
    __weak typeof(self) weakSelf = self;
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        if (!finished) {
            return;
        }
        [weakSelf play];
    }];
}

- (void)notifyEvent:(NSString *)message {
    if (self.onEvent) {
        self.onEvent(message);
    }
}

- (void)dealloc {
    [self stop];
}

@end
