require 'spec_helper_lite'
require 'processor/data_processor'

describe Processor::DataProcessor do
  it "should have a name equals to underscored class name" do
    subject.name.should eq "processor_data_processor"
  end

  it "should be done when there are 0 records to process" do
    records = []
    subject.done?(records).should be true
  end

  %w[done? fetch_records total_records process].each do |method_name|
    it "should respond to #{method_name}" do
      subject.should respond_to method_name
    end
  end
end

