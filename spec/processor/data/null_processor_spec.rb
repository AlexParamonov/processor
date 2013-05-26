require 'spec_helper_lite'
require 'processor/data/null_processor'

describe Processor::Data::NullProcessor do
  it "should have a name equals to underscored class name" do
    subject.name.should eq "processor_data_null_processor"
  end

  it "should have zero records" do
    subject.records.should be_empty
    subject.total_records.should be_zero
  end
end

