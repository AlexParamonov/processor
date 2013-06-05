require 'spec_helper_lite'
require 'processor/subroutine/name'

describe Processor::Subroutine::Name do
  let(:processor) { stub.tap { |p| p.stub_chain(:class, :name).and_return("NameSpace::DataProcessor") } }
  let(:subroutine) { Processor::Subroutine::Name.new processor }

  it "should have a name equals to underscored processor class name" do
    subroutine.name.should eq "name_space_data_processor"
  end

  it "should use processor's name method if defined" do
    processor.stub(name: "Processor's name")
    subroutine.name.should eq "Processor's name"
  end

  it "should use real object's name, not delegator" do
    double_wrapped_processor = Processor::Subroutine::Name.new(SimpleDelegator.new processor)
    double_wrapped_processor.name.should eq "name_space_data_processor"
  end
end

