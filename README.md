Processor
==========
[![Build Status](https://travis-ci.org/AlexParamonov/processor.png?branch=master)](http://travis-ci.org/AlexParamonov/processor)
[![Gemnasium Build Status](https://gemnasium.com/AlexParamonov/processor.png)](http://gemnasium.com/AlexParamonov/processor)
[![Coverage Status](https://coveralls.io/repos/AlexParamonov/processor/badge.png?branch=master)](https://coveralls.io/r/AlexParamonov/processor?branch=master)


Processor is a tool that helps to iterate over collection and
perform complex actions on a result. It is extremely useful in data
migrations, report generation, etc.

Collection could be iteratively fetched by parts but for processor
it will looks like an endless collection. There are a lot such tiny
goodness that makes usage of processor pleasant. Need logging,
exception processing, post/pre processing a result - no problems, all
included and easily extended.

Use the processor to DRY your migrations, report and stop mess with
logging and post processing.

Did I mentioned you can run in threads as easy as say
`processor.run_in_threads 10`?

Processor could execute any `DataProcessor` you specify and log
entire process using any number of loggers you need. You may add own
observers for monitoring background tasks on even send an email to
business with generated report. Processor provide customisation for
almost every part of it.


Contents
---------
1. Installation
1. Requirements
1. Usage
    1. Data processors
    1. Subroutines
    1. Run modes
    1. Processor Thread
    1. Observers
1. Contacts
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
Working with a data is responsibility of a `DataProcessor`.

`DataProcessor` should obtain records to process by its `records`
method and process a record by `process` method. If some post/pre
action is needed, it could be performed inside `start` and `finish`
methods. In case of exceptions there are `error(exception)` and
`record_error(record, exception)` methods. `error` method is called if
unprocessed errors happened during processing and `record_error` if
processing current record raised. `finalize` method will run in any
case allowing you to gracefully finalize processing.

To add new `DataProcessor` it is recommended to inherit from
`NullProcessor` and implement methods that are needed only.

`Processor` provides several data processors:

1. NullProcessor [[code](https://github.com/AlexParamonov/processor/blob/master/lib/processor/data/null_processor.rb), [specs](https://github.com/AlexParamonov/processor/blob/master/spec/processor/data/null_processor_spec.rb)]
1. ArrayProcessor [[code](https://github.com/AlexParamonov/processor/blob/master/lib/processor/data/array_processor.rb), [specs](https://github.com/AlexParamonov/processor/blob/master/spec/processor/data/array_processor_spec.rb)]
1. BatchProcessor [[code](https://github.com/AlexParamonov/processor/blob/master/lib/processor/data/batch_processor.rb), [specs](https://github.com/AlexParamonov/processor/blob/master/spec/processor/data/batch_processor_spec.rb)]
1. CsvProcessor
1. SolrPagesProcessor

The last two are more as example, your probably would change them.

#### ArrayProcessor
The simplest one: `process` and `records` methods should be implemented.


#### BatchProcessor
Allows to fetch records by batches of defined size.

It is based on `query` method that is supposed to run a query method on
a database.

Recommended to override `fetch_batch` method to get real reason to use
batch processing. `fetch_batch` could be `query.page(next_page)` for
example. See `data/solr_pages_processor.rb`.


#### Other
see `data/csv_processor.rb` for running migration from CSV files.


### Subroutines
Subroutines are small programs that do exactly one task. It is
possible to enhance data processor by passing it to subroutine first.
Subroutines are decorators. There are several predefined subroutines:

1. Name [[code](https://github.com/AlexParamonov/processor/blob/master/lib/processor/subroutine/name.rb), [specs](https://github.com/AlexParamonov/processor/blob/master/spec/processor/subroutine/name_spec.rb)]
1. Count [[code](https://github.com/AlexParamonov/processor/blob/master/lib/processor/subroutine/counter.rb), [specs](https://github.com/AlexParamonov/processor/blob/master/spec/processor/subroutine/counter_spec.rb)]
1. Recursion [[code](https://github.com/AlexParamonov/processor/blob/master/lib/processor/subroutine/recursion.rb), [specs](https://github.com/AlexParamonov/processor/blob/master/spec/processor/subroutine/recursion_spec.rb)]

`Subroutine::Name` adds `name` method that returns name of the current
data processor. `Subroutine::Count` adds `remaining_records_count` and
`processed_records_count` methods. `Subroutine::Recursion` prevents
recursion of data processor. It uses `total_records` method and take
care about keeping count of `process` method calls in borders.

Some subroutines are used by parts of `Processor` when needed:
`Subroutine::Name` is used in `Observer::Logger`, `Subroutine::Count`
is used by `Subroutine::Recursion`

To use `Subroutine::Recursion`, first wrap a data processor before
running it:

``` ruby
user_updater = Processor::Subroutine::Recursion.new(UpdateUserLocationCodes.new)
Processor::Thread.new(user_updater).run_successive
```

### Run modes
Currently 2 run modes are supported:


#### Successive
It runs `process` one by one for each found record returned by
`records` method.

Call it using a `Processor::Thread`:
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

Call it using a `Processor::Thread`:
``` ruby
Processor::Thread.new(migration).run_in_threads 5
```


### Observers
Processor support unlimited number of observers that are watching
processing.

They could monitor `Data Processor`s and output to logs, console
or file. Or they can show a progress bar on the console. Or pack a
generated report to archive and send it by email to the business on
success or notify developers on failure.


This observers should respond to `update` method. But if you inherit
from `Processor::Observers::NullObserver` you'll get a bunch of
methods, such as before_ and after_ processing, error handling methods
to use. See `Processor::Observers::Logger` for example.

Read below section Processor Thread to see how to use observers in runner.


### Processor Thread
`Processor::Thread` is a Facade pattern. It simplifies access to all
Processor classes and provides __stable__ interface.

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
thread.run_as do |processor|
  processor.records.each do |record|
    processor.process record
  end
end
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

It is recommended to wrap Processor::Thread by classes named like:
``` ruby
WeeklyReport
TaxonomyMigration
UserDataImport
```

The point is to hide configuration of observers and use (if you wish)
your own API to run reports or migrations:
``` ruby
weekly_report.create_and_deliver
user_data_import.from_csv(file)
etc.
```

It is possible to use it raw, but please don't fear to add a wrapper
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

Find more examples under [example directory](https://github.com/AlexParamonov/processor/tree/master/example)

Contacts
-------------
Have questions or recommendations? Contact me via `alexander.n.paramonov@gmail.com`
Found a bug or have enhancement request? You are welcome at [Github bugtracker](https://github.com/AlexParamonov/processor/issues)


Compatibility
-------------
tested with Ruby

* 1.9.3
* rbx-19mode
* ruby-head

See [build history](http://travis-ci.org/#!/AlexParamonov/processor/builds)

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
