Pod::Spec.new do |s|

  s.name         = "DDComponent"
  s.version      = "0.0.2"
  s.summary      = "Make a collection controller to several component"

  s.description  = <<-DESC
Make a collection controller to several component. Make the controller smaller.
                   DESC

  s.homepage     = "https://github.com/djs66256/DDComponent"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  s.author             = { "Daniel" => "djs66256@163.com" }
  # Or just: s.author    = "Daniel"
  # s.authors            = { "Daniel" => "djs66256@163.com" }
  # s.social_media_url   = "http://twitter.com/Daniel"

  # s.platform     = :ios
  s.platform     = :ios, "8.0"

  #  When using multiple platforms
  s.ios.deployment_target = "8.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/djs66256/DDComponent.git", :tag => "0.0.2" }
  s.source_files  = "Class", "Class/**/*.{h,m,swift}"
  s.exclude_files = "Class/Exclude"

  # s.public_header_files = "Classes/**/*.h"

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"

  s.framework  = "UIKit"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"
  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
