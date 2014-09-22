
ENV['RACK_ENV'] = 'test'

require 'capybara'
require 'capybara/dsl'
require 'test/unit'

require_relative '../recording_service'

class RecordingServiceTest < Test::Unit::TestCase
  include Capybara::DSL
  # Capybara.default_driver = :selenium # <-- use Selenium driver

  def setup
    config = Sunra::Config::Global
    Capybara.app = Sunra::Recording::Service.new(config)
  end

  def test_home
    visit '/'
    assert page.has_content?('Sunra::Recording::Service')
  end

  def test_status
    visit '/status'
    assert page.has_content?('studio_id')
    assert page.has_content?('project_id')
    assert page.has_content?('booking_id')
    assert page.has_content?('ffserver')
    assert page.has_content?('is_recording')
    assert page.has_content?('start_time')
    assert page.has_content?('end_time')
    assert page.has_content?('duration')
    assert page.has_content?('recorders')
    assert page.has_content?('last_api_error')
  end

  def test_start
    visit '/stop'
    assert page.has_content?('studio_id')
  end

  def test_start
    visit '/stop'
    assert page.has_content?('Call to stop but recording is stopped')
    assert page.has_content?('recording_api.stop')

  end
end

