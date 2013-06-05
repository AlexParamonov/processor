shared_examples_for "a records processor" do
  let(:process_runner) { described_class.new }
  let(:records) { 1..2 }
  let(:processor) { stub.tap { |p| p.stub(records: records) }.as_null_object }

  it "should fetch records from processor" do
    processor.should_receive(:records).and_return([])
    process_runner.call processor
  end

  it "should send each found record to processor" do
    records.each { |record| processor.should_receive(:process).with(record) }
    process_runner.call processor
  end

  describe "exception handling" do
    describe "processing a record raised StandardError" do
      let(:records) { 1..3 }

      it "should continue processing" do
        processor.should_receive(:process).exactly(3).times.and_raise(StandardError)
        expect { process_runner.call processor }.to_not raise_error
      end

      it "should call record_error" do
        processor.should_receive(:process).at_least(1).and_raise(StandardError)
        processor.should_receive(:record_error).at_least(1)
        process_runner.call processor
      end
    end

    describe "processing a record raised Exception" do
      it "should break processing" do
        processor.should_receive(:process).once.and_raise(Exception)
        expect { process_runner.call processor }.to raise_error(Exception)
      end
    end
  end
end
