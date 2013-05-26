Processor
==========
[![Build Status](https://travis-ci.org/AlexParamonov/processor.png?branch=master)](http://travis-ci.org/AlexParamonov/processor)
[![Gemnasium Build Status](https://gemnasium.com/AlexParamonov/processor.png)](http://gemnasium.com/AlexParamonov/processor)  

Processor could execute any `DataProcessor` you specify and log entire
process using any number of loggers you need.

You may add own observers for monitoring background tasks on even send
an email to bussiness with generated report.

Processor provide customisation for almost every part of it.  


Contents
---------
1. Installation
1. Requirements
1. Usage
    1. Data processors
    1. Run modes
    1. Processor Thread
    1. Observers
1. Compatibility
1. Contributing
1. Copyright

Installation
------------
Add this line to your application's Gemfile:
``` ruby
gem 'processor'
```

And then execute:
``` sh
bundle
```

Or install it yourself as:
``` sh
gem install processor
```

Requirements
------------
1. Ruby 1.9
1. Rspec2 for testing

Usage
------------

### Data processors
Actual processing is done by a Data Processor, provided by end user.  
Inherit your Data Processor from NullProcessor to get default behavior
out of the box. After inheritance Processor should implement in at
least 2 methods:

1. `process(record)`
1. `records`

There are additional methods you could implement for Data Processor:

`start`, `finish`, `error(exception)` and `finalize`.

This methods are called if Data Processor started and successfully
finished. `error` method is called if unprocessed errors happend
during processig. `finalize` is called in any case allowing you to
gracefully finalize a processing.

See `Processor::Example::Migration` for example (`example/migration.rb`).

There are several predefined data processors you can reuse:


#### ArrayProcessor
The simplest one: `process` and `records` methods should be implemented.


#### BatchProcessor
Allows to fetch records by batches of defined size.

It is based on `query` method that suppose to run a query method on
database.

Recomended to override `fetch_batch` method to get real reason to
use batch processing. `fetch_batch` could be `query.first(10)` or
`query.page(next_page)`. See `data/solr_pages_processor.rb` and
`data/solr_processor.rb` for example.


#### Other
see `data/csv_processor.rb` for running migration from CSV files.


### Run modes
Currently 2 run modes are supported:


#### Successive
It runs `process` one by one for each found record returned by
`records` method.

Recomended to call it using a `Processor::Thread`:
``` ruby
Processor::Thread.new(migration).run_successive
```

#### Threads
It runs `process` for each found record returned by `records` method
not waiting for previous `process` to finish.

Possible to specify number of threads used by passing a number to
constructor:
``` ruby
Processor::ProcessRunner::Threads.new 5
```

Recomended to call it using a Processor::Thread :
``` ruby
Processor::Thread.new(migration).run_in_threads 5
```


### Observers
Processor support unlimited number of observers, watching processing.

Thay could monitor running migrations and output to logs, console or
file usefull information. Or thay can show a progress bar to your
console. Or pack a generated report to archive and send by email to
bussiness on success or notify developers on failure.


This observers should respond to `update` method. But if you inherit
from `Processor::Observers::NullObserver` you'll get a bunch of
methods, such as before_ and after_ processing, error handling methods
to use. See `Processor::Observers::Logger` for example.

Read below section Processor Thread to see how to use observers in runner.


### Processor Thread
`Processor::Thread` is a Facade pattern. It simplifies access to all
Processor classes and provide __stable__ interface.

Creating a new Thread:
``` ruby
Processor::Thread.new data_processor
```

You may provide optional observers:
``` ruby
Processor::Thread.new data_processor, observer1, observer2, ...
```

Instance have a `run_as` method that accepts a block:
``` ruby
thread = Processor::Thread.new @migration
thread.run_as do |processor, *|
  processor.records.each do |record|
    processor.process record
  end
end
```

Block could accept next arguments: `processor`, `events`,
`recursion_preventer` method. Last one could be called to prevent
recurtion:
``` ruby
recursion_preventer.call
```

Instance have a `run_successive` method: 
``` ruby
data_processor = UserLocationMigration.new
thread = Processor::Thread.new data_processor
thread.run_successive
```

And `run_in_threads` method:
``` ruby
data_processor = UserCsvImport.new csv_file
thread = Processor::Thread.new data_processor
thread.run_in_threads 10
```

See `spec/processor/thread_spec.rb` and `spec/example_spec.rb` and
`example` directory for other usage examples.

It is recomended to wrap Processor::Thread by classes named like:
``` ruby
WeeklyReport
TaxonomyMigration
UserDataImport
```

The point is to hide configuration of observers and use (if you wish)
your own API to run reports or migrations:
``` ruby
weekly_report.create_and_deliver
user_data_import.import_from_csv(file)
etc.
```

It is possible to use it raw, but please dont fear to add a wrapper
class like `CsvUserImport` for this:
``` ruby
csv_data_processor = Processor::Data::CsvProcessor.new file
stdout_notifier = Processor::Observer::Logger.new(Logger.new(STDOUT))
logger_observer = Processor::Observer::Logger.new
Processor::Thread.new(
  csv_data_processor,
  stdout_notifier,
  logger_observer,
  email_notification_observer
).run_in_threads 5
```

More documentation could be found by running
``` sh
rspec
```

Compatibility
-------------
tested with Ruby

* 1.9.3
* rbx-19mode
* ruby-head

see [build history](http://travis-ci.org/#!/AlexParamonov/processor/builds)

Contributing
-------------
1. Fork repository [AlexParamonov/processor](https://github.com/AlexParamonov/processor)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Copyright
---------
Copyright © 2013 Alexander Paramonov.
Released under the MIT License. See the LICENSE file for further details.
