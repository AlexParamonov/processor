Processor
==========
[![Build Status](https://travis-ci.org/AlexParamonov/processor.png?branch=master)](http://travis-ci.org/AlexParamonov/processor)
[![Gemnasium Build Status](https://gemnasium.com/AlexParamonov/processor.png)](http://gemnasium.com/AlexParamonov/processor)  

Universal processor for data migration

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
Ruby 1.9
rspec2 for testing

Usage
------------
1. Implement a DataProcessor. See Processor::Example::Migration, Processor::Example::SolrMigration, Processor::Example::SolrPagesMigration
1. Run your DataProcessor:

``` ruby
thread = Processor::Thread.new data_processor
thread.run_successive
```
See spec/processor/thread_spec.rb and spec/example_spec.rb for other usage examples:

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

Compatibility
-------------
tested with Ruby

* 1.9.3
* jruby-19mode
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
