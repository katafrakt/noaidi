# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'noaidi/version'

Gem::Specification.new do |spec|
  spec.name          = "noaidi"
  spec.version       = Noaidi::VERSION
  spec.authors       = ["Paweł Świątkowski"]
  spec.email         = ["inquebrantable@gmail.com"]

  spec.summary       = %q{Functional shamanism for Ruby}
  spec.description   = %q{Functional shamanism for Ruby}
  spec.homepage      = "https://github.com/katafrakt/noaidi"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|benchmark)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
