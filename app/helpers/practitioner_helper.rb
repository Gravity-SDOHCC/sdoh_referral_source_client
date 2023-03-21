module PractitionerHelper
  include SessionHelper

  def save_current_practitioner(practitioner)
    session[:practitioner] = compress_object(practitioner)
  end

  def save_practitioner_id(practitioner_id)
    session[:practitioner_id] = practitioner_id
  end

  def get_current_practitioner
    @current_practitioner = decompress_object(session[:practitioner])
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
end
