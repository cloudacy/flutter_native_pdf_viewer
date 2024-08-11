#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_native_pdf_viewer.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_native_pdf_viewer'
  s.version          = '5.0.1'
  s.summary          = 'A lightweight PDF viewer for iOS and Android, using platform-native elements.'
  s.description      = <<-DESC
A lightweight PDF viewer for iOS and Android, using platform-native elements.
                       DESC
  s.homepage         = 'https://github.com/cloudacy/flutter_native_pdf_viewer'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'cloudacy OG' => 'office@cloudacy.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'flutter_native_pdf_viewer_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
