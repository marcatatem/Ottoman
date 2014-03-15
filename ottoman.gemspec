# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ottoman/version'

Gem::Specification.new do |spec|
  spec.name          = "ottoman"
  spec.version       = Ottoman::VERSION
  spec.authors       = ["Marca Tatem"]
  spec.email         = ["marca.tatem@gmail.com"]
  spec.summary       = %q{Couchbase (> 2.0) ORM for Ruby on Rails 4}
  spec.description   = spec.summary
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activemodel", "~> 4.0.0"
  if RUBY_PLATFORM =~ /java/
    spec.add_dependency "gson", "~> 0.6.1"
    spec.add_dependency "couchbase-jruby-client", "~> 0.2.0"
  else
    spec.add_dependency "oj", "~> 2.1.4"
    spec.add_dependency "couchbase", "~> 1.3.2"
  end
  

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.6"
  spec.add_development_dependency "rails", "~> 4.0.0"
end
