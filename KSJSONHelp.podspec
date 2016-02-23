#
#
Pod::Spec.new do |s|
  s.name             = "KSJSONHelp"
  s.version          = "0.5.14"
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
  s.module_map = "module.modulemap"
  s.libraries = 'sqlite3'                               
end
