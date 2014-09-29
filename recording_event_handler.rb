
module Sunra
  module Recording
    # Base class
    class RecordingEventHandler
      def starting
        fail "Not Implemented"
      end

      def started
        fail "Not Implemented"
      end

      def error
        fail "Not Implemented"
      end

      def stopping
        fail "Not Implemented"
      end

      def stopped
        fail "Not Implemented"
      end
    end

    class NullRecordingEventHandler < RecordingEventHandler
      def initialize(*args); end
      def started; end
      def stopped; end
      def error; end
      def stopping; end
      def stopped; end
    end

    class IDProvider
      attr_accessor :project_id,
                    :booking_id,
                    :recording_id,
                    :studio_id

      def initialize(studio_id: nil, booking_id: nil,
                     recording_id: nil, project_id: nil)
        @studio_id = studio_id
        @booking_id = booking_id
        @project_id = project_id
        @recording_id = recording_id
      end
    end

    class DBRecordingEventHandler < RecordingEventHandler
      def initialize(db_proxy, id_provider)
        @id_provider, @db_proxy = id_provider, db_proxy
      end

      # We use this to set up the booking and project ids
      def starting
        @id_provider.project_id,
        @id_provider.booking_id = @db_proxy.get_current_booking(@studio_id)
      end

      def started(recorders)
        @id_provider.recording_id = @db_proxy
          .start_new_recording(@id_provider.project_id,
                               @id_provider.booking_id,
                               recorders)
      end

      def error
      end

      def stopping(recorder = nil)
        @db_proxy.update_format(recorder) unless recorder.nil?
      end

      def stopped(recorders = nil)
        @db_proxy.stop_recording(@id_provider.project_id,
                                 @id_provider.booking_id,
                                 @id_provide.recording_id,
                                 recorders)
      end
    end
  end
end
