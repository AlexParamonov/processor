Processor
==========
[![Build Status](https://travis-ci.org/AlexParamonov/processor.png?branch=master)](http://travis-ci.org/AlexParamonov/processor)
[![Gemnasium Build Status](https://gemnasium.com/AlexParamonov/processor.png)](http://gemnasium.com/AlexParamonov/processor)  

Processor could execute any `DataProcessor` you specify and log entire process using any number of loggers you need.  
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
1. Implement a `DataProcessor`. See `Processor::Example::Migration`
and `processor/data` directory. CSV and Solr data processors are usabe
but not yet finished and tested.
1. Run your `DataProcessor`:

``` ruby
data_processor = UserLocationMigration.new
thread = Processor::Thread.new data_processor
thread.run_successive
```
See `spec/processor/thread_spec.rb` and `spec/example_spec.rb` and
`example` directory for other usage examples.  


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

### Observers
Observers should respond to `update` method but if you inherit from
`Processor::Observers::NullObserver` you'll get a bunch of methods to
use. See `Processor::Observers::Logger` for example.

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
