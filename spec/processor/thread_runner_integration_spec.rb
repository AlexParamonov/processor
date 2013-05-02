require 'spec_helper_lite'
require_relative '../../example/debug_runner'
require_relative '../../example/migration'
require 'fileutils'

describe "Running a migration" do
  it "should migrate all records" do
    records = %w[item1 item2 item3 item4 item5]
    records.each do |record|
      record.should_receive(:do_something).once
    end
    migration = Processor::Example::Migration.new records
    migration_runner = Processor::Example::DebugRunner.new
    migration_runner.run migration
  end
end
