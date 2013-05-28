require 'spec_helper_lite'
require 'processor/messenger'

describe Processor::Messenger do
  let(:io) { STDOUT }

  it "should delegate to logger" do
    io.should_receive(:write)
    messenger = Processor::Messenger.new :debug, io
    messenger.debug "debug message"
  end

  it "should accept symbol as messaging level" do
    messenger = Processor::Messenger.new :info
    messenger.level.should eq Logger::INFO
  end

  it "should not output anything if :null level provided" do
    io.should_not_receive(:write)
    messenger = Processor::Messenger.new :null, io
    messenger.fatal "fatal error"
  end

  it "should not send empty messages" do
    io.should_not_receive(:write)
    messenger = Processor::Messenger.new :info, io
    [nil, ""].each do |empty_message|
      messenger.message empty_message
    end
  end

  it "should send messages from a name of sender" do
    sender = "File Logger"
    io.should_receive(:write).with /#{sender}/
    messenger = Processor::Messenger.new :info, io, sender
    messenger.error "failed to create log file"
  end

  describe "messages" do
    let(:messenger) { Processor::Messenger.new :debug, io }
    %w[debug info error fatal].each do |message_level|
      it "should send #{message_level} message" do
        message = "#{message_level} message"
        io.should_receive(:write).with /#{message}/
        messenger.send message_level, message
      end
    end
  end

  it "should send info message by .message method" do
    messenger = Processor::Messenger.new :info, io
    messenger.should_receive(:info).with("test message")
    messenger.message "test message"
  end

  describe "formatter" do
    let(:messenger) { Processor::Messenger.new :info, io }

    it "should accept formatter proc" do
      io.should_receive(:write).with("test message")
      messenger.formatter = -> _,_,_,message do
        message
      end

      messenger.message "test message"
    end
  end
end
