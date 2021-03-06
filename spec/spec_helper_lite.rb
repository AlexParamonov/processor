require "processor"
if Processor::RUNNING_ON_CI
  require 'coveralls'
  Coveralls.wear!
else
  require 'pry'
end

ENV['RAILS_ENV'] ||= 'test'
require 'rspec'

$: << File.expand_path('../lib', File.dirname(__FILE__))
