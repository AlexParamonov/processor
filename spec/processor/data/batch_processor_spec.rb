require "spec_helper_lite"

require "processor/data/batch_processor"

describe Processor::Data::BatchProcessor do
  it "should create and process records by batch" do
    processor = Processor::Data::BatchProcessor.new 2

    records = (1..10).each_slice(2).map do |first_record, second_record|
      record1 = mock("record_#{first_record}")
      record2 = mock("record_#{second_record}")

      record1.should_receive(:created).ordered
      record2.should_receive(:created).ordered

      record1.should_receive(:processed).ordered
      record2.should_receive(:processed).ordered

      [ record1, record2 ]
    end.flatten

    query = Enumerator.new do |y|
      while records.any?
        record = records.shift
        record.created
        y << record
      end
    end

    processor.stub(query: query)
    processor.records.each do |record|
      record.processed
    end
  end

  it "should have total records count equals to count of query" do
    query = 1..5
    subject.stub(query: query)
    subject.total_records.should eq 5
  end

  it "should stop iteration if fetch_records returned empty result set" do
    subject.stub(fetch_batch: [])
    subject.records.to_a.should eq []
  end
end
