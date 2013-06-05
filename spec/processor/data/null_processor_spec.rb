require 'spec_helper_lite'
require 'processor/data/null_processor'
require 'processor/runner'
require 'processor/process_runner/successive'

describe Processor::Data::NullProcessor do
  it "should have zero records" do
    subject.records.should be_empty
    subject.total_records.should be_zero
  end

  describe "required methods" do
    it "should respond to all happy path methods" do
      collector = Class.new do
        def records; [1] end
        def method_missing(method, *)
          @methods = @methods.to_a << method
        end
        attr_reader :methods
      end.new

      runner = Processor::Runner.new collector
      runner.run Processor::ProcessRunner::Successive.new
      collector.methods.each do |method|
        subject.should respond_to method
      end
    end

    %w[record_error error total_records].each do |method|
      it { subject.should respond_to method }
    end
  end
end

