Pod::Spec.new do |s|
  s.name = 'SwiftMarkdownBinary'
  s.version = '0.8.0-patch.1'
  s.summary = 'A patched static XCFramework distribution of swift-markdown'
  s.description = <<-DESC
    A binary distribution of swift-markdown 0.8.0 that requires double tildes
    for strikethrough. The Markdown module is packaged as a static XCFramework.
  DESC
  s.homepage = 'https://github.com/FeliksLv01/swift-markdown-xcframework'
  s.license = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.author = { 'FeliksLv01' => 'felikslv@163.com' }
  s.source = {
    :http => "https://github.com/FeliksLv01/swift-markdown-xcframework/releases/download/swift-markdown-#{s.version}/Markdown.xcframework.zip",
    :sha256 => '6cced53923415a6a73acbae503bb521021db7174fd5b5c102e2e26a58bd891bb'
  }
  s.ios.deployment_target = '15.0'
  s.swift_versions = ['5.9', '6.0']
  s.vendored_frameworks = 'Markdown.xcframework'
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
