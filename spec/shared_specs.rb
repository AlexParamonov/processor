shared_examples_for "a runner" do
  let(:runner) { described_class.new processor }
  let(:records_processor) { runner.method(:process_records) }
  let(:records) { 1..2 }
  let(:processor) { stub }

  let(:no_recursion_preventer) { ->{} }
  let(:no_events) { stub.as_null_object }

  it "should send each found record to processor" do
    records.each { |record| processor.should_receive(:process).with(record) }
    records_processor.call records, no_events, no_recursion_preventer
  end

  describe "exception handling" do
    describe "processing a record raised RuntimeError" do
      it "should continue processing" do
        processor.should_receive(:process).twice.and_raise(RuntimeError)
        expect { records_processor.call records, no_events, no_recursion_preventer }.to_not raise_error
      end

      it "should register a record_processing_error event" do
        mock.tap do |events_registrator|
          events_registrator.should_receive(:register) do |event_name, failed_record, exception|
            next if event_name != :record_processing_error
            event_name.should eq :record_processing_error
            failed_record.should eq record
            exception.should be_a RuntimeError
            event.trigger
          end.any_number_of_times
          runner.stub(events: events_registrator)
        end

        processor.stub(:process).and_raise(RuntimeError)

        records_processor.call records, no_events, no_recursion_preventer rescue nil
      end
    end
  end

  it "should not fall into recursion" do
    processor.stub(done?: false)
    processor.stub(fetch_records: records)

    runner.stub(max_records_to_process: 10)
    processor.should_receive(:process).at_most(100).times
    expect { runner.run }.to raise_error(Exception, /Processing fall into recursion/)
  end
end
