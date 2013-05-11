shared_examples_for "a records processor" do
  let(:records_processor) { described_class.new }
  let(:records) { 1..2 }
  let(:processor) { stub }

  let(:no_recursion_preventer) { Proc.new{} }
  let(:no_events) { stub.as_null_object }

  it "should send each found record to processor" do
    records.each { |record| processor.should_receive(:process).with(record) }
    records_processor.call records, processor, no_events, no_recursion_preventer
  end

  describe "exception handling" do
    describe "processing a record raised RuntimeError" do
      it "should continue processing" do
        processor.should_receive(:process).twice.and_raise(RuntimeError)
        expect { records_processor.call records, processor, no_events, no_recursion_preventer }.to_not raise_error
      end

      it "should register a record_processing_error event" do
        event = mock.tap { |event| event.should_receive(:trigger).any_number_of_times }

        events_registrator = stub
        events_registrator.should_receive(:register) do |event_name, failed_record, exception|
          next if event_name != :record_processing_error
          event_name.should eq :record_processing_error
          exception.should be_a RuntimeError
          event.trigger
        end.any_number_of_times

        processor.stub(:process).and_raise(RuntimeError)

        records_processor.call records, processor, events_registrator, no_recursion_preventer rescue nil
      end
    end
  end
end
