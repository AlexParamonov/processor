require 'spec_helper_lite'
require 'processor/events_registrator'

describe Processor::EventsRegistrator do
  subject { Processor::EventsRegistrator }

  it "should build observers using processor" do
    processor = stub
    observers = 3.times.map do
      stub(:observer).tap { |observer| observer.should_receive(:call).with(processor).once }
    end

    subject.new(processor, observers)
  end

  it "should broadcast events to all observers" do
    observers = 3.times.map do
      observer = stub(:observer)
      observer.should_receive(:update).with(:test_event).once
      -> processor { observer }
    end

    events = subject.new(stub(:processor), observers)
    events.register :test_event
  end
end
