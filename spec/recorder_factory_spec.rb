require_relative '../recorder_factory'

include Sunra::Recording

describe RecorderFactory do
  let(:rf) { RecorderFactory }

  it 'has a class method called create' do
    expect(rf.respond_to?(:create)).to eq true
  end

  it 'accepts a call to create with an empty array' do
    expect(rf.create([])).to eq []
  end

  it 'accepts a call to create with an array of strings' do
    expect(rf.create(%w(dog cat from))).to eq []
  end

  it 'returns an array containing a recorder if mp4 is an element' do
    arr = rf.create(%w(dog cat mp4))
    expect(arr.size).to eq 1
    expect(arr[0].class).to eq Recorder
  end

  it 'returns an array containing a recorder if hls is an element' do
    arr = rf.create(%w(dog cat hls))
    expect(arr.size).to eq 1
    expect(arr[0].class).to eq Recorder
  end

  it 'returns an array containing a capture if mp3 is an element' do
    arr = rf.create(%w(dog cat mp3))
    expect(arr.size).to eq 1
    expect(arr[0].class).to eq Recorder
  end

  it 'returns an array containing a capture if mpg is an element' do
    arr = rf.create(%w(dog mpg mpekjfwe))
    expect(arr.size).to eq 1
    expect(arr[0].class).to eq Recorder
  end

  it "returns an array containing 3 captures if 'mpg', 'mp3', ''mp4' are elements " do
    arr = rf.create(%w(mp3 mpg mp4))
    expect(arr.size).to eq 3
    expect(arr[0].class).to eq Recorder
    expect(arr[1].class).to eq Recorder
    expect(arr[2].class).to eq Recorder
  end
end
