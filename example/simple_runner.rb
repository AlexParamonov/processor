require 'processor/thread_runner'
require 'processor/observer/logger'

module Processor
  module Example
    class SimpleRunner < ThreadRunner
      def initialize
        super Processor::Observer::Logger.new
      end
    end
  end
end
