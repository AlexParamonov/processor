module Processor
  module Observer
    class NullObserver
      def method_missing(*); end
    end
  end
end
