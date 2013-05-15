module Processor
  module ProcessRunner
    class Threads
      def initialize(number_of_threads = 1)
        @number_of_threads = number_of_threads
        @threads = []
      end

      def call(processor, events, recursion_preventer)
        join_threads

        begin
          processor.records.each do |record|
            recursion_preventer.call
            if threads_created >= number_of_threads then join_threads end

            new_thread(processor, record) do |thread_data_processor, thread_record|
              begin
                events.register :before_record_processing, thread_record

                result = thread_data_processor.process(thread_record)

                events.register :after_record_processing, thread_record, result
              rescue StandardError => exception
                events.register :record_processing_error, thread_record, exception
              end
            end

          end
        ensure # join already created threads
          join_threads
        end
      end

      private
      attr_reader :threads_created, :number_of_threads

      def new_thread(processor, record, &block)
        @threads << ::Thread.new(processor, record, &block)
        @threads_created += 1
      end

      def join_threads
        @threads.each(&:join)
        @threads_created = 0
        @threads = []
      end

    end
  end
end
