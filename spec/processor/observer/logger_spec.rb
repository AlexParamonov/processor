require 'spec_helper_lite'
require 'processor/observer/logger'

describe Processor::Observer::Logger do
  let(:processor) { stub.as_null_object }
  subject { Processor::Observer::Logger }
    it "accepts logger builder as parameter" do
      external_logger = mock
      logger_observer = subject.new processor, logger: -> name { external_logger }

      external_logger.should_receive(:info)
      logger_observer.send(:logger).info
    end

    it "use ruby Logger if no external logger provided" do
      logger = subject.new processor

      Logger.should_receive(:new).and_return(stub.as_null_object)
      logger.send(:logger)
    end
end

