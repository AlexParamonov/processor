module Processor
  class EventProcessor
    def initialize(processor, observers = [])
      @observers = observers
      @processor = processor
    end

    def register(event, *data)
      observers.each do |observer|
        observer.update event.to_sym, processor, *data
      end
    end

    def method_missing(method, *args)
      register "before_#{method}", *args
      result = processor.public_send method, *args
      register "after_#{method}", result, *args

      result
    end

    private
    attr_reader :observers, :processor
  end
end
