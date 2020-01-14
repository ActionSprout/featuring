lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'featuring/version'

Gem::Specification.new do |spec|
  spec.name          = "featuring"
  spec.version       = Featuring::VERSION
  spec.authors       = ["Bryan Powell"]
  spec.email         = ["bryan@bryanp.org"]

  spec.summary       = %q{Attach feature flags to your objects.}
  spec.description   = %q{Easily define feature flags and attach them to your objects. Supports persistence via ActiveRecord.}
  spec.homepage      = "https://github.com/ActionSprout/featuring"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.4.6'

  root_files = %w[
    featuring.gemspec
    README.md
    LICENSE.txt
    CHANGELOG.md
  ]

  lib_files = Dir['lib/**/**'].to_a

  spec.files = root_files + lib_files

  spec.require_paths = ["lib"]
end
