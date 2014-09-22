require_relative '../recorder'

# Refer to lib/capture.rb for full spec.
#
describe :recorder do

  describe :initialize do
    it "takes a config" do
      pending
    end

    it "takes an optional block" do
      pending
    end

    it "returns a valid instance of Recorder" do
      pending
    end
  end

  describe :status do
    it "adds the recording_number" do
      pending
    end
  end

  describe :start do
    context "when the project and booking are the same as the last time" do
    
    end

    context "when the project or booking_id differ from last time" do
    end

    it "increments the recording_number by 1" do
      pending
    end

    it "sets the directory to the correct value" do
      pending
    end

  end
end
