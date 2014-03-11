# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rbatch/version'

Gem::Specification.new do |gem|
  gem.name          = "rbatch"
  gem.version       = RBatch::VERSION
  gem.authors       = ["fetaro"]
  gem.email         = ["fetaro@gmail.com"]
  gem.description   = "Batch Script Framework"
  gem.summary       = "Batch Script Framework"
  gem.homepage      = "https://github.com/fetaro/rbatch"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version     = ">= 1.9.0"
  gem.license = 'MIT'
end
