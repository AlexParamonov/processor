require 'spec_helper_lite'
require_relative 'specs'
require 'processor/process_runner/threads'

describe Processor::ProcessRunner::Threads do
  let(:no_recursion_preventer) { Proc.new{} }
  let(:no_events) { stub.as_null_object }
  it_behaves_like "a records processor"

  it "should run in defined number of threads" do
    process_runner = Processor::ProcessRunner::Threads.new 5

    process_runner.should_receive(:join_threads).once.ordered.and_call_original
    process_runner.should_receive(:new_thread).exactly(5).times.ordered.and_call_original
    process_runner.should_receive(:join_threads).once.ordered.and_call_original
    process_runner.should_receive(:new_thread).exactly(4).times.ordered.and_call_original
    process_runner.should_receive(:join_threads).once.ordered.and_call_original

    processor = mock
    processor.stub(records: 1..9)
    processor.should_receive(:process).exactly(9).times

    process_runner.call(processor, no_events, no_recursion_preventer)
  end
end
