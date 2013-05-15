require 'spec_helper_lite'
require 'processor/runner'

describe Processor::Runner do
  let(:runner) { Processor::Runner.new(processor, events_registrator) }
  let(:processor) { stub }
  let(:events_registrator) { stub.as_null_object }
  let(:no_process_runner) { Proc.new{} }

  describe "exception handling" do
    describe "processing records raised" do
      it "should break processing and rerise" do
        expect do
          runner.run Proc.new { raise RuntimeError }
        end.to raise_error(RuntimeError)
      end

      it "should register a processing_error event" do
        register_processing_error_event mock.tap { |event| event.should_receive :trigger }
        runner.run Proc.new { raise RuntimeError } rescue nil
      end
    end

    private
    def register_processing_error_event(event)
      # Check that processing_error event was register
      events_registrator.should_receive(:register) do |event_name, current_processor, exception|
        next if event_name != :processing_error
        event_name.should eq :processing_error
        current_processor.should eq processor
        exception.should be_a RuntimeError
        event.trigger
      end.any_number_of_times
    end
  end

  describe "recursion" do
    before(:each) do
      processor.stub(total_records: 100)
      processor.stub(records: 1..Float::INFINITY)
    end

    it "should not fall into recursion" do
      processor.should_receive(:process).at_most(1000).times

      expect do
        process_runner = Proc.new do |data_processor, events, recursion_preventer|
          data_processor.records.each do |record|
            recursion_preventer.call
            data_processor.process record
          end
        end
        runner.run process_runner
      end.to raise_error(Exception, /Processing fall into recursion/)
    end

    it "should have 10% + 10 rerurns window" do
      processor.should_receive(:process).exactly(120).times

      expect do
        process_runner = Proc.new do |data_processor, events, recursion_preventer|
          data_processor.records.each do |record|
            recursion_preventer.call
            data_processor.process record
          end
        end
        runner.run process_runner
      end.to raise_error(Exception, /Processing fall into recursion/)
    end
  end
end

