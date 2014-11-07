# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'processor/version'
require 'processor/environment'

Gem::Specification.new do |gem|
  gem.name          = "processor"
  gem.version       = Processor::VERSION
  gem.authors       = ["Alexander Paramonov"]
  gem.email         = ["alexander.n.paramonov@gmail.com"]
  gem.summary       = %q{Universal processor for iteration over a collection with threads, logging and post processing}
  gem.description   = %q{Processor is a tool that helps to iterate over collection and perform complex actions on a result. It is extremely useful in data migrations, report generation, etc. }
  gem.homepage      = "http://github.com/AlexParamonov/processor"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec", "~> 2.6"
  gem.add_development_dependency "pry" unless Processor::RUNNING_ON_CI
  gem.add_development_dependency "pry-plus" if "ruby" == RUBY_ENGINE && false == Processor::RUNNING_ON_CI
  gem.add_development_dependency "coveralls" if Processor::RUNNING_ON_CI
end

