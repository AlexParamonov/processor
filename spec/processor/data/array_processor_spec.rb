require 'spec_helper_lite'
require 'processor/data/array_processor'

describe Processor::Data::ArrayProcessor do
  it "should have total records count equals to count of records" do
    subject.stub(records: 1..5)
    subject.total_records.should eq 5
  end
end

