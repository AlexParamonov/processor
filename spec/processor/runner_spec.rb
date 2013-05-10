require 'spec_helper_lite'
require 'processor/successive_runner'

describe Processor::Runner do
  let(:runner) { Processor::Runner.new(processor) }
  let(:processor) { stub }

  it "should fetch records from processor till it'll be done" do
    processor.stub(:done?).and_return(false, false, true)
    processor.should_receive(:fetch_records).exactly(3).times.and_return([])
    runner.run
  end

  describe "exception handling" do
    let(:record) { stub }
    before(:each) do
      processor.stub(:fetch_records).and_return([record], [record], [])
    end

    describe "processing records raised" do
      before(:each) do
        processor.stub(done?: false)
      end

      it "should break processing and rerise" do
        expect do
          runner.run { raise RuntimeError }
        end.to raise_error(RuntimeError)
      end

      it "should register a processing_error event" do
        register_processing_error_event mock.tap { |event| event.should_receive :trigger }
        runner.run { raise RuntimeError } rescue nil
      end
    end

    describe "fetching records raised" do
      it "should break processing and rerise Exception" do
        processor.stub(:fetch_records).and_raise(RuntimeError)
        processor.should_not_receive(:process)
        expect { runner.run }.to raise_error(RuntimeError)
      end

      it "should register a processing_error" do
        register_processing_error_event mock.tap { |event| event.should_receive :trigger }

        processor.stub(:fetch_records).and_raise(RuntimeError)
        runner.run rescue nil
      end
    end

    private
    def register_processing_error_event(event)
      # Check that processing_error event was register
      mock.tap do |events_registrator|
        events_registrator.should_receive(:register) do |event_name, current_processor, exception|
          next if event_name != :processing_error
          event_name.should eq :processing_error
          current_processor.should eq processor
          exception.should be_a RuntimeError
          event.trigger
        end.any_number_of_times
        runner.stub(events: events_registrator)
      end
    end
  end

  describe "recursion" do
    before(:each) do
      processor.stub(done?: false)
      processor.stub(total_records: 100)
      processor.stub(fetch_records: 1..3)
    end

    it "should not allow infinit recursion" do
      processor.should_receive(:process).at_most(1000).times

      expect do
        runner.run do |records, events_registrator, recursion_preventer|
          records.each do |record|
            recursion_preventer.call
            processor.process record
          end
        end
      end.to raise_error(Exception, /Processing fall into recursion/)
    end

    it "should have 10% + 10 rerurns window" do
      processor.should_receive(:process).exactly(120).times

      expect do
        runner.run do |records, events_registrator, recursion_preventer|
          records.each do |record|
            recursion_preventer.call
            processor.process record
          end
        end
      end.to raise_error(Exception, /Processing fall into recursion/)
    end
  end
end

