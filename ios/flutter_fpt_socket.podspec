#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_fpt_socket.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_fpt_socket'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'ScClient'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  
  s.preserve_paths = 'ScClient.framework'
  s.xcconfig = {
                 'FRAMEWORK_SEARCH_PATHS' => ['${PODS_TARGET_SRCROOT}/Libraries'],
                 'HEADER_SEARCH_PATHS' => ["${PODS_ROOT}/../.symlinks/plugins/plugin_name/ios/Libraries/ScClient.framework/Headers"]
                }
  s.vendored_frameworks = 'ScClient.framework'
  
end
