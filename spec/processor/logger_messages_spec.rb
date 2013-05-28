require "spec_helper_lite"
require "logger"
require "processor/logger_messages"

describe Processor::LoggerMessages do
  let(:presenter) { Processor::LoggerMessages.for logger }
  shared_examples_for "a null logger" do
    it "should not produce any output" do
      presenter.finished.should eq ""
      presenter.initialized.should eq ""
    end
  end

  describe "Ruby Logger" do
    describe "file" do
      let(:filename) { "/tmp" }
      let(:logger) { Logger.new File.new(filename) }

      it "should include file name into message" do
        presenter.finished.should include filename
        presenter.initialized.should include filename
      end
    end

    describe "filename" do
      let(:filename) { "/tmp/processor_gem_test.log" }
      let(:logger) { Logger.new filename }

      it "should include file name into message" do
        presenter.finished.should include filename
        presenter.initialized.should include filename
      end
    end

    describe "null" do
      let(:logger) { ::Logger.new(File::NULL) }
      it_behaves_like "a null logger"
    end

    describe "STDOUT" do
      let(:logger) { Logger.new(STDOUT) }

      it "should include IO in the message" do
        presenter.initialized.should include "IO"
        presenter.finished.should eq ""
      end
    end

    describe "STDERR" do
      let(:logger) { Logger.new(STDERR) }

      it "should include IO in the message" do
        presenter.initialized.should include "IO"
        presenter.finished.should eq ""
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
