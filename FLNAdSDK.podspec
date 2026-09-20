Pod::Spec.new do |s|
  s.name             = 'FLNAdSDK'
  s.version          = '6.2.0.19'
  s.summary          = 'FLNAdSDK iOS advertising SDK'
  s.description      = 'FLNAdSDK iOS advertising SDK, distributed as a binary XCFramework.'
  s.homepage         = 'https://github.com/FlowXGroup/FLNAdSDK-iOS'
  s.license          = { :type => 'Copyright', :text => 'Copyright © FlowXGroup. All rights reserved.' }
  s.author           = 'FlowXGroup'
  s.source           = { :git => 'https://github.com/FlowXGroup/FLNAdSDK-iOS.git', :tag => s.version.to_s }

  s.platform         = :ios, '13.0'
  s.requires_arc     = true
  s.static_framework = true

  s.vendored_frameworks = 'FLNAdSDK.xcframework'

  s.frameworks = 'UIKit', 'Foundation', 'AdSupport', 'AVFoundation', 'CoreAudio', 'CoreServices'
  s.weak_frameworks = 'AppTrackingTransparency'

  s.pod_target_xcconfig = {
    'OTHER_LDFLAGS' => '-ObjC'
  }
  s.user_target_xcconfig = {
    'OTHER_LDFLAGS' => '-ObjC'
  }
end
