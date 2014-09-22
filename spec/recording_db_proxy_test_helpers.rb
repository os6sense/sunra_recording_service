require 'rest-client'
require 'json'

module Recording_db_proxy_test_helpers
  # Descrption::
  # Helper method to test the connection
  def test_connection
    ::RestClient::Resource.new("#{@resource_url}").get
  end

  def _create_project(client_name, project_name)
    url = "#{@resource_url}/projects.json?auth_token=#{@api_key}"

    return ::RestClient::Resource.new(url).tap do |new_rec|
      result = new_rec.post(
        :project => {:client_name => client_name, :project_name => project_name}
      )
      return JSON.parse(result)["uuid"]
    end
  end

  def _create_booking(uuid, booking_detail)
    url = "#{@resource_url}/projects/#{uuid}/bookings.json?auth_token=#{@api_key}"
    return ::RestClient::Resource.new(url).tap do |new_rec|
      result = new_rec.post(
        :booking => {
          :facility_studio => booking_detail[:studio_id],
          :date => booking_detail[:date],
          :start_time => booking_detail[:start_time],
          :end_time => booking_detail[:end_time]
        }
      )
      return JSON.parse(result)[1]["id"]
    end
  end

  def _delete_project(uuid)
    url = "#{@resource_url}/projects/#{uuid}?auth_token=#{@api_key}"
    ::RestClient::Resource.new(url).delete
  end
end
