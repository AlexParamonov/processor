require 'spec_helper_lite'
require_relative 'specs'
require 'processor/process_runner/successive'

describe Processor::ProcessRunner::Successive do
  it_behaves_like "a records processor"
end
