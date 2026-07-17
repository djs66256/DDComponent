#
# Be sure to run `pod lib lint DDComponent.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DDComponent'
  s.version          = '0.6.0'
  s.summary          = 'Make a collection controller to several component'

  s.description      = <<-DESC
Make a collection controller to several component. Make the controller smaller.
                       DESC

  s.homepage         = 'https://github.com/djs66256/DDComponent'
  s.license          = 'MIT'
  s.author           = { 'Daniel' => 'djs66256@163.com' }
  s.source           = { :git => 'https://github.com/djs66256/DDComponent.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

  s.source_files = 'DDComponent/Classes/**/*'

  s.subspec 'Macros' do |ss|
    ss.source_files = 'DDComponentMacros/Sources/DDComponentMacrosClient/**/*.swift'
    ss.dependency 'SwiftSyntax/Macros', '~> 600.0'
    ss.pod_target_xcconfig = {
      'OTHER_SWIFT_FLAGS' => '-load-plugin-executable DDComponentMacros#DDComponentMacros'
    }
  end

  s.resource_bundles = {
    'DDComponent' => ['DDComponent/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
end
