require 'spec_helper_lite'
require 'shared_specs'
require 'processor/thread_runner'

describe Processor::ThreadRunner do
  it_behaves_like "a runner"
end
