#!/usr/bin/env ruby

require 'digest'
require 'open3'

root = File.expand_path('..', __dir__)
version = File.read(File.join(root, 'VERSION')).strip
zip_path = File.join(root, 'Markdown.xcframework.zip')
abort "Missing #{zip_path}" unless File.file?(zip_path)

sha256 = Digest::SHA256.file(zip_path).hexdigest
checksum, error, status = Open3.capture3('swift', 'package', 'compute-checksum', zip_path)
abort "Failed to compute SwiftPM checksum: #{error}" unless status.success?
checksum = checksum.strip

package_path = File.join(root, 'Package.swift')
package = File.read(package_path)
abort 'Package.swift release URL was not updated' unless package.sub!(/swift-markdown-[^\/]+\/Markdown\.xcframework\.zip/, "swift-markdown-#{version}/Markdown.xcframework.zip")
abort 'Package.swift checksum was not updated' unless package.sub!(/checksum: "[0-9a-f]{64}"/, "checksum: \"#{checksum}\"")
File.write(package_path, package)

podspec_path = File.join(root, 'SwiftMarkdownBinary.podspec')
podspec = File.read(podspec_path)
abort 'Podspec version was not updated' unless podspec.sub!(/s\.version = '[^']+'/, "s.version = '#{version}'")
abort 'Podspec SHA-256 was not updated' unless podspec.sub!(/:sha256 => '[0-9a-f]{64}'/, ":sha256 => '#{sha256}'")
File.write(podspec_path, podspec)

puts "version=#{version}"
puts "checksum=#{checksum}"
puts "sha256=#{sha256}"
