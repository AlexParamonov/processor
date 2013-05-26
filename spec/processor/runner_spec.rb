require 'spec_helper_lite'
require 'processor/runner'

describe Processor::Runner do
  let(:runner) { Processor::Runner.new(processor, events_registrator) }
  let(:processor) { stub.as_null_object }
  let(:events_registrator) { stub.as_null_object }
  let(:no_process_runner) { Proc.new{} }
  let(:event) { mock.tap {|m| m.should_receive(:trigger)} }

  describe "start processing" do
    it "should start processing" do
      processor.should_receive(:start)
      runner.run no_process_runner
    end

    it "should register a processing_started event" do
      register_processing_event :processing_started
      runner.run no_process_runner
    end
  end

  describe "finish processing" do
    it "should finish processing" do
      processor.should_receive(:finish)
      runner.run no_process_runner
    end

    it "should register a processing_finished event" do
      register_processing_event :processing_finished
      runner.run no_process_runner
    end

    it "should finalize processing" do
      processor.should_receive(:finalize)
      runner.run no_process_runner
    end

    it "should register a processing_finalized event" do
      register_processing_event :processing_finalized
      runner.run no_process_runner
    end
  end

  describe "processing error" do
    describe "processing records raised" do
      let(:process_runner) { Proc.new { raise RuntimeError } }

      it "should break processing and rerise" do
        expect do
          runner.run process_runner
        end.to raise_error(RuntimeError)
      end

      it "should send error to processor" do
        processor.should_receive(:error)
        runner.run process_runner rescue nil
      end

      it "should register a processing_error event" do
        register_processing_error_event
        runner.run process_runner rescue nil
      end

      it "should finalize processing" do
        processor.should_receive(:finalize)
        runner.run process_runner rescue nil
      end

      it "should register a processing_finalized event" do
        register_processing_event :processing_finalized
        runner.run process_runner rescue nil
      end
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

  private
  def register_processing_error_event
    # Check that processing_error event was register
    events_registrator.should_receive(:register) do |triggered_event_name, current_processor, exception|
      next if triggered_event_name != :processing_error
      triggered_event_name.should eq :processing_error
      current_processor.should eq processor
      exception.should be_a RuntimeError
      event.trigger
    end.any_number_of_times

    event
  end

  def register_processing_event(event_name)
    events_registrator.should_receive(:register) do |triggered_event_name, current_processor, exception|
      next if triggered_event_name != event_name
      triggered_event_name.should eq event_name
      current_processor.should eq processor
      event.trigger
    end.any_number_of_times

    event
  end
end

