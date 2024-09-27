#
# Be sure to run `pod lib lint LCombineExtension.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LCombineExtension'
  s.version          = '0.3.0'
  s.summary          = 'A short description of LCombineExtension.'
  
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
  DESC
  
  s.homepage         = 'https://gitlab-ha.immotors.com/capp/iOS/l-combine-ext'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dongzb01' => 'dzb8818082@163.com' }
  s.source           = { :git => 'https://gitlab-ha.immotors.com/capp/iOS/l-combine-ext.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.requires_arc     = true
  s.ios.deployment_target = '13.0'
  s.frameworks = 'Combine', 'Foundation', 'UIKit'
  s.source_files = 'LCombineExtension/Classes/**/*.{swift,h,m}'
  
end
