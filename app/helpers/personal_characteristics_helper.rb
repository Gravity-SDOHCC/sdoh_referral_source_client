module PersonalCharacteristicsHelper
  include SessionHelper
  include PersonalCharacteristicsDefinitionsHelper

  def fetch_personal_characteristics
    client = get_client
    begin
      search_params = {
        parameters: {
          category: "personal-characteristic",
          subject: patient_id,
          # _maxresults: 5,
          # _count: 5
          _sort: "-date"
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
        Rails.logger.error("Failed to fetch patient's personal characteristics. Status: #{response.response[:code]} - #{response.response[:body]}")

        [false, "Failed to fetch patient's personal characteristics. Status: #{response.response[:code]} - #{response.response[:body]}"]
      end
    rescue Errno::ECONNREFUSED => e
      Rails.logger.error(e.full_message)

      [false, "Connection refused. Please check FHIR server's URL #{get_server_base_url} is up and try again. #{e.message}"]
    # rescue Rack::Timeout::RequestTimeoutException => e
    #   [false, "Request timeout. Please try again later. #{e.message}"]
    end
  end

  # This is used to populate the select options for the personal characteristic form
  def self.options_for_type(type)
    case type
    when 'personal_pronouns'
      PERSONAL_PRONOUNS
    when 'ethnicity'
      ETHNICITY
    when 'race'
      RACE
    when 'sex_gender'
      SEX_GENDER
    when 'sexual_orientation'
      SEXUAL_ORIENTATION
    when 'gender_identity'
      GENDER_IDENTITY
    else
      []
    end
  end

end
