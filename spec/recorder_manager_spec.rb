require_relative '../recorder_manager'

describe Sunra::Recording::RecorderManager do
  let(:rm) {Sunra::Recording::RecorderManager.new}

  describe :initialize do
    it "takes an empty array as a parameter" do
      Sunra::Recording::RecorderManager.new([]).should be
        instance_of Sunra::Recording::RecorderManager
    end

    it "takes an array containing Sunra::Recorder object elements" do
      arr = [double("Sunra::Recorder"), double("Sunra::Recorder")]
      Sunra::Recording::RecorderManager.new(arr).should be
        instance_of Sunra::Recording::RecorderManager
    end

    it "can be called with no parameters" do
      Sunra::Recording::RecorderManager.new.should be
        instance_of Sunra::Recording::RecorderManager
    end
  end

  describe :add_recorder do
    it "allows the addition of a single recorder" do
      rm.add_recorder(double("Sunra::Recorder"))
      rm.recorders.size.should eq 1
    end
  end

  describe :add_recorders do
    it "allows the addition of an array of multiple recorders" do
      rm.add_recorders([double("Sunra::Recorder"),
                        double("Sunra::Recorder")])
      rm.recorders.size.should eq 2
    end
  end

  describe :recorders do
    it "returns the array of recorders" do
      rm.recorders.should be_a Array
    end
  end

  describe :duration do
    it "should equal 00:00:00 when first initialised" do
      rm.duration.should eq "00:00:00"
    end
  end

  describe :is_recording? do
    it "should equal false when first initialised" do
      rm.is_recording?.should eq false
    end

    it "should return false if a recorder with pid = -1 is added" do
      rm.add_recorder double("Sunra::Recorder", pid: -1)
      rm.is_recording?.should eq false
    end

    it "should return true if a recorder with pid > -1 is added" do
      rm.add_recorder double("Sunra::Recorder", pid: 9999)
      rm.is_recording?.should eq true
    end

    it "should return false if ANY pids = -1" do
      rm.add_recorders([ double("Sunra::Recorder", pid: 9999),
                         double("Sunra::Recorder", pid: -1)
      ])
      rm.is_recording?.should eq false
    end

    it "should return true if ALL pids > -1" do
      rm.add_recorders([ double("Sunra::Recorder", pid: 9999),
                         double("Sunra::Recorder", pid: 9998)
      ])
      rm.is_recording?.should eq true
    end
  end

  describe :status do
    context "with no recorders" do
      it "should return an empty array" do
        rm.status.should eq []
      end
    end
  end

  describe :start_recorders do
    let(:project_id) {100000}
    let(:booking_id) {9999999}

    context "without any recorders defined" do
      it "raises a recorder error" do
        expect { rm.start_recorders(project_id, booking_id) }.to raise_error(
          Sunra::Recording::RecorderManager::RecorderError
        )
      end
    end

    context "with valid recorders defined" do
      let(:recorders) {[ double("Sunra::Recorder", pid: 1000, start: 1000),
                       double("Sunra::Recorder", pid: 1000, start: 1000)]}

      before(:each) do
        rm.add_recorders(recorders)
      end

      it "returns true if all recorders start" do
        rm.start_recorders(project_id, booking_id).should eq true
        rm.start_time.should_not be nil
      end

      it "sets the end_time to nil" do
        rm.start_recorders(project_id, booking_id)
        rm.end_time.should be nil
      end

      it "raises RecorderError if any one recorder fails to start" do
        rm.add_recorder double("Sunra::Recorder", pid: -1, start: -1)
        expect{ rm.start_recorders(project_id, booking_id)}.to raise_error(Sunra::Recording::RecorderManager::RecorderError)
      end

      it "sets start_time to the value of DateTime.now" do
        DateTime.stub(:now).and_return(DateTime.new(2014,1,1,10,11,12))
        rm.start_recorders(project_id, booking_id)
        rm.start_time.should eq DateTime.new(2014,1,1,10,11,12)
      end

      describe :duration do
        it "reads 00:00:15 15 seconds after start" do
          DateTime.stub(:now).and_return(DateTime.new(2014,1,1,10,11,10))
          rm.start_recorders(project_id, booking_id).should eq true
          DateTime.stub(:now).and_return(DateTime.new(2014,1,1,10,11,25))
          rm.duration.should eq "00:00:15"
        end
        it "reads 00:01:10 1 minute and 10 seconds after start" do
          DateTime.stub(:now).and_return(DateTime.new(2014,1,1,10,11,10))
          rm.start_recorders(project_id, booking_id).should eq true
          DateTime.stub(:now).and_return(DateTime.new(2014,1,1,10,12,20))
          rm.duration.should eq "00:01:10"
        end
        it "reads 01:01:10 1 hour, 1 minute and 10 seconds after start" do
          DateTime.stub(:now).and_return(DateTime.new(2014,1,1,10,11,10))
          rm.start_recorders(project_id, booking_id).should eq true
          DateTime.stub(:now).and_return(DateTime.new(2014,1,1,11,12,20))
          rm.duration.should eq "01:01:10"
        end
      end
    end
  end

  describe :stop_recorders do

  end
end
