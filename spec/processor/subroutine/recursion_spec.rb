require 'spec_helper_lite'
require 'processor/subroutine/recursion'

describe Processor::Subroutine::Recursion do
  let(:processor) { stub(total_records: 100) }
  let(:subroutine) { Processor::Subroutine::Recursion.new processor }

  it "should not fall into recursion" do
    processor.should_receive(:process).at_most(1000).times

    expect do
      1001.times { subroutine.process }
    end.to raise_error(Exception, /Processing fall into recursion/)
  end

  it "should have 10% + 10 rerurns window" do
    processor.should_receive(:process).exactly(120).times

    expect do
      121.times { subroutine.process }
    end.to raise_error(Exception, /Processing fall into recursion/)
  end
end
