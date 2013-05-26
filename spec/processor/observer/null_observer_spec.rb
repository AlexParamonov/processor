require 'spec_helper_lite'
require 'processor/observer/null_observer'

describe Processor::Observer::NullObserver do
  it "should send update message to itself if know how to respond to this message" do
    subject.should_receive(:know_how)
    subject.update :know_how
  end

  it "should ignore update message if dont know how to respond to this message" do
    subject.stub(:respond_to?).with(:unknown_method).and_return(false)
    subject.should_not_receive(:unknown_method)
    subject.update :unknown_method
  end

  it "should blow up if got undefined method call" do
    expect { subject.undefined_method }.to raise_error(NoMethodError)
  end
end
