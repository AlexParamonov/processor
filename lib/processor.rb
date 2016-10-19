require "processor/environment"
require "processor/version"

require "processor/data/array_processor"
require "processor/data/batch_processor"
require "processor/data/null_processor"
require "processor/data/solr_pages_processor"
require "processor/data/csv_processor"
require "processor/data/active_record_batch_processor"

require "processor/observer/logger"
require "processor/observer/null_observer"

require "processor/process_runner/successive"
require "processor/process_runner/threads"

require "processor/subroutine/counter"
require "processor/subroutine/recursion"
require "processor/subroutine/name"

require "processor/runner"
require "processor/thread"

module Processor
end
