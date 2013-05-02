module Processor
  class EventsRegistrator
    def initialize(observers)
      @observers = observers
    end

    def register(event, *data)
      observers.each do |observer|
        observer.update event, *data
      end
    end

    private
    attr_reader :observers
  end
end
