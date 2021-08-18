Pod::Spec.new do |s|
  s.name             = 'WMSegmentControl'
  s.version          = '3.0'
  s.summary          = 'Custom segment control for iOS'
 
  s.description      = <<-DESC
Custom segment control for iOS. Create a stylish segment control for you app.
                       DESC
 
  s.homepage         = 'https://github.com/malekwasim/WMSegmentControl'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Wasim' => 'Wasim.malek.009@gmail.com' }
  s.source           = { :git => 'https://github.com/malekwasim/WMSegmentControl.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '12.0'
  s.source_files = 'WMSegmentControl/Source/*.swift'
  s.swift_version = "5.0"
 
end