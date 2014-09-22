# File:: recorder.rb
require 'active_support/core_ext/module/delegation'
require 'sunra_capture'

module Sunra
  module Recording
    # ==== Description::
    # Capture is intended to deal with capturing from the ffserver and
    # is wrapped here in a class which insulates it from some of the extranious
    # responsibilities it was aquiring.
    class Recorder
      attr_accessor :project_id,
                    :booking_id,
                    :recording_id,
                    :format_id,
                    :recording_number,
                    :_capturer

      # Instance variables
      delegate :start_time,
               :end_time,
               :directory,
               :filename,
               :filesize,
               :base_filename,
               :format,
               :pid,
               :to => :_capturer

      # Methods
      delegate :stop,
               :is_recording?,
               :to => :_capturer

      def initialize(config, &block)
        # We use block.call(self) here deliberately so that we pass
        # along a reference to the *recorder* and not just the *capturer*.
        @_capturer = Sunra::Capture.new(config) { block.call(self) }
        @config = config
        @recording_number = 0
      end

      def status
        s = @_capturer.status
        s[:recording_number] = @recording_number
        return s
      end

      # TODO: find a way to *reliably* test if a feed is working. Note that
      # this does depend on the *source*
      def start(project_id, booking_id, start_time)
        # There are hackish ways to do this but ffserver doesnt respond
        # to "head" nor does the status page relably report on the individual
        # feeds.
        #
        # The *PROPER* way to fix this would be to patch ffserver to
        #  [1] reliably detect if a feed is getting data
        #  [2] include that in the status page
        #  [3] return the status as json

        if project_id != @project_id || booking_id != @booking_id
          @recording_number = 0 # project or booking has changed
        end

        @project_id = project_id
        @booking_id = booking_id

        @recording_number += 1

        set_capture_dir

        # Start is called with start time since this may differ from
        # the when the capture process starts by a few ms
        @_capturer.start(Sunra::Capture.time_as_filename(start_time))
      end

      protected

      # === Description
      # set the @capturers directory for placing recordings into.
      def set_capture_dir
        @_capturer.directory =
          "#{@config.storage_dir}/#{@project_id}/#{@booking_id}"
        @_capturer.directory +=
          "/#{@config.add_dir}" unless @config.add_dir == ""
      end
    end
  end
end
