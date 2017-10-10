Pod::Spec.new do |s|
  s.name         = "ProgressiveAlertView"
  s.version      = "0.0.2"
  s.summary      = "ProgressiveAlertView is simply a progressive alert view for iOS, liked universal clipboard."
  s.license      = { :type => 'MIT' }
  s.screenshots  = "http://7xilk1.com1.z0.glb.clouddn.com/progressiveAlertView.jpg"
  s.author       = { "hechen" => "hechen4815463@gmail.com" }
  s.homepage     = "https://github.com/hechen/ProgressiveAlertView"
  s.social_media_url   = "https://twitter.com/OgreMergO"
  s.source       = { :git => "https://github.com/hechen/ProgressiveAlertView.git", :tag => "#{s.version}" }
  s.frameworks  = "UIKit"
  s.requires_arc = true;

  s.source_files  = [
    "Classes/*.{h,m}",
    "Classes/**/*.{h,m}",
  ]
  s.public_header_files = [
    "Classes/*.h"
  ]
  s.platform = :ios
  s.ios.deployment_target = '9.0'

end
