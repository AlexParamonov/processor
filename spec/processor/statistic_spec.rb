require 'spec_helper_lite'
require 'processor/statistic'
require 'processor/data/array_processor'

describe Processor::Statistic do
  let(:records) { 1..5 }
  let(:data_processor) { Processor::Data::ArrayProcessor.new }
  subject { Processor::Statistic.new data_processor }

  before(:each) do
    data_processor.stub(records: records)
  end

  it "should delegate total_records to data_processor" do
    data_processor.should_receive(:total_records)
    subject.total_records
  end

  it "should count remaining records" do
    records.reverse_each do |counter|
      subject.remaining_records_count.should eq counter
      subject.record_processed
    end
  end

  describe "over process" do
    let(:records) { [] }

    specify "remaining_records_count should be zero" do
      subject.remaining_records_count.should eq 0
      subject.record_processed
      subject.remaining_records_count.should eq 0
    end

    specify "processed_records_count should keep counting" do
      subject.processed_records_count.should eq 0
      subject.record_processed
      subject.processed_records_count.should eq 1
      subject.record_processed
      subject.processed_records_count.should eq 2
    end
  end

  it "should count processed records" do
    records = *1..5
    subject.stub(records: records)

    5.times do |counter|
      subject.processed_records_count.should eq counter
      subject.record_processed
    end
  end
end

