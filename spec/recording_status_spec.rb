require_relative "../recording_status.rb"

require 'rspec'

describe Sunra::Recording::StatusHash do
    before :each do
      #Sunra::Capture = double("Sunra::Capture")
      #Sunra::Capture.stub(:ffserver?).and_return(true)

      api = double("Sunra::Recording::API")
      api.stub(:studio_id).and_return(1)
      api.stub(:project_id).and_return("abcdefghi")
      api.stub(:booking_id).and_return(20)
      api.stub(:api_error).and_return("none")

      rm = double("Sunra::Recording::RecorderManager")
      rm.stub(:is_recording?).and_return(false)
      rm.stub(:start_time).and_return("20:00")
      rm.stub(:end_time).and_return(nil)
      rm.stub(:duration).and_return("00:00:10")
      rm.stub(:status).and_return([])

      @sh = Sunra::Recording::StatusHash.new(api, rm)
    end

    it "has a studio_id key with a value 1" do
      @sh.has_key?(:studio_id).should eq true
      @sh[:studio_id].should eq 1
    end

    it "has a to_json method which returns a json representation" do
      @sh.to_json.should include("studio_id")
      @sh.to_json.should include("abcdefghi")

      @sh.to_json.should include("booking_id")
      @sh.to_json.should include("20")
    end
end
