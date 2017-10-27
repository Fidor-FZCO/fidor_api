# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fidor_api"
  spec.version       = ENV['VERSION'] || '0.0.0'
  spec.authors       = ["Klaus Meyer"]
  spec.email         = ["spam@klaus-meyer.net"]

  spec.summary       = "Simple ruby client for the Fidor Bank API"
  spec.description   = "Connect to the Fidor Bank API"
  spec.homepage      = "https://github.com/klausmeyer/fidor_api"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 0.8"
  spec.add_dependency "activesupport", ">= 4.2", "< 5.2"
  spec.add_dependency "activemodel", ">= 4.2", "< 5.2"
  spec.add_dependency "model_attribute", "~> 2.1"
end
