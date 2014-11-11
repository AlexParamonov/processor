require 'logger'
require 'processor/messenger'

module Processor
  module Observer
    class NullObserver
      attr_reader :processor

      def initialize(options = {})
        @messenger = options.fetch :messenger, Processor::Messenger.new(:info, STDERR, self.class.name)
        @processor = options.fetch :processor, nil
      end

      def update(method_name, processor = nil, *args)
        @processor ||= processor
        send method_name, *args if respond_to? method_name
      end

      private
      attr_reader :messenger
    end
  end
end
