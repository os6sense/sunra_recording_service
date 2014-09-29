require 'json'
require 'sinatra'

require 'sunra_utils/config/recording'

require_relative 'recording_event_handler'
require_relative 'recording_api'
require_relative 'id_provider'

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
        set :logger, Sinatra::Passenger::Logger.new(root, environment)
      end

      set :project_id, 0

      def initialize(global_config)
        super()
        @api = create_api(global_config)
        @api_key = global_config.api_key
      end

      def validate_api_key(key)
        halt 401, { unauthorized: '401' }.to_json if @api_key != key
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
        "{studio_id: #{@api.studio_id}}"
      end

      private

      def create_api(config)
        create_proxy(config).tap do | proxy |
          create_provider(config).tap do | provider |
            create_event_handler(proxy, provider).tap do | handler |
              return Sunra::Recording::API.new(handler, provider)
            end
          end
        end
      end

      # creates an instance
      def _obj(class_name)
        @_service ||= Object
          .const_get('Sunra::Utils::Config::Recording::Service')
        @_service.send(class_name).tap do | cls |
          return Object.const_get("#{cls}")
        end
      end

      def create_proxy(config)
        _obj('proxy_class').new(config.api_key,
                                config.project_rest_api_url)
      end

      def create_event_handler(proxy, provider)
        _obj('event_handler_class').new(proxy, provider)
        #DBRecordingEventHandler.new(proxy, provider)
      end

      def create_provider(config)
        _obj('provider_class').new(studio_id: config.studio_id)
        #IDProvider.new(studio_id: config.studio_id)
      end
    end
  end
end
