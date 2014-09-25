require 'json'
require 'sinatra'

require_relative 'recording_api'

require_relative '../../lib/sinatra_passenger'
require_relative '../../lib/recording_db_proxy'

module Sunra
  module Recording
    # ==== Description
    # Provide a webservice (json interface only) allowing for calls to start
    # and stop recordings locally.
    #
    # +start+ will call the recording api # to launch multiple capture clients
    # in mpX formats.
    # +stop+ will stop any recordings.
    # +status+ will provide information about the current state of the service.
    class Service < Sinatra::Base
      helpers Sinatra::Passenger

      configure :production, :staging, :development do
        puts "**********BLAH"
        puts root
        puts "**********IIII"
        set :logger, Sinatra::Passenger::Logger.new(root, environment)
      end

      set :project_id, 0

      def initialize(config)
        super()

        @global_config = config
        @api = Sunra::Recording::API.new(
          Sunra::Recording::DB_PROXY.new(@global_config.api_key,
                                         @global_config.project_rest_api_url),
          @global_config.studio_id
        )
      end

      def validate_api_key(key)
        if @global_config.api_key != key
          halt 401, { unauthorized: '401' }.to_json
        end
      end

      get '/' do
        return { 'name' => 'Sunra::Recording::Service',
                 'description' => 'start - start and return the status
                  stop - stop recording and return the status
                  status - return the status' }.to_json
      end

      get '/start/*' do
        validate_api_key(params[:api_key])
        halt @api.start.to_json
      end

      get '/stop/*' do
        validate_api_key(params[:api_key])
        halt @api.stop.to_json
      end

      get '/status/*' do
        validate_api_key(params[:api_key])
        halt @api.status.to_json
      end

      # Make the studio_id available via a simple json call
      get '/studio_id' do
        "{studio_id: #{@global_config.studio_id}}"
      end
    end
  end
end
