require 'spec_helper_lite'
require 'processor/null_processor'

describe Processor::NullProcessor do
  it "should have a name equals to underscored class name" do
    subject.name.should eq "processor_null_processor"
  end
end

