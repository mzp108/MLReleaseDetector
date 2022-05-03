#
# Be sure to run `pod lib lint MLReleaseDetector.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MLReleaseDetector'
  s.version          = '0.1.0'
  s.summary          = 'Detect memory leaks for your iOS projects automatically.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  MLReleaseDetector can automatically detect memory leaks including UIViewController, UIView, strongly referenced custom properties or instance variables.
                       DESC

  s.homepage         = 'https://github.com/mzp108/MLReleaseDetector'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mazhipeng' => 'mazhipeng108@gmail.com' }
  s.source           = { :git => 'https://github.com/mzp108/MLReleaseDetector.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'MLReleaseDetector/Classes/**/*'
  s.frameworks = 'UIKit'
  
end
