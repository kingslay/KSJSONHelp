#
#
Pod::Spec.new do |s|
  s.name             = "KSJSONHelp"
  s.version          = "2.0.0"
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
  s.default_subspec = "Core"
  s.module_name      = 'KSJSONHelp'
  s.subspec "Core" do |ss|
    ss.source_files  = 'Core/Source/**/*.swift'
  end
  s.subspec "SQL" do |ss|
    ss.source_files  = "SQL/Source/**/*.swift"
    ss.dependency "KSJSONHelp/Core"
  end
  # s.subspec "SQLite" do |ss|
  #   ss.source_files  = "SQLite/Source/**/*.swift"
  #   ss.dependency "KSJSONHelp/SQL"
  #   ss.preserve_paths = 'SQLite/CocoaPods/**/*'
  #   ss.pod_target_xcconfig = {
  #     'SWIFT_INCLUDE_PATHS[sdk=macosx*]'           => '$(SRCROOT)/KSJSONHelp/SQLite/CocoaPods/macosx',
  #     'SWIFT_INCLUDE_PATHS[sdk=iphoneos*]'         => '$(SRCROOT)/KSJSONHelp/SQLite/CocoaPods/iphoneos',
  #     'SWIFT_INCLUDE_PATHS[sdk=iphonesimulator*]'  => '$(SRCROOT)/KSJSONHelp/SQLite/CocoaPods/iphonesimulator',
  #     'SWIFT_INCLUDE_PATHS[sdk=appletvos*]'        => '$(SRCROOT)/KSJSONHelp/SQLite/CocoaPods/appletvos',
  #     'SWIFT_INCLUDE_PATHS[sdk=appletvsimulator*]' => '$(SRCROOT)/KSJSONHelp/SQLite/CocoaPods/appletvsimulator',
  #     'SWIFT_INCLUDE_PATHS[sdk=watchos*]'          => '$(SRCROOT)/KSJSONHelp/SQLite/CocoaPods/watchos',
  #     'SWIFT_INCLUDE_PATHS[sdk=watchsimulator*]'   => '$(SRCROOT)/KSJSONHelp/SQLite/CocoaPods/watchsimulator'
  #   }
  #   ss.libraries = 'sqlite3'
  # end
  s.subspec 'SQLiteStandalone' do |ss|
    ss.source_files  = "SQLite/Source/**/*.swift"
    ss.dependency "KSJSONHelp/SQL"
    ss.xcconfig = { 'OTHER_SWIFT_FLAGS' => '$(inherited) -DSQLITE_SWIFT_STANDALONE' }
    ss.dependency 'sqlite3'
end
end
