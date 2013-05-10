require 'spec_helper_lite'
require_relative '../example/example_runner'
require_relative '../example/migration'
require 'fileutils'

describe "Example" do
  before(:each) do
    records = %w[item1 item2 item3 item4 item5]
    records.each do |record|
      record.should_receive(:do_something).once
    end
    @migration = Processor::Example::Migration.new records
  end

  it "should use logger and messenger" do
    migration_runner = Processor::Example::ExampleRunner.new @migration
    migration_runner.run
  end

  it "should run without configuration" do
    runner = Processor::ThreadRunner.new @migration
    runner.run
  end

  pending "should run in threads" do
    processor = Processor.new @migration
    processor.run :threads
  end

  pending "should run successive" do
    processor = Processor.new @migration
    processor.run :successive
  end

  pending "should run with own block" do
    processor = Processor.new @migration
    processor.run do |records, events, recursion_preventer|
      records.each do |record|
        recursion_preventer.call
        processor.process record
      end
    end
  end
end
