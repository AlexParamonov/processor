require 'logger'
require 'processor/messenger'

module Processor
  module Observer
    class NullObserver
      def initialize(options = {})
        @messenger = options.fetch :messenger, Processor::Messenger.new(:info, STDOUT, self.class.name)
      end

      def update(method_name, *args)
        send method_name, *args if respond_to? method_name
      end

      private
      attr_reader :messenger
    end
  end
end
