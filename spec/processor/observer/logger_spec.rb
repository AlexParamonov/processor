require 'spec_helper_lite'
require 'processor/observer/logger'

describe Processor::Observer::Logger do
  subject { Processor::Observer::Logger.new logger, messenger: messenger, messages: messages, processor: processor }

  let(:processor) { stub.as_null_object }
  let(:messages) { stub.as_null_object }
  let(:messenger) { ::Logger.new("/dev/null") }
  let(:logger) { ::Logger.new("/dev/null") }

  describe "logger" do
    describe "as proc" do
      let(:external_logger) { stub }
      let(:logger) { -> name { external_logger } }

      it "should be assepted" do
        subject.logger.should eq external_logger
      end
    end

    describe "as object" do
      let(:external_logger) { stub }
      let(:logger) { external_logger }

      it "should be assepted" do
        subject.logger.should eq external_logger
      end
    end

    describe "nil" do
      let(:logger) { nil }

      it "uses ruby Logger" do
        ruby_logger = stub.as_null_object
        observer = subject
        ::Logger.should_receive(:new).and_return(ruby_logger)
        observer.logger.should eq ruby_logger
      end
    end
  end

  describe "messages" do
    describe "as object" do
      let(:messages) { stub }

      it "should be assepted" do
        messages.should_receive(:initialized)
        subject.after_start nil
      end
    end

    describe "as hash" do
      let(:messages) { { initialized: "INIT" } }

      it "should be assepted" do
        messenger.should_receive(:info).with("INIT")
        subject.after_start nil
      end
    end
  end
end

