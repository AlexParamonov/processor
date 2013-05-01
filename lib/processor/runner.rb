module Processor
  class Runner
    def initialize(*observers)
      @observers = observers
    end

    def run
      register_event :prepare, self
      register_event :found, total_records

      while have_records?(records = fetch_records_batch)
        threads = []
        begin
          records.each do |record|
            recursion_preventer
            threads << Thread.new(record) do |thread_record|
              begin
                register_event :before_proccessing, thread_record

                result = migrate(thread_record)

                register_event :after_proccessing, thread_record, result
              rescue RuntimeError => exception
                register_event :record_migration_error, thread_record, exception
              end
            end
          end
        ensure # join already created threads even if recursion was detected
          threads.each(&:join)
        end
      end

      register_event :finalize, self
    rescue Exception => exception
      register_event :migration_error, self, exception
      raise exception
    end

    def name
      self.class.name.underscore.tr("/", "_")
    end

    def message(content, sender = "Observer")
      puts "\nMessage from #{sender}:\n> #{content}\n"
    end

    def register_event(method_name, *args)
      observers.each do |observer|
        observer.public_send method_name, *args
      end
    end

    protected
    def migrate(record)
      raise NotImplementedError
    end

    def fetch_records_batch
      raise NotImplementedError
    end

    def total_records
      0
    end

    private
    attr_reader :observers

    def have_records?(records_set)
      records_set.count > 0
    end

    def recursion_preventer
      @counter ||= 0
      @counter += 1
      raise Exception, "Migration fall into recursion. Check logs." if @counter > (total_records * 1.1).round + 10
    end
  end
end
