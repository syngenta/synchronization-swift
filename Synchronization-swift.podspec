#
# Be sure to run `pod lib lint ${POD_NAME}.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Synchronization-swift'
  s.version          = `git describe --abbrev=0 --tags`
  s.summary          = 'Synchronization library'
  s.description      = "Library witch help to create tree structure for synchronization and syncronize data"

  s.homepage         = 'https://github.com/cropio/synchronization-swift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Evgeny Kalashnikov' => 'lumyk@me.com' }
  s.source           = { :git => 'git@github.com:cropio/synchronization-swift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'

  s.source_files = 'Sources/**/*'
  s.dependency 'PromiseKit', '~> 6'
end
