module ServiceRequestsHelper
  include SessionHelper

  def save_service_requests(service_requests)
    Rails.cache.write(service_requests_key, service_requests, expires_in: 1.hour)
  end

  def get_service_requests
    Rails.cache.read(service_requests_key)
  end

  def fetch_service_requests
    client = get_client
    search_params = {
      parameters: {
        subject: patient_id,
        _sort: "-_lastUpdated"
      }
    }
    service_requests = get_service_requests
    return [true, service_requests] if service_requests.present?

    begin
      response = client.search(FHIR::ServiceRequest, search: search_params)
      if response.response[:code] == 200
        entries = response.resource.entry
        service_requests = entries.map do |entry|
          ServiceRequest.new(entry.resource, fhir_client: client)
        end
        save_service_requests(service_requests)
        [true, service_requests]
      else
        [false, "Failed to fetch patient's service requests. Status: #{response.response[:code]} - #{response.response[:body]}"]
      end
    rescue Errno::ECONNREFUSED => e
      [false, "Connection refused. Please check FHIR server's URL #{get_server_base_url} is up and try again. #{e.message}"]
    rescue StandardError => e
      [false, "Something went wrong. #{e.message}"]
    end
  end
end
