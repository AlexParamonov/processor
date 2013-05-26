require 'spec_helper_lite'
require 'processor/subroutine/counter'

describe Processor::Subroutine::Counter do
  let(:records) { 1..10 }
  let(:processor) { stub(total_records: 10, process: true) }
  let(:subroutine) { Processor::Subroutine::Counter.new processor }

  it "should count remaining records" do
    subroutine.remaining_records_count.should eq 10
    records.each do
      expect { subroutine.process }.to change { subroutine.remaining_records_count }.by -1
    end
  end

  it "should count processed records" do
    subroutine.processed_records_count.should eq 0
    records.each do
      expect { subroutine.process }.to change { subroutine.processed_records_count }.by 1
    end
  end

  describe "over process" do
    before(:each) do
      10.times { subroutine.process }
    end

    specify "remaining_records_count should be zero" do
      subroutine.remaining_records_count.should eq 0
      5.times do
        expect { subroutine.process }.to_not change { subroutine.remaining_records_count }.from 0
      end
    end

    specify "processed_records_count should keep counting" do
      subroutine.processed_records_count.should eq 10
      5.times do
        expect { subroutine.process }.to change { subroutine.processed_records_count }.by 1
      end
    end
  end

end

