module Sunra
  module Recording
    # The null handler is there to simply ignore any calls
    class NullRecordingEventHandler
      def initialize(*_args)
      end

      def started
      end

      def stopped
      end

      def error
      end

      def stopping
      end

      def stopped
      end
    end

    # Calls are made via the proxy to manage the updating of informatio
    # on the project manager.
    class DBRecordingEventHandler
      def initialize(db_proxy, id_provider)
        @id_provider, @db_proxy = id_provider, db_proxy
        @auto_upload = Sunra::Utils::Config::Recording::Service.auto_upload
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
        upload = @auto_upload.include?(recorder.format)

        @db_proxy.update_format(recorder, upload) unless recorder.nil?
      end

      def stopped(recorders = nil)
        @db_proxy.stop_recording(@id_provider.project_id,
                                 @id_provider.booking_id,
                                 @id_provider.recording_id,
                                 recorders)
      end
    end
  end
end
