module Processor
  class EventsRegistrator
    def initialize(processor, observer_sources)
      @observers = observer_sources.map do |source|
        source.call(processor)
      end
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
