Pod::Spec.new do |s|
  s.name             = "KSJSONHelp"
  s.version          = "0.5.4"
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
  s.social_media_url = "http://weibo.com/p/1005051702286027/home?from=page_100505&mod=TAB#place"
  s.module_name      = 'KSJSONHelp'
  s.ios.deployment_target = "8.0"
  s.tvos.deployment_target = "9.0"
  s.osx.deployment_target = "10.9"

  s.module_map = "Source/SQLite/module.modulemap"
  s.libraries = 'sqlite3'
  s.source_files = 'Source/**/*.{c,h,m,swift}'
end
