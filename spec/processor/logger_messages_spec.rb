require "spec_helper_lite"
require "logger"
require "processor/logger_messages"

describe Processor::LoggerMessages do
  let(:messages) { Processor::LoggerMessages.new logger }
  shared_examples_for "a null logger" do
    it "should not produce any output" do
      messages.finished.should eq ""
      messages.initialized.should eq ""
    end
  end

  describe "Ruby Logger" do
    describe "file" do
      let(:filename) { "/tmp" }
      let(:logger) { Logger.new File.new(filename) }

      it "should include file name into message" do
        messages.finished.should include filename
        messages.initialized.should include filename
      end
    end

    describe "filename" do
      let(:filename) { "/tmp/processor_gem_test.log" }
      let(:logger) { Logger.new filename }

      it "should include file name into message" do
        messages.finished.should include filename
        messages.initialized.should include filename
      end
    end

    describe "null" do
      let(:logger) { ::Logger.new(File::NULL) }
      it_behaves_like "a null logger"
    end

    describe "STDOUT" do
      let(:logger) { Logger.new(STDOUT) }

      it "should include IO in the message" do
        messages.initialized.should include "IO"
        messages.finished.should eq ""
      end
    end

    describe "STDERR" do
      let(:logger) { Logger.new(STDERR) }

      it "should include IO in the message" do
        messages.initialized.should include "IO"
        messages.finished.should eq ""
      end
    end
  end

  describe "nil" do
    let(:logger) { nil }
    it_behaves_like "a null logger"
  end

  describe "unknown object" do
    let(:logger) { Object.new }
    it_behaves_like "a null logger"
  end

end
