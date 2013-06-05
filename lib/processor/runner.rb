module Processor
  class Runner
    def initialize(processor)
      @processor = processor
    end

    def run(process_runner)
      processor.start
      process_runner.call processor
      processor.finish

    rescue Exception => exception
      processor.error exception
      raise exception

    ensure
      processor.finalize
    end

    private
    attr_reader :processor
  end
end
