# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'processor/version'

Gem::Specification.new do |gem|
  gem.name          = "processor"
  gem.version       = Processor::VERSION
  gem.authors       = ["Alexander Paramonov"]
  gem.email         = ["alexander.n.paramonov@gmail.com"]
  gem.summary       = %q{Universal processor for data migration and reports generation.}
  gem.description   = %q{Processor could execute any DataProcessor you specify and log entire process.
  You may add own observers for monitoring background tasks on even send an email to business with generated report.}
  gem.homepage      = "http://github.com/AlexParamonov/processor"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec", ">= 2.6"
  gem.add_development_dependency "pry-plus"
end

