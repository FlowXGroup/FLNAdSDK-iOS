# FLNAdSDK

iOS 广告 SDK（XCFramework 二进制分发）。

**版本：** 6.2.1.1  
**最低系统：** iOS 13.0

## 安装（CocoaPods）

```ruby
pod 'FLNAdSDK', :git => 'https://github.com/FlowXGroup/FLNAdSDK-iOS.git', :tag => '6.2.1.1'
```

```bash
pod install
```

## Demo

仓库内附带 `FlowNetDemo`。克隆本仓后：

```bash
cd FlowNetDemo
pod install
open FlowNetDemo.xcworkspace
```

Demo 通过 CocoaPods 拉取 `FLNAdSDK`（与上方相同的 git + tag），不链接本地 xcframework。

## 工程要求

- 增加 `-ObjC`（通过 CocoaPods 接入时一般已自动注入）
- 建议链接：AdSupport、AVFoundation、CoreAudio、CoreServices；iOS 14+ 按需使用 AppTrackingTransparency
- 静态 XCFramework，一般无需 Embed

## 接入说明

详见同目录《ADN-SDK 6.2.1.1 集成说明（iOS）.pdf》。

## 合规与隐私

接入前请阅读并完成合规与隐私披露：

- [SDK 合规说明](https://adssp.innoads.cn/doc/protocol_doc/02sdk_developer_usage_compliance_specifications_20260306MK.html)
- [App 合规说明](https://adssp.innoads.cn/doc/protocol_doc/01developer_compliance_guidelines20260309MK.html)
- [App Store 隐私信息说明](https://adssp.innoads.cn/doc/pages/appst1/)
- [ADN SDK 隐私政策](https://adssp.innoads.cn/doc/protocol_doc/03innoad_sdk_sprivacy_policy_20260309MK.html)

更完整说明见集成文档。

## License

Copyright © FlowXGroup. All rights reserved.
