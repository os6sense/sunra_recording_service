require_relative '../recording_api'
require 'sunra_config'

require 'rspec'

describe Sunra::Recording::API do

  def create_recorder_stub(pid, start, stop,
                           start_exception = nil,
                           stop_exception = nil)

    r = double('Sunra::Capture')

    allow(r).to receive(:pid).and_return(pid)

    if start_exception.nil?
      allow(r).to receive(:start).and_return(true)
    else
      allow(r).to receive(:start).and_raise(start_exception)
    end

    if stop_exception.nil?
      allow(r).to receive(:stop).and_return(true)
    else
      allow(r).to receive(:stop).and_raise(stop_exception)
    end

    allow(r).to receive(:status).and_return({})

    return r
  end

  def create_recorder_stubs(pid = -1)
    [
      create_recorder_stub(pid, true, true),
      create_recorder_stub(pid, true, true)
    ]
  end

  before :each do
    # Happy path

    @global_config = double('Sunra::Config::Global')
    allow(@global_config).to receive(:studio_id).and_return('1')
    allow(@global_config).to receive(:studio_name).and_return('test_studio')
    allow(@global_config).to receive(:api_key).and_return('1234567890')

    @db_api = double('Sunra::Recording::DB_PROXY')
    allow(@db_api).to receive(:start_new_recording).and_return(11_111)
    allow(@db_api).to receive(:get_current_booking).and_return(9999, 8888)
    allow(@db_api).to receive(:stop_recording).and_return(true)

    @api = Sunra::Recording::API.new(@db_api, 1)# @global_config)
  end

  it 'provides #is_recording which returns false when no recorders are set' do
    expect(@api.is_recording?).to eq false
  end

  it 'provides #is_recording which returns false when not recording' do
    @api.add_recorders( create_recorder_stubs()  )
    expect(@api.is_recording?).to eq false
  end

  #it "#is_recording reports true when all recorders have a valid pid" do
  #  @api.add_recorders( create_recorder_stubs(pid = 1000)  )
  #  @api.is_recording?).to eq true
  #end

  #it 'provides a method #studio_id which returns the studio_id from the config file' do
    #expect(@api.studio_id).to eq 1
  #end

  it 'returns a duration of 00:00:00 if start_time is nil' do
    expect(@api.duration).to eq '00:00:00'
  end

  describe '#start' do
    def test_hash(h)
      expect(h[:is_recording]).to eq false
      expect(h[:start_time]).to eq nil
      expect(h[:end_time]).to eq nil
      expect(h[:duration]).to eq '00:00:00'
    end

    context 'Cannot connect to rest db proxy' do
      it 'should return Sunra::Recording::Status with with a connection error' do
        allow(@db_api).to receive(:get_current_booking).and_raise(StandardError.new 'Connection refused - error 2')
        #puts @api.start#.to_s).to include("Connection refused")
      end
    end

    #context "DBAPI (stub) is available, but recorders not stubbed to start" do
      #it "should return Sunra::Recording::Status with an error" do
        #h = @api.start
        #test_hash(h)
        #h[:last_error].to_s).to include("Failed to start")
      #end
    #end

    #context "DBAPI (stub) is available, recorders stubbed to start" do
      #it "should return Sunra::Recording::Status with an error" do
        #@api.add_recorders( create_recorder_stubs()  )
        #h = @api.start
        #test_hash(h)
        #h[:last_error].to_s).to include("Failed to start")
      #end
    #end

  end
end
