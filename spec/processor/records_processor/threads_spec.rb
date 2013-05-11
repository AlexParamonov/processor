require 'spec_helper_lite'
require_relative 'specs'
require 'processor/records_processor/threads'

describe Processor::RecordsProcessor::Threads do
  it_behaves_like "a records processor"
  it "should run in defined number of threads"
end
