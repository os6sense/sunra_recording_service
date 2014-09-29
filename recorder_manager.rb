# File:: Recorder_manager.rb

require 'sunra_utils/capture'
require 'sunra_utils/logging'

module Sunra
  module Recording

    # ==== Description
    # manages the collection of recorders.
    class Sunra::Recording::RecorderManager

      include Sunra::Utils::Logging

      class RecorderError < StandardError; end

      attr_reader :error,
                  :start_time,
                  :end_time

      def initialize(recorder_factory = nil)
        @_recorders = recorder_factory ? recorder_factory : []
      end

      def add_recorder(recorder)
        @_recorders << recorder
      end

      def recorders
        @_recorders
      end

      def add_recorders(recorders)
        @_recorders += recorders
      end

      def status
        status = []
        @_recorders.each { |r| status << r.status }
        return status
      end

      # ==== Description
      # Return true if ALL of the Capture class recorders have a pid > -1
      def is_recording?
        @_recorders.empty? ? false : @_recorders.each.all? { |r| r.pid > -1 }
      end

      # ==== Description
      # Return the duration of the recording in HH:MM:SS format
      def duration
        return '00:00:00' if @start_time.nil?
        d = DateTime.now.to_time - @start_time.to_time
        d = @end_time.to_time - @start_time.to_time unless @end_time.nil?
        Time.at(d).utc.strftime '%H:%M:%S'
      end

      # +project_id+ and +booking_id+ # are combined to create the directory
      # name into which recordings will be placed
      def start_recorders(project_id, booking_id)
        # Provide a more granular error if recording is attempted without
        # any recorders defined.
        fail(RecorderError, 'No Recorders Provided') if @_recorders.empty?

        @_recorders.each do |r|
          # Start Each Recorder, any single recording failing to start is
          # enough to cause ALL to fail.
          begin
            @start_time = DateTime.now
            r.start(project_id, booking_id, @start_time)
          rescue Exception => msg
            # To be safe and to ensure we dont end up in an unknown state
            # with some recorders starting but being left dangling we force
            # all recorders to stop *if possible* when there is an error.
            @_recorders.each do |rs|
              begin
                rs.stop
              rescue Exception
              end
            end

            @start_time = @end_time = nil
            raise(RecorderError, msg)
          end
        end

        # Final check that recording has indeed been started
        sleep(0.5)

        if is_recording?
          @end_time = nil
          return true
        else
          # recording has not started and it is unclear why,
          @start_time = @end_time = nil
          fail(RecorderError, 'Failed to start recording, reason unknown!')
        end
      end

      def update_endtime
        @end_time = DateTime.now
      end

      # ==== Description
      # Attept to call the stop method on the defined recorders. +end_time+
      # will be set to now as a result if successful.
      def stop_recorders
        fail(RecorderError, 'No Recorders Provided') if @_recorders.empty?

        errors = []

        @_recorders.each do |r|
          begin
            r.stop if r.is_recording?
          rescue => msg
            errors << "Error Stopping #{r.format} recorder: #{msg}"
          end
        end

        update_endtime

        fail RecorderError, errors if errors.size > 0
      end
    end
  end
end
