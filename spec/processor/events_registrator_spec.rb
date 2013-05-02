require 'spec_helper_lite'
require 'processor/events_registrator'

describe Processor::EventsRegistrator do
  subject { Processor::EventsRegistrator }

  it "should broadcast events to all observers" do
    observers = 3.times.map do
      stub(:observer).tap { |observer| observer.should_receive(:update).with(:test_event).once }
    end

    events = subject.new(observers)
    events.register :test_event
  end
end
