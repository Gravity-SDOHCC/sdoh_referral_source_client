module PersonalCharacteristicsHelper
  include PersonalCharacteristicsConstants
  include SessionHelper

  def save_personal_characteristics(personal_characteristics)
    session[:personal_characteristics] = compress_object(personal_characteristics)
  end

  def get_personal_characteristics
    decompress_object(session[:personal_characteristics])
  end

  def fetch_personal_characteristics
    personal_characteristics = get_personal_characteristics
    if personal_characteristics
      return [true, personal_characteristics]
    end

    client = get_client
    begin
      search_params = {
        parameters: {
          category: "personal-characteristics",
          subject: patient_id
        }
      }
      response = client.search(FHIR::Observation, search: search_params)
      if response.response[:code] == 200
        entries = response.resource.entry
        personal_characteristics = entries.map do |entry|
          PersonalCharacteristic.new(entry.resource)
        end
        [true, personal_characteristics]
      else
        [false, "Failed to fetch patient's personal characteristics. Status: #{response.response[:code]} - #{response.response[:body]}"]
      end
    rescue Errno::ECONNREFUSED => e
      [false, "Connection refused. Please check FHIR server's URL #{get_server_base_url} is up and try again. #{e.message}"]
    # rescue Rack::Timeout::RequestTimeoutException => e
    #   [false, "Request timeout. Please try again later. #{e.message}"]
    end
  end
end
