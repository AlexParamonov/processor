require "processor/version"

require "processor/data/array_processor"
require "processor/data/batch_processor"
require "processor/data/null_processor"
require "processor/data/solr_processor"
require "processor/data/solr_pages_processor"

require "processor/observer/logger"
require "processor/observer/null_observer"

require "processor/process_runner/successive"
require "processor/process_runner/threads"

require "processor/runner"
require "processor/thread"

module Processor
end
