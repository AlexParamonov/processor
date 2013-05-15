require "spec_helper_lite"

require "processor/data/batch_processor"

describe Processor::Data::BatchProcessor do
  it "should create and process records by batch" do
    processor = Processor::Data::BatchProcessor.new 2

    watcher = mock
    5.times do
      watcher.should_receive(:created).ordered
      watcher.should_receive(:created).ordered
      watcher.should_receive(:processed).ordered
      watcher.should_receive(:processed).ordered
    end

    query = Enumerator.new do |y|
      a = 1
      loop do
        break if a > 10
        watcher.created
        y << a
        a += 1
      end
    end

    processor.stub(query: query)
    processor.records.each do |record|
      watcher.processed
    end
  end

  it "should have total records count equals to count of query" do
    query = 1..5
    subject.stub(query: query)
    subject.total_records.should eq 5
  end
end
