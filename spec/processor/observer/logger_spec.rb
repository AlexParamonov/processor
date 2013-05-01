require 'spec_helper_lite'
require 'processor/observer/logger'

describe Processor::Observer::Logger do
  subject { Processor::Observer::Logger }
    it "accepts logger as parameter" do
      external_logger = mock
      logger = subject.new(external_logger)

      external_logger.should_receive(:info)
      logger.send(:logger).info
    end

    it "use ruby Logger if no external logger provided" do
      logger = subject.new
      logger.stub(:create_log_filename)

      Logger.should_receive(:new).and_return(stub.as_null_object)
      logger.send(:logger).info
    end
end

