require_relative "../recorder_factory"

describe Sunra::Recording::RecorderFactory do
  before :each do 
    @rf = Sunra::Recording::RecorderFactory
  end

  it "has a class method called create" do
    @rf.respond_to?(:create).should eq true
  end

  it "accepts a call to create with an empty array" do
    @rf.create([]).should eq []
  end

  it "accepts a call to create with an array of strings" do
    @rf.create(["dog", "cat", "from"]).should eq []
  end

  it "returns an array containing a recorder if 'mp4' is an element" do
    arr = @rf.create(["dog", "cat", "mp4"])
    arr.size.should eq 1
    arr[0].class.should eq Sunra::Recording::Recorder
  end

  it "returns an array containing a recorder if 'hls' is an element" do
    arr = @rf.create(["dog", "cat", "hls"])
    arr.size.should eq 1
    arr[0].class.should eq Sunra::Recording::Recorder
  end

  it "returns an array containing a capture if 'mp3' is an element" do
    arr = @rf.create(["dog", "cat", "mp3"])
    arr.size.should eq 1
    arr[0].class.should eq Sunra::Recording::Recorder
  end

  it "returns an array containing a capture if 'mpg' is an element" do
    arr = @rf.create(["dog", "mpg", "mpekjfwe"])
    arr.size.should eq 1
    arr[0].class.should eq Sunra::Recording::Recorder
  end

  it "returns an array containing 3 captures if 'mpg', 'mp3', ''mp4' are elements " do
    arr = @rf.create(["mp3", "mpg", "mp4"])
    arr.size.should eq 3
    arr[0].class.should eq Sunra::Recording::Recorder
    arr[1].class.should eq Sunra::Recording::Recorder
    arr[2].class.should eq Sunra::Recording::Recorder
  end
end
