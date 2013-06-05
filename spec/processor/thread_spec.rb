require 'spec_helper_lite'
require 'processor/thread'
require_relative '../../example/migration'

describe Processor::Thread do
  before(:each) do
    records = %w[item1 item2 item3 item4 item5]
    records.each do |record|
      record.should_receive(:do_something).once
    end
    @migration = Processor::Example::Migration.new records
  end

  it "should run a migration using provided block" do
    thread = Processor::Thread.new @migration
    thread.run_as do |processor|
      processor.records.each do |record|
        processor.process record
      end
    end
  end

  it "should run a migration successive" do
    thread = Processor::Thread.new @migration
    thread.run_successive
  end

  it "should run a migration in threads" do
    thread = Processor::Thread.new @migration
    thread.run_in_threads
  end

  it "should run a migration in specifien number of threads" do
    thread = Processor::Thread.new @migration
    thread.run_in_threads 3
  end
end
