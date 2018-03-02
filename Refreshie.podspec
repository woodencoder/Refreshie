Pod::Spec.new do |s|
  s.name             = 'Refreshie'
  s.version          = '0.2.1'
  s.summary          = 'Android-like refresh indicator for iOS'
 
  s.description      = <<-DESC
Refresher provides an easy-to-use pull-to-refresh indicator which also happens to be fully customizable!
                       DESC
 
  s.homepage         = 'https://github.com/woodencoder/Refreshie'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Vladislav Klimenko' => '<woodencoder@gmail.com>' }
  s.source           = { :git => 'https://github.com/woodencoder/Refreshie.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '10.0'
  s.source_files = 'Refreshie/Source/*.swift'

  s.frameworks = 'UIKit'

  s.swift_version = '4.0'
 
end