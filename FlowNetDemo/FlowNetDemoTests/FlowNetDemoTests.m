//
//  FlowNetDemoTests.m
//  FlowNetDemoTests
//
//  说明：FLNAdSDK.framework 当前为真机 slice 时，模拟器下无法对 SDK 做静态链接。
//  此处校验宿主 App 是否已嵌入 FLNAdSDK；SDK 类方法联调请在真机运行 Demo。
//

#import <XCTest/XCTest.h>

@interface FlowNetDemoTests : XCTestCase
@end

@implementation FlowNetDemoTests

- (void)testHostAppEmbedsFLNAdSDKFramework {
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    NSString *appPath = [[testBundle.bundlePath stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
    NSString *frameworkPath = [appPath stringByAppendingPathComponent:@"Frameworks/FLNAdSDK.framework"];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:frameworkPath],
                  @"宿主应通过 Embed Frameworks 携带 FLNAdSDK.framework（路径：%@）",
                  frameworkPath);
}

@end
