require 'spec_helper_lite'
require 'processor/migration'

describe Processor::Migration do
  let(:migration) { Processor::Migration.new }
  it "should process a record" do
    expect{ migration.process stub }.to_not raise_error
  end

  it "should fetch records" do
    records = stub
    migration = Processor::Migration.new records
    migration.fetch_all.should eq records
  end
end
