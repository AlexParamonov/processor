require 'spec_helper_lite'
require 'processor/thread_runner'

processor = Class.new do
  def done?(records)
    records.count < 1
  end

  def total_records
    10
  end
end.new

describe Processor::ThreadRunner do
  let(:runner) { Processor::ThreadRunner.new }
  let(:events_registrator) { stub.as_null_object }
  before(:each) do
    runner.stub(events_registrator: events_registrator)
  end

  it "should fetch records from processor till it'll be done" do
    processor.stub(:done?).and_return(false, false, true)
    processor.should_receive(:fetch_records).exactly(3).times.and_return([])
    runner.run processor
  end

  it "should send each found record to processor" do
    records = [mock(:one), mock(:two), mock(:three)]
    records.each { |record| processor.should_receive(:process).with(record) }

    processor.stub(:fetch_records).and_return(records, [])
    runner.run processor
  end

  describe "exception handling" do
    let(:record) { stub }
    before(:each) do
      processor.stub(:fetch_records).and_return([record], [record], [])
    end

    describe "processing a record raised RuntimeError" do
      it "should continue processing" do
        processor.should_receive(:process).twice.and_raise(RuntimeError)
        expect { runner.run processor }.to_not raise_error
      end

      it "should register a record_processing_error event" do
        event_registered = false
        events_registrator.should_receive(:register) do |event_name, failed_record, exception|
          next if event_name != :record_processing_error
          event_name.should eq :record_processing_error
          failed_record.should eq record
          exception.should be_a RuntimeError
          event_registered = true
        end.any_number_of_times

        processor.stub(:process).and_raise(RuntimeError)

        begin
          runner.run processor
        rescue Exception; end
        event_registered.should be_true
      end
    end

    describe "processing a record raised Exception" do
      it "should break processing and rerise Exception" do
        custom_exception = Class.new Exception
        processor.should_receive(:process).once.and_raise(custom_exception)
        expect { runner.run processor }.to raise_error(custom_exception)
      end

      it "should register a processing_error event" do
        event_registered = false
        events_registrator.should_receive(:register) do |event_name, exception|
          next if event_name != :processing_error
          event_name.should eq :processing_error
          exception.should be_a Exception
          event_registered = true
        end.any_number_of_times

        processor.stub(:process).and_raise(Exception)

        begin
          runner.run processor
        rescue Exception; end
        event_registered.should be_true
      end
    end

    describe "fetching records raised" do
      it "should break processing and rerise Exception" do
        custom_exception = Class.new RuntimeError
        processor.stub(:fetch_records).and_raise(custom_exception)
        processor.should_not_receive(:process)
        expect { runner.run processor }.to raise_error(custom_exception)
      end

      it "should register a processing_error" do
        event_registered = false
        events_registrator.should_receive(:register) do |event_name, exception|
          next if event_name != :processing_error
          event_name.should eq :processing_error
          exception.should be_a RuntimeError
          event_registered = true
        end.any_number_of_times

        processor.stub(:fetch_records).and_raise(RuntimeError)

        begin
          runner.run processor
        rescue Exception; end
        event_registered.should be_true
      end
    end
  end

  describe "recursion" do
    it "should not allow infinit recursion" do
      processor.stub(:fetch_records).and_return([:one, :two])
      processor.should_receive(:process).at_most(100).times
      expect { runner.run processor }.to raise_error(Exception, /Processing fall into recursion/)
    end

    it "should have 10% + 10 rerurns window" do
      processor.stub(total_records: 100)
      processor.stub(:fetch_records).and_return([:one, :two])
      processor.should_receive(:process).exactly(120).times
      expect { runner.run processor }.to raise_error(Exception, /Processing fall into recursion/)
    end
  end
end

