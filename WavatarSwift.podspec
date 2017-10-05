#
# Be sure to run `pod lib lint WavatarSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WavatarSwift'
  s.version          = '1.0.0'
  s.summary          = 'WavatarSwift is a swift implementation of "Wavatar", identical to wavatars from gravatar.com.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
WavatarSwift is a swift implementation of "Wavatar". They are produced localy, so you don't need any internet to make them.
                       DESC

  s.homepage         = 'https://github.com/serebryakov-av/WavatarSwift'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Anton Serebryakov' => 'serebryakov.anton@gmail.com' }
  s.source           = { :git => 'https://github.com/serebryakov-av/WavatarSwift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'WavatarSwift/Classes/**/*'
  
  s.resource_bundles = {
    'WavatarSwift' => ['WavatarSwift/Assets/Parts.bundle']
  }

  s.frameworks = 'UIKit'
end
