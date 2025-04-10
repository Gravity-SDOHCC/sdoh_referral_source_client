module QuestionnaireHelper
  include SessionHelper

  def save_questionnaires(questionnaires)
    Rails.cache.write(questionnaires_key, questionnaires, expires_in: 30.minutes)
  end

  def fetch_questionnaires_bundle
    client = get_client
    search_params = {
      parameters: {
        _sort: "title",
      },
    }

    begin
      response = client.search(FHIR::Questionnaire, search: search_params)
      if response.response[:code] == 200
        save_questionnaires(response.resource)
        [true, response.resource]
      else
        Rails.logger.error("Failed to fetch questionnaires. Status: #{response.response[:code]} - #{response.response[:body]}")

        [false, "Failed to fetch questionnaires. Status: #{response.response[:code]} - #{response.response[:body]}"]
      end

    rescue Errno::ECONNREFUSED => e
      Rails.logger.error(e.full_message)

      [false, "Connection refused. Please check FHIR server's URL #{get_server_base_url} is up and try again. #{e.message}"]
    rescue StandardError => e
      Rails.logger.error(e.full_message)

      [false, "Something went wrong. #{e.message}"]
    end
  end
end