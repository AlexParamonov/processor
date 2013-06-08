require 'pry' unless Processor::RUNNING_ON_CI

ENV['RAILS_ENV'] ||= 'test'
require "rspec"

$: << File.expand_path('../lib', File.dirname(__FILE__))
