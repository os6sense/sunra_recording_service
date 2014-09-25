require_relative '../recorder'

include Sunra::Recording
# Refer to lib/capture.rb for full spec.
describe :recorder do
  let(:mp3_config) do
    d = double('Sunra::Utils::Config::MP3')
    allow(d).to receive(:extension).and_return('MP3')
    allow(d).to receive(:storage_dir).and_return('/home/testuser')
    d
  end

  describe :initialize do
    before(:each) do
      @recorder = Recorder.new(mp3_config)
    end

    it 'requires a config' do
      expect { Recorder.new }.to raise_error StandardError
    end

    it 'takes an optional block' do
      expect(Recorder.new(mp3_config) { 'terminated' }).to be_kind_of Recorder
    end

    it 'returns a valid instance of Recorder' do
      expect(Recorder.new(mp3_config)).to be_kind_of Recorder
    end

    it { expect(@recorder.recording_number).to eq 0 }
  end

  describe :status do
    before(:each) do
      @recorder = Recorder.new(mp3_config)
    end

    it 'returns a hash' do
      expect(@recorder.status).to be_kind_of Hash
    end

    it 'sets the recording_number in the status hash' do
      expect(@recorder.status[:recording_number]).to eq 0
    end
  end

  describe :start do

    before(:each) do
      @recorder = Recorder.new(mp3_config)
    end

    context 'when the project and booking are the same as the last time' do

    end

    context 'when the project or booking_id differ from last time' do
    end

    it 'increments the recording_number by 1' do
    end

    it 'sets the directory to the correct value' do
    end
  end
end
