require 'spec_helper_lite'
require 'processor/event_processor'

describe Processor::EventProcessor do
  let(:processor) { stub.as_null_object }
  let(:observer) { stub.as_null_object }
  let(:observers) { [observer] }
  subject { Processor::EventProcessor.new(processor, observers) }


  it "should delegate methods to processor" do
    processor.should_receive(:method_name).and_return("result")
    subject.method_name.should eq "result"
  end

  it "should send a processor by update method" do
    observer.should_receive(:update).with(/method_name/, processor)
    subject.method_name
  end

  describe "before and after events" do
    it "should fire before_method_name event before calling processor.method_name" do
      observer.should_receive(:update).ordered do |event|
        event.should eq :before_method_name
      end
      processor.should_receive(:method_name).ordered
      subject.method_name
    end

    it "should fire after_method_name event after calling processor.method_name" do
      observer.should_receive(:update)
      processor.should_receive(:method_name, processor).ordered
      observer.should_receive(:update).ordered do |event|
        event.should eq :after_method_name
      end
      subject.method_name
    end

    it "should send result of processing to after_ event" do
      result = stub
      processor.stub(method_name: result)
      observer.should_receive(:update).with(:after_method_name, processor, result).ordered
      subject.method_name
    end
  end

  describe "broadcasting of events" do
    let(:observers) do
      3.times.map do
        stub(:observer).tap { |observer| observer.should_receive(:update).with(:test_event, processor).once }
      end
    end

    it "should broadcast events to all observers" do
      subject.register :test_event
    end
  end
end
