# File:: recording_api.rb
require 'active_support/core_ext/module/delegation'

require 'sunra_utils/config/global'
require 'sunra_utils/logging'

require_relative 'recorder_factory'
require_relative 'recorder_manager'
require_relative 'recording_status'

module Sunra
  module Recording
    # ==== Description
    # Provides a simple API to the recording system allowing
    # recording to be started or stopped, and the status of any
    # recording process to be monitored. Primary purpose is to simplify
    # the seperate concerns of managing recording and updating the DB.
    class API
      include Sunra::Utils::Logging

      class APIError < StandardError; end

      attr_reader :api_error,
                  :recorder_manager

      delegate :project_id,
               :booking_id,
               :recording_id,
               :studio_id,
               to: :@id_provider

      delegate :add_recorder,
               :add_recorders,
               :is_recording?,
               :duration,
               to: :recorder_manager

      # ==== Description
      # Initialise the API
      #
      # ==== Params
      # +db_api+ :: dbi_api to use to update the databae
      # +studio_id+ :: ID of the studio doing the recording
      # def initialize(db_api, studio_id)
      def initialize(recording_event_handler, id_provider)
        @recording_event_handler = recording_event_handler
        @id_provider = id_provider

        @api_error = { loc: '', msg: '' }

        rf = RecorderFactory.create do | recorder |
          _handle_recorder_stopped(recorder)
        end

        @recorder_manager = RecorderManager.new(rf)
      end

      # ==== Description
      # Start each of the configured recorders if not currently recording
      # otherwise return the current status. Several conditions may prevent
      # recording from starting:
      #
      # 1) If there is a recording process already started
      # 2) If there is no booking/session scheduled - recordings MUST be
      #    attached to a booking.
      # 3) if the ffserver is not currently running calls to start the recorder
      #    will fail.
      # 4) If we fail to record the start in the db.
      #
      # ==== Returns
      # Returns the result of a call to +status+ with the parameters SUCCESS or
      # FAILURE
      def start
        @api_error = { loc: 'recording_api.start', msg: '' }

        safe_call do
          fail(APIError,
               'Call to start while recording in progress!') if is_recording?

          @recording_event_handler.starting
          @recorder_manager.start_recorders(project_id, booking_id)
          @recording_event_handler.started(@recorder_manager.recorders)
        end
        return status
      end

      # ==== Description
      # Call the Capture.stop method on each of the recorders to attempt
      # to stop a session recording and close the recording (e.g. mp3, mp4)
      # files.
      def stop
        @api_error = { loc: 'recording_api.stop', msg: '' }
        safe_call do
          fail(APIError,
               'Call to stop but recording is stopped') unless is_recording?

          @recorder_manager.stop_recorders
        end
        return status
      end

      # ==== Description
      # Helper Method.
      # Wraps a block, rescuing from the most common errors and logging them.
      def safe_call# (&block)
        yield
      rescue Sunra::Utils::Recording::DBProxy::DBProxyError,
             Sunra::Recording::RecorderManager::RecorderError,
             APIError => e
        _error e
      end

      # ==== Description
      # A block which calls this is passed to the recorder (via the factory)
      # in our initialize method. This method is then called IF any single
      # recorder stops.
      def _handle_recorder_stopped(recorder)
        @api_error = { loc: 'recording_api.stop', msg: '' }

        # update the format
        @recording_event_handler.stopping(recorder)

        # if all the individual recorders have been stopped update the db
        if @recorder_manager.recorders.all? { | rec | !rec.is_recording? }
          @recording_event_handler.stopped(@recorder_manager.recorders)
          @recorder_manager.update_endtime
        end
      end

      # ==== Description
      # Return the StatusHash
      def status
        @_sh ||= Sunra::Recording::StatusHash.new(self, @recorder_manager)
      end

      # ==== Description
      # Log an error and return the status hash
      #
      # ==== Params
      # +msg+ log +msg+. if nil the value of +@api_error[:msg] will be logged
      def _error(msg = nil)
        @api_error[:msg] = msg if msg
        logger.warn(@api_error[:loc]) { @api_error[:msg].message  }
      end
    end
  end
end
