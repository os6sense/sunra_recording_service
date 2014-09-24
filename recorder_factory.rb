require 'sunra_utils/config/global'
require 'sunra_utils/config/recording'

require_relative 'recorder'

module Sunra
  module Recording
    # Creates recorders
    class RecorderFactory
      class << self
        # ==== Description
        # public class method to create a set of recorders.
        #
        # If create is called called without any parameters then the GLOBAL
        # config file will be used to determine which formats to load. This
        # is specified via the recording_formats key i.e.
        # recording_formats: mp4, mp3
        #
        # Alteratively a container which responds to include? can be passed
        # via the types param e.g. ['MP3', 'MP4']
        #
        # ==== Example Usage
        # create()
        #
        # create(['MP3', 'MP4'])
        #
        # === Returns
        # An array of Recorder objects.
        def create(types = nil, &block)
          types = Sunra::Utils::Config::Global.recording_formats if types.nil?

          return create_from_types(types.map(&:upcase), [], &block)
        end

        protected

        def create_from_type(recorders, type, &block)
          recorders << Sunra::Recording::Recorder.new(
            Object.const_get("Sunra::Utils::Config::Recording::#{type}")
              .new(__dir__),
            &block
          )
        end

        # ==== Description
        # Horrible name. Given an array containing a list of
        # types (MP3, MP4, and MPG at the moment) this method will
        # create the approriate recorder.
        #
        # ==== Example Usage:
        #  return create_from_types(types.map(&:upcase), [])
        #
        # ==== Params
        # +types+::  any container which responds to #include? and
        # will test for the presense of one of the concrete recorder
        # types (MP4. MP3, and MPG)
        # +recorders+::  An array containing any existing recorders.
        # New recorders will be added to this array.
        #
        # ==== Returns
        # An array of recorders.
        def create_from_types(types, recorders, &block)
          types.map!(&:upcase)

          types.each do | type |
            if %w(MP3 MP4 MPG HLS).include?(type)
              create_from_type(recorders, type, &block)
            end
          end

          return recorders
        end

      end
    end
  end
end
