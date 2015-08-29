# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'blog_es/version'

Gem::Specification.new do |spec|
  spec.name          = "blog_es"
  spec.version       = BlogEs::VERSION
  spec.authors       = ["Dario Hamidi"]
  spec.email         = ["dario@gowriteco.de"]

  spec.summary       = %q{A blog built using event sourcing}
  spec.homepage      = "https://github.com/dhamidi/ruby-blog-event-sourcing"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "json"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "pry"
end
