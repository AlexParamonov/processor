require 'spec_helper_lite'
require 'processor/runner'

describe Processor::Runner do
  let(:runner) { Processor::Runner.new(processor) }
  let(:processor) { stub.as_null_object }
  let(:no_process_runner) { Proc.new{} }

  it "should start processing" do
    processor.should_receive(:start)
    runner.run no_process_runner
  end

  it "should finish processing" do
    processor.should_receive(:finish)
    runner.run no_process_runner
  end

  it "should finalize processing" do
    processor.should_receive(:finalize)
    runner.run no_process_runner
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

      it "should finalize processing" do
        processor.should_receive(:finalize)
        runner.run process_runner rescue nil
      end
    end
  end
end

