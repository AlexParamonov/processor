require 'spec_helper_lite'
require 'processor/subroutine/name'

describe Processor::Subroutine::Name do
  let(:processor) { stub.tap { |p| p.stub_chain(:class, :name).and_return("NameSpace::DataProcessor") } }
  let(:subroutine) { Processor::Subroutine::Name.new processor }

  it "should have a name equals to underscored processor class name" do
    subroutine.name.should eq "name_space_data_processor"
  end
end

