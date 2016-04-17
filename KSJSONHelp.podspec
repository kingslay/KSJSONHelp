#
#
Pod::Spec.new do |s|
  s.name             = "KSJSONHelp"
  s.version          = "0.6.4"
  s.summary          = "swift's MJExtension"

  s.description      = <<-DESC
    KSJSONHelp is a lightweight and pure Swift implemented library for
    conversion between JSON and model
    Simple ActiveRecord implementation for working with your database
                       DESC

  s.homepage         = "https://github.com/kingslay/KSJSONHelp"
  s.license          = 'MIT'
  s.author           = { "kingslay" => "kingslay@icloud.com" }
  s.source           = { :git => "https://github.com/kingslay/KSJSONHelp.git", :tag => s.version.to_s }
  s.ios.deployment_target = "8.0"
  s.tvos.deployment_target = "9.0"
  s.osx.deployment_target = "10.9"
  s.source_files = 'Source/**/*.{c,h,m,swift}'
  s.module_name      = 'KSJSONHelp'
  s.preserve_paths = 'CocoaPods/**/*'
  s.pod_target_xcconfig = {
    'SWIFT_INCLUDE_PATHS[sdk=macosx*]'           => '$(SRCROOT)/KSJSONHelp/CocoaPods/macosx',
    'SWIFT_INCLUDE_PATHS[sdk=iphoneos*]'         => '$(SRCROOT)/KSJSONHelp/CocoaPods/iphoneos',
    'SWIFT_INCLUDE_PATHS[sdk=iphonesimulator*]'  => '$(SRCROOT)/KSJSONHelp/CocoaPods/iphonesimulator',
    'SWIFT_INCLUDE_PATHS[sdk=appletvos*]'        => '$(SRCROOT)/KSJSONHelp/CocoaPods/appletvos',
    'SWIFT_INCLUDE_PATHS[sdk=appletvsimulator*]' => '$(SRCROOT)/KSJSONHelp/CocoaPods/appletvsimulator',
    'SWIFT_INCLUDE_PATHS[sdk=watchos*]'          => '$(SRCROOT)/KSJSONHelp/CocoaPods/watchos',
    'SWIFT_INCLUDE_PATHS[sdk=watchsimulator*]'   => '$(SRCROOT)/KSJSONHelp/CocoaPods/watchsimulator'
  }
  s.libraries = 'sqlite3'                               
end
