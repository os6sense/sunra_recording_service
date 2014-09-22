require_relative '../recording_api'
require_relative '../recording_db_proxy'
require 'sunra_config'

require 'rspec'

describe Sunra::Recording::API do

  def create_recorder_stub(pid, start, stop, start_exception=nil, stop_exception=nil)
    r = double("Sunra::Capture")

    r.stub(:pid).and_return(pid)

    if start_exception.nil?
      r.stub(:start).and_return(true)
    else
      r.stub(:start).and_raise(start_exception)
    end

    if stop_exception.nil?
      r.stub(:stop).and_return(true)
    else
      r.stub(:stop).and_raise(stop_exception)
    end

    r.stub(:status).and_return({})

    return r
  end

  def create_recorder_stubs pid=-1
    [
      create_recorder_stub(pid, true, true),
      create_recorder_stub(pid, true, true)
    ]
  end

  before :each do
    # Happy path

    @global_config = double("Sunra::Config::Global")
    @global_config.stub(:studio_id).and_return("1")
    @global_config.stub(:studio_name).and_return("test_studio")
    @global_config.stub(:api_key).and_return("1234567890")

    @db_api = double("Sunra::Recording::DB_PROXY")
    @db_api.stub(:start_new_recording).and_return(11111)
    @db_api.stub(:get_current_booking).and_return(9999, 8888)
    @db_api.stub(:stop_recording).and_return(true)

    @api = Sunra::Recording::API.new(@db_api, 1)# @global_config)
  end

  it "provides #is_recording which returns false when no recorders are set" do
    @api.is_recording?.should eq false
  end

  it "provides #is_recording which returns false when not recording" do
    @api.add_recorders( create_recorder_stubs()  )
    @api.is_recording?.should eq false
  end

  #it "#is_recording reports true when all recorders have a valid pid" do
  #  @api.add_recorders( create_recorder_stubs(pid = 1000)  )
  #  @api.is_recording?.should eq true
  #end

  it "provides a method #studio_id which returns the studio_id from the config file" do
    @api.studio_id.should eq 1
  end

  it "returns a duration of 00:00:00 if start_time is nil" do
    @api.duration.should eq "00:00:00"
  end

  describe "#start" do
    def test_hash h
      h[:is_recording].should eq false
      h[:start_time].should eq nil
      h[:end_time].should eq nil
      h[:duration].should eq "00:00:00"
    end

    context "Cannot connect to rest db proxy" do
      it "should return Sunra::Recording::Status with with a connection error" do
        @db_api.stub(:get_current_booking).and_raise(StandardError.new "Connection refused - error 2")
        #puts @api.start#.to_s.should include("Connection refused")
      end
    end

    #context "DBAPI (stub) is available, but recorders not stubbed to start" do
      #it "should return Sunra::Recording::Status with an error" do
        #h = @api.start
        #test_hash(h)
        #h[:last_error].to_s.should include("Failed to start")
      #end
    #end

    #context "DBAPI (stub) is available, recorders stubbed to start" do
      #it "should return Sunra::Recording::Status with an error" do
        #@api.add_recorders( create_recorder_stubs()  )
        #h = @api.start
        #test_hash(h)
        #h[:last_error].to_s.should include("Failed to start")
      #end
    #end

  end
end
