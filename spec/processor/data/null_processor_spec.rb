require 'spec_helper_lite'
require 'processor/data/null_processor'

describe Processor::Data::NullProcessor do
  it "should have a name equals to underscored class name" do
    subject.name.should eq "processor_data_null_processor"
  end
end

