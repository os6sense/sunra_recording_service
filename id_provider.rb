require 'time'

module Sunra
  module Recording
    # Providers are meant to solve the problem of coeercing the recording
    # service for more general duties. The base provider and ID provider
    # are designed for the existing service which revolves around the concepts
    # of ids which are used for the various directory names when creating a
    # recording.
    class Provider
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

    class IDProvider < Provider; end

    # A simple provider that *should* result in a directory structure
    # based on date and time of a recording
    class DateTimeProvider < Provider
      def recording_id=(_val)
      end

      def initialize(*args)
        super
        @recording_id = 0
      end

      def project_id
        return '2014-11-01'
      end

      def booking_id
        ''
      end

      def recording_id
        @recording_id += 1
      end

      def studio_id
        'no_studio'
      end
    end
  end
end
