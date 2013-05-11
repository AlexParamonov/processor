require 'spec_helper_lite'
require_relative '../example/migrator'
require_relative '../example/migration'

describe "Example" do
  before(:each) do
    records = %w[item1 item2 item3 item4 item5]
    records.each do |record|
      record.should_receive(:do_something).once
    end
    @migration = Processor::Example::Migration.new records
  end

  it "migration should use 2 loggers and messenger" do
    migrator = Processor::Example::Migrator.new @migration
    migrator.migrate
  end
end
