require 'sunra_utils/capture'

module Sunra
  module Recording
    # Description::
    # Creates a hash from a selection of the API and recording_managers
    # fields to provide an overview of the status of recording.
    class StatusHash < Hash
      require 'json'

      def initialize(api, recorder_manager)
        @_api = api
        @_rm = recorder_manager
        _update
      end

      # Description::
      def _update
        self[:studio_id]      = @_api.studio_id
        self[:project_id]     = @_api.project_id
        self[:booking_id]     = @_api.booking_id
        self[:ffserver]       = Sunra::Capture.ffserver?
        self[:is_recording]   = @_rm.is_recording?
        self[:start_time]     = @_rm.start_time
        self[:end_time]       = @_rm.end_time
        self[:duration]       = @_rm.duration
        self[:recorders]      = []
        self[:last_api_error] = @_api.api_error
        self[:recorders]      = @_rm.status
      end

      def [](key)
        _update
        super
      end

      def to_json
        _update
        super
      end
    end
  end
end
