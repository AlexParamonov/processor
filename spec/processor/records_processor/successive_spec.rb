require 'spec_helper_lite'
require_relative 'specs'
require 'processor/records_processor/successive'

describe Processor::RecordsProcessor::Successive do
  it_behaves_like "a records processor"
end
