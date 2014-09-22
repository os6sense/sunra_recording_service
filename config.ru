require 'rubygems'
require 'rack/cors'
require 'sinatra'
require 'sunra_config/global'

require File.expand_path("../recording_service", __FILE__)

set :environment, ENV['RACK_ENV'].to_sym

configure :production, :staging do
  disable :run, :reload
end

configure :development do
  enable :run
end

use Rack::Cors do |config|
  config.allow do |allow|
    allow.origins '*'
    allow.resource '*',
                   :methods => [:get, :post, :put, :delete],
                   :headers => :any,
                   :max_age => 0
  end
end

run Sunra::Recording::Service.new(Sunra::Config::Global)
