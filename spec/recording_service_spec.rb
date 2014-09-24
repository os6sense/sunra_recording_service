
ENV['RACK_ENV'] = 'test'

require 'capybara'
require 'capybara/dsl'

require_relative '../recording_service'

include Sunra::Recording

describe Service do
  include Capybara::DSL
  # Capybara.default_driver = :selenium # <-- use Selenium driver


  before(:all) do
    config = Sunra::Utils::Config::Global
    Capybara.app = Sunra::Recording::Service.new(config)
    @api_key = 'rRTzQQPqCyazDmNnTxrC'
  end

  describe :home do
    before(:all) do
      visit '/'
    end

    it 'has a header' do
      expect(page.has_content?('Sunra::Recording::Service')).to eq true
    end
  end

  describe :status do
    before(:all) do
      api_key = 'rRTzQQPqCyazDmNnTxrC'
      visit "/status/?api_key=#{@api_key}"
    end
    it { expect(page.has_content?('studio_id')).to be true }
    it { expect(page.has_content?('project_id')).to be true }
    it { expect(page.has_content?('booking_id')).to be true }
    it { expect(page.has_content?('ffserver')).to be true }
    it { expect(page.has_content?('is_recording')).to be true }
    it { expect(page.has_content?('start_time')).to be true }
    it { expect(page.has_content?('end_time')).to be true }
    it { expect(page.has_content?('duration')).to be true }
    it { expect(page.has_content?('recorders')).to be true }
    it { expect(page.has_content?('last_api_error')).to be true }
  end

  describe :start do
    before(:all) do
      visit "/start/?api_key=#{@api_key}"
    end
    it { expect(page.has_content?('No Current Booking Found')).to be true }
    it { expect(page.has_content?('studio_id')).to be true }
  end

  describe :stop do
    before(:all) do
      visit "/stop/?api_key=#{@api_key}"
    end

    it { expect(page.has_content?('Call to stop but recording is stopped')).to be true }
    it { expect(page.has_content?('recording_api.stop')).to be true }
  end
end

