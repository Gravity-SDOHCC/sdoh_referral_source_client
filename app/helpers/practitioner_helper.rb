module PractitionerHelper
  include SessionHelper

  def save_current_practitioner(practitioner)
    Rails.cache.write(practitioner_key, practitioner, expires_in: 1.day)
  end

  def save_practitioner_id(practitioner_id)
    session[:practitioner_id] = practitioner_id
  end

  def get_current_practitioner
    @current_practitioner = Rails.cache.read(practitioner_key)
  end

  def practitioner_id
    session[:practitioner_id]
  end

  def fetch_practitioner
    practitioner = get_current_practitioner
    if practitioner
      return [true, practitioner]
    end

    client = get_client
    begin
      response = client.read(FHIR::Practitioner, practitioner_id)
      if response.response[:code] == 200
        practitioner = Practitioner.new(response.resource)
        save_current_practitioner(practitioner)
        [true, practitioner]
      else
        [false, "Failed to fetch practitioner. Practitioner may not exist. Status: #{response.response[:code]} - #{response.response[:body]}"]
      end
    rescue Errno::ECONNREFUSED => e
      [false, "Connection refused. Please check FHIR server's URL #{get_server_base_url} is up and try again. #{e.message}"]
      # rescue Rack::Timeout::RequestTimeoutException => e
      #   [false, "Request timeout. Please try again later. #{e.message}"]
    end
  end

  def fetch_and_cache_practitioners
    Rails.cache.fetch(practitioners_key, expires_in: 1.day) do
      response = get_client.read_feed(FHIR::Practitioner)

      if response.is_a?(FHIR::Bundle)
        entries = response.entry.map(&:resource)
        entries.map { |entry| Practitioner.new(entry) }
      else
        raise "Error fetching Practitioners from FHIR server. You need to choose a test provider to continue. Status code: #{response.response[:code]}"
      end
    end
  end

  def fetch_and_cache_practitionerRoleId
    Rails.cache.fetch(practitioner_role_id_key, expires_in: 1.day) do
      response = get_client.search(FHIR::PractitionerRole, search: { parameters: { practitioner: practitioner_id }})

      if response.is_a?(FHIR::Bundle)
        entries = response.entry.map(&:resource)
        entries.first&.id
      end
    end
  end
end
