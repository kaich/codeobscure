# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'codeobscure/version'

Gem::Specification.new do |spec|
  spec.name          = "codeobscure"
  spec.version       = Codeobscure::VERSION
  spec.authors       = ["kaich"]
  spec.email         = ["chengkai1853@163.com"]

  spec.summary       = %q{Code Obscure For Xcode Project}
  spec.description   = %q{Code Obscure Tool.You can use it simplely}
  spec.homepage      = "https://github.com/kaich/codeobscure"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = Dir["lib/**/*"] + %w{ bin/codeobscure} + %w{ filtSymbols} + %w{ filtSymbols_standard}
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = Dir["test/**/*.rb"]
  spec.require_paths = ["lib","bin"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_runtime_dependency 'colorize' , '~> 0.7'
  spec.add_runtime_dependency "xcodeproj", "~> 1.5"
  spec.add_runtime_dependency "sqlite3", "~> 1.3"
end
