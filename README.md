Processor
==========
[![Build Status](https://travis-ci.org/AlexParamonov/processor.png?branch=master)](http://travis-ci.org/AlexParamonov/processor)
[![Gemnasium Build Status](https://gemnasium.com/AlexParamonov/processor.png)](http://gemnasium.com/AlexParamonov/processor)  

Processor could execute any DataProcessor you specify and log entire process using any number of loggers you need.  
You may add own observers for monitoring background tasks on even send an email to bussiness with generated report.  
Processor provide customisation for almost every part of it.  


Contents
---------
1. Installation
1. Requirements
1. Usage
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
1. Implement a `DataProcessor`. See `Processor::Example::Migration`, `Processor::Example::SolrMigration`, `Processor::Example::SolrPagesMigration`
1. Run your `DataProcessor`:

``` ruby
thread = Processor::Thread.new data_processor
thread.run_successive
```
See `spec/processor/thread_spec.rb` and `spec/example_spec.rb` and
`example` directory for other usage examples.  
Below are specs for most valuable parts of the gem.

``` rspec
Processor::Thread
  should run a migration using provided block
  should run a migration successive
  should run a migration in threads

Processor::DataProcessor
  should have a name equals to underscored class name
  should be done when there are 0 records to process
  should respond to done?
  should respond to fetch_records
  should respond to total_records
  should respond to process

Processor::Observer::Logger
  accepts logger builder as parameter
  accepts logger as parameter
  use ruby Logger if no external logger provided
```

It is recomended to wrap Processor::Thread in your classes like:

```
WeeklyReport
TaxonomyMigration
UserDataImport
```
to hide configuration of observers or use your own API to run
migrations:

```
weekly_report.create_and_deliver
user_data_import.import_from_csv(file)
etc.
```

Sure, it is possible to use it raw, but please dont fear to add a
wrapper class for it:

```
csv_data_processor = CsvDataProcessor.new file
stdout_notifier = Processor::Observer::Logger.new(Logger.new(STDOUT))
logger_observer = Processor::Observer::Logger.new
Processor::Thread.new(
  csv_data_processor,
  stdout_notifier,
  logger_observer,
  email_notification_observer
).run_in_threads
```

### Observers
Observers should respond to `update` method but if you inherit from
`Processor::Observers::NullObserver` you'll get a bunch of methods to
use. See `Processor::Observers::Logger` for example.

Compatibility
-------------
tested with Ruby

* 1.9.3
* jruby-19mode
* rbx-19mode
* ruby-head
* jruby-head

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
