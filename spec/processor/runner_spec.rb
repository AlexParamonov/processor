require 'spec_helper_lite'
require 'processor/runner'

describe Processor::Runner do
  let(:runner) { Processor::Runner.new }

  it "should fetch_records_batch till get an empty results" do
    runner.stub(:have_records?).and_return(true, true, false)
    runner.should_receive(:fetch_records_batch).exactly(3).times.and_return([])
    runner.run
  end

  it "should migrate each found record" do
    records = [mock(:one), mock(:two), mock(:three)]
    records.each { |record| runner.should_receive(:migrate).with(record) }
    runner.stub(:fetch_records_batch).and_return(records, [])
    runner.run
  end

  it "should broadcast events to all observers" do
    observers = 3.times.map{ stub.tap{ |observer| observer.should_receive(:test).once } }
    runner = Processor::Runner.new(*observers)
    runner.register_event :test
  end

  describe "exception handling" do
    let(:record) { stub }

    it "should register a record_migration_error event if record migration raised RuntimeError" do
      runner.stub(:migrate).and_raise(RuntimeError)

      event_triggered = false
      runner.should_receive(:register_event) do |event_name, failed_record, exception|
        next if event_name != :record_migration_error
        event_name.should eq :record_migration_error
        failed_record.should eq record
        exception.should be_a RuntimeError
        event_triggered = true
      end.any_number_of_times

      runner.stub(:fetch_records_batch).and_return([record], [])
      runner.run

      event_triggered.should be_true
    end

    it "should register a migration_error event and reraise if record migration raised Exception" do
      runner.stub(:migrate).and_raise(Exception)

      event_triggered = false
      runner.should_receive(:register_event) do |event_name, migration, exception|
        next if event_name != :migration_error
        event_name.should eq :migration_error
        migration.should eq runner
        exception.should be_a Exception
        event_triggered = true
      end.any_number_of_times

      runner.stub(:fetch_records_batch).and_return([record], [])
      expect { runner.run }.to raise_error(Exception)

      event_triggered.should be_true
    end

    it "should register a migration_error event and reraise if fetch_records_batch raised" do
      runner.stub(:fetch_records_batch).and_raise(RuntimeError)

      event_triggered = false
      runner.should_receive(:register_event) do |event_name, migration, exception|
        next if event_name != :migration_error
        event_name.should eq :migration_error
        migration.should eq runner
        exception.should be_a RuntimeError
        event_triggered = true
      end.any_number_of_times

      expect { runner.run }.to raise_error(RuntimeError)

      event_triggered.should be_true
    end
  end

  describe "send method to user" do
    it "outputs a message to STDOUT" do
      $stdout.should_receive(:puts)
      runner.message "Hello"
    end

    it "outputs sender of a message" do
      $stdout.should_receive(:puts).with(/Sender.*Hello/m)
      runner.message "Hello", "Sender"
    end

    it "send message from Observer if no sender provided" do
      $stdout.should_receive(:puts).with(/Observer.*Hello/m)
      runner.message "Hello"
    end
  end

  describe "recursion" do
    it "should not allow infinit recursion" do
      runner.stub(total_records: 4)
      runner.stub(:fetch_records_batch).and_return([:one, :two])
      runner.should_receive(:migrate).at_most(100).times
      expect { runner.run }.to raise_error(Exception, /Migration fall into recursion/)
    end

    it "should have 10% + 10 rerurns window" do
      runner.stub(total_records: 100)
      runner.stub(:fetch_records_batch).and_return([:one, :two])
      runner.should_receive(:migrate).exactly(120).times
      expect { runner.run }.to raise_error(Exception, /Migration fall into recursion/)
    end
  end
end

