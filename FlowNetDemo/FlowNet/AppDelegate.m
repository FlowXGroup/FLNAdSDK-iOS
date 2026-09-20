//
//  AppDelegate.m
//  FlowNet
//
//  Created by lee on 2025/12/12.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "FLNDemoAdConfig.h"

#import <FLNAdSDK/FLNAdSDKManager.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [self initAdSDK];
    
    UIViewController*  rootVC = [[ViewController alloc] init];
 
    UINavigationController* navigationVC = [[UINavigationController alloc] initWithRootViewController:rootVC];
    self.window.rootViewController = navigationVC;
    navigationVC.navigationBar.hidden = NO;

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)initAdSDK {
 
    NSString * version = [FLNAdSDKManager sdkVersion];
    NSLog(@"sdkVersion %@",version);
    
    FLNInitConfig * config = [[FLNInitConfig alloc] init];
    config.appId = kFLNDemoAppId;
    config.userId= @"";
    [[FLNAdSDKManager sharedInstance] startWithConfig:config
                                   completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"[FLNAdSDK] start success, appId=%@", [[FLNAdSDKManager sharedInstance] getAppId]);
        } else {
            NSLog(@"[FLNAdSDK] start failed: %@", error);
        }
    }];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self requestTrackingPermission];
    });
}

- (void)requestTrackingPermission {
    if (@available(iOS 14, *)) {
        if ([ATTrackingManager trackingAuthorizationStatus] == ATTrackingManagerAuthorizationStatusNotDetermined) {
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                switch (status) {
                    case ATTrackingManagerAuthorizationStatusAuthorized:
                        NSLog(@"用户已授权跟踪");
                        break;
                    case ATTrackingManagerAuthorizationStatusDenied:
                        NSLog(@"用户已拒绝跟踪");
                        break;
                    case ATTrackingManagerAuthorizationStatusNotDetermined:
                        NSLog(@"用户尚未做出选择");
                        break;
                    case ATTrackingManagerAuthorizationStatusRestricted:
                        NSLog(@"跟踪功能受限");
                        break;
                    default:
                        break;
                }
            }];
        } else {
        }
    }
}
@end
