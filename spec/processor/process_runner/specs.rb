shared_examples_for "a records processor" do
  let(:process_runner) { described_class.new }
  let(:records) { 1..2 }
  let(:processor) { stub.tap { |p| p.stub(records: records) } }

  let(:no_events) { stub.as_null_object }

  it "should fetch records from processor" do
    processor.should_receive(:records).and_return([])
    process_runner.call processor, no_events
  end

  it "should send each found record to processor" do
    records.each { |record| processor.should_receive(:process).with(record) }
    process_runner.call processor, no_events
  end

  describe "exception handling" do
    describe "processing a record raised StandardError" do
      it "should continue processing" do
        processor.should_receive(:process).twice.and_raise(StandardError)
        expect { process_runner.call processor, no_events }.to_not raise_error
      end

      it "should register a record_processing_error event" do
        event = mock.tap { |event| event.should_receive(:trigger).any_number_of_times }

        events_registrator = stub
        events_registrator.should_receive(:register) do |event_name, failed_record, exception|
          next if event_name != :record_processing_error
          event_name.should eq :record_processing_error
          exception.should be_a StandardError
          event.trigger
        end.any_number_of_times

        processor.stub(:process).and_raise(StandardError)

        process_runner.call processor, events_registrator rescue nil
      end
    end

    describe "processing a record raised Exception" do
      it "should break processing" do
        processor.should_receive(:process).once.and_raise(Exception)
        expect { process_runner.call processor, no_events }.to raise_error(Exception)
      end
    end
  end
end
