//
//  FLNDemoNativeVideoView.h
//  FlowNet
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^FLNDemoNativeVideoEventHandler)(NSString *message);

@interface FLNDemoNativeVideoView : UIView

@property (nonatomic, copy, nullable) FLNDemoNativeVideoEventHandler onEvent;

- (instancetype)initWithVideoURLString:(NSString *)videoURLString muted:(BOOL)muted;
- (void)play;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
