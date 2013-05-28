require 'spec_helper_lite'
require 'processor/observer/logger'

describe Processor::Observer::Logger do
  let(:processor) { stub.as_null_object }
  let(:no_messages) { ::Logger.new("/dev/null") }
  let(:no_logger) { ::Logger.new("/dev/null") }
  subject { Processor::Observer::Logger }

  it "accepts logger builder as parameter" do
    external_logger = mock
    logger_observer = subject.new -> name { external_logger }, messenger: no_messages

    external_logger.should_receive(:info)
    logger_observer.processing_started processor
  end

  it "accepts logger as parameter" do
    external_logger = mock
    logger_observer = subject.new external_logger, messenger: no_messages

    external_logger.should_receive(:info)
    logger_observer.processing_started processor
  end

  it "use ruby Logger if no external logger provided" do
    logger_observer = subject.new nil, messenger: no_messages

    Logger.should_receive(:new).and_return(stub.as_null_object)
    logger_observer.processing_started processor
  end

  it "accepts messages object as option" do
    messages = mock
    messages.should_receive(:initialized)

    observer = subject.new no_logger, messages: messages, messenger: no_messages
    observer.processing_started processor
  end

  it "accepts messages hash as option" do
    messages = {initialized: "INIT"}
    messenger = no_messages
    messenger.should_receive(:info).with("INIT")

    observer = subject.new no_logger, messages: messages, messenger: messenger
    observer.processing_started processor
  end
end

